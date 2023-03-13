extends CharacterBody2D

@export var color: Util.COLOR = Util.COLOR.COLORLESS
var damage: int
var initial_velocity = 10

func _ready():
	velocity += Vector2(1000, 0).rotated(rotation - PI/2)
	#velocity = Vector2(10,0)
	
func _physics_process(_delta):
	move_and_slide()


func _on_area_2d_body_entered(body):
	if body.has_method("damage"):
		body.damage()
	queue_free()

func _on_Timer_timeout():
	queue_free()
