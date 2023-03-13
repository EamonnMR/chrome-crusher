extends Node2D

func get_aim_dir() -> float:
	var mouse = get_global_mouse_position()
	# $Cursor.global_position = mouse;
	# var aim = get_angle_to(mouse)
	var aim_vector = (mouse - global_position).normalized()
	return aim_vector.angle()

# Facings to radians
const E = PI * 0
const SE = PI * .25
const S = PI * .5
const SW = PI * .75
const W = PI * 1
const NW = PI * 1.25
const N = PI * 1.5
const NE = PI * 1.75

func get_motion() -> Vector2:
	var ideal_face = null
	
	var l = false
	var r = false
	var u = false
	var d = false
	
	if (Input.is_key_pressed(KEY_A)):
		l = true
	if (Input.is_key_pressed(KEY_D)):
		r = true
	if (Input.is_key_pressed(KEY_W)):
		u = true
	if (Input.is_key_pressed(KEY_S)):
		d = true
		
	if r:
		if d:
			ideal_face = SE
		elif u:
			ideal_face = NE
		else:
			ideal_face = E
	elif l:
		if d:
			ideal_face = SW
		elif u:
			ideal_face = NW
		else:
			ideal_face = W
	elif u:
		ideal_face = N
	elif d:
		ideal_face = S
	else:
		return Vector2(0,0)
	
	return Vector2(1, 0).rotated(ideal_face)

func selected_color() -> Util.COLOR:
	if Input.is_key_pressed(KEY_Q):
		return Util.COLOR.RED
	if Input.is_key_pressed(KEY_E):
		return Util.COLOR.GREEN
	if Input.is_key_pressed(KEY_R):
		return Util.COLOR.BLUE
	return Util.COLOR.COLORLESS