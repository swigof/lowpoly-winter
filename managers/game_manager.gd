extends Node

var _first_capture := true
var _menu: Control
var _level: Node3D
var _player: Player

func init_menu(parent: Node):
	_menu = preload("res://scenes/menu/menu.tscn").instantiate()
	_menu.visible = false
	_menu.z_index = 1
	parent.add_child(_menu)
	
func init_world(parent: Node):
	_level = preload("res://scenes/levels/world.tscn").instantiate()
	_player = preload("res://scenes/player/player.tscn").instantiate()
	_player.position.y = 10
	_level.add_child(_player)
	parent.add_child(_level)

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
	_player.show_crosshair(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func unpause():
	_menu.visible = false
	get_tree().paused = false
	_player.show_crosshair(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_first_capture = false
