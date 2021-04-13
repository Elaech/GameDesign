extends Control


signal player_menu_exit
signal player_menu_resume
onready var cursed_chips = get_node("CursedChips/HBoxContainer/Counter")

func update_chips(value):
	cursed_chips.text= str(value)

func show():
	self.visible = true
	self.set_process(true)
	
func hide():
	self.visible = false
	self.set_process(false)


func _on_Exit_button_up():
	emit_signal("player_menu_exit")


func _on_Resume_button_up():
	emit_signal("player_menu_resume")
