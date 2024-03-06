extends Node

var color_spectrum: Gradient = preload("res://color_spectrum_oklab.tres")

var clone_groups: Dictionary
var clone_spread: Dictionary
var nodes_clone_group: Dictionary

var process_groups: Array = ["player_spaceship"]

func _process(delta: float) -> void:
	for i in process_groups:
		process_group(i)

func process_group(group_name: String) -> void:
	var group: Array = get_tree().get_nodes_in_group(group_name)
	if group.is_empty():
		return
	
	var positions_x = group.map(func(item: Node2D): return item.position.x)
	var positions_y = group.map(func(item: Node2D): return item.position.y)
	#var error = (positions_x.max() - positions_x.min()) + (positions_y.max() - positions_y.min())
	var error = Vector2(positions_x.max(), positions_y.max()) - Vector2(positions_x.min(), positions_y.min())
	clone_spread[group_name] = error

