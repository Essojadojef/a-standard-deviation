extends CanvasLayer

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
	
