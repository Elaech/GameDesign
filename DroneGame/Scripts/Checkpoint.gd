extends Area2D

export var checkpoint_number = 0
signal checkpoint_activated(checkpoint)
onready var sprite = get_node("Sprite")

func _ready():
	sprite.frame = 2


func activate():
	sprite.frame = 0

func deactivate():
	sprite.frame = 2

func progress():
	sprite.frame = 1
	
func _on_Checkpoint_area_entered(area):
	emit_signal("checkpoint_activated", self)
