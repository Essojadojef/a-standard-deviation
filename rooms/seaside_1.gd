extends Room

func _ready() -> void:
	spawn_clones($Crabbit, clone_multiplier, 1)
	spawn_clones($Crabbit2, clone_multiplier, 1)
	spawn_clones($CharacterBody2D, clone_multiplier, 1)
	spawn_clones($PlayerCharacterBody, clone_multiplier, 1)
