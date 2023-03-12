extends Node2D

@export var color: Util.COLOR

func shoot():
	print("Shoot ", color)

func block():
	$ShieldGraphic.show()
	$Timer.start()

func _on_timer_timeout():
	$ShieldGraphic.hide()
