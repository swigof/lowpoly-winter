extends Node3D

@export var area: Area3D
@export var missile: Node3D
@export var missile_speed: float

var _player: Player
var _missile_forward_vector: Vector3
var _missile_is_moving: bool

func _on_area_3d_body_entered(body: Node3D):
	if body is Player:
		_player = body
		_player.hook_max = 300
		_missile_forward_vector = missile.global_basis.y
		missile.position = Vector3(300, 100, 100)
		_missile_is_moving = true

func _on_area_3d_body_exited(body: Node3D):
	if body == _player:
		_player.hook_max = Player.HOOK_DISTANCE_DEFAULT
		missile.position = Vector3(300, 100, 100)
		_missile_is_moving = false

func _process(delta: float):
	missile.position += _missile_forward_vector * missile_speed * delta
