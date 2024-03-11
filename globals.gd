extends Node

# room transition

var progress = {
	"forest_1_solved" = false,
	"forest_2_solved" = false,
	"flowers_phase" = 0,
	"golf_cleared" = false,
	"frogs_obtained" = 0,
}

var room_transition: bool = false
var room_transition_direction: Vector2
var last_room_filepath: String
var player_position: Vector2

signal room_transition_finished(prev_room, direction)

var color_spectrum: Gradient = preload("res://color_spectrum_rgb.tres")

var gui = preload("res://gui.tscn").instantiate()

var bgm_player: = AudioStreamPlayer.new()

var clone_groups: Dictionary
var clone_spread: Dictionary
var nodes_clone_group: Dictionary

var process_groups: Array = ["player"]

func _ready() -> void:
	read_save()
	
	add_child(bgm_player)
	bgm_player.bus = "BGM"
	bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	play_bgm(preload("res://music/Seaside exploration r2.ogg"))

func setup_gui():
	if !gui.is_inside_tree():
		add_child(gui)

func play_bgm(stream: AudioStream):
	if bgm_player.stream == stream: return
	bgm_player.stream = stream
	bgm_player.play()

func _process(delta: float) -> void:
	for i in process_groups:
		process_group(i)

func process_group(group_name: String) -> void:
	var group: Array = get_tree().get_nodes_in_group(group_name)
	if group.is_empty():
		return
	
	var positions_x = group.map(func(item: Node2D): return item.position.x)
	var positions_y = group.map(func(item: Node2D): return item.position.y)
	#var error = (positions_x.max() - positions_x.min()) + (positions_y.max() - positions_y.min())
	var error = Vector2(positions_x.max(), positions_y.max()) - Vector2(positions_x.min(), positions_y.min())
	clone_spread[group_name] = error

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			# handle close request
			write_save()

func write_save():
	#var save_game = FileAccess.open("user://save.txt", FileAccess.WRITE)
	#var json_string = JSON.stringify(progress)
	#save_game.store_line(json_string)
	
	# Create new ConfigFile object.
	var config = ConfigFile.new()
	for i in progress:
		config.set_value("Progress", i, progress[i])
	
	config.save("user://save.txt")

func read_save():
	if !FileAccess.file_exists("user://save.txt"):
		print("Savefile does not exist")
		return
	
	"""
	var save_game = FileAccess.open("user://save", FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		
		# Creates the helper class to interact with JSON
		var json = JSON.new()
		
		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		# Get the data from the JSON object
		var node_data = json.get_data()
		
	var json_string = JSON.stringify(progress)
	save_game.store_line(json_string)
	"""
	
	var config = ConfigFile.new()
	
	# Load data from a file.
	var err = config.load("user://save.txt")
	
	# If the file didn't load, ignore it.
	if err != OK:
		return
	
	progress.forest_1_solved = config.get_value("Progress", "forest_1_solved", false)
	progress.forest_2_solved = config.get_value("Progress", "forest_2_solved", false)
	progress.forest_2_solved = config.get_value("Progress", "flower_phase", 0)
	progress.forest_2_solved = config.get_value("Progress", "golf_cleared", false)
	progress.frogs_obtained  = config.get_value("Progress", "frogs_obtained", 0)
	
	
