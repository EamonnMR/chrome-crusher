extends Control

func enable():
	show()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _process(delta):
	if Input.is_key_pressed(KEY_R):
		get_tree().change_scene_to_file("res://Main.tscn")
