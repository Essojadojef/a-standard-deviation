extends Room

func neighbour_rooms(side: int) -> String:
	match side:
		SIDE_TOP: return "res://rooms/eagle_nest_topright.tscn"
		SIDE_BOTTOM: return "res://rooms/forest_maze.tscn"
	return super.neighbour_rooms(side)
