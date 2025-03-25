extends Camera2D

@export var screen_width: int = 64
@export var screen_height: int = 64

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_screen_center_position().x - Game.player.position.x > screen_width:
		position.x -= 2 * screen_width
	if get_screen_center_position().x - Game.player.position.x < -screen_width:
		position.x += 2 * screen_width
	if get_screen_center_position().y - Game.player.position.y > screen_height:
		position.y -= 2 * screen_height
	if get_screen_center_position().y - Game.player.position.y < -screen_height:
		position.y += 2 * screen_height
