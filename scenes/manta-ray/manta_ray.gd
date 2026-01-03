extends Node3D

@onready var animation := $AnimationPlayer

func _ready():
	animation.play("Armature|Swim")

func _on_animation_player_animation_finished(anim_name: StringName):
	animation.play(anim_name)
