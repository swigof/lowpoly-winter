extends Node

var _medal_scene: PackedScene = preload("res://scenes/medal_popup/medal_popup.tscn")
var _parent: Node

func _ready():
	NG.on_session_change.connect(_on_session_change)
	NG.ready.connect(_on_ng_ready)

func init(parent: Node):
	_parent = parent
	NG.on_medal_unlocked.connect(_popup_medal)

func unlock_medal(medal_id: int):
	var medal = NG.get_medal_resource(medal_id)
	if medal != null and medal.unlocked:
		return
	NG.medal_unlock(medal_id)

func _on_ng_ready():
	# Hack to avoid incomprehensible 999 error on auto-init sign in
	var ng_init_timer: Timer = Timer.new()
	ng_init_timer.one_shot = true
	ng_init_timer.timeout.connect(NG.init)
	add_child(ng_init_timer)
	ng_init_timer.start(1)

func _on_session_change(_session: NewgroundsSession):
	NG.medal_get_list()

func _popup_medal(medal_id: int):
	var medal_resource: MedalResource = NG.get_medal_resource(medal_id)
	if medal_resource == null:
		return
	var medal_popup: MedalPopup = _medal_scene.instantiate()
	medal_popup.set_medal_details(
		medal_resource.name,
		medal_resource.get_medal_value(),
		medal_resource.icon
	)
	_parent.add_child(medal_popup)
