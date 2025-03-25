extends CharacterBody2D

signal aggroed
signal chase_complete

@export var id: String

@export var chase_music: AudioStream
var default_music: AudioStream

@export var path: CatPath
var current_path_index: int = 0
var target_pos: Vector2

#@export var pounce_speed: float = 96
var pounce_height: int = 10
@export var gravity: float = 288
@export var initial_wait_time: float = 1
var wait_time: float
var pounce_vert_force: float
@export var climb_speed: float = 64
@export var end_music_fade_time: float = 1

var timer: float

@onready var sprite: = $Sprite2D as AnimatedSprite2D
@onready var hurtbox: = $Hurtbox/CollisionShape2D as CollisionShape2D
@onready var start_pos: = position

var active: = false
enum CatState {hidden, wait, pounce, drop, preclimb, climb, stop}
var state: CatState = CatState.hidden

func _ready() -> void:
	Game.instance.after_load.connect(save_check)
	Game.instance.on_respawn.connect(reset)
	default_music = MusicPlayer.stream
	wait_time = initial_wait_time

func save_check() -> void:
	if Game.completed_chases.has(id): 
		chase_complete.emit()
		queue_free()

func appear() -> void:
	if active: return
	hurtbox.set_deferred("disabled", false)
	aggroed.emit()
	active = true
	Game.in_chase = true
	MusicPlayer.switch_song(chase_music)
	wait()

func reset() -> void:
	Game.in_chase = false
	Game.instance.chase_reset.emit()
	position = start_pos
	rotation = 0
	sprite.play("hide")
	sprite.flip_h = false
	
	hurtbox.set_deferred("disabled", true)
	active = false
	state = CatState.hidden
	current_path_index = 0
	wait_time = initial_wait_time
	
	MusicPlayer.switch_song(default_music)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		Game.respawn()

func _physics_process(delta: float) -> void:
	match state:
		CatState.wait:
			velocity.y += gravity * delta
			move_and_slide()
			
			timer -= delta
			if timer <= 0:
				next_path_node()
		CatState.pounce:
			velocity.y += gravity * delta
			move_and_slide()
			
			if (velocity.x > 0 && target_pos.x < position.x) || (velocity.x < 0 && target_pos.x > position.x):
				velocity.x = 0
				position.x = target_pos.x
			
			if position.distance_to(target_pos) <= 2:
				position = target_pos
				wait()
			
		CatState.drop:
			velocity.y += gravity * delta
			move_and_slide()
			
			if position.y >= target_pos.y:
				wait()
		CatState.preclimb:
			next_path_node()
		CatState.climb:
			move_and_slide()
			
			if (velocity.y > 0 && target_pos.y < position.y) || (velocity.y < 0 && target_pos.y > position.y):
				velocity.y = 0
				position = target_pos
				rotation = 0
				sprite.flip_h = false
				next_path_node()

func wait() -> void:
	sprite.play("crouch")
	state = CatState.wait
	timer = wait_time
	velocity.x = 0

func pounce() -> void:
	state = CatState.pounce
	target_pos = path.nodes[current_path_index].position
	pounce_height = path.nodes[current_path_index].pounce_height
	pounce_vert_force = sqrt(2 * gravity * pounce_height)
	
	var delta = target_pos.y - position.y
	timer = sqrt(pounce_vert_force * pounce_vert_force - 2 * -gravity * delta)
	timer = (pounce_vert_force + timer) / gravity
	velocity.y = -pounce_vert_force
	velocity.x = (target_pos.x - position.x) / timer
	
	sprite.play("leap")
	sprite.flip_h = target_pos.x < position.x

func climb_setup():
	rotation_degrees = -90
	position = target_pos
	sprite.play("climb")
	state = CatState.preclimb

func climb():
	state = CatState.climb
	velocity.x = 0
	velocity.y = climb_speed
	if target_pos.y < position.y:
		velocity.y *= -1
		sprite.flip_h = false
	else: sprite.flip_h = true

func next_path_node():
	if current_path_index >= path.nodes.size(): 
		wait()
		return
	
	var current_node := path.nodes[current_path_index]
	target_pos = current_node.position
	wait_time = current_node.wait_time
	match current_node.type:
		CatPathNode.Type.pounce:
			pounce()
		CatPathNode.Type.drop:
			velocity.x = 0
			state = CatState.drop
		CatPathNode.Type.preclimb:
			climb_setup()
		CatPathNode.Type.climb:
			climb()
		CatPathNode.Type.wait_for_player:
			if !current_node.player_detected:
				sprite.flip_h = !sprite.flip_h
				sprite.play("crouch")
				state = CatState.stop
			else:
				wait_time = 0
				wait()
	
	current_path_index += 1

func complete():
	Game.in_chase = false
	Game.completed_chases.append(id)
	Game.save_to_file()
	MusicPlayer.fade_to_song(default_music, end_music_fade_time)
	chase_complete.emit()
	queue_free()
