extends StaticBody3D

func _ready():
	var mesh = $MeshInstance3D.mesh as BoxMesh
	var material = mesh.material as ShaderMaterial
	material.set_shader_parameter("uv_scale", Vector2(scale.x, scale.x))
