extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: PhysicsBody2D):
	if "velocity_field" in body:
		body.velocity_field = 1

func _on_body_exited(body: PhysicsBody2D):
	if "velocity_field" in body:
		body.velocity_field = 0
