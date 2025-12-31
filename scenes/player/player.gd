class_name Player extends CharacterBody3D

@export var speed: float:
	set(val):
		_standard_speed_squared_cutoff = val * val + 0.1
		speed = val
@export var fall_acceleration: float
@export var jump_impulse: float

const TILT_LOWER_LIMIT := deg_to_rad(-89.0)
const TILT_UPPER_LIMIT := deg_to_rad(89.0)
const VELOCITY_CAP: float = 100
const SQUARED_VELOCITY_CAP: float = VELOCITY_CAP * VELOCITY_CAP
const HOOK_DISTANCE_DEFAULT: float = 100
const CAMERA_FOG_DEFAULT: float = 0.01

var hook_max: float = HOOK_DISTANCE_DEFAULT

var _pivot: Node3D
var _camera: Camera3D
var _chain: Chain
var _crosshair: TextureRect
var _crosshair_default: Texture
var _crosshair_target: Texture
var _pulling: bool
var _hooked_node: Node3D
var _local_pull_position: Vector3
var _velocity_is_from_pull: bool
var _standard_speed_squared_cutoff: float
var _velocity_start_acc: float
var _nudge_velocity: Vector3
var _mouse_rotation: Vector3
var _rotation_input: float
var _tilt_input: float
var _has_hooked_missile: bool

func show_crosshair(value: bool):
	_crosshair.visible = value

func set_camera_fog_density(value: float):
	_camera.environment.fog_density = value

func _ready():
	_pivot = $CameraPivot
	_camera = $CameraPivot/Camera3D
	_crosshair = $CameraPivot/Camera3D/Crosshair
	_chain = $Chain
	_camera.environment.fog_density = CAMERA_FOG_DEFAULT
	_crosshair_default = preload("res://assets/textures/crosshair-default.png")
	_crosshair_target = preload("res://assets/textures/crosshair-target.png")

func _physics_process(delta: float):
	_velocity_start_acc += delta
	velocity -= _nudge_velocity
	_nudge_velocity = Vector3.ZERO
	
	var ray_result = _get_forward_ray_intersect()
	if ray_result.is_empty():
		_crosshair.texture = _crosshair_default
	else:
		_crosshair.texture = _crosshair_target
	
	var input_dir: Vector2
	if not _has_hooked_missile:
		input_dir = _process_input(ray_result)
	
	if not _pulling:
		if input_dir:
			var direction := _pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)
			direction = direction.normalized()
			if not is_on_floor() or velocity.length_squared() > _standard_speed_squared_cutoff:
				var influence: float = 1 - min(_velocity_start_acc, 0.9)
				var nudge_x := direction.x * speed * delta * 60 * influence
				var nudge_z := direction.z * speed * delta * 60 * influence
				_nudge_velocity = Vector3(nudge_x, 0, nudge_z)
				_apply_resistance(delta)
			else:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
				_velocity_is_from_pull = false
		elif velocity:
			if _velocity_is_from_pull:
				_apply_resistance(delta)
			elif is_on_floor():
				velocity.x = 0
				velocity.z = 0
		if not is_on_floor():
			velocity.y -= fall_acceleration * delta
		elif Input.is_action_just_pressed("jump"):
			velocity.y = jump_impulse
			_velocity_start_acc = 0
	else:
		var target := _hooked_node.to_global(_local_pull_position)
		_chain.target = target
		var pull_accel := target - position
		velocity = velocity.slerp(pull_accel, delta)
		velocity += pull_accel * delta
		if input_dir:
			var direction := _pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)
			direction = direction.normalized()
			var nudge_x := direction.x * speed * delta * 10
			var nudge_z := direction.z * speed * delta * 10
			_nudge_velocity = Vector3(nudge_x, 0, nudge_z)
	
	velocity += _nudge_velocity
	_cap_velocity()
	move_and_slide()
	_update_camera(delta)

func _get_forward_ray_intersect() -> Dictionary:
	var from := _camera.global_position
	var to := _camera.global_position + -_camera.global_basis.z * hook_max
	var q := PhysicsRayQueryParameters3D.create(from, to)
	return get_world_3d().direct_space_state.intersect_ray(q)

func _process_input(ray_result: Dictionary) -> Vector2:
	if Input.is_action_just_pressed("fire"):
		if not ray_result.is_empty():
			var global_ray_position = ray_result.position
			_hooked_node = ray_result.collider
			_local_pull_position = _hooked_node.to_local(global_ray_position)
			_chain.target = global_ray_position
			_chain.is_active = true
			_pulling = true
			_velocity_is_from_pull = true
			if _hooked_node is Missile:
				_has_hooked_missile = true
	elif Input.is_action_just_released("fire"):
		_pulling = false
		_chain.is_active = false
		_velocity_start_acc = 0
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

func _apply_resistance(delta: float):
	if is_on_floor():
		# ground friction
		velocity.x -= velocity.x * delta * 5
		velocity.z -= velocity.z * delta * 5
		if velocity.length_squared() < 1:
			velocity.x = 0
			velocity.z = 0
	else:
		# air drag
		velocity.x -= velocity.x * delta
		velocity.z -= velocity.z * delta

func _cap_velocity():
	if velocity.length_squared() > SQUARED_VELOCITY_CAP:
		velocity = velocity.normalized() * VELOCITY_CAP

func _update_camera(delta: float):
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	var pivot_rotation := Vector3(0.0,_mouse_rotation.y,0.0)
	var camera_rotation := Vector3(_mouse_rotation.x,0.0,0.0)
	
	_camera.transform.basis = Basis.from_euler(camera_rotation)
	_camera.rotation.z = 0.0
	
	_pivot.global_transform.basis = Basis.from_euler(pivot_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_rotation_input = -event.relative.x * SettingsManager.look_sensitivity
		_tilt_input = -event.relative.y * SettingsManager.look_sensitivity
