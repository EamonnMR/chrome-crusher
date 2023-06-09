extends CharacterBody2D

const RUSH_SPEED = 280.0
const CASUAL_SPEED = 150.0
const JUMP_VELOCITY = -400.0

var players_in_detect_radius = []

var target: CharacterBody2D = null

var next_patrol_node = null

@export var melee: bool = true

@export var spot_delay: float = 0.5
@export var attack_delay: float = 0.2

enum STATE {
	PATROL,
	IDLE,
	SPOT_DELAY,
	SHOOTING,
	RUSHING,
	SHOOT_DELAY,
	ATTACK_DELAY,
	ATTACKING,
	SEARCHING
}

@export var state: STATE = STATE.PATROL

@export var patrol_path_paths: Array[NodePath]

@onready var patrol_path = patrol_path_paths.map(self.get_node)

func _ready():
	$SpotDelayTimer.wait_time = spot_delay
	$AttackDelayTimer.wait_time = attack_delay
	match state:
		STATE.PATROL:
			change_state_patrol()

func _physics_process(delta):
	match state:
		STATE.PATROL:
			_check_visible_player()
			_chase(delta, next_patrol_node, CASUAL_SPEED)
		STATE.IDLE:
			_check_visible_player()
		STATE.RUSHING:
			_maintain_contact()
			_chase(delta, target, RUSH_SPEED)
			if not melee:
				$Weapon.shoot()
		STATE.SHOOT_DELAY:
			#_maintain_contact()
			_face(delta, target)
		STATE.SHOOTING:
			_maintain_contact()
			_face(delta, target)
			$Weapon.shoot()
		STATE.ATTACK_DELAY:
			_face(delta, target)
			velocity = Vector2(0,0)
		STATE.ATTACKING:
			_face(delta, target)
			velocity = Vector2(0,0)
			$Weapon.shoot()
		STATE.SEARCHING:
			_chase(delta, $LastSeenGhost, RUSH_SPEED)
	$Label.text = str(STATE.keys()[state])
	$Label.rotation = - rotation
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
		
func _chase(delta, to, speed) -> void:
	if is_instance_valid(to):
		_face(delta, to)
		velocity = Vector2(speed, 0).rotated(rotation - PI/2)
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
	if melee:
		_change_state_rush()
	else:
		_change_state_shoot_delay()

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

func _change_state_shoot():
	state = STATE.SHOOTING

func _change_state_shoot_delay():
	state = STATE.SHOOT_DELAY
	$AttackDelayTimer.start()

func _maintain_contact():
	pass

func _on_attack_delay_timer_timeout():
	match state:
		STATE.ATTACK_DELAY:
			_change_state_attacking()
		STATE.SHOOT_DELAY:
			_change_state_shoot()
