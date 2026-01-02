class_name Firework extends GPUParticles3D

func _ready():
	restart()

func _on_finished():
	queue_free()
