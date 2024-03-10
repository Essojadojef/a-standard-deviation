extends StaticBody2D
class_name WallMixFilter

func _physics_process(delta: float) -> void:
	var group = "player"
	var player_characters = get_tree().get_nodes_in_group(group)
	if !player_characters or !Globals.clone_spread.has(group): return
	
	var gate_open = (
		player_characters.size() == get_parent().clone_multiplier and
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
