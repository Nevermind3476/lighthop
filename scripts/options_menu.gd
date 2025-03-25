extends Control

signal back

@export var default_focus: Control

func _ready() -> void:
	visibility_changed.connect(reload)
	reload()

func reload() -> void:
	%MainSubmenu/MasterVolume/MasterVolumeSlider.value = OptionsManager.master_volume
	%MainSubmenu/Music/MusicVolumeSlider.value = OptionsManager.music_volume
	%MainSubmenu/SoundEffects/SoundVolumeSlider.value = OptionsManager.sound_volume
	%MainSubmenu/FullscreenButton.text =\
	 "Fullscreen: On" if OptionsManager.fullscreen else "Fullscreen: Off"
	%MainSubmenu/FullscreenButton.button_pressed = OptionsManager.fullscreen
	
	default_focus.grab_focus()

func _on_master_volume_slider_value_changed(value: float) -> void:
	OptionsManager.master_volume = value
	AudioServer.set_bus_volume_db(0, 20 * (log(value) / log(10) - 1))
	

func _on_music_volume_slider_value_changed(value: float) -> void:
	OptionsManager.music_volume = value
	AudioServer.set_bus_volume_db(2, 20 * (log(value) / log(10) - 1))
	

func _on_sound_volume_slider_value_changed(value: float) -> void:
	OptionsManager.sound_volume = value
	AudioServer.set_bus_volume_db(1, 20 * (log(value) / log(10) - 1))
	

func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	OptionsManager.fullscreen = toggled_on
	%MainSubmenu/FullscreenButton.text = "Fullscreen: On" if toggled_on else "Fullscreen: Off"
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if toggled_on 
	else DisplayServer.WINDOW_MODE_WINDOWED)
	if toggled_on:
		#OptionsManager.default_window_size = get_window().size
		pass
	else:
		get_window().size = OptionsManager.default_window_size
		get_window().move_to_center()

func _return() -> void:
	OptionsManager.save()
	back.emit()

func _on_controls_button_pressed() -> void:
	%MainSubmenu.visible = false
	%ControlsSubmenu.visible = true
	%ControlsSubmenu.default_focus.grab_focus()
	%ControlsSubmenu/ScrollContainer.scroll_vertical = 0

func _on_return_to_main_submenu() -> void:
	%ControlsSubmenu.visible = false
	%MainSubmenu.visible = true
	%MainSubmenu/ControlsButton.grab_focus()

func _on_fullscreen_button_pressed() -> void:
	_on_fullscreen_button_toggled(!OptionsManager.fullscreen)
