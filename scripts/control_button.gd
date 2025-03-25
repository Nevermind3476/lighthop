class_name ControlsButton extends Button

@export var input_action: String

signal rebind(input_action: StringName, rquesting_button: Button)

var original_text: String

func _ready() -> void:
	original_text = text
	visibility_changed.connect(_on_update)
	_on_update()

func _pressed() -> void:
	rebind.emit(input_action, self)

func _on_update() -> void:
	var parsed_text := original_text
	var i := -1
	while i < original_text.length():
		i = original_text.find("CTRL:", i + 1)
		if i < 0: break
		var j := original_text.find(":", i + 5)
		var input_name := original_text.substr(i + 5, j - i - 5)
		input_name = get_readable_name(InputMap.action_get_events(input_name)[0])
		parsed_text = parsed_text.replace(original_text.substr(i, j - i + 1), input_name)
	
	text = parsed_text

static func get_readable_name(input_event: InputEvent) -> String:
	var output := ""
	if input_event is InputEventKey:
		output = input_event.as_text_physical_keycode()
	else: output = input_event.as_text()
	if output != "Left": output = output.replace("Left", "L")
	if output != "Right": output = output.replace("Right", "R")
	return output
