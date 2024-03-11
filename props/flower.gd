extends Entity

@export_range(0, 1)
var base_level: float
@export_range(0, 1)
var peak_level: float = 1
@export
var color_shift: float = 0

var velocity_field : float = 0

var hitstun:float

func _ready() -> void:
	damage_received.connect(_on_damage_received)

func _process(delta: float) -> void:
	modulate = Globals.color_spectrum.sample(color_shift / 2 + .5)
	modulate.a = peak_level

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if hitstun:
		hitstun = max(hitstun - delta, 0)
		move_and_slide()
		return
	
	var error = get_grid_aligned_position() - position
	velocity = velocity.lerp(Vector2(), .3) + error * .2

	move_and_slide()

func get_grid_aligned_position() -> Vector2:
	return position.snapped(Vector2.ONE * 32)

func _on_damage_received(hit_direction: Vector2):
	hitstun = .125
	#hit_direction = Vector2.RIGHT.rotated(snapped(hit_direction.angle(), PI / 4)) # only + or x movement
	hit_direction = hit_direction.rotated(color_shift * PI * .33)
	#velocity = hit_direction.normalized() * (600 * ease(color_shift + .5, -2) + 100)
	velocity = hit_direction.normalized() * (500 * pow(cos(PI * color_shift), 1.5) + 200)
