extends Node2D

@export_range(0, 1)
var base_level: float
@export
var peak_level: float = 1
@export
var color_shift: float = 0

var pressed = false

func _process(delta: float) -> void:
	modulate = Globals.color_spectrum.sample(color_shift / 2 + .5)
	modulate *= peak_level

func _on_damage_received(direction: Vector2):
	press()

func press():
	pressed = true
	$Sprite2D.frame = 1

func depress():
	pressed = false
	$Sprite2D.frame = 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != self and body is Entity and body.color_shift == color_shift and !pressed:
		press()

func _on_area_2d_body_exited(_body: Node2D) -> void:
	var overlapping_bodies: Array = $Area2D.get_overlapping_bodies()
	var valid_overlapping_bodies = overlapping_bodies.any(
		func(body): return body != self and body is Entity and body.color_shift == color_shift
	)
	if !valid_overlapping_bodies:
		depress()
