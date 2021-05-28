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
var movable_position = Vector2(-1000,1000)
var current_zone = 0
var enemy_spawn_time
var base_spawn_time = 5
var is_spawning = false
var evoked_enemies = []
var rng = RandomNumberGenerator.new()
var blackhole
var enlarge_time = 0.016
var enlarge_rate = 1.0085

func _ready():
	load_player_data()
	init_level()
	player_data[CURRENT_LEVEL] = LEVEL
	player_data[CURRENT_CHECKPOINT] = null
	player_data[CURRENT_HEALTH] = player_data[MAX_HEALTH]
	player_data[KILLED_ENEMIES] = []
	rng.seed = OS.get_unix_time()
	save_player_data()
	initial_despawn()


func initial_despawn():
	gate_list = $Pause/Gates.get_children()
	despawn(gate_list[3])
	for cc in $Pause/Resources.get_children():
		despawn(cc)
	despawn($Pause/Portal)
	for zone in $Pause/Death.get_children():
		despawn(zone)
		zone.visible = false
	for enemy in $Pause/Enemies0.get_children():
		despawn(enemy)
	for enemy in $Pause/Enemies1.get_children():
		despawn(enemy)
	for enemy in $Pause/Enemies2.get_children():
		despawn(enemy)
	detection_zones = $Pause/Detection.get_children()
	for det in detection_zones:
		if det.get_id() !=0:
			despawn(det)

func spawn_enemy():
	var enemies = get_current_enemies()
	for enemy in evoked_enemies:
		enemies.erase(enemy)
	if !enemies.empty():
		enemies.shuffle()
		evoked_enemies.append(enemies[0])
		evoke(enemies[0])

func get_current_enemies():
	match current_zone:
		0:
			return $Pause/Enemies0.get_children()
		1:
			return $Pause/Enemies1.get_children()
		2:
			return $Pause/Enemies2.get_children()


func enlarge_blackhole():
	var x  = blackhole.scale
	var loc_eng = enlarge_rate - ($Pause/Boss.life*1.0/$Pause/Boss.max_life)*0.005
	blackhole.scale *= loc_eng

func spawn_blackhole():
	blackhole.visible = true
	evoke(blackhole)
	$Pause/DeathZoneTimer.start(enlarge_time)

func next_phase():
	enemy_spawn_time = base_spawn_time * $Pause/Boss.life*1.0/$Pause/Boss.max_life+2
	$Pause/EnemySpawnTimer.start(enemy_spawn_time)
	$Pause/Boss.targetable()
	is_spawning = true

func transition():
	is_spawning = false
	$Pause/EnemySpawnTimer.stop()
	$Pause/Boss.untargetable()
	for enemy in evoked_enemies:
		despawn(enemy)
	spawn_blackhole()
	evoked_enemies = []
	make_gate()

func make_gate():
	var detection_zones = null
	var gates = null
	match current_zone:
		0:
			detection_zones = [$Pause/Detection/PlayerDetectionZone2,
			$Pause/Detection/PlayerDetectionZone5]
			gates = [gate_list[0],gate_list[2]]
		1:
			detection_zones = [$Pause/Detection/PlayerDetectionZone6,
			$Pause/Detection/PlayerDetectionZone3]
			gates = [gate_list[0],gate_list[1]]
		2:
			detection_zones = [$Pause/Detection/PlayerDetectionZone7,
			$Pause/Detection/PlayerDetectionZone4]
			gates = [gate_list[1],gate_list[2]]
	var choice = int(rng.randf_range(0.1,1.9))
	evoke(detection_zones[choice])
	despawn(gates[choice])
	

func despawn_enemy(enemy):
	if enemy in evoked_enemies:
		evoked_enemies.erase(enemy)
	despawn(enemy)

func despawn(it):
	if "make_noise" in it:
		it.make_noise = false
	it.position +=movable_position

func evoke(it):
	if "heal" in it:
		it.heal()
	it.position -=movable_position
	if "make_noise" in it:
		it.make_noise = true
	

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
		enemy.emit_signal("enemy_death",enemy)
		enemy.queue_free()
	for enemy in $Pause/Enemies0.get_children():
		despawn(enemy)
	for enemy in $Pause/Enemies1.get_children():
		despawn(enemy)
	for enemy in $Pause/Enemies2.get_children():
		despawn(enemy)
	evoke($Pause/Portal/portal)


func _on_Boss_boss_chunked():
	transition()

func _on_PlayerDetectionZone_player_here(zone):
	despawn(zone)
	if blackhole != null:
		$Pause/DeathZoneTimer.stop()
		blackhole.scale = Vector2(1,1)
		despawn(blackhole)
		blackhole.visible = false
	match zone.ID:
		0:
			evoke(gate_list[3])
			current_zone = 0
			blackhole = $Pause/Death/DeathZone
		1:
			evoke(gate_list[0])
			current_zone = 0
			blackhole = $Pause/Death/DeathZone
		2:
			evoke(gate_list[0])
			current_zone = 1
			blackhole = $Pause/Death/DeathZone2
		3:
			evoke(gate_list[1])
			current_zone = 1
			blackhole = $Pause/Death/DeathZone2
		4:
			evoke(gate_list[1])
			current_zone = 2
			blackhole = $Pause/Death/DeathZone3
		5:
			evoke(gate_list[2])
			current_zone = 2
			blackhole = $Pause/Death/DeathZone3
		6:
			evoke(gate_list[2])
			current_zone = 0
			blackhole = $Pause/Death/DeathZone
		_:
			pass
	next_phase()

func _on_EnemySpawnTimer_timeout():
	$Pause/EnemySpawnTimer.stop()
	if is_spawning:
		spawn_enemy()
	$Pause/EnemySpawnTimer.start(enemy_spawn_time)


func _on_DeathZoneTimer_timeout():
	$Pause/DeathZoneTimer.stop()
	enlarge_blackhole()
	$Pause/DeathZoneTimer.start(enlarge_time)
