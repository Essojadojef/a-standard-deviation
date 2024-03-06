extends Node2D

func _ready() -> void:
	
	var clone_multiplier = 5 # 3
	
	spawn_clones($PlayerSpaceship, clone_multiplier, 1)
	spawn_clones($SpaceEnemy, clone_multiplier, 1)
	spawn_clones($CharacterBody2D, clone_multiplier, 1)

func spawn_clones(base_node: Node, n: int, spread: float):
	for i in range(1, n):
		var shift: float = ceil(float(i) / 2) * (1 if i % 2 else -1)
		var node = base_node.duplicate()
		node.color_shift += shift * spread / (n - 1)
		node.name += "_%d" % i
		add_child(node, true)
#
