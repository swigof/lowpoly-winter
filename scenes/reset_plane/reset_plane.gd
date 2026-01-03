class_name ResetPlane extends Area3D

func _on_body_entered(body: Node3D):
	if body is Player:
		GameManager.reset_player()
