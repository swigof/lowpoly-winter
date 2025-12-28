extends CharacterBody3D

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

var _line: MeshInstance3D
var _pivot: Node3D
var _camera: Camera3D
var _pulling: bool
var _pull_position: Vector3
var _velocity_is_from_pull: bool
var _standard_speed_squared_cutoff: float
var _velocity_start_acc: float
var _nudge_velocity: Vector3
var _mouse_rotation: Vector3
var _rotation_input: float
var _tilt_input: float

func _ready():
	_line = MeshInstance3D.new()
	_line.top_level = true
	add_child(_line)
	_pivot = $CameraPivot
	_camera = $CameraPivot/Camera3D

func _physics_process(delta: float):
	_velocity_start_acc += delta
	velocity -= _nudge_velocity
	_nudge_velocity = Vector3.ZERO
	
	if Input.is_action_just_pressed("fire"):
		var from := _camera.global_position
		var to := _camera.global_position + -_camera.global_basis.z * 100
		var q := PhysicsRayQueryParameters3D.create(from, to)
		var result := get_world_3d().direct_space_state.intersect_ray(q)
		if not result.is_empty():
			_pull_position = result.position
			_pulling = true
			_line.visible = true
			_velocity_is_from_pull = true
	elif Input.is_action_just_released("fire"):
		_pulling = false
		_line.visible = false
		_velocity_start_acc = 0
	
	if not _pulling:
		var input_dir: Vector2
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		if input_dir:
			var direction := _pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)
			direction = direction.normalized()
			if not is_on_floor() or velocity.length_squared() > _standard_speed_squared_cutoff:
				var influence: float = 1 - min(_velocity_start_acc, 1)
				var nudge_x := direction.x * speed * influence
				var nudge_z := direction.z * speed * influence
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
		var mesh := ImmediateMesh.new()
		mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		mesh.surface_add_vertex(_camera.global_position + Vector3(0,-0.1,0))
		mesh.surface_add_vertex(_pull_position)
		mesh.surface_end()
		_line.mesh = mesh
		var pull_accel := _pull_position - position
		velocity = velocity.slerp(pull_accel, delta)
		velocity += pull_accel * delta
	
	velocity += _nudge_velocity
	_cap_velocity()
	move_and_slide()
	_update_camera(delta)

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
