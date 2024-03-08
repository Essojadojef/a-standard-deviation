extends Room

func _ready() -> void:
	Globals.bgm_player.stream = preload("res://music/Seaside exploration r2.ogg")
	Globals.bgm_player.play()
	spawn_clones($CharacterBody2D, clone_multiplier, 1)
	spawn_clones($PlayerCharacterBody, clone_multiplier, 1)

func neighbour_rooms(side: int) -> String:
	if side == SIDE_RIGHT:
		return "res://rooms/seaside_2.tscn"
	return super.neighbour_rooms(side)
