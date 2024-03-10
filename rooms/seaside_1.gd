extends Room

func neighbour_rooms(side: int) -> String:
	if side == SIDE_RIGHT:
		return "res://rooms/seaside_2.tscn"
	return super.neighbour_rooms(side)
