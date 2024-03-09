extends TextureRect

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var current_room: Room
	if get_tree().current_scene is Room:
		current_room = get_tree().current_scene
	else:
		return
	
	var player_character = get_tree().get_nodes_in_group("player").front()
	var focus_indicator = (
		player_character.focus_color_shift / 2 + .5 if player_character.focus_color else
		-2
	)
	
	for i in current_room.clone_multiplier:
		draw_point(current_room.clone_multiplier, i, focus_indicator)

func draw_point(amount: int, index: int, focus_indicator: float):
	var angle_step = TAU / amount
	var angle = -angle_step * (amount - 1) * .5 + angle_step * index
	var color_shift = .5 * index / (amount - 1) + .25
	var color = Globals.color_spectrum.sample(color_shift)
	var direction = Vector2.UP.rotated(angle)
	draw_circle(pivot_offset + direction * 15, 2, color)
	
	# focus indicator
	if focus_indicator < -1:
		draw_line(
			pivot_offset + direction * 8,
			pivot_offset + direction.rotated(angle_step) * 8,
			Color.WHITE, 1, false
		)
	elif abs(focus_indicator - color_shift) < .01: # account for some error
		draw_line(
			pivot_offset + direction * 12,
			pivot_offset - direction.rotated(angle_step * .25) * 12,
			color, 1, false
		)
		draw_line(
			pivot_offset + direction * 12,
			pivot_offset - direction.rotated(angle_step * -.25) * 12,
			color, 1, false
		)
		draw_line(
			pivot_offset - direction.rotated(angle_step * .25) * 12,
			pivot_offset - direction.rotated(angle_step * -.25) * 12,
			color, 1, false
		)
	
