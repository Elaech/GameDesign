extends Control

const PATH_TO_SAVE = "user://save.dat"
const PASSWORD = "10293847"
var player_data
onready var counter = get_node("CursedChips/Counter")


func _ready():
	load_player_data()
	print(player_data)
	counter.text = str(player_data["CC"])




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
		"levels" : [1],
		"max_health" : 500,
		"damage_factor": 1
	}
	var file = File.new()
	var error = file.open_encrypted_with_pass(PATH_TO_SAVE,File.WRITE,PASSWORD)
	if error == OK:
		file.store_var(player_data)
		file.close()
	
