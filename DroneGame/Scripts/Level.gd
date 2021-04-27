extends Node2D

const CC = "CC"
const UNLOCKED_LVL = "unlocked_levels"
const MAX_HEALTH = "max_health"
const CURRENT_HEALTH = "current_health"
const DAMAGE_FACTOR = "damage_factor"
const CURRENT_CHECKPOINT = "current_checkpoint"
const CURRENT_LEVEL = "current_level"
const TAKEN_RESOURCES = "taken_resources"
const PATH_TO_SAVE = "user://save.dat"
const PASSWORD = "10293847"
const SAVE_VERSION = "version"
const LIFE_UP = "life_upgrade"
const DMG_UP = "damage_upgrade"
const IMMUNITY_UP = "immunity_upgrade"
const CURRENT_VERSION = 1
var LEVEL
var START_PLAYER_POS
var NEXT_LEVEL
onready var all_checkpoints =get_node("Pause/Checkpoints")
onready var all_resources = get_node("Pause/Resources")
onready var player = get_node("Pause/Player")
onready var level_info = get_node("Pause/LevelInfo")
onready var pause_menu = get_node("PauseMenu")
onready var escape_timer = get_node("Timer")
var player_data
var checkpoint_data = null
var current_checkpoint = null
var not_saved_resources = []
var not_saved_enemies = []
var game_pause = false
var enemy_respawn_position

func _ready():
	load_player_data()
	init_level()
	if player_data[CURRENT_LEVEL] == LEVEL and player_data["current_checkpoint"] != null:
		load_checkpoint_from_save()
		load_checkpoint()
	else:
		player_data[CURRENT_LEVEL] = LEVEL
		player_data[CURRENT_CHECKPOINT] = null
		player_data[CURRENT_HEALTH] = player_data[MAX_HEALTH]
		save_player_data()


func _process(delta):
	if Input.is_action_pressed("pause") and escape_timer.is_stopped():
		if game_pause:
			pause_menu.hide()
			game_pause = false
			get_tree().paused = false
		else:
			pause_menu.update_chips(player_data[CC])
			pause_menu.set_global_position(player.global_position)
			pause_menu.show()
			game_pause = true
			get_tree().paused = true
		escape_timer.start(0.5)

func init_level():
	pause_menu.hide()
	init_player_stats()
	self.LEVEL = level_info.LEVEL
	self.START_PLAYER_POS =  level_info.START_PLAYER_POS
	self.NEXT_LEVEL = level_info.NEXT_LEVEL
	self.enemy_respawn_position = level_info.RESPAWN
	init_resources()

func init_player_stats():
	player.DAMAGE = calculate_damage()
	player.MAX_LIFE = calculate_life()
	player.LIFE = player.MAX_LIFE
	print(player.LIFE)
	player.IMMUNITY_TIME = calculate_immunity()
	player.update_healthbar()

func calculate_damage():
	return 10+3*player_data[DMG_UP]+0.3*gauss(player_data[DMG_UP]-1)

func calculate_life():
	return 500+100*player_data[LIFE_UP]+10*gauss(player_data[LIFE_UP]-1)

func calculate_immunity():
	return 1+0.1*player_data[IMMUNITY_UP]+0.01*gauss(player_data[IMMUNITY_UP]-1)

func gauss(n):
	return n*(n+1)/2


func reached_checkpoint(checkpoint):
	if current_checkpoint != null:
		if current_checkpoint.checkpoint_number != checkpoint.checkpoint_number:
			current_checkpoint.deactivate()
			current_checkpoint = checkpoint
			save_unsaved_resources()
			save_killed_enemies()
			player_data["current_health"] = player.LIFE
			player_data["current_checkpoint"] = current_checkpoint.checkpoint_number
			save_player_data()
			current_checkpoint.activate()
		elif !not_saved_resources.empty() or !not_saved_enemies.empty():
			save_unsaved_resources()
			save_killed_enemies()
			player_data["current_health"] = player.LIFE
			player_data["current_checkpoint"] = current_checkpoint.checkpoint_number
			save_player_data()
			current_checkpoint.activate()
	else:
		current_checkpoint = checkpoint
		save_unsaved_resources()
		save_killed_enemies()
		player_data["current_health"] = player.LIFE
		player_data["current_checkpoint"] = current_checkpoint.checkpoint_number
		save_player_data()
		current_checkpoint.activate()

func load_checkpoint():
	player.cannon_active = false
	player.motion = Vector2.ZERO
	respawn_not_saved_resources()
	respawn_killed_enemies()
	if current_checkpoint!= null:
		current_checkpoint.activate()
		player.global_position = current_checkpoint.global_position
		player.LIFE = min(player_data["current_health"],player_data["max_health"])
		player.update_life(player_data["current_health"])
	else:
		player.global_position = START_PLAYER_POS
		player.LIFE = player_data["max_health"]
		player.update_life(player_data["max_health"])
	for enemy in $Pause/Enemies.get_children():
		enemy.respawn()

func _on_Checkpoint_checkpoint_activated(checkpoint):
	reached_checkpoint(checkpoint)


func load_checkpoint_from_save():
	for child in all_checkpoints.get_children():
		if child.checkpoint_number == player_data["current_checkpoint"]:
			current_checkpoint = child
			break
	


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

func capture_resource(resource):
	if !not_saved_resources.has(resource):
		if current_checkpoint != null:
			current_checkpoint.progress()
		not_saved_resources.append(resource)
		despawn_resource(resource)
	
func kill_enemy(enemy):
	if !not_saved_enemies.has(enemy):
		if current_checkpoint != null:
			current_checkpoint.progress()
		not_saved_enemies.append(enemy)
		enemy.despawn(enemy_respawn_position)

func save_killed_enemies():
	for enemy in not_saved_enemies:
		enemy.queue_free()
	not_saved_enemies = []

func respawn_killed_enemies():
	for enemy in not_saved_enemies:
		enemy.respawn()
	not_saved_enemies = []

func save_unsaved_resources():
	player_data[CC] += not_saved_resources.size()
	for res in not_saved_resources:
		player_data[TAKEN_RESOURCES][LEVEL].append(res.resource_number)
		res.queue_free()
	not_saved_resources = []

func init_resources():
	if player_data[TAKEN_RESOURCES] == null:
		player_data[TAKEN_RESOURCES]= {}
	if player_data[TAKEN_RESOURCES].has(LEVEL):
		var taken_resources = player_data[TAKEN_RESOURCES][LEVEL]
		print(taken_resources)
		for res_nr in taken_resources:
			delete_resource(res_nr)
	else:
		player_data[TAKEN_RESOURCES][LEVEL] = []

func delete_resource(number):
	for res in all_resources.get_children():
		if res.resource_number == number:
			res.queue_free()

func respawn_not_saved_resources():
	for res in not_saved_resources:
		res.visible = true
	not_saved_resources = []

func despawn_resource(resource):
	resource.visible = false


func _on_Player_player_dies():
	load_checkpoint()


func _on_CursedChip_resource_captured(resource):
	capture_resource(resource)

func _on_enemy_vanquish(enemy):
	kill_enemy(enemy)


func _on_PauseMenu_player_menu_resume():
	pause_menu.hide()
	game_pause = false
	get_tree().paused = false
	escape_timer.start(0.5)


func _on_PauseMenu_player_menu_exit():
	get_tree().paused = false
	get_tree().change_scene("res://Levels/TitleScreen.tscn")


func _on_Timer_timeout():
	escape_timer.stop()


func _on_Portal_level_finished():
	if !(NEXT_LEVEL in player_data[UNLOCKED_LVL]): 
		player_data[UNLOCKED_LVL].append(NEXT_LEVEL)
	player_data[CURRENT_CHECKPOINT] = null
	save_player_data()
	get_tree().change_scene(map_level_to_string(NEXT_LEVEL))

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
