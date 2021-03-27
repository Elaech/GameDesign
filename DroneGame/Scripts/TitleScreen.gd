extends Control



func _on_PlayButton_button_up():
	get_tree().change_scene("res://Levels/Level1_0world.tscn")



func _on_ExitButton_button_up():
	get_tree().quit()
