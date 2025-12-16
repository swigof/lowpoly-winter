extends Control

# TODO Add actual pausing and move to a game/window manager

static var _first_capture := true

func _on_play_button_pressed() -> void:
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent):
	if (Input.mouse_mode != Input.MOUSE_MODE_CAPTURED) and event is InputEventMouseButton:
		if not visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			_first_capture = false

func _process(_delta: float):
	if not visible and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE and not _first_capture:
		visible = true
	elif Input.is_action_just_pressed("pause"):
		if not visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			visible = true
