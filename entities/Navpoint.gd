extends Area2D

func _on_body_entered(body):
	body.on_navpoint_reached(self)
