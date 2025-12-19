extends CharacterBody3D

@export var speed: int
@export var fall_acceleration: int
@export var jump_impulse: int

const TILT_LOWER_LIMIT := deg_to_rad(-90.0)
const TILT_UPPER_LIMIT := deg_to_rad(90.0)

var _line: MeshInstance3D
var _camera: Camera3D
var _pulling: bool
var _pull_position: Vector3

var _mouse_rotation: Vector3
var _rotation_input: float
var _tilt_input: float

func _ready():
	_line = MeshInstance3D.new()
	_line.top_level = true
	add_child(_line)
	_camera = $Camera3D

func _physics_process(delta: float):
	if Input.is_action_just_pressed("fire"):
		var from := _camera.global_position
		var to := _camera.global_position + -_camera.global_basis.z * 100
		var q := PhysicsRayQueryParameters3D.create(from, to)
		var result := get_world_3d().direct_space_state.intersect_ray(q)
		if not result.is_empty():
			_pull_position = result.position
			_pulling = true
			_line.visible = true
			velocity.x = 0
			velocity.z = 0
	elif Input.is_action_just_released("fire"):
		_pulling = false
		_line.visible = false
	
	if not _pulling:
		var input_dir: Vector2
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
		
		if not is_on_floor():
			velocity.y = velocity.y - (fall_acceleration * delta)
		elif Input.is_action_just_pressed("jump"):
			velocity.y = jump_impulse
	
	else:
		var mesh := ImmediateMesh.new()
		mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		mesh.surface_add_vertex(_camera.global_position + Vector3(0,-0.1,0))
		mesh.surface_add_vertex(_pull_position)
		mesh.surface_end()
		_line.mesh = mesh
		var pull_accel := _pull_position - position
		velocity += pull_accel * delta
	
	move_and_slide()
	_update_camera(delta)

func _update_camera(delta: float):
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	var player_rotation := Vector3(0.0,_mouse_rotation.y,0.0)
	var camera_rotation := Vector3(_mouse_rotation.x,0.0,0.0)
	
	_camera.transform.basis = Basis.from_euler(camera_rotation)
	_camera.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(player_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_rotation_input = -event.relative.x * SettingsManager.look_sensitivity
		_tilt_input = -event.relative.y * SettingsManager.look_sensitivity
