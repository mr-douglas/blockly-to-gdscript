extends "res://scene_2d.gd"

const IDLE_SHEET := preload("res://art/frog-idle.png")
const RUN_SHEET := preload("res://art/frog-run.png")
const FRAME_SIZE := Vector2i(32, 32)
const RUN_FPS := 14.0
const MOVE_SPEED := 170.0

var frog := AnimatedSprite2D.new()
var status: Label

func _ready() -> void:
	rectangle(self, Vector2(384, 216), Vector2(768, 432), Color("#164b58"))
	rectangle(self, Vector2(384, 362), Vector2(768, 140), Color("#396a68"))
	frog.sprite_frames = SpriteFrames.new()
	frog.sprite_frames.remove_animation("default")
	add_strip(&"idle", IDLE_SHEET, 10.0)
	add_strip(&"run", RUN_SHEET, RUN_FPS)
	frog.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	frog.position = Vector2(384, 237)
	frog.scale = Vector2(5, 5)
	add_child(frog)
	status = label_at(Vector2(20, 12), "")
	play_clip(&"idle")

func add_strip(animation: StringName, sheet: Texture2D, fps: float) -> void:
	var frames := frog.sprite_frames
	frames.add_animation(animation)
	frames.set_animation_speed(animation, fps)
	frames.set_animation_loop(animation, true)
	var columns := int(float(sheet.get_width()) / FRAME_SIZE.x)
	for column in range(columns):
		var frame := AtlasTexture.new()
		frame.atlas = sheet
		frame.region = Rect2(Vector2(column * FRAME_SIZE.x, 0), Vector2(FRAME_SIZE))
		frame.filter_clip = true
		frames.add_frame(animation, frame)

func play_clip(animation: StringName) -> void:
	if frog.animation != animation or not frog.is_playing():
		frog.play(animation)
		status.text = "Clip: %s · Hold Left or Right" % animation

func _process(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	if direction != 0.0:
		frog.flip_h = direction < 0.0
		frog.position.x = clampf(frog.position.x + direction * MOVE_SPEED * delta, 64, 704)
	play_clip(&"run" if direction != 0.0 else &"idle")
