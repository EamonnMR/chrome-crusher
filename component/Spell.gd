extends Node2D

@export var color: Util.COLOR
@export var projectile_scene: PackedScene
@export var projectile_velocity: float = 10
@export var spread: float
@export var damage: float
@export_flags_2d_physics var projectile_mask: int

var cooldown = false
@onready var parent = get_node("../../")

func shoot():
	if not cooldown:
		_start_cooldown()
		_create_projectile()
		#_effects()

func block():
	# TODO: Block projectiles
	$ShieldGraphic.show()
	$Timer.start()

func _on_timer_timeout():
	$ShieldGraphic.hide()

func _start_cooldown():
	cooldown = true
	$Cooldown.start()

func _on_cooldown_timeout():
	cooldown = false

func _create_projectile():
	var projectile = projectile_scene.instantiate()
	projectile.color = color
	projectile.global_transform = global_transform
	projectile.damage = damage
	projectile.initial_velocity = projectile_velocity
	#projectile.velocity = parent.velocity
	var proj_area: Area2D = projectile.get_node("Area2D")
	proj_area.collision_mask = projectile_mask
	projectile.rotate(randf_range(-spread/2, spread/2))

	parent.get_node("../").add_child(projectile)
