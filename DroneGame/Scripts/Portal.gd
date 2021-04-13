extends Node2D

onready var Portal = get_node("portal")


# Called when the node enters the scene tree for the first time.
func _ready(): 
	Portal.set_speed_scale(0.4)
	pass # Replace with function body.


func _process(delta):
	pass



func _on_portal_animation_finished():
	Portal.set_speed_scale(0.8)
	Portal.set_animation("Loop")
