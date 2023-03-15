extends CharacterBody2D

const SPEED = 280.0
const JUMP_VELOCITY = -400.0

var players_in_detect_radius = []

var target: CharacterBody2D = null

enum STATE {
	#PATROL,
	IDLE,
	#MOVING_TO_LAST_KNOWN_POSITION,
	#SPOT_DELAY,
	#SHOOTING,
	RUSHING,
	#ATTACK_DELAY,
	#ATTACKING
}

var state: STATE = STATE.IDLE

func _physics_process(delta):
	match state:
		STATE.IDLE:
			_check_visible_player()
		STATE.RUSHING:
			_process_rushing(delta)
	move_and_slide()
	
func _check_visible_player() -> void:
	for possible_target in players_in_detect_radius:
		if _has_los(possible_target):
			_change_state_rush(possible_target)

func _has_los(los_target) -> bool:
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(
		PhysicsRayQueryParameters2D.create(
		global_position,
		los_target.global_position,
		17, [self])
	)
	if result.has("collider"):
		if result.collider == los_target:
			return true
		else:
			return false
	else:
		return false

func _process_rushing(delta) -> void:
	if is_instance_valid(target):
		rotation = global_position.angle_to_point(target.global_position) + PI/2
		velocity = Vector2(SPEED,0).rotated(rotation - PI/2)
	else:
		_change_state_idle()

func _change_state_idle() -> void:
	target = null
	state = STATE.IDLE

func _change_state_rush(new_target) -> void:
	target = new_target
	state = STATE.RUSHING

func damage(color):
	queue_free()

func _on_detect_area_body_entered(body):
	if body in get_tree().get_nodes_in_group("players"):
		players_in_detect_radius.append(body)


func _on_detect_area_body_exited(body):
	if body in get_tree().get_nodes_in_group("players"):
		players_in_detect_radius.erase(body)

func _on_melee_weapon_object_in_threat_range(object):
	if object == target:
		$MeleeWeapon.shoot()
