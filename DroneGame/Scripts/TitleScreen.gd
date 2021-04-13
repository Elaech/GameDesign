extends Control

const CC = "CC"
const UNLOCKED_LVL = "unlocked_levels"
const MAX_HEALTH = "max_health"
const DAMAGE_FACTOR = "damage_factor"
const CURRENT_CHECKPOINT = "current_checkpoint"
const CURRENT_LEVEL = "current_level"
const TAKEN_RESOURCES = "taken_resources"
const PATH_TO_SAVE = "user://save.dat"
const PASSWORD = "10293847"
const SAVE_VERSION = "version"
# do not change current version 
# unless you want the save data of players to be deleted
# the need of this is in case we revert back and must make save data changes
const CURRENT_VERSION = 1

var player_data
onready var counter = get_node("CursedChips/HBoxContainer/Counter")
onready var play_label = get_node("Buttons/PlayButton/Label")
onready var pause_menu = null

func _ready():
	load_player_data()
	print(player_data)
	counter.text = str(player_data["CC"])
	if(player_data[CURRENT_LEVEL] != null):
		if(player_data[CURRENT_CHECKPOINT] != null):
			play_label.text = "Resume"
		else:
			play_label.text = "Continue"



func _on_PlayButton_button_up():
	get_tree().change_scene("res://Levels/Level1_0world.tscn")



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
		"damage_factor": 1,
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
	
