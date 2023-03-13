extends Node2D

@export var color: Util.COLOR

var in_melee_area = []

@export_flags_2d_physics var mask: int

func _ready():
	$MeleeArea.collision_mask = mask

func shoot():
	for body in in_melee_area:
		if body.has_method("damage"):
			body.damage()

func block():
	pass
	# Melee weapon can't block

func _on_melee_area_body_entered(body):
	in_melee_area.append(body)


func _on_melee_area_body_exited(body):
	in_melee_area.erase(body)
