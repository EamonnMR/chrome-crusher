extends CharacterBody2D

const SPEED = 280.0
const JUMP_VELOCITY = -400.0

var players_in_detect_radius = []

var target: CharacterBody2D = null

var next_patrol_node = null

enum STATE {
	PATROL,
	IDLE,
	#MOVING_TO_LAST_KNOWN_POSITION,
	SPOT_DELAY,
	#SHOOTING,
	RUSHING,
	ATTACK_DELAY,
	ATTACKING
}

@export var state: STATE = STATE.PATROL

@export var patrol_path_paths: Array[NodePath]

@onready var patrol_path = patrol_path_paths.map(self.get_node)

func _ready():
	match state:
		STATE.PATROL:
			change_state_patrol()

func _physics_process(delta):
	match state:
		STATE.PATROL:
			_check_visible_player()
			_chase(delta, next_patrol_node)
		STATE.IDLE:
			_check_visible_player()
		STATE.RUSHING:
			_chase(delta, target)
		STATE.ATTACK_DELAY:
			_face(delta, target)
			velocity = Vector2(0,0)
		STATE.ATTACKING:
			_face(delta, target)
			velocity = Vector2(0,0)
			$MeleeWeapon.shoot()
	$Label.text = str(state)
	move_and_slide()
	
func _check_visible_player() -> void:
	for possible_target in players_in_detect_radius:
		if _has_los(possible_target):
			if "parent" in possible_target:
				target = possible_target.parent
			else:
				target = possible_target
			_change_state_spot_delay()

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

func _face(delta, at) -> void:
	if is_instance_valid(at):
		rotation = global_position.angle_to_point(at.global_position) + PI/2
		
func _chase(delta, to) -> void:
	if is_instance_valid(to):
		_face(delta, to)
		velocity = Vector2(SPEED,0).rotated(rotation - PI/2)
	else:
		change_state_patrol()

func _change_state_idle() -> void:
	target = null
	state = STATE.IDLE

func _change_state_rush() -> void:
	state = STATE.RUSHING

func damage(color):
	queue_free()

func _on_detect_area_body_entered(body):
	if body in get_tree().get_nodes_in_group("players"):
		players_in_detect_radius.append(body)


func _on_detect_area_body_exited(body):
	if body in get_tree().get_nodes_in_group("players"):
		players_in_detect_radius.erase(body)

func _change_state_attack_delay():
	state = STATE.ATTACK_DELAY
	$AttackDelayTimer.start()
	
func _change_state_spot_delay():
	state = STATE.SPOT_DELAY
	$SpotDelayTimer.start()

func _change_state_attacking():
	state = STATE.ATTACKING
	$AttackRepositionTimer.start()


func _on_attack_reposition_timer_timeout():
	match state:
		STATE.ATTACKING:
			_change_state_rush()

func _on_attack_area_body_entered(body):
	if body_is_target(body):
		match state:
			STATE.RUSHING:
				_change_state_attack_delay()

func  _on_attack_area_body_exited(body):
	if body_is_target(body):
		match state:
			STATE.ATTACK_DELAY:
				_change_state_rush()
			STATE.ATTACKING:
				_change_state_rush()

func body_is_target(body):
	if body == target:
		return true
	if not is_instance_valid(target):
		return false
	if "parent" in body and body.parent == target:
		return true

func _on_spot_delay_timer_timeout():
	_change_state_rush()

func on_navpoint_reached(navpoint):
	var index = patrol_path.find(navpoint)
	if index >= 0:
		next_patrol_node = patrol_path[(index + 1) % patrol_path.size()]

func change_state_patrol():
	if not patrol_path.size() > 0:
		state = STATE.IDLE
	else:
		state = STATE.PATROL
		next_patrol_node = patrol_path[0]
