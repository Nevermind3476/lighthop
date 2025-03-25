class_name PauseMenu extends CanvasLayer

@export var default_button: Control
@export var respawn_button: Control
@export var orb_counter: Control
@export var options_menu: Control
@export var main_submenu: Control

func _ready() -> void:
	visible = false

func pause() -> void:
	get_tree().paused = true
	visible = true
	
	options_menu.visible = false
	main_submenu.visible = true
	default_button.grab_focus()
	
	respawn_button.visible = Game.in_chase
	orb_counter.visible = Game.reached_temple
	
	MusicPlayer.volume_db -= 6

func unpause() -> void:
	get_tree().paused = false
	visible = false
	
	MusicPlayer.volume_db += 6

func quit() -> void:
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			unpause()
		else: pause()

func _on_options_pressed() -> void:
	options_menu.visible = true
	main_submenu.visible = false
	options_menu.default_focus.grab_focus()

func _on_options_menu_back() -> void:
	options_menu.visible = false
	main_submenu.visible = true
	default_button.grab_focus()

func _on_respawn_pressed() -> void:
	unpause()
	Game.respawn()
