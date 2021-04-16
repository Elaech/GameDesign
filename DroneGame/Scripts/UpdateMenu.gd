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
const LIFE_UP = "life_upgrade"
const DMG_UP = "damage_upgrade"
const IMMUNITY_UP = "immunity_upgrade"

onready var current_currency = get_node("Moneyz/Label")
onready var current_life = get_node("Upgrades/Life/Value")
onready var current_immunity = get_node("Upgrades/Immunity/Value")
onready var current_damage = get_node("Upgrades/Damage/Value")
onready var current_life_cost = get_node("Upgrades/Life/Cost")
onready var current_immunity_cost = get_node("Upgrades/Immunity/Cost")
onready var current_damage_cost = get_node("Upgrades/Damage/Cost")

var player_data= null
var life_base = 500
var damage_base = 10
var immunity_base = 1

func _ready():
	load_player_data()
	current_currency.text = str(player_data[CC])
	current_life_cost.text = str((player_data[LIFE_UP]+1))
	current_damage_cost.text = str((player_data[DMG_UP]+1))
	current_immunity_cost.text = str((player_data[IMMUNITY_UP]+1))
	current_life.text = str(calculate_life())
	current_damage.text = str(calculate_damage())
	current_immunity.text = str(calculate_immunity())+'s'

func gauss(n):
	return n*(n+1)/2


func calculate_damage():
	return damage_base+3*player_data[DMG_UP]+0.3*gauss(player_data[DMG_UP]-1)

func calculate_life():
	return life_base+100*player_data[LIFE_UP]+10*gauss(player_data[LIFE_UP]-1)

func calculate_immunity():
	return immunity_base+0.1*player_data[IMMUNITY_UP]+0.01*gauss(player_data[IMMUNITY_UP]-1)


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


func _on_Back_button_up():
	get_tree().change_scene("res://Levels/TitleScreen.tscn")


func _on_Reset_button_up():
	player_data[CC] += gauss(player_data[LIFE_UP]) 
	player_data[CC] += gauss(player_data[DMG_UP]) 
	player_data[CC] += gauss(player_data[IMMUNITY_UP]) 
	current_damage.text = str(damage_base)
	current_life.text = str(life_base)
	current_immunity.text = str(immunity_base)+'s'
	current_currency.text = str(player_data[CC])
	player_data[LIFE_UP] = 0
	player_data[DMG_UP] = 0
	player_data[IMMUNITY_UP] = 0
	current_damage_cost.text = str(1) 
	current_life_cost.text = str(1) 
	current_immunity_cost.text = str(1) 
	save_player_data()


func _on_LifeButton_button_up():
	if player_data[CC] >= (player_data[LIFE_UP]+1):
		player_data[CC] -= (player_data[LIFE_UP]+1)
		player_data[LIFE_UP] +=1
		current_currency.text = str(player_data[CC])
		current_life_cost.text = str((player_data[LIFE_UP]+1))
		current_life.text = str(calculate_life())
		save_player_data()
		
func _on_DamageButton_button_up():
	if player_data[CC] >= (player_data[DMG_UP]+1):
		player_data[CC] -= (player_data[DMG_UP]+1)
		player_data[DMG_UP] +=1
		current_currency.text = str(player_data[CC])
		current_damage_cost.text = str((player_data[DMG_UP]+1))
		current_damage.text = str(calculate_damage())
		save_player_data()


func _on_ImmunityButton_button_up():
	if player_data[CC] >= (player_data[IMMUNITY_UP]+1):
		player_data[CC] -= (player_data[IMMUNITY_UP]+1)
		player_data[IMMUNITY_UP] +=1
		current_currency.text = str(player_data[CC])
		current_immunity_cost.text = str((player_data[IMMUNITY_UP]+1))
		current_immunity.text = str(calculate_immunity())+'s'
		save_player_data()

