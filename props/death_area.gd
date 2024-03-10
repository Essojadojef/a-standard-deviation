extends Area2D

@export
var filter_color: bool = true

@export_range(0, 1)
var peak_level: float = 1
@export
var color_shift: float = 0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	modulate = Globals.color_spectrum.sample(color_shift / 2 + .5) * peak_level

func _on_body_entered(body: Node2D) -> void:
	if body != self and body is Entity:
		if filter_color and body.color_shift != color_shift:
			return
		
		if body.has_signal("defeated"):
			body.defeated.emit()
		body.queue_free()
