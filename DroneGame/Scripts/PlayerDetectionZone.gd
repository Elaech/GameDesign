extends Area2D

export var ID = 0
signal player_here(zone)

func get_id():
	return ID


func _on_PlayerDetectionZone_area_entered(area):
	emit_signal("player_here",self)
