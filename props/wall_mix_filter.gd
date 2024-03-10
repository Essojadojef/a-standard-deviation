extends StaticBody2D
class_name WallMixFilter

func _process(delta: float) -> void:
	var group = "player"
	if !Globals.clone_groups.has(group): return
	
	var gate_open = (
		Globals.clone_groups[group] == get_parent().clone_multiplier and
		(Globals.clone_spread[group] as Vector2).length() < 1
	)
	
	if gate_open:
		add_collision_exception_with_group("player")
	else:
		remove_collision_exception_with_group("player")

func add_collision_exception_with_group(group_name: String):
	for i in get_tree().get_nodes_in_group(group_name):
		add_collision_exception_with(i)

func remove_collision_exception_with_group(group_name: String):
	for i in get_tree().get_nodes_in_group(group_name):
		remove_collision_exception_with(i)
