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

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	seed_rng()

func seed_rng():
	rng.seed = floor(Time.get_unix_time_from_system() + position.x / 16 * PI + position.y / 16)

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
	
	velocity = velocity.lerp(Vector2(), .5)
	
	if velocity.length() > 0:
		jump_count = 0
		seed_rng()
	
	move_and_slide()
	
	jump_timer -= delta
	if jump_timer < 0:
		jump_timer += 2 + rng.randf() * 5
		jump_count = 1 + rng.randi() % 4
		setup_jump()
	
	if jump_count:
		process_jump(delta)

var jump_start_pos: Vector2
var jump_end_pos: Vector2
var jump_phase: float
var jump_count: int
var jump_timer: float = 3

func process_jump(delta: float):
	jump_phase = clamp(jump_phase + delta * 4, 0, 1)
	
	position = lerp(jump_start_pos, jump_end_pos, jump_phase)
	position.y -= sin(jump_phase * PI) * 32
	
	if jump_phase == 1:
		jump_count -= 1
		
		if jump_count:
			setup_jump()

func setup_jump():
	var viewport_size = get_viewport_rect().size
	var target_location = viewport_size / 2 + Vector2.RIGHT.rotated(rng.randf() * TAU) * viewport_size / 2
	jump_start_pos = position
	jump_end_pos = position.move_toward(target_location, 64)
	jump_phase = 0
