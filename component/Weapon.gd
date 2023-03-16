extends Node2D

@export var color: Util.COLOR = Util.COLOR.COLORLESS

var in_melee_area = []

@export_flags_2d_physics var mask: int
@export var belated: bool

signal object_in_threat_range(object)

signal object_exited_threat_range(object)

var cooldown:bool = false


func _ready():
	$MeleeArea.collision_mask = mask

func shoot():
	if not cooldown:
		_start_cooldown()
		$AnimationPlayer.play("swing")
		if not belated:
			_do_damage()
		return true

func block():
	return false

func _on_melee_area_body_entered(body):
	in_melee_area.append(body)
	object_in_threat_range.emit(body)


func _on_melee_area_body_exited(body):
	in_melee_area.erase(body)
	object_exited_threat_range.emit(body)

func _start_cooldown():
	cooldown = true
	$Cooldown.start()

func _on_cooldown_timeout():
	cooldown = false
	
func do_belated_damage():
	if belated:
		_do_damage()
		
func _do_damage():
	for body in in_melee_area:
		if body.has_method("damage"):
			body.damage(color)
