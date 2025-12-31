extends Node3D

@export var area_shape: CollisionShape3D
@export var missile: Node3D
@export var missile_speed: float
@export var missile_start_position: Vector3

var _player: Player
var _missile_forward_vector: Vector3
var _missile_is_moving: bool
var _area_box: BoxShape3D

func _ready():
	_area_box = area_shape.shape

func _on_area_3d_body_entered(body: Node3D):
	if body is Player:
		_player = body
		_player.hook_max = 300
		_missile_forward_vector = missile.global_basis.y
		missile.position = missile_start_position
		_missile_is_moving = true

func _on_area_3d_body_exited(body: Node3D):
	if body == _player:
		_player.hook_max = Player.HOOK_DISTANCE_DEFAULT
		missile.position = missile_start_position
		_missile_is_moving = false
		_player = null

func _process(delta: float):
	if not _player:
		return
	missile.position += _missile_forward_vector * missile_speed * delta
	var scene_depth := area_shape.to_local(_player.global_position).x
	var depth_factor := inverse_lerp(-_area_box.size.x / 2, -_area_box.size.x / 4, scene_depth)
	depth_factor = clampf(depth_factor, 0, 1)
	_player.set_camera_fog_density(lerp(Player.CAMERA_FOG_DEFAULT, 0.003, depth_factor))
