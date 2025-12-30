class_name Chain extends MultiMeshInstance3D

const MESH_SCALE := Vector3.ONE * 0.05
const SPACING := 0.15

@export var hit_sound_player: AudioStreamPlayer3D
@export var shoot_sound_player: AudioStreamPlayer3D

var is_active: bool:
	set(value):
		visible = value
		is_active = value
		_first_frame = value
var target: Vector3

var _first_frame: bool

func _process(_d):
	if not is_active:
		return
	
	if _first_frame:
		hit_sound_player.global_position = target
		hit_sound_player.play()
		shoot_sound_player.play()
		_first_frame = false
	
	var direction := target - global_position
	var length := direction.length()
	var unit_direction := direction / length
	
	var count: int = ceil(length / SPACING)
	multimesh.instance_count = count
	var offset := fmod(length, SPACING * 2)
	for i in range(0, count):
		var distance := offset + SPACING * i
		var pos := unit_direction * distance
		var bas := Basis()
		bas.y = Vector3.UP
		bas.x = unit_direction.cross(bas.y).normalized()
		bas.z = -unit_direction
		if i % 2 == 0:
			bas = bas.rotated(bas.z, deg_to_rad(90))
		bas = bas.scaled(MESH_SCALE)
		var trans := Transform3D(bas, pos)
		multimesh.set_instance_transform(i, trans)
