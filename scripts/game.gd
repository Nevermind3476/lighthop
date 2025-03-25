class_name Game extends Node

signal after_load
signal on_respawn
signal chase_reset

@export var pause_menu_scene: PackedScene

static var new_save_flag: bool

static var instance: Game
static var player: PlayerController
static var pause_menu: PauseMenu
static var background: Sprite2D

static var respawn_coords: Vector2
static var in_chase: = false
static var reached_temple: = false
static var orbs_collected: int
const total_orbs: = 9

const save_file_path: = "user://save_file.json"
static var collected_items: Array
static var completed_chases: Array

func _init() -> void:
	instance = self

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player") as PlayerController
	respawn_coords = player.position
	
	background = get_tree().get_first_node_in_group("Background") as Sprite2D
	
	pause_menu = pause_menu_scene.instantiate() as PauseMenu
	add_child(pause_menu)
	
	if !new_save_flag:
		load_file(save_file_path)
		after_load.emit()

func _exit_tree() -> void:
	save_to_file()

static func change_background(new_image: Texture2D) -> void:
	background.texture = new_image

static func respawn() -> void:
	player.position = respawn_coords
	player.respawn()
	instance.on_respawn.emit()

func temple_reached() -> void:
	reached_temple = true
	print("reached temple")

static func load_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if(!file):
		push_error("Failed to load file at " + path)
		return
	
	var parsed_json = JSON.parse_string(file.get_as_text())
	file.close()
	if(!parsed_json):
		push_error("Could not parse the savefile at " + path)
		return
	if(!(parsed_json is Dictionary)):
		push_error("Unexpected result from parsing the savefile at " + path)
		return
	
	parsed_json = parsed_json as Dictionary
	orbs_collected = parsed_json.get("orbs_collected")
	player.can_charge_jump = parsed_json.get("can_charge_jump")
	player.can_infi_jump = parsed_json.get("can_infi_jump")
	player.extra_jumps = parsed_json.get("extra_jumps")
	collected_items = parsed_json.get("collected_items")
	completed_chases = parsed_json.get("completed_chases")
	reached_temple = parsed_json.get("reached_temple")
	player.position = Vector2(parsed_json.get("player_pos")[0], parsed_json.get("player_pos")[1])
	respawn_coords = Vector2(parsed_json.get("respawn_coords")[0], parsed_json.get("respawn_coords")[1])


static func save_to_file() -> void:
	var dict: Dictionary = {}
	dict["orbs_collected"] = orbs_collected
	dict["collected_items"] = collected_items
	dict["completed_chases"] = completed_chases
	dict["reached_temple"] = reached_temple
	dict["can_charge_jump"] = player.can_charge_jump
	dict["can_infi_jump"] = player.can_infi_jump
	dict["extra_jumps"] = player.extra_jumps
	dict["respawn_coords"] = [respawn_coords.x, respawn_coords.y]
	if in_chase:
		dict["player_pos"] = [respawn_coords.x, respawn_coords.y]
	else: dict["player_pos"] = [player.position.x, player.position.y]
	
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(dict, "\t"))
	file.close()
