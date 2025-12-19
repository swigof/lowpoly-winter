extends Control

var _in_settings := false

@onready var sensitivity_label := $VBoxContainer/SettingsVBox/SensHBox/Value
@onready var sensitivity_slider := $VBoxContainer/SettingsVBox/SensHBox/SensSlider
@onready var volume_label := $VBoxContainer/SettingsVBox/VolumeHBox/Value
@onready var volume_slider := $VBoxContainer/SettingsVBox/VolumeHBox/VolumeSlider
@onready var top_container := $VBoxContainer/TopLevelVBox
@onready var settings_container := $VBoxContainer/SettingsVBox
@onready var credits_container := $VBoxContainer/CreditsVBox
@onready var back_button := $VBoxContainer/BackButton

func _ready():
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

func _on_play_button_pressed():
	GameManager.unpause()

func _on_settings_button_pressed():
	_in_settings = true
	top_container.visible = false
	settings_container.visible = true
	back_button.visible = true

func _on_credits_button_pressed():
	top_container.visible = false
	credits_container.visible = true
	back_button.visible = true

func _on_back_button_pressed():
	if _in_settings:
		SettingsManager.save_settings()
		_in_settings = false
	top_container.visible = true
	settings_container.visible = false
	credits_container.visible = false
	back_button.visible = false

func _on_volume_slider_value_changed(value: float):
	SettingsManager.change_volume(value)
	
func _on_sens_slider_value_changed(value: float):
	SettingsManager.change_sensitivity(value)
