extends Entity

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

var hitstun: float

func _ready() -> void:
	damage_received.connect(_on_damage_received)

func _process(delta: float) -> void:
	modulate = (
		Globals.color_spectrum.sample(color_shift / 2 + .5) *
		(peak_level - base_level) +
		Color.WHITE * base_level
	)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var movement_speed = SPEED * pow(2, color_shift * velocity_field)
	var rotation_speed = SPEED * pow(2, color_shift)
	
	if hitstun:
		hitstun = max(hitstun - delta, 0)
		move_and_slide()
		return
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
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
	
	process_attack()

func process_attack():
	$Hurtbox.position = forward_vector * 24
	$Hurtbox.rotation = forward_vector.angle()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action") and has_node("Hurtbox"):
		attack()

func attack():
	$Hurtbox.add_to_group("hurtbox")
	$Hurtbox.show()
	$Hurtbox.process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().create_timer(.125, false).timeout.connect(stop_attack)

func stop_attack():
	$Hurtbox.hide()
	$Hurtbox.process_mode = Node.PROCESS_MODE_DISABLED

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body == self: return
	
	if body is CharacterBody2D and body.color_shift == color_shift:
		body.damage_received.emit(forward_vector)

func _on_damage_received(hit_direction: Vector2):
	hitstun = .125
	velocity = hit_direction * 300 * pow(2, color_shift * 1.5)
	stop_attack()
