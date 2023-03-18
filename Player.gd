extends CharacterBody2D

var selected_color: Util.COLOR = Util.COLOR.COLORLESS

var active_shield = null

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
	for spell in spells.values():
		spell.get_node("Sprite2D").hide()
	switch_spell(selected_color)

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
	if Input.is_action_just_pressed("block"):
		if active_shield == null and spells[selected_color].block():
			switch_spell(Util.COLOR.COLORLESS)
	if Input.is_action_just_pressed("shoot"):
		if spells[selected_color].shoot():
			switch_spell(Util.COLOR.COLORLESS)

func damage(color):
	if active_shield != null:
		if active_shield.damage(color):
			dead()
	else:
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

func switch_spell(new_color: Util.COLOR):
	spells[selected_color].get_node("Sprite2D").hide()
	selected_color = new_color
	spells[selected_color].get_node("Sprite2D").show()
