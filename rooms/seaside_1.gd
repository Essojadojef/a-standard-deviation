extends Room

func neighbour_rooms(side: int) -> String:
	if side == SIDE_RIGHT:
		return "res://rooms/seaside_2.tscn"
	return super.neighbour_rooms(side)

func _ready() -> void:
	$FrogRed.visible = Globals.progress.frogs_obtained & 1
	$FrogGreen.visible = Globals.progress.frogs_obtained & 2
	$FrogBlue.visible = Globals.progress.frogs_obtained & 4
	spawn_clones($PlayerCharacterBody2, clone_multiplier, 1)
	super._ready()
