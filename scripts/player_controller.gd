class_name PlayerController extends CharacterBody2D

signal jumped
signal charge_jumped
signal charge_complete

@export var gravity: float = 288

@export_group("walking")
@export var walk_speed: float = 64
@export var inertia: float = 4
var target_walk_speed: float
var walk_accel: float

@export_group("jump")
@export var jump_height: int = 19
var jump_force: float
@export var coyote_time: float
var coyote_timer: float = 0
@export var jump_buffer_time: float
var jump_buffer_timer: float = 0
@export var extra_jumps: int = 0
var remaining_extra_jumps: int = 0
@export var can_infi_jump: = false

@export_group("charge jump")
@export var can_charge_jump: = false
@export var charge_jump_delay: float = 0.5
var charge_jump_timer: float = 0
@export var charge_jump_height_mult: float = 1
@export var charge_jump_speed: float = 128
@export var max_walk_accel = 128
var charge_jump_force: float
var charged: bool

var facing_left: bool = false
@onready var sprite: AnimatedSprite2D = $Sprite2D as AnimatedSprite2D

enum State {ground, jump, charging, charge_jump}
var state: State = State.ground

func _ready() -> void:
	jump_force = sqrt(2 * gravity * jump_height)
	charge_jump_force = sqrt(2 * gravity * jump_height * charge_jump_height_mult)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("charge_jump"):
		charged = false
		if state != State.charging: return
		modulate = Color.WHITE
		state = State.ground if is_on_floor() else State.jump
		if charge_jump_timer >= charge_jump_delay:
			charge_jump()
		charge_jump_timer = 0
	
	if event.is_action_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	
	match state:
		State.ground:
			handle_movement_input()
			velocity.x += walk_accel
			
			coyote_timer = coyote_time
			remaining_extra_jumps = extra_jumps
			
			if can_charge_jump && Input.is_action_pressed("charge_jump"):
				state = State.charging
			
			if !is_on_floor():
				state = State.jump
			
			sprite.play("walk") if absf(velocity.x) > 8 else sprite.play("default")
		
		State.jump:
			handle_movement_input()
			velocity.x += walk_accel
			
			coyote_timer -= delta
			
			if is_on_floor():
				state = State.ground
			
			sprite.play("jump")
		
		State.charging:
			handle_movement_input()
			target_walk_speed *= 0.5
			velocity.x += (target_walk_speed - velocity.x) / inertia 
			jump_buffer_timer = 0
			
			charge_jump_timer += delta
			if charge_jump_timer > charge_jump_delay:
				if !charged: charge_complete.emit()
				charged = true
				modulate = Color.YELLOW
			
			sprite.play("default")
		
		State.charge_jump:
			handle_movement_input()
			if signf(target_walk_speed) == -signf(velocity.x):
				walk_accel = clampf(walk_accel, -max_walk_accel * delta, max_walk_accel * delta)
				velocity.x += walk_accel
			if absf(velocity.x) <= absf(target_walk_speed):
				velocity.x += walk_accel
				state = State.jump
			
			if is_on_floor() && velocity.y >= 0:
				state = State.ground
			
			sprite.play("jump")
	
	#jump buffer
	if(jump_buffer_timer > 0):
		jump_buffer_timer -= delta
		if(coyote_timer > 0):
			jump()
		elif((remaining_extra_jumps > 0 || can_infi_jump)):
			remaining_extra_jumps -= 1
			jump()
	
	sprite.flip_h = facing_left
	
	move_and_slide()

func handle_movement_input() -> void:
	target_walk_speed = Input.get_axis("left", "right") * walk_speed
	if target_walk_speed != 0: facing_left = target_walk_speed < 0
	walk_accel = (target_walk_speed - velocity.x) / inertia 

func jump() -> void:
	velocity.y = -jump_force
	jump_buffer_timer = 0
	coyote_timer = 0
	
	state = State.jump
	jumped.emit()

func charge_jump() -> void:
	velocity.y = -jump_force * charge_jump_height_mult
	velocity.x = charge_jump_speed
	if facing_left: velocity.x *= -1
	
	jump_buffer_timer = 0
	coyote_timer = 0
	
	state = State.charge_jump
	charge_jumped.emit()

func respawn() -> void:
	state = State.ground
	velocity = Vector2.ZERO
