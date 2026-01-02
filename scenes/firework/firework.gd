class_name Firework extends Node3D

@export var particles: Array[GPUParticles3D]

func _ready():
	for particle in particles:
		particle.restart()

func _on_finished():
	queue_free()
