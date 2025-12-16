extends CharacterBody3D

@export var speed: int
@export var fall_acceleration: int
@export var jump_impulse: int
@export var look_sensitivity: float

const TILT_LOWER_LIMIT := deg_to_rad(-90.0)
const TILT_UPPER_LIMIT := deg_to_rad(90.0)

var _mouse_rotation: Vector3
var _rotation_input: float
var _tilt_input: float

func _physics_process(delta: float):
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
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
	
	move_and_slide()
	_update_camera(delta)

func _update_camera(delta: float):
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	var player_rotation := Vector3(0.0,_mouse_rotation.y,0.0)
	var camera_rotation := Vector3(_mouse_rotation.x,0.0,0.0)
	
	$Camera3D.transform.basis = Basis.from_euler(camera_rotation)
	$Camera3D.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(player_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_rotation_input = -event.relative.x * look_sensitivity
		_tilt_input = -event.relative.y * look_sensitivity
