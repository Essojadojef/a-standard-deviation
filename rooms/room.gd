extends Node2D
class_name Room

@export
var clone_multiplier: int = 7

# room transition
var exit_direction = {
	SIDE_LEFT: Vector2.LEFT,
	SIDE_TOP: Vector2.UP,
	SIDE_RIGHT: Vector2.RIGHT,
	SIDE_BOTTOM: Vector2.DOWN
}

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
	
	var peak_level = 1.2 / pow(n, .5) # random formula but looks like it works
	# ideally when all the clones ovelap the sprite should be white-balanced
	# (white should be white, colors with lower value should not clip)
	base_node.peak_level = peak_level
	base_node.base_level = 0
	
	for i in range(1, n):
		var shift: float = ceil(float(i) / 2) * (1 if i % 2 else -1)
		var node = base_node.duplicate()
		node.color_shift += shift * spread / (n - 1)
		node.peak_level = peak_level
		node.name += "_%d" % i
		add_child(node, true)
		
		Globals.clone_groups[clone_group_id].append(node)
		Globals.nodes_clone_group[base_node] = clone_group_id
		

func unspawn_clones(base_node: Node):
	var clone_group_id: String = base_node.scene_file_path
	
	base_node.peak_level = 1
	base_node.color_shift = 0
	base_node.base_level = 1
	
	for i in Globals.clone_groups[clone_group_id]:
		if i == base_node:
			continue
		
		remove_child(i)
		i.queue_free()

const playable_area = Rect2(0, 0, 512, 288)

func _process(delta: float) -> void:
	process_room_transition()

func process_room_transition() -> void:
	if Globals.room_transition:
		return
	
	var player_nodes = get_tree().get_nodes_in_group("player")
	var player_nodes_outside_room = player_nodes.filter(is_outside_room)
	if player_nodes_outside_room.is_empty():
		return
	
	var exit_position = player_nodes_outside_room.pick_random().position
	
	if exit_position.x < 0:
		perform_room_transition(SIDE_LEFT)
	if exit_position.y < 0:
		perform_room_transition(SIDE_TOP)
	if exit_position.x > playable_area.size.x:
		perform_room_transition(SIDE_RIGHT)
	if exit_position.y > playable_area.size.y:
		perform_room_transition(SIDE_BOTTOM)

func is_outside_room(node: Node2D) -> bool:
	return !playable_area.has_point(node.position)

func perform_room_transition(exit: int):
	Globals.room_transition = true
