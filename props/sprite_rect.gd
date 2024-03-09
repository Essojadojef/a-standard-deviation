@tool
extends Node2D

@export var texture : Texture2D: set = set_texture
@export var rect : Rect2: set = set_rect

func set_texture(value: Texture2D):
	texture = value
	queue_redraw()

func set_rect(value: Rect2):
	rect = value
	queue_redraw()

func _draw():
	draw_texture_rect(texture, rect, true)
