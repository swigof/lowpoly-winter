extends Control

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
	GameManager.unpause()

func _on_settings_button_pressed() -> void:
	$VBoxContainer/TopLevelVBox.visible = false
	$VBoxContainer/SettingsVBox.visible = true
	$VBoxContainer/BackButton.visible = true

func _on_credits_button_pressed() -> void:
	$VBoxContainer/TopLevelVBox.visible = false
	$VBoxContainer/CreditsVBox.visible = true
	$VBoxContainer/BackButton.visible = true

func _on_back_button_pressed() -> void:
	if $VBoxContainer/SettingsVBox.visible == true: # TODO clean this up
		SettingsManager.save_settings()
	$VBoxContainer/TopLevelVBox.visible = true
	$VBoxContainer/SettingsVBox.visible = false
	$VBoxContainer/CreditsVBox.visible = false
	$VBoxContainer/BackButton.visible = false

func _on_volume_slider_value_changed(value: float) -> void:
	SettingsManager.change_volume(value)
	
func _on_sens_slider_value_changed(value: float) -> void:
	SettingsManager.change_sensitivity(value)
