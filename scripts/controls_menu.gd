extends Control

var listening: bool
var input_event: InputEvent

@export var rebind_indicator: Control
@export var default_focus: Control

signal input_found

func listen_for_keybind(input_action: StringName, requesting_button: ControlsButton) -> void:
	listening = true
	rebind_indicator.visible = true
	await input_found
	InputMap.action_erase_events(input_action)
	InputMap.action_add_event(input_action, input_event)
	requesting_button._on_update()
	listening = false
	rebind_indicator.visible = false

func _input(event: InputEvent) -> void:
	if !(event.is_action_type() and listening):
		return
	
	if event is InputEventMouseButton:
		event.double_click = false
	
	input_event = event
	accept_event()
	input_found.emit()
