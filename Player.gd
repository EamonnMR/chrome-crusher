extends CharacterBody2D


const SPEED = 300.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	var direction = $ChordedController.get_motion()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	velocity = direction * SPEED
	$Sprite.rotation = $ChordedController.get_aim_dir() + (PI / 2.0)
	$ChordedController.get
	move_and_slide()
