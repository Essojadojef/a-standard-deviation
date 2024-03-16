extends RigidBody2D

@export_range(0, 1)
var base_level: float
@export_range(0, 1)
var peak_level: float
@export
var color_shift: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate = Globals.color_spectrum.sample(color_shift / 2 + .5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_destroy_timer_timeout() -> void:
	queue_free()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body == self: return
	
	if body is CharacterBody2D and body.color_shift == color_shift:
		body.velocity += linear_velocity
		queue_free()
