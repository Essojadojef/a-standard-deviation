extends Room

@export
var boss_max_damage:int = 7 * 5
@export
var frog_in_distress_id:int

var eagle_clones = []

func _ready() -> void:
	
	var frogs_saved = []
	for i in 3: 
		if Globals.progress.frogs_obtained & (1 << i):
			frogs_saved.append(i)
		
	
	boss_max_damage += 7 * (5 + frogs_saved.size() * 2)
	
	if frogs_saved.has(frog_in_distress_id):
		remove_child($Frog)
		remove_child($Eaglefly)
	
	super._ready()

func neighbour_rooms(side: int) -> String:
	return Globals.last_room_filepath

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	process_battle()

func setup_clone(node: Node2D):
	if node.scene_file_path == "res://enemies/eaglefly.tscn":
		eagle_clones.append(node)

func process_battle():
	if !eagle_clones:
		$CanvasLayer2.visible = false
		return
	
	var boss_damage: int = eagle_clones.reduce(
		func(accum: int, entity: Entity): return accum + entity.damage,
		0
	)
	
	$CanvasLayer2.visible = true
	$CanvasLayer2/BossBar.value = boss_damage
	$CanvasLayer2/BossBar.max_value = boss_max_damage
	
	if boss_damage > boss_max_damage:
		Globals.progress.frogs_obtained |= 1 << frog_in_distress_id
		
		for i in eagle_clones:
			i.queue_free()
		eagle_clones.clear()
