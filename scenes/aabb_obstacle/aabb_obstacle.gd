@tool
extends StaticBody3D

var mesh_instance: MeshInstance3D
var collision_shape: CollisionShape3D
var collision_box: BoxShape3D

@export var mesh: Mesh:
	set(resource):
		mesh = resource
		_update_mesh_instance()

func _ready():
	mesh_instance = $MeshInstance
	collision_shape = $Collision
	collision_box = collision_shape.shape
	_update_mesh_instance()

func _update_mesh_instance():
	if mesh == null or mesh_instance == null or collision_box == null:
		return
	var aabb = mesh.get_aabb()
	mesh_instance.mesh = mesh
	collision_shape.position = aabb.position + aabb.size * 0.5
	collision_box.size = aabb.size
