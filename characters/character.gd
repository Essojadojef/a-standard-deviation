extends CharacterBody2D

const SPEED = 160.0
const JUMP_VELOCITY = -400.0

@export_range(0, 1)
var base_level: float
@export_range(0, 1)
var peak_level: float = 1
@export
var color_shift: float = 0

var velocity_field : float = 0

var forward_vector: Vector2

func _process(delta: float) -> void:
	#modulate = Color().from_hsv(clamp(shift + 1, 0, 2) / 3, 1.0 - base_level, peak_level)
	modulate = Globals.color_spectrum.sample(color_shift / 2 + .5)
	modulate *= peak_level

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var movement_speed = SPEED * pow(2, color_shift * velocity_field)
	var rotation_speed = SPEED * pow(2, color_shift)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Vector2()
	if direction:
		velocity = direction * movement_speed
		forward_vector = direction
	else:
		velocity = velocity.move_toward(Vector2(), movement_speed)
	
	var forw_vector_angle = snapped(forward_vector.angle(), PI / 2)
	
	match int(forw_vector_angle / PI * 2):
		0:
			$Sprite2D.frame = 2
			$Sprite2D.flip_h = false
		1:
			$Sprite2D.frame = 0
			$Sprite2D.flip_h = false
		2, -2:
			$Sprite2D.frame = 2
			$Sprite2D.flip_h = true
		-1:
			$Sprite2D.frame = 3
			$Sprite2D.flip_h = true
	
	"""forw_vector = lerp(-transform.y, forw_vector, .5).normalized()
	
	var right_vector = forw_vector.rotated(PI / 2)
	transform.y = -forw_vector
	transform.x = right_vector"""

	move_and_slide()
	
