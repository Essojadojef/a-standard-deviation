extends CharacterBody2D

const SPEED = 300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

@export_range(0, 1)
var base_level: float
@export_range(0, 1)
var peak_level: float = 1
@export
var color_shift: float = 0

var velocity_field : float = 0

func _process(delta: float) -> void:
	#modulate = Color().from_hsv(clamp(shift + 1, 0, 2) / 3, 1.0 - base_level, peak_level)
	modulate = Globals.color_spectrum.sample(color_shift / 2 + .5)
	modulate.a = peak_level

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var movement_speed = SPEED * pow(2, color_shift * velocity_field)
	var rotation_speed = SPEED * pow(2, color_shift)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction
	if direction:
		velocity = direction * movement_speed
	else:
		velocity = velocity.lerp(Vector2(), .2)

	move_and_slide()

func _draw() -> void:
	draw_line(Vector2(), Vector2.UP * 1024, Color.WHITE)

