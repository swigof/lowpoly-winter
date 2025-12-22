extends Node

var _first_capture := true
var _menu: Control

func init_menu(parent: Node):
	_menu = preload("res://scenes/menu/menu.tscn").instantiate()
	_menu.visible = false
	_menu.z_index = 1
	parent.add_child(_menu)

func _input(event: InputEvent):
	if not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and not get_tree().paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_first_capture = false

func _process(_delta: float):
	if get_tree().paused:
		return
	var mouse_visible := Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE
	if (mouse_visible and not _first_capture) or Input.is_action_just_pressed("pause"):
		pause()

func pause():
	_menu.visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func unpause():
	_menu.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_first_capture = false
