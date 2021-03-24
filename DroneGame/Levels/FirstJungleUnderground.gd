extends Node2D

const player_res =  preload("res://WorldObjects/Player.tscn")
onready var player = get_node("Player")

func _process(delta):
	if player == null:
		if Input.is_key_pressed(KEY_O):
			player = player_res.instance()
			player.global_position = self.global_position
			self.add_child(player)
