extends Node2D

@export
var clone_multiplier: int = 7

func _ready() -> void:
	spawn_clones($PlayerSpaceship, clone_multiplier, 1)
	spawn_clones($SpaceEnemy, clone_multiplier, 1)
	spawn_clones($CharacterBody2D, clone_multiplier, 1)
	spawn_clones($PlayerCharacterBody, clone_multiplier, 1)

func spawn_clones(base_node: Node, n: int, spread: float):
	var clone_group_id: String = base_node.scene_file_path
	Globals.clone_groups[clone_group_id] = []
	Globals.clone_groups[clone_group_id].append(base_node)
	Globals.nodes_clone_group[base_node] = clone_group_id
	
	base_node.peak_level = .5
	
	for i in range(1, n):
		var shift: float = ceil(float(i) / 2) * (1 if i % 2 else -1)
		var node = base_node.duplicate()
		node.color_shift += shift * spread / (n - 1)
		node.peak_level = .5
		node.name += "_%d" % i
		add_child(node, true)
		
		Globals.clone_groups[clone_group_id].append(node)
		Globals.nodes_clone_group[base_node] = clone_group_id
		
