extends Control


signal player_menu_exit
signal player_menu_resume
onready var cursed_chips = get_node("CursedChips/HBoxContainer/Counter")
var sound = true
var atk_sound = true
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


func _on_Kill_Sound_button_up():
	if sound:
		$"Buttons/Kill Sound".modulate = Color(1,0,0,0.7)
		sound = false
		kill_bg_sound()
		
	else:
		$"Buttons/Kill Sound".modulate = Color(1,1,1,1)
		sound = true
		start_bg_sound()



func kill_bg_sound():
	get_parent().get_node("Pause/Player").stop_bg_sound()

func kill_shoot_sound():
	get_parent().get_node("Pause/Player").stop_shoot_sound()
	
func start_bg_sound():
	get_parent().get_node("Pause/Player").start_bg_sound()
	
func start_shoot_sound():
	get_parent().get_node("Pause/Player").start_shoot_sound()
	



func _on_Kill_Sound2_button_up():
	if atk_sound:
		$"Buttons/Kill Sound2".modulate = Color(1,0,0,0.7)
		atk_sound = false
		kill_shoot_sound()
		
	else:
		$"Buttons/Kill Sound2".modulate = Color(1,1,1,1)
		atk_sound = true
		start_shoot_sound()
