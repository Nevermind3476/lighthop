extends CharacterBody2D

@export var gravity: float
@export var jump_height: float
var jump_force: float
@export var horiz_speed: float
@export var idle_time: float
var timer: float
@export var facing_left: = false

var idle: = true

@onready var sprite: = $Sprite2D as Sprite2D

func _ready() -> void:
	jump_force = sqrt(2 * gravity * jump_height)
	timer = idle_time * randf_range(0.5, 1.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if idle:
		timer -= delta
		
		if timer <= 0:
			jump()
	else:
		velocity.y += gravity * delta
		move_and_slide()
		
		if is_on_floor():
			idle = true
			timer = idle_time * randf_range(0.5, 1.5)
			velocity = Vector2.ZERO
			sprite.frame = 0

func jump() -> void:
	facing_left = !facing_left
	sprite.flip_h = facing_left
	velocity.y = -jump_force
	velocity.x = horiz_speed
	if facing_left: velocity.x *= -1
	sprite.frame = 1
	idle = false
