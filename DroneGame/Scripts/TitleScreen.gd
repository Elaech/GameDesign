extends Control

const CC = "CC"
const UNLOCKED_LVL = "unlocked_levels"
const MAX_HEALTH = "max_health"
const DAMAGE_FACTOR = "damage_factor"
const CURRENT_CHECKPOINT = "current_checkpoint"
const CURRENT_LEVEL = "current_level"
const TAKEN_RESOURCES = "taken_resources"
const PATH_TO_SAVE = "user://save.dat"
const PATH_TO_SAVE_CONTROL = "user://controls.dat"
const PASSWORD = "10293847"
const SAVE_VERSION = "version"
# do not change current version 
# unless you want the save data of players to be deleted
# the need of this is in case we revert back and must make save data changes
const CURRENT_VERSION = 2
var control_data
var player_data
onready var counter = get_node("CursedChips/HBoxContainer/Counter")
onready var play_label = get_node("Buttons/PlayButton/Label")
onready var pause_menu = null

func _ready():
	load_player_data()
	load_player_control_data()
	apply_player_control_data()
	print(player_data)
	counter.text = str(player_data["CC"])
	if(player_data[CURRENT_LEVEL] != null):
		if(player_data[CURRENT_CHECKPOINT] != null):
			play_label.text = "Resume"
		else:
			play_label.text = "Continue"
	



func _on_PlayButton_button_up():
	if player_data[CURRENT_LEVEL]!=null:
		get_tree().change_scene(map_level_to_string(player_data[CURRENT_LEVEL]))
	else:
		get_tree().change_scene(map_level_to_string(player_data[UNLOCKED_LVL].max()))


func map_level_to_string(level):
	if level==1:
		return "res://Levels/Level1_0world.tscn"
	elif level==2:
		return "res://Levels/Level2World.tscn"
	elif level==3:
		return "res://Levels/Level3World.tscn"
	elif level==4:
		return "res://Levels/Level4World.tscn"
	elif level==5:
		return "res://Levels/Level5World.tscn"
	else:
		return "res://Levels/Level5World.tscn" 

func _on_ExitButton_button_up():
	get_tree().quit()


func save_player_data():
	var file = File.new()
	var error = file.open_encrypted_with_pass(PATH_TO_SAVE,File.WRITE,PASSWORD)
	if error == OK:
		file.store_var(player_data)
		file.close()
	
func load_player_data():
	var file = File.new()
	if (!file.file_exists(PATH_TO_SAVE)):
		new_player_data()
	var error = file.open_encrypted_with_pass(PATH_TO_SAVE,File.READ,PASSWORD)
	if error == OK:
		player_data = file.get_var()
		file.close()
	if player_data[SAVE_VERSION] < CURRENT_VERSION:
		new_player_data()
	
func new_player_data():
	player_data = {
		"CC" : 0,
		"unlocked_levels" : [1],
		"max_health" : 500,
		"damage_upgrade": 0,
		"life_upgrade": 0,
		"immunity_upgrade":0,
		"current_checkpoint": null,
		"current_level": null,
		"current_health" : null,
		"taken_resources" : null,
		"killed_enemies" : null,
		"version": CURRENT_VERSION
	}
	var file = File.new()
	var error = file.open_encrypted_with_pass(PATH_TO_SAVE,File.WRITE,PASSWORD)
	if error == OK:
		file.store_var(player_data)
		file.close()
	
func save_player_control_data():
	var file = File.new()
	var error = file.open_encrypted_with_pass(PATH_TO_SAVE_CONTROL,File.WRITE,PASSWORD)
	if error == OK:
		file.store_var(control_data)
		file.close()
	
func load_player_control_data():
	var file = File.new()
	if (!file.file_exists(PATH_TO_SAVE_CONTROL)):
		new_player_control_data()
	var error = file.open_encrypted_with_pass(PATH_TO_SAVE_CONTROL,File.READ,PASSWORD)
	if error == OK:
		control_data = file.get_var()
		file.close()

func apply_player_control_data():
	for key in control_data.keys():
		var ev = InputEventKey.new()
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
	save_player_control_data()
	

func _on_LevelsButton_button_up():
	get_tree().change_scene("res://Levels/LevelMenu.tscn")


func _on_UpgradesButton_button_up():
	get_tree().change_scene("res://Levels/UpdateMenu.tscn")


func _on_OptionsButton_button_up():
	get_tree().change_scene("res://Levels/Options.tscn")
