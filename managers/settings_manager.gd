extends Node

var look_sensitivity: float = 0.1
var volume: float = 1.0

signal volume_changed
signal sensitivity_changed

func _ready():
	load_settings()

func load_settings():
	var save_file = FileAccess.open("user://save", FileAccess.READ)
	if save_file == null or save_file.get_length() < 16:
		print("loading failed - no file found or invalid contents")
		return
	change_volume(save_file.get_double())
	change_sensitivity(save_file.get_double())

func save_settings():
	var save_file = FileAccess.open("user://save", FileAccess.WRITE)
	if not save_file.store_double(volume):
		print("saving failed - volume: ", volume)
		return
	if not save_file.store_double(look_sensitivity):
		print("saving failed - look_sensitivity: ", look_sensitivity)
		return

func change_volume(value: float):
	volume = value
	AudioServer.set_bus_volume_linear(0, volume)
	if volume <= 0:
		AudioServer.set_bus_mute(0, true)
	else:
		AudioServer.set_bus_mute(0, false)
	volume_changed.emit()

func change_sensitivity(value: float):
	look_sensitivity = value
	sensitivity_changed.emit()
