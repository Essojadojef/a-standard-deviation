extends Room

func _ready() -> void:
	spawn_clones($PlayerSpaceship, clone_multiplier, 1)
	spawn_clones($CharacterBody2D, clone_multiplier, 1)
	spawn_clones($PlayerCharacterBody, clone_multiplier, 1)
	spawn_clones($Flower, clone_multiplier, 1)
