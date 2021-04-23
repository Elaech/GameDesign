extends Control


const PATH_TO_SAVE_CONTROL = "user://controls.dat"
const PASSWORD = "10293847"
var control_data = null
onready var move_up = get_node("RemapInputs/Movement/CannonUP")
onready var move_down = get_node("RemapInputs/Movement/CannonDown")
onready var move_right = get_node("RemapInputs/Movement/CannonRight")
onready var move_left = get_node("RemapInputs/Movement/CannonLeft")
onready var pause = get_node("RemapInputs/Other/Pause")
onready var switch = get_node("RemapInputs/Other/Cannon Switch")
onready var c1 = get_node("RemapInputs/Other/Cannon 1")
onready var c2 = get_node("RemapInputs/Other/Cannon 2")
onready var c3 = get_node("RemapInputs/Other/Cannon 3")
var selected = null
var selected_name = null

func _ready():
	load_player_control_data()
	remap_all_labels()

func select_property(item,name):
	if selected!=null:
		selected.modulate = Color(1,1,1,1)
	selected = item
	selected_name = name
	selected.modulate = Color(0.851,0.22,1,1)

func _input(event):
	if selected!=null:
		if event is InputEventKey and event.pressed:
			if event.scancode != KEY_ENTER and !(event.scancode in control_data.values()):
				control_data[selected_name] = event.scancode
				remap_all_labels()
				save_player_control_data()
				

func _on_BackButton_button_up():
	get_tree().change_scene("res://Levels/TitleScreen.tscn")

func save_player_control_data():
	var file = File.new()
	var error = file.open_encrypted_with_pass(PATH_TO_SAVE_CONTROL,File.WRITE,PASSWORD)
	if error == OK:
		file.store_var(control_data)
		file.close()
	
func load_player_control_data():
	var file = File.new()
	if (!file.file_exists(PATH_TO_SAVE_CONTROL)):
		get_tree().quit()
	var error = file.open_encrypted_with_pass(PATH_TO_SAVE_CONTROL,File.READ,PASSWORD)
	if error == OK:
		control_data = file.get_var()
		file.close()

func apply_player_control_data():
	for key in control_data.keys():
		var ev = InputEvent.new()
		ev.scancode = control_data[key]
		InputMap.action_erase_events(key)
		InputMap.action_add_event(key,ev)
	
func new_player_control_data():
	control_data = {
		"cannon_up": KEY_W,
		"cannon_down": KEY_S,
		"cannon_left": KEY_A,
		"cannon_right": KEY_D,
		"pause": KEY_ESCAPE,
		"cannon_switch": KEY_R,
		"cannon_1":KEY_1,
		"cannon_2":KEY_2,
		"cannon_3":KEY_3
	}
	remap_all_labels()
	save_player_control_data()

func remap_wrong_keys(key):
	match key:
		KEY_ESCAPE:
			return "Escape"
		KEY_SPACE:
			return "Space"
		KEY_CAPSLOCK:
			return "Capslock"
		KEY_SHIFT:
			return "Shift"
		KEY_CONTROL:
			return "Control"
		KEY_TAB:
			return "Tab"
		KEY_UP:
			return "Up"
		KEY_DOWN:
			return "Down"
		KEY_LEFT:
			return "Left"
		KEY_RIGHT:
			return "Right"
		KEY_ALT:
			return "Alt"
		KEY_DELETE:
			return "Delete"
		KEY_BACK:
			return "Back"
		KEY_BACKSPACE:
			return "Backspace"
		KEY_ENTER:
			return "Enter"
		KEY_END:
			return "End"
		_:
			return char(key)
	
func remap_all_labels():
	move_up.get_node("Key").text = (remap_wrong_keys(control_data["cannon_up"]))
	move_down.get_node("Key").text = (remap_wrong_keys(control_data["cannon_down"]))
	move_left.get_node("Key").text = (remap_wrong_keys(control_data["cannon_left"]))
	move_right.get_node("Key").text = (remap_wrong_keys(control_data["cannon_right"]))
	pause.get_node("Key").text = (remap_wrong_keys(control_data["pause"]))
	switch.get_node("Key").text = (remap_wrong_keys(control_data["cannon_switch"]))
	c1.get_node("Key").text = (remap_wrong_keys(control_data["cannon_1"]))
	c2.get_node("Key").text = (remap_wrong_keys(control_data["cannon_2"]))
	c3.get_node("Key").text = (remap_wrong_keys(control_data["cannon_3"]))



func _on_CannonUP_button_up():
	select_property(move_up,"cannon_up")


func _on_CannonDown_button_up():
	select_property(move_down,"cannon_down")


func _on_CannonRight_button_up():
	select_property(move_right,"cannon_right")


func _on_CannonLeft_button_up():
	select_property(move_left,"cannon_left")


func _on_Pause_button_up():
	select_property(pause,"pause")


func _on_Cannon_Switch_button_up():
	select_property(switch,"cannon_switch")


func _on_Cannon_1_button_up():
	select_property(c1,"cannon_1")


func _on_Cannon_2_button_up():
	select_property(c2,"cannon_2")


func _on_Cannon_3_button_up():
	select_property(c3,"cannon_3")
