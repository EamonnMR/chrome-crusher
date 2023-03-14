extends Control

@onready var icons = {
	Util.COLOR.COLORLESS: $Weapon,
	Util.COLOR.RED: $SpellR,
	Util.COLOR.GREEN: $SpellG,
	Util.COLOR.BLUE: $SpellB
}

func _process(delta):
	if get_tree().get_root().get_node("World").has_node("Player"):
		show()
			
		var current_color = get_tree().get_root().get_node("World/Player").selected_color
		
		for icon in icons.values():
			mod_deselected(icon)
		
		mod_selected(icons[current_color])
	else:
		hide()
	
func mod_selected(tex: TextureRect):
	tex.modulate.a = 1.0
	#tex.show()

func mod_deselected(tex: TextureRect):
	tex.modulate.a = 0.2
	#tex.hide()
