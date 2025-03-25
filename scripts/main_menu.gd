extends Control

@export var game_scene: PackedScene
@export var continue_button: Control
@export var default_focus: Control
@export var main_submenu: Control
@export var options_menu: Control

func _ready() -> void:
	if FileAccess.file_exists(Game.save_file_path):
		default_focus = continue_button
	else: continue_button.visible = false
	default_focus.grab_focus()

func _on_play_button_pressed(new_save: bool) -> void:
	Game.new_save_flag = new_save
	var game: = game_scene.instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	queue_free()

func _on_options_button_pressed() -> void:
	options_menu.visible = true
	main_submenu.visible = false

func _on_options_menu_back() -> void:
	options_menu.visible = false
	main_submenu.visible = true
	default_focus.grab_focus()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
