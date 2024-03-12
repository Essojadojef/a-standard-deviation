extends CanvasLayer

var max_health = 3

func _process(delta: float) -> void:
	var current_room: Room
	if get_tree().current_scene is Room:
		current_room = get_tree().current_scene
	else:
		return
	
	var characters_health: Dictionary = {}
	for i in get_tree().get_nodes_in_group("player"):
		characters_health[i.color_shift] = max_health - i.damage
	
	var frogs_obtained: int = 0
	for i in 3:
		if Globals.progress.frogs_obtained & (1 << i):
			frogs_obtained += 1
	
	max_health = 3 + frogs_obtained
	
	for i in 10:
		process_heart(i, characters_health)
	

func process_heart(index: int, characters_health: Dictionary):
	var heart_sprite: TextureRect = $Hearts.get_child(index)
	var heart_border: TextureRect = $HeartsBorder.get_child(index)
	heart_sprite.visible = index < max_health
	heart_border.visible = index < max_health
	
	var heart_colors = []
	for i in characters_health:
		if characters_health[i] > index:
			heart_colors.append(i)
	heart_sprite.modulate = Globals.sample_colors(heart_colors)

func _on_player_character_defeated(character: Entity):
	var color = Globals.color_spectrum.sample(character.color_shift / 2 + .5)
	var viewport_size:Vector2 = $Waves.get_viewport_rect().size
	var origin: Vector2 = character.position / viewport_size * 2 - Vector2.ONE
	var shader_polygon: Node2D = $Waves.duplicate(7)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	add_child(shader_polygon)
	
	shader_polygon.show()
	var shader_material: ShaderMaterial = shader_polygon.material
	shader_material.set_shader_parameter("origin", origin)
	shader_material.set_shader_parameter("modulate", color)
	shader_polygon.get_node("AnimationPlayer").play("waves")
	tween.tween_property(shader_material, "shader_parameter/modulate", Color.BLACK, 2).from(color)
	
	await tween.finished
	
	shader_polygon.queue_free()
	
