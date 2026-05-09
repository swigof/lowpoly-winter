class_name MedalPopup extends SubViewportContainer

@export var _animator: AnimationPlayer
@export var _medal_icon: TextureRect
@export var _medal_label: Label

func _ready():
	_animator.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(_anim_name: StringName):
	queue_free()

func set_medal_details(text: String, points: int, icon: Texture2D):
	_medal_icon.texture = icon
	_medal_label.text = str(points) + "P - " + text
