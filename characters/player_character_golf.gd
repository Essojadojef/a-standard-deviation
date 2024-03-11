extends "res://characters/player_character.gd"

func _input(event: InputEvent) -> void:
	
	if (event.is_action("move_left") or event.is_action("move_right") or
		event.is_action("move_up") or event.is_action("move_down")):
		set_physics_process(true)
	
	if event.is_action_pressed("action"):
		return
	
	super._input(event)
