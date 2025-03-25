extends AudioStreamPlayer

var mute := false

@onready var default_volume := volume_db
var mute_volume: float = -60
var transition_volume: float = -30

var fade_rate: float
var fade_target: float
var fading: bool = false

signal fade_complete

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func fade_to(time: float, volume: float):
	fade_rate = absf(volume - volume_db) / time
	fade_target = volume
	fading = true

func fade_by(time: float, volume: float):
	fade_rate = volume / time
	fade_target = volume_db + volume
	fading = true

func fade_out(time: float):
	fade_rate = absf(mute_volume + volume_db) / time
	fade_target = mute_volume
	fading = true
	mute = true

func fade_in(time: float):
	if !playing: play()
	if volume_db < transition_volume: volume_db = transition_volume
	fade_rate = absf(default_volume - volume_db) / time
	fade_target = default_volume
	fading = true
	mute = false

func switch_song(new_song: AudioStream):
	if stream == new_song: return
	stream = new_song
	play(0)

func fade_to_song(new_song: AudioStream, time: float):
	#fade_complete.emit()
	if stream == new_song: return
	fade_to(time / 2, transition_volume)
	await fade_complete
	switch_song(new_song)
	fade_in(time / 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if !fading: return
	
	if volume_db < fade_target:
		volume_db += delta * fade_rate
		if volume_db > fade_target:
			volume_db = fade_target
			fading = false
			fade_complete.emit()
	
	if volume_db > fade_target:
		volume_db -= delta * fade_rate
		if volume_db < fade_target:
			volume_db = fade_target
			fading = false
			fade_complete.emit()
	
	if volume_db == fade_target:
		fading = false
		fade_complete.emit()
