extends StaticBody2D


export(Array,int) var battle_targets = []
var remaining = 0
onready var sprite = $Sprite
onready var collision = $CollisionShape2D


func _ready():
	print(battle_targets.size())
	if battle_targets.size() <= 0:
		open()
	remaining = battle_targets.size()
	get_enemies()

func open():
	collision.set_deferred("disabled",true)
	sprite.visible = false

func get_enemies():
	var enemies = get_tree().root.get_child(0).get_node("Pause/Enemies")
	for enemy in enemies.get_children():
		if enemy.enemy_id in battle_targets:
			enemy.connect("enemy_death",self,"on_battle_target_death")

func on_battle_target_death(enemy):
	remaining -= 1
	if remaining == 0:
		open()
