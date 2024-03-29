extends Entity

const SPEED = 300.0

@export_range(0, 1)
var base_level: float
@export_range(0, 1)
var peak_level: float = 1
@export
var color_shift: float = 0

var velocity_field : float = 0

var rng = RandomNumberGenerator.new()

var hitstun: float

var jump_start_pos: Vector2
var jump_end_pos: Vector2
var jump_phase: float
var jump_count: int
var jump_timer: float = .5

func _ready() -> void:
	damage_received.connect(_on_damage_received)
	
	if Globals.room_transition:
		await  Globals.room_transition_finished
	
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
	
	if hitstun:
		hitstun = max(hitstun - delta, 0)
		move_and_slide()
		return
	
	# disappear afer hitstunc
	if damage >= max_damage:
		queue_free()
		return
	
	velocity = Vector2()
	
	
	jump_timer -= delta
	if jump_timer < 0:
		jump_timer += rng.randf() + .75
		jump_count = 1 + rng.randi() % 4
		setup_jump()
	
	if jump_count:
		process_jump(delta)

func process_jump(delta: float):
	jump_phase = clamp(jump_phase + delta * 4, 0, 1)
	
	position = lerp(jump_start_pos, jump_end_pos, jump_phase)
	position.y -= sin(jump_phase * PI) * 32
	
	if jump_phase == 1:
		jump_count -= 1
		
		if jump_count:
			setup_jump()

func setup_jump():
	seed_rng()
	var viewport_size = get_viewport_rect().size
	var target_location = Vector2.RIGHT.rotated(rng.randf() * TAU)
	target_location = target_location * viewport_size * .4 + viewport_size / 2
	# target_location = random point in a circle, scaled to slightly less
	# of half the viewport, centered around the middle of the viewport
	jump_start_pos = position
	jump_end_pos = position.move_toward(target_location, 64)
	jump_phase = 0

func _on_damage_received(hit_direction: Vector2):
	damage += 1
	hitstun = .125
	velocity = hit_direction * 300 * pow(2, color_shift * 1.5)
	jump_count = 0
	seed_rng()
	jump_timer = 0
	Globals.play_sfx(preload("res://sounds/hit.wav"))

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body == self: return
	if !body.is_in_group("player"): return
	if body.color_shift != color_shift: return
	
	if jump_count:
		var movement: Vector2 = (jump_end_pos - jump_start_pos)
		body.damage_received.emit(movement.normalized())
