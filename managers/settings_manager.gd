extends Node

var look_sensitivity: float = 0.1
var volume: float = 1.0

signal volume_changed
signal sensitivity_changed

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
