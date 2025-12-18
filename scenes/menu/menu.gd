extends Control

# TODO Add actual pausing and move to a game/window manager

static var _first_capture := true

var sensitivity_label: Label
var sensitivity_slider: Slider
var volume_label: Label
var volume_slider: Slider

func _ready() -> void:
	sensitivity_label = $VBoxContainer/SettingsVBox/SensHBox/Value
	sensitivity_slider = $VBoxContainer/SettingsVBox/SensHBox/SensSlider
	volume_label = $VBoxContainer/SettingsVBox/VolumeHBox/Value
	volume_slider = $VBoxContainer/SettingsVBox/VolumeHBox/VolumeSlider
	SettingsManager.sensitivity_changed.connect(_update_sensitivity)
	SettingsManager.volume_changed.connect(_update_volume)
	_update_sensitivity()
	_update_volume()

func _update_sensitivity():
	sensitivity_label.text = "%03.1f" % (SettingsManager.look_sensitivity * 10)
	sensitivity_slider.value = SettingsManager.look_sensitivity

func _update_volume():
	volume_label.text = "%03.0f" % (SettingsManager.volume * 100)
	volume_slider.value = SettingsManager.volume

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

func _on_volume_slider_value_changed(value: float) -> void:
	SettingsManager.change_volume(value)
	
func _on_sens_slider_value_changed(value: float) -> void:
	SettingsManager.change_sensitivity(value)

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
