class_name CatPathNode extends Marker2D

enum Type {pounce, drop, preclimb, climb, wait_for_player}
@export var type: Type
@export var pounce_height: int = 10
@export var wait_time: float = 0.3
@export var player_detect_radius: int = 8
var player_detected: = false

func _ready() -> void:
	Game.instance.chase_reset.connect(reset)
	

func _physics_process(delta: float) -> void:
	if type == Type.wait_for_player && Game.player.position.distance_squared_to(position) < pow(player_detect_radius, 2):
		player_detected = true

func reset() -> void:
	player_detected = false
