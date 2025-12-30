extends CanvasLayer

func _ready():
	GameManager.init_menu(self)
	GameManager.init_world($Dither/Viewport)
