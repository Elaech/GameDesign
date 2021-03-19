extends CanvasLayer

func _process(_delta):
	self.transform = get_parent().transform
