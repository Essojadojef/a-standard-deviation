extends Entity

@export_range(0, 1)
var base_level: float
@export
var peak_level: float = 1
@export
var color_shift: float = 0

var pressed = false

func _ready() -> void:
	damage_received.connect(_on_damage_received)

func _process(delta: float) -> void:
	modulate = Globals.color_spectrum.sample(color_shift / 2 + .5)
	modulate *= peak_level

func _on_damage_received(direction: Vector2):
	press()

func press():
	pressed = true
	$Sprite2D.frame = 1
	$DepressTimer.start()

func depress():
	pressed = false
	$Sprite2D.frame = 0

