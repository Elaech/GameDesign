extends Area2D


export var resource_number = 0
signal resource_captured(resource)


func _on_CursedChip_area_entered(area):
	emit_signal("resource_captured",self)
