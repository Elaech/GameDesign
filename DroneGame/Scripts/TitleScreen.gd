extends Control

const CC = "CC"
const UNLOCKED_LVL = "unlocked_levels"
const MAX_HEALTH = "max_health"
const DAMAGE_FACTOR = "damage_factor"
const CURRENT_CHECKPOINT = "current_checkpoint"
const CURRENT_LEVEL = "current_level"
const PATH_TO_SAVE = "user://save.dat"
const PASSWORD = "10293847"
const CURRENT_VERSION = 0


var player_data
onready var counter = get_node("CursedChips/Counter")
onready var play_label = get_node("Buttons/PlayButton/Label")

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
		"version": 0
	}
	var file = File.new()
	var error = file.open_encrypted_with_pass(PATH_TO_SAVE,File.WRITE,PASSWORD)
	if error == OK:
		file.store_var(player_data)
		file.close()
	
