extends Area2D

@export var color: Util.COLOR



func _on_object_entered(object):
	if object.has_method("damage"):
		object.damage(color)
