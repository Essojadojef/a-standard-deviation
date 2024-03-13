extends Room

func neighbour_rooms(side: int) -> String:
	if side == SIDE_RIGHT:
		return "res://rooms/seaside_2.tscn"
	return super.neighbour_rooms(side)

func _ready() -> void:
	$FrogRed.visible = Globals.progress.frogs_obtained & 1
	$FrogGreen.visible = Globals.progress.frogs_obtained & 2
	$FrogBlue.visible = Globals.progress.frogs_obtained & 4
	super._ready()

func  _process(delta: float) -> void:
	$PlayerCharacterBody2.forward_vector = (
		$PlayerCharacterBody.position - $PlayerCharacterBody2.position
	)
