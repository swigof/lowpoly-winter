extends Node3D

@onready var _cube := $Cube

var _materials: Array[Material]
var _material_index := 0

func _ready():
	var dir = DirAccess.open("res://shaders/materials")
	dir.list_dir_begin()
	for file_name in dir.get_files():
		if file_name.get_extension() == "tres":
			var resource = load("res://shaders/materials/"+file_name)
			if resource is Material:
				_materials.append(resource)

func _process(delta: float):
	if _material_index < _materials.size():
		_cube.mesh.material = _materials[_material_index]
	else:
		queue_free()
	_material_index += 1
	_cube.rotate(Vector3.UP, delta)
