class_name AudioText extends Area3D

@export var texts: Array[String]
@export var audios: Array[AudioStream]
@export var delay: float
@export var start_delay: float
@export var medal_id: int
@export_group("Nodes")
@export var label: Label3D
@export var audio_player: AudioStreamPlayer3D
@export var timer: Timer
@export var screen_notifier: VisibleOnScreenNotifier3D

var _index: int = -1
var _player: Player = null

func _process(_d):
	if _player and _index == -1 and timer.is_stopped() and screen_notifier.is_on_screen():
		timer.start(start_delay)

func _on_timer_timeout():
	_index += 1
	var has_text := len(texts) > _index
	var has_audio := len(audios) > _index
	if not has_audio and not has_text:
		_player = null
		_index = -1
		label.text = ""
		_unlock_medal()
		return
	var timer_delay := 0.0
	if has_text:
		label.text = texts[_index]
		timer_delay = len(label.text) * 0.125
	if has_audio:
		audio_player.stream = audios[_index]
		audio_player.play()
		var audio_length = audio_player.stream.get_length()
		if timer_delay < audio_length:
			timer_delay = audio_player.stream.get_length()
	timer_delay += delay
	timer.start(timer_delay)

func _on_body_entered(body: Node3D):
	if body is Player:
		_player = body

func _on_body_exited(body: Node3D):
	if body == _player:
		_player = null

func _on_visible_on_screen_notifier_3d_screen_exited():
	if _index == -1:
		timer.stop()

func _unlock_medal():
	if medal_id != 0:
		NgManager.unlock_medal(medal_id)
