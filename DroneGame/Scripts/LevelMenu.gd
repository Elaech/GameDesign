extends Control

const CC = "CC"
const UNLOCKED_LVL = "unlocked_levels"
const MAX_HEALTH = "max_health"
const DAMAGE_FACTOR = "damage_factor"
const CURRENT_CHECKPOINT = "current_checkpoint"
const CURRENT_LEVEL = "current_level"
const CURRENT_HEALTH = "current_health"
const TAKEN_RESOURCES = "taken_resources"
const PATH_TO_SAVE = "user://save.dat"
const PASSWORD = "10293847"
const SAVE_VERSION = "version"

onready var levels = get_node("LevelButtons")
var player_data = null
var level_labels = []

func _ready():
	load_player_data()
	for child in levels.get_children():
		var lvl = int(child.name)
		if lvl in player_data[UNLOCKED_LVL]:
			child.get_children()[0].text = str(lvl)
	

func load_player_data():
	var file = File.new()
	if (!file.file_exists(PATH_TO_SAVE)):
		get_tree().quit()
	var error = file.open_encrypted_with_pass(PATH_TO_SAVE,File.READ,PASSWORD)
	if error == OK:
		player_data = file.get_var()
		file.close()
	else:
		get_tree().quit()

func save_player_data():
	var file = File.new()
	var error = file.open_encrypted_with_pass(PATH_TO_SAVE,File.WRITE,PASSWORD)
	if error == OK:
		file.store_var(player_data)
		file.close()
	else:
		get_tree().quit()

func map_level_to_string(level):
	return "res://Levels/Level1_0world.tscn"

func load_level(level):
	player_data[CURRENT_HEALTH] = player_data[MAX_HEALTH]
	player_data[CURRENT_CHECKPOINT] = null
	save_player_data()
	get_tree().change_scene(map_level_to_string(level))


func _on_Button_button_up():
	load_level(1)


func _on_Button2_button_up():
	load_level(2)


func _on_Button3_button_up():
	load_level(3)


func _on_Button4_button_up():
	load_level(4)


func _on_Button5_button_up():
	load_level(5)


func _on_BackButton_button_up():
	get_tree().change_scene("res://Levels/TitleScreen.tscn")
