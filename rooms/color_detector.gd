extends Room

var flowers = []

var puzzle_phase: int = 0
const flower_colors = [
	# phase: [ combination: [ color_shifts, ... ], ... ], ...
	[[-2. / 6], [1. / 6], [.5]],
	[[0, 1. / 6], [2. / 6, -2. / 6], [-.5, .5]],
	[[-2. / 6, .5], [-1. / 6, 1. / 6], [2. / 6, -.5]],
]

var solution_time: float = 0

func _ready() -> void:
	puzzle_phase = Globals.progress.flowers_phase
	if puzzle_phase > 2:
		unlock_door()
	super._ready()

func setup_clone(node: Node2D):
	if node.scene_file_path == "res://props/flower.tscn":
		flowers.append(node)

func neighbour_rooms(side: int) -> String:
	match side:
		SIDE_TOP: return "res://rooms/eagle_nest_topright.tscn"
		SIDE_BOTTOM: return "res://rooms/forest_maze.tscn"
	return super.neighbour_rooms(side)

func unlock_door():
	for y in range(0, 6):
		$TileMap.erase_cell(0, Vector2i(26, y))
		$TileMap.erase_cell(0, Vector2i(27, y))
		$TileMap.erase_cell(0, Vector2i(28, y))
		$TileMap.erase_cell(0, Vector2i(29, y))

func unlock_door_anim():
	for y in range(0, 6):
		await get_tree().create_timer(.33).timeout
		$TileMap.erase_cell(0, Vector2i(26, y))
		$TileMap.erase_cell(0, Vector2i(27, y))
		$TileMap.erase_cell(0, Vector2i(28, y))
		$TileMap.erase_cell(0, Vector2i(29, y))

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	process_puzzle(delta)

func perform_room_transition(room_transition_character: Entity):
	super.perform_room_transition(room_transition_character)
	flowers.clear()

func process_puzzle(delta: float):
	if puzzle_phase > 2 or !flowers:
		return
	
	var target_combinations: Array = flower_colors[puzzle_phase].map(
		func(color_shift_array): return sample_colors(color_shift_array)
	)
	var target_matched: Array = [false, false, false]
	
	$CanvasLayer2/Node2D1.modulate = target_combinations[0]
	$CanvasLayer2/Node2D2.modulate = target_combinations[1]
	$CanvasLayer2/Node2D3.modulate = target_combinations[2]
	
	var pos_combinations = {}
	for i in flowers:
		var pos = Vector2i(i.get_grid_aligned_position())
		
		if !pos_combinations.has(pos):
			pos_combinations[pos] = []
		
		pos_combinations[pos].append(i.color_shift)
	
	var combinations = pos_combinations.values().map(
		func(color_shift_array): return sample_colors(color_shift_array)
	)
	
	for i in 3:
		target_matched[i] = combinations.has(target_combinations[i])
	
	$CanvasLayer2/Node2D1/SpriteL.offset.x = 0 if target_matched[0] else -2
	$CanvasLayer2/Node2D1/SpriteR.offset.x = 0 if target_matched[0] else  2
	$CanvasLayer2/Node2D2/SpriteL.offset.x = 0 if target_matched[1] else -2
	$CanvasLayer2/Node2D2/SpriteR.offset.x = 0 if target_matched[1] else  2
	$CanvasLayer2/Node2D3/SpriteL.offset.x = 0 if target_matched[2] else -2
	$CanvasLayer2/Node2D3/SpriteR.offset.x = 0 if target_matched[2] else  2
	
	var solution = target_matched.all(func(item): return item)
	
	if solution:
		solution_time += delta
		
	else:
		solution_time = 0
	
	$Mouth.region_rect = Rect2(0, 32 if solution else 96, 64, 32)
	
	if solution_time >= 1:
		solution_time = 0
		puzzle_phase += 1
		Globals.progress.flowers_phase = puzzle_phase
		
		if puzzle_phase > 2:
			unlock_door_anim()
		
	

func sample_colors(array: Array) -> Color:
	var color = Color()
	for i in array:
		color += Globals.color_spectrum.sample(i / 2 + .5).srgb_to_linear()
	return color.linear_to_srgb() + Color(.2, .2, .2) # add bg color
