extends "res://pixel_art_2d.gd"

const TRACKS := [
	preload("res://art/audio/music-title.ogg"),
	preload("res://art/audio/music-level.ogg"),
]
const TRACK_NAMES := ["Title Screen", "Level 1"]
const LOOP_MUSIC := true
const VOLUME_STEP := 3.0
const QUIETEST := -30.0

var music := AudioStreamPlayer.new()
var track := 0
var info: Label

func _ready() -> void:
	backdrop()
	terrain(self, Vector2(384, 391), Vector2(768, 82))
	var dancer := strip(self, FROG_RUN, 32)
	dancer.position = Vector2(384, 286)
	dancer.scale = Vector2(4, 4)
	add_child(music)
	info = label_at(Vector2(18, 12), "")
	play_track(0)

func play_track(index: int) -> void:
	track = index
	var stream: AudioStreamOggVorbis = TRACKS[index]
	# Without loop, the player stops when it reaches the end of the file.
	stream.loop = LOOP_MUSIC
	music.stream = stream
	music.play()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("right"):
		play_track(posmod(track + 1, TRACKS.size()))
	if Input.is_action_just_pressed("left"):
		play_track(posmod(track - 1, TRACKS.size()))
	if Input.is_action_just_pressed("action"):
		music.stream_paused = not music.stream_paused
	if Input.is_action_just_pressed("up"):
		music.volume_db = minf(music.volume_db + VOLUME_STEP, 0.0)
	if Input.is_action_just_pressed("down"):
		music.volume_db = maxf(music.volume_db - VOLUME_STEP, QUIETEST)
	show_info()

func show_info() -> void:
	var state := "Playing"
	if music.stream_paused:
		state = "Paused"
	elif not music.playing:
		state = "Stopped"
	info.text = "%s: %s  %s / %s\nVolume: %.0f dB   Loop: %s\nLeft/Right: change track   Up/Down: volume   Space: pause" % [
		state, TRACK_NAMES[track], clock(music.get_playback_position()),
		clock(music.stream.get_length()), music.volume_db, "on" if LOOP_MUSIC else "off"]

func clock(seconds: float) -> String:
	return "%d:%02d" % [floori(seconds / 60.0), int(seconds) % 60]
