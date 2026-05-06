extends Node3D

@onready var _cube := $Cube
@onready var _particler := $Particler
@onready var _chain := $Chain

var _materials: Array[Material]
var _particles: Array[ParticleProcessMaterial]
var _material_index := 0
var _particle_index := 0
var _materials_done := false
var _particles_done := false

func _ready():
	var dir_files = ResourceLoader.list_directory("res://shaders/materials")
	for file_name in dir_files:
		if file_name.get_extension() == "tres":
			var resource = load("res://shaders/materials/"+file_name)
			if resource is Material:
				_materials.append(resource)
	dir_files = ResourceLoader.list_directory("res://shaders/particles")
	for file_name in dir_files:
		if file_name.get_extension() == "tres":
			var resource = load("res://shaders/particles/"+file_name)
			if resource is ParticleProcessMaterial:
				_particles.append(resource)
	_chain.target = position
	_chain.is_active = true

func _process(delta: float):
	if _material_index < _materials.size():
		_cube.mesh.material = _materials[_material_index]
		_material_index += 1
	else:
		_materials_done = true
	if _particle_index < _particles.size():
		_particler.process_material = _particles[_particle_index]
		_particle_index += 1
	else:
		_particles_done = true
	if _materials_done and _particles_done:
		queue_free()
	_cube.rotate(Vector3.UP, delta)
