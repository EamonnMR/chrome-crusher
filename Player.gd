extends CharacterBody2D

var selected_color: Util.COLOR = Util.COLOR.COLORLESS

@onready var spells = {
	Util.COLOR.COLORLESS: $Sprite/Weapon,
	Util.COLOR.RED: $Sprite/Spell_R,
	Util.COLOR.GREEN: $Sprite/Spell_G,
	Util.COLOR.BLUE: $Sprite/Spell_B
}

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
	selected_color = $ChordedController.selected_color()
	_handle_shooting()
	move_and_slide()


func _handle_shooting():
	if Input.is_action_pressed("shoot"):
		spells[selected_color].shoot()
	if Input.is_action_pressed("block"):
		spells[selected_color].block()
