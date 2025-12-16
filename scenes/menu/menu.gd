extends Control

# TODO Add actual pausing and move to a game/window manager

static var _first_capture := true

func _on_play_button_pressed() -> void:
	visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_first_capture = false

func _on_settings_button_pressed() -> void:
	$VBoxContainer/TopLevelVBox.visible = false
	$VBoxContainer/SettingsVBox.visible = true
	$VBoxContainer/BackButton.visible = true

func _on_credits_button_pressed() -> void:
	$VBoxContainer/TopLevelVBox.visible = false
	$VBoxContainer/CreditsVBox.visible = true
	$VBoxContainer/BackButton.visible = true

func _on_back_button_pressed() -> void:
	$VBoxContainer/TopLevelVBox.visible = true
	$VBoxContainer/SettingsVBox.visible = false
	$VBoxContainer/CreditsVBox.visible = false
	$VBoxContainer/BackButton.visible = false

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0, value)

func _input(event: InputEvent):
	if (Input.mouse_mode != Input.MOUSE_MODE_CAPTURED) and event is InputEventMouseButton:
		if not visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			_first_capture = false

func _process(_delta: float):
	if not visible and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE and not _first_capture:
		visible = true
		get_tree().paused = true
	elif Input.is_action_just_pressed("pause"):
		if not visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			visible = true
			get_tree().paused = true
