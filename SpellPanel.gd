extends Control

@onready var icons = {
	Util.COLOR.COLORLESS: $Weapon,
	Util.COLOR.RED: $SpellR,
	Util.COLOR.GREEN: $SpellG,
	Util.COLOR.BLUE: $SpellB
}

@onready var player = get_tree().get_root().get_node("World/Player")

func _process(delta):
	if is_instance_valid(player):
		show()
		var player = get_tree().get_nodes_in_group("players")[0]
		var current_color = get_tree().get_root().get_node("World/Player").selected_color
		
		for icon in icons.values():
			mod_deselected(icon)
		
		mod_selected(icons[current_color])
		
		for color in icons.keys():
			var icon = icons[color]
			var pb: TextureProgressBar = icon.get_node("ProgressBar")
			var timer: Timer = player.spells[color].get_node("Cooldown")
			if timer.time_left > 0:
				pb.value = 100 - (100 * (timer.time_left / timer.wait_time))
			else:
				pb.value = 100
	else:
		hide()
		
	
func mod_selected(tex: TextureRect):
	tex.modulate.a = 1.0
	#tex.show()

func mod_deselected(tex: TextureRect):
	tex.modulate.a = 0.2
	#tex.hide()
