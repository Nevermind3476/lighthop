extends Node

#const file_path := "user://options.json"

var master_volume: float = 10
var music_volume: float = 10
var sound_volume: float = 10

var fullscreen: bool = true

var default_window_size: Vector2i

func _ready() -> void:
	load_file()
	
	AudioServer.set_bus_volume_db(0, 20 * (log(master_volume) / log(10) - 1))
	AudioServer.set_bus_volume_db(1, 20 * (log(sound_volume) / log(10) - 1))
	AudioServer.set_bus_volume_db(2, 20 * (log(music_volume) / log(10) - 1))
	
	if !fullscreen: get_window().move_to_center()
	
	default_window_size = Vector2i(ProjectSettings.get_setting("display/window/size/window_width_override"),
	 ProjectSettings.get_setting("display/window/size/window_height_override"))
	
	if default_window_size == Vector2i.ZERO:
		var base_res := Vector2i(ProjectSettings.get("display/window/size/viewport_width"),
			ProjectSettings.get("display/window/size/viewport_height"))
		default_window_size = base_res * mini((DisplayServer.screen_get_size().x - 90) / base_res.x, 
			(DisplayServer.screen_get_size().y - 90) / base_res.y)


func save() -> void:
	var config := ConfigFile.new()
	config.set_value("options","master_volume",master_volume)
	config.set_value("options","music_volume",music_volume)
	config.set_value("options","sound_volume",sound_volume)
	
	config.set_value("display", "window/size/mode", 4 if fullscreen else 0)
	config.set_value("display", "window/size/window_width_override", default_window_size.x)
	config.set_value("display", "window/size/window_height_override", default_window_size.y)
	
	for action in InputMap.get_actions():
		if action.begins_with("ui"):
			continue
		
		config.set_value("input", action, { "deadzone": InputMap.action_get_deadzone(action),
		 "events": InputMap.action_get_events(action)})
	
	config.save(ProjectSettings.get_setting("application/config/project_settings_override"))

func load_file() -> void:
	var config := ConfigFile.new()
	config.load(ProjectSettings.get_setting("application/config/project_settings_override"))
	
	for key: String in config.get_section_keys("options"):
		set(key, config.get_value("options", key))
	
	fullscreen = config.get_value("display","window/size/mode", 4) == 4
