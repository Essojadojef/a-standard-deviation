@tool
extends CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var width = 2
	$Sprite2DLeft.position.x   = -shape.size.x / 2
	$Sprite2DTop.position.y    = -shape.size.y / 2
	$Sprite2DRight.position.x  =  shape.size.x / 2
	$Sprite2DBottom.position.y =  shape.size.y / 2
	$Sprite2DLeft.region_rect   = Rect2(0, 0, width, shape.size.y)
	$Sprite2DTop.region_rect    = Rect2(0, 0, shape.size.x, width)
	$Sprite2DRight.region_rect  = Rect2(64 - width, 0, width, shape.size.y)
	$Sprite2DBottom.region_rect = Rect2(0, 64 - width, shape.size.x, width)

