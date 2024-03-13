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
@export
var follow_cursor = false

var hitstun: float

var focus_color = false
var focus_color_shift:float = 0

signal defeated()

func _ready() -> void:
	var frogs_obtained: int = 0
	for i in 3:
		if Globals.progress.frogs_obtained & (1 << i):
			frogs_obtained += 1
	
	max_damage = 3 + Globals.progress.frogs_obtained
	
	damage_received.connect(_on_damage_received)
	defeated.connect(Globals.gui._on_player_character_defeated.bind(self))
	defeated.connect(Globals.sfx_play_player_character_defeated)

func _process(delta: float) -> void:
	modulate = (
		Globals.color_spectrum.sample(color_shift / 2 + .5) *
		(peak_level - base_level) +
		Color.WHITE * base_level
	)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var player_control = !focus_color or color_shift == focus_color_shift
	
	var movement_speed = SPEED * pow(2, color_shift * velocity_field)
	var rotation_speed = SPEED * pow(2, color_shift)
	
	if hitstun:
		hitstun = max(hitstun - delta, 0)
		visible = fmod(hitstun * 10, 1) > .5
		move_and_slide()
		return
	
	visible = true
	
	if damage >= max_damage:
		defeated.emit()
		queue_free()
		return
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction and player_control:
		velocity = velocity.lerp(direction * movement_speed, .25)
		forward_vector = direction
	else:
		velocity = velocity.lerp(Vector2(), .5)
	
	if follow_cursor and !direction and !$AttackTimer.time_left:
		forward_vector = get_cursor_direction()
	
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

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action"):
		attack()
	if Globals.cheats_enabled and event.is_action_pressed("commute_formation"):
		focus_commute()

func focus_commute():
	var player_characters = get_tree().get_nodes_in_group("player")
	var colors = player_characters.map(func(node): return node.color_shift)
	colors.sort()
	
	if !focus_color:
		focus_color = true
		focus_color_shift = colors.front()
		return
	
	if focus_color_shift == colors.back():
		focus_color = false
		return
	
	var current_index = colors.find(focus_color_shift)
	assert(current_index > -1)
	
	focus_color_shift = colors[current_index + 1]
	

func process_attack():
	$Hurtbox.position = forward_vector * 24
	$Hurtbox.rotation = forward_vector.angle()

func attack():
	$Hurtbox.add_to_group("hurtbox")
	$Hurtbox.show()
	$Hurtbox/CollisionPolygon2D.disabled = false
	$AttackTimer.start(.125)

func _on_attack_timer_timeout() -> void:
	stop_attack()

func stop_attack():
	$Hurtbox.hide()
	$Hurtbox/CollisionPolygon2D.disabled = true

func get_cursor_direction():
	return (get_global_mouse_position() - global_position).normalized()

func shoot():
	var projectile_scene = preload("res://characters/arrow.tscn")
	var projectile = projectile_scene.instantiate()
	var cursor_direction: Vector2 = get_cursor_direction()
	projectile.rotation = cursor_direction.angle()
	projectile.color_shift = color_shift
	projectile.position = position + cursor_direction * 32
	projectile.linear_velocity = cursor_direction * 600
	add_sibling(projectile)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body == self: return
	
	if body is Entity and abs(body.color_shift - color_shift) < .1:
		body.damage_received.emit(forward_vector)

func _on_damage_received(hit_direction: Vector2):
	if hitstun: return
	damage += 1
	hitstun = .125
	#velocity = hit_direction * 300 * pow(2, color_shift * 1.5)
	velocity = hit_direction * 300 * (randf() + randf())
	stop_attack()
	#Globals.play_sfx(preload("res://sounds/hit.wav"))
	Globals.play_sfx(preload("res://sounds/oh_1.wav"))

