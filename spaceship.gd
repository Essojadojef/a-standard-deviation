@tool
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

@export_range(0, 1)
var base_level: float
@export_range(0, 1)
var peak_level: float
@export
var color_shift: float = 0
@export
var color_spectrum: Gradient

func _process(delta: float) -> void:
	#modulate = Color().from_hsv(clamp(shift + 1, 0, 2) / 3, 1.0 - base_level, peak_level)
	modulate = color_spectrum.sample(color_shift / 2 + .5)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var movement_speed = SPEED # * pow(2, color_shift)
	var rotation_speed = SPEED * pow(2, color_shift)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		velocity = direction * movement_speed
	else:
		velocity = velocity.move_toward(Vector2(), movement_speed)
	
	var forw_vector = (get_global_mouse_position() - global_position).normalized()
	forw_vector = forw_vector.rotated(color_shift * 2 * TAU / 3)
	var right_vector = forw_vector.rotated(PI / 2)
	transform.y = -forw_vector
	transform.x = right_vector

	move_and_slide()

func _draw() -> void:
	draw_line(Vector2(), Vector2.UP * 1024, Color.WHITE)
