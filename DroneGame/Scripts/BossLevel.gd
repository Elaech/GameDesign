extends Node2D

const CC = "CC"
const KILLED_ENEMIES = "killed_enemies"
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

var gate_list
var detection_zones
var movable_position = Vector2(-500,500)
var current_zone = 0


func _ready():
	load_player_data()
	init_level()
	player_data[CURRENT_LEVEL] = LEVEL
	player_data[CURRENT_CHECKPOINT] = null
	player_data[CURRENT_HEALTH] = player_data[MAX_HEALTH]
	player_data[KILLED_ENEMIES] = []
	save_player_data()
	initial_despawn()


func initial_despawn():
	gate_list = $Pause/Gates.get_children()
	despawn(gate_list[3])
	for cc in $Pause/Resources.get_children():
		despawn(cc)
	despawn($Pause/Portal)
	for enemy in $Pause/Enemies.get_children():
		despawn(enemy)
	for enemy in $Pause/Enemies1.get_children():
		despawn(enemy)
	for enemy in $Pause/Enemies2.get_children():
		despawn(enemy)
	detection_zones = $Pause/Detection.get_children()
	for det in detection_zones:
		if det.get_id() !=0:
			despawn(det)

func despawn(it):
	if "make_noise" in it:
		it.make_noise = false
	it.position +=movable_position

func evoke(it):
	if "make_noise" in it:
		it.make_noise = true
	it.position -=movable_position

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

func restart_level():
	get_tree().change_scene("res://Levels/Level5World.tscn")




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
		player_data[CC] += 1
		despawn_resource(resource)



func delete_resource(number):
	for res in all_resources.get_children():
		if res.resource_number == number:
			res.queue_free()



func despawn_resource(resource):
	resource.visible = false


func _on_Player_player_dies():
	restart_level()


func _on_CursedChip_resource_captured(resource):
	capture_resource(resource)
	save_player_data()


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
	player_data[CURRENT_CHECKPOINT] = null
	save_player_data()
	get_tree().change_scene("res://Levels/Level5World.tscn")


func _on_Boss_boss_death(boss):
	$Pause/Boss.queue_free()
	for cc in $Pause/Resources.get_children():
		evoke(cc)
	for enemy in $Pause/Enemies.get_children():
		if "enemy_id" in enemy and enemy.enemy_id == 999:
			enemy.emit_signal("enemy_death",enemy)
			enemy.queue_free()
		despawn(enemy)
	for enemy in $Pause/Enemies1.get_children():
		despawn(enemy)
	for enemy in $Pause/Enemies2.get_children():
		despawn(enemy)
	evoke($Pause/Portal/portal)


func _on_Boss_boss_chunked():
	return
	$Pause/Boss.untargetable()

func _on_PlayerDetectionZone_player_here(zone):
	if zone.ID == 0:
		zone.queue_free()
		evoke(gate_list[3])
