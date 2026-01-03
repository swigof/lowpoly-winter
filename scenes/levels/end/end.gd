extends Node3D

@export var missile_speed: float
@export var missile_start_position: Vector3
@export_group("Nodes")
@export var area_shape: CollisionShape3D
@export var missile: Node3D
@export var cutscene_marker: Marker3D
@export var camera_target: Marker3D
@export var cutscene_timer: Timer
@export var firework_timer: Timer
@export var cutscene_music: AudioStreamPlayer3D
@export var end_label: Label3D
@export var text_animation: AnimationPlayer
@export var audio_text: AudioText

var _player: Player
var _missile_forward_vector: Vector3
var _missile_is_moving: bool
var _area_box: BoxShape3D
var _firework_scene: PackedScene = preload("res://scenes/firework/firework.tscn")

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
	if _missile_is_moving:
		missile.position += _missile_forward_vector * missile_speed * delta
	var scene_depth := area_shape.to_local(_player.global_position).x
	var depth_factor := inverse_lerp(-_area_box.size.x / 2, -_area_box.size.x / 4, scene_depth)
	depth_factor = clampf(depth_factor, 0, 1)
	_player.set_camera_fog_density(lerp(Player.CAMERA_FOG_DEFAULT, 0.003, depth_factor))
	var missile_distance_sq := (_player.global_position - missile.global_position).length_squared()
	if missile_distance_sq < 1000.0:
		_start_cutscene()

func _start_cutscene():
	_missile_is_moving = false
	missile.visible = false
	_player.stop_pull()
	_player.velocity = Vector3.ZERO
	_player.show_crosshair(false)
	_player.set_camera_exposure(0)
	_player.global_position = cutscene_marker.global_position
	_player.camera_look_at(camera_target.global_position)
	remove_child(audio_text)
	audio_text.queue_free()
	cutscene_timer.start(1)

func _on_cutscene_timer_timeout():
	_player.set_camera_exposure(1)
	var firework: Firework = _firework_scene.instantiate()
	firework.position = missile.position
	add_child(firework)
	cutscene_music.play()
	firework_timer.start()
	var minutes := int(GameManager.stopwatch / 60)
	var seconds := int(GameManager.stopwatch - minutes * 60)
	end_label.text = "Freed from the chain in\n%02d:%02d" % [minutes, seconds]
	text_animation.play("text_fade")

func _on_firework_timer_timeout():
	var firework: Firework = _firework_scene.instantiate()
	firework.position.x = randf_range(200, 300)
	firework.position.y = randf_range(50, 100)
	firework.position.z = randf_range(-75, 150)
	add_child(firework)
	firework_timer.start(randf_range(0.5, 2))
