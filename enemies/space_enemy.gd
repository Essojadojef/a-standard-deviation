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

var formation: int

func _ready() -> void:
	if color_shift == 0:
		spawn_clones.call_deferred(3, 1)

func spawn_clones(n: int, spread: float):
	for i in range(1, n):
		var shift: float = ceil(float(i) / 2) * (1 if i % 2 else -1)
		var node = load("res://spaceships/ship.tscn").instantiate()
		node.color_shift += shift * spread / 2
		get_parent().add_child(node)

func _process(delta: float) -> void:
	#modulate = Color().from_hsv(clamp(shift + 1, 0, 2) / 3, 1.0 - base_level, peak_level)
	modulate = color_spectrum.sample(color_shift / 2 + .5)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	var movement_speed = SPEED # * pow(2, color_shift)
	var rotation_speed = SPEED * pow(2, color_shift)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction
	if direction:
		velocity = direction * movement_speed
	else:
		velocity = velocity.move_toward(Vector2(), movement_speed)
	
	var forw_vector = get_forward_vector()
	var forw_vector_angle = forw_vector.angle()
	
	# formations
	if formation == 1:
		forw_vector_angle += (color_shift * 2 * PI / 12)
	if formation == 2:
		forw_vector_angle += (color_shift * 2 * TAU / 3)
	
	var angle = angle_difference(transform.y.angle() + PI, forw_vector_angle)
	rotate(angle * 20 * delta)
	
	"""forw_vector = lerp(-transform.y, forw_vector, .5).normalized()
	
	var right_vector = forw_vector.rotated(PI / 2)
	transform.y = -forw_vector
	transform.x = right_vector"""

	move_and_slide()

func _draw() -> void:
	draw_line(Vector2(), Vector2.UP * 1024, Color.WHITE)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("commute_formation"):
		formation = (formation + 1) % 3
	
	if event.is_action_pressed("action"):
		shoot()

func shoot():
	var projectile_scene = preload("res://spaceships/projectile.tscn")
	var projectile = projectile_scene.instantiate()
	projectile.color_shift = color_shift
	projectile.position = position + get_forward_vector() * 16
	projectile.linear_velocity = get_forward_vector() * 600
	add_sibling(projectile)

func get_forward_vector():
	return -transform.y.normalized()
