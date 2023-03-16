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

func _ready():
	enable_hits()

func _physics_process(delta):
	var direction = $ChordedController.get_motion()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	velocity = direction * SPEED
	$Sprite.rotation = $ChordedController.get_aim_dir() + (PI / 2.0)
	$ChordedController.set_selected_color(self)
	_handle_shooting()
	move_and_slide()

func _handle_shooting():
	if Input.is_action_pressed("block"):
		if spells[selected_color].block():
			selected_color = Util.COLOR.COLORLESS
	if Input.is_action_pressed("shoot"):
		if spells[selected_color].shoot():
			selected_color = Util.COLOR.COLORLESS

func damage(color):
	dead()
	
func dead():
	get_tree().get_root().get_node("World/HUD/Restart").enable()
	var camera = Camera2D.new()
	camera.position = global_position
	get_node("../").add_child(camera)
	camera.make_current()
	queue_free()

# TODO: Make this color-specific?
func enable_hits():
	collision_layer = 2+16 #player + player-detect

func disable_hits():
	collision_layer = 16
