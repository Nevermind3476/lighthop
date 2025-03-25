extends VisibleOnScreenNotifier2D

@export var image: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_entered.connect(on_screen_entered)

func on_screen_entered() -> void:
	Game.change_background(image)
