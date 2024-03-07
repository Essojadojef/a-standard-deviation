extends Room

func _ready() -> void:
	spawn_clones($CharacterBody2D, clone_multiplier, 1)
	spawn_clones($PlayerCharacterBody, clone_multiplier, 1)

func perform_room_transition(exit: int):
	Globals.room_transition = true
	
	var player_character = $PlayerCharacterBody
	unspawn_clones(player_character)
	
	var room_size = get_viewport_rect().size
	var next_room = (load("res://rooms/seaside_2.tscn") as PackedScene).instantiate()
	add_sibling(next_room)
	next_room.position = Vector2(room_size.x, 0) * 2
	#get_tree().change_scene_to_file("res://rooms/seaside_2.tscn")
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", Vector2(-room_size.x * 2, 0), 1)
	$Camera2D.top_level = true
	#tween.tween_property($Camera2D, "position", Vector2(room_size.x, 0), 1)
	player_character.top_level = true
	tween.tween_property(player_character, "position", player_character.position - Vector2(room_size.x, 0), 1)
	tween.tween_property(next_room, "position", Vector2(), 1)
	
	await tween.finished
	
	Globals.player_position = player_character.position
	queue_free()
	
	Globals.room_transition = false
	Globals.room_transition_finished.emit(scene_file_path, exit_direction[exit])
