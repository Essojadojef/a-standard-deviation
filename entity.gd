extends CharacterBody2D
class_name Entity

var damage: int = 0
@export
var max_damage: int = 0

signal damage_received(hit_direction: Vector2)
