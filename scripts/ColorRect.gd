extends ColorRect

func _ready():
	size.x = get_viewport_rect().size.x
	size.y = get_viewport_rect().size.y
