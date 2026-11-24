extends "res://scene_2d.gd"

# Shared pixel art for the 2D platformer lessons. The images are from
# Pixel Adventure 1 by Pixel Frog (CC0). art/pixel/fetch.sh downloads them,
# and runner/build.sh runs it when the website is built.
# The helpers below only draw things. Each lesson still makes its own bodies,
# areas and collision shapes, so the physics is the same as before.
const FROG_IDLE := preload("res://art/frog-idle.png")
const FROG_RUN := preload("res://art/frog-run.png")
const FROG_JUMP := preload("res://art/pixel/frog-jump.png")
const FROG_FALL := preload("res://art/pixel/frog-fall.png")
const SKY := preload("res://art/pixel/background-blue.png")
const TERRAIN := preload("res://art/pixel/terrain.png")
const APPLE := preload("res://art/pixel/apple.png")
const SPIKES := preload("res://art/pixel/spikes.png")
const SAW := preload("res://art/pixel/saw.png")
const PLANK := preload("res://art/pixel/platform.png")
const TROPHY := preload("res://art/pixel/trophy.png")
const FLAG_EMPTY := preload("res://art/pixel/checkpoint-empty.png")
const FLAG_RAISE := preload("res://art/pixel/checkpoint-raise.png")
const FLAG_WAVE := preload("res://art/pixel/checkpoint-wave.png")

# The grass-topped dirt block in the terrain sheet. Its 16-pixel edges are
# kept and its middle is repeated to fill any size.
const GRASS_BLOCK := Rect2(96, 0, 48, 48)
const EDGE := 16

## Fill the screen with a repeating background tile.
func backdrop() -> void:
	tiled(self, SKY, Vector2(384, 216), Vector2(768, 432))

## A solid block: a StaticBody2D with grass art and a matching collision box.
func block(at: Vector2, size: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = at
	terrain(body, Vector2.ZERO, size)
	add_box(body, size)
	add_child(body)
	return body

## Grass art with no collision shape. On its own it is not solid.
func terrain(parent: Node, at: Vector2, size: Vector2) -> void:
	var art := NinePatchRect.new()
	art.texture = TERRAIN
	art.region_rect = GRASS_BLOCK
	art.patch_margin_left = mini(EDGE, int(size.x / 2))
	art.patch_margin_right = mini(EDGE, int(size.x / 2))
	art.patch_margin_top = mini(EDGE, int(size.y))
	art.patch_margin_bottom = clampi(int(size.y) - EDGE, 0, EDGE)
	art.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE
	art.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_TILE
	place(parent, art, at, size)

## Repeat a small image to cover a rectangle centred on `at`.
func tiled(parent: Node, tile: Texture2D, at: Vector2, size: Vector2) -> void:
	var art := TextureRect.new()
	art.texture = tile
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_TILE
	art.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	place(parent, art, at, size)

func place(parent: Node, art: Control, at: Vector2, size: Vector2) -> void:
	art.size = size
	art.position = at - size / 2
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(art)

## Play a sprite sheet whose frames sit side by side, `frame_width` pixels each.
func strip(parent: Node, sheet: Texture2D, frame_width: int) -> AnimatedSprite2D:
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = SpriteFrames.new()
	add_frames(sprite.sprite_frames, &"default", sheet, frame_width, true)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.play()
	parent.add_child(sprite)
	return sprite

func add_frames(frames: SpriteFrames, animation: StringName, sheet: Texture2D,
		frame_width: int, loop: bool) -> void:
	if not frames.has_animation(animation):
		frames.add_animation(animation)
	frames.set_animation_speed(animation, 20.0)
	frames.set_animation_loop(animation, loop)
	for column in range(sheet.get_width() / frame_width):
		var frame := AtlasTexture.new()
		frame.atlas = sheet
		frame.region = Rect2(column * frame_width, 0, frame_width, sheet.get_height())
		frames.add_frame(animation, frame)

## Wooden planks `size` wide, with their top at the top of `size`.
## The planks are grouped in one Node2D so they can be moved together.
func planks(parent: Node, size: Vector2) -> Node2D:
	var art := Node2D.new()
	var count := maxi(1, ceili(size.x / 32.0))
	for i in range(count):
		var piece := strip(art, PLANK, 32)
		piece.position = Vector2((i - (count - 1) / 2.0) * 32.0, 4.0 - size.y / 2)
	art.scale.x = size.x / (count * 32.0)
	parent.add_child(art)
	return art

## A checkpoint pole standing on the floor. play(&"raise") raises the flag.
func checkpoint_pole(parent: Node) -> AnimatedSprite2D:
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = SpriteFrames.new()
	add_frames(sprite.sprite_frames, &"default", FLAG_EMPTY, 64, false)
	add_frames(sprite.sprite_frames, &"raise", FLAG_RAISE, 64, false)
	add_frames(sprite.sprite_frames, &"wave", FLAG_WAVE, 64, true)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position.y = -18
	sprite.animation_finished.connect(wave_flag.bind(sprite))
	parent.add_child(sprite)
	return sprite

func wave_flag(sprite: AnimatedSprite2D) -> void:
	if sprite.animation == &"raise":
		sprite.play(&"wave")

## Give a body the Ninja Frog. The frog chooses idle, run, jump or fall from
## how the body moves, and turns to face the way it is going.
func frog(body: Node2D) -> AnimatedSprite2D:
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = SpriteFrames.new()
	add_frames(sprite.sprite_frames, &"idle", FROG_IDLE, 32, true)
	add_frames(sprite.sprite_frames, &"run", FROG_RUN, 32, true)
	add_frames(sprite.sprite_frames, &"jump", FROG_JUMP, 32, true)
	add_frames(sprite.sprite_frames, &"fall", FROG_FALL, 32, true)
	sprite.sprite_frames.remove_animation(&"default")
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Move the art up so the frog's feet line up with a 28-pixel-tall box.
	sprite.position.y = -2
	sprite.play(&"idle")
	sprite.set_meta(&"last", body.position)
	body.add_child(sprite)
	get_tree().physics_frame.connect(animate_frog.bind(body, sprite))
	return sprite

func animate_frog(body: Node2D, sprite: AnimatedSprite2D) -> void:
	if not is_instance_valid(body) or not is_instance_valid(sprite):
		return
	# Work out how fast the body moved since the last physics tick. The first
	# lesson changes position directly, so velocity alone is not enough.
	var last: Vector2 = sprite.get_meta(&"last")
	var motion := (body.position - last) * Engine.physics_ticks_per_second
	sprite.set_meta(&"last", body.position)
	var character := body as CharacterBody2D
	if character and character.velocity != Vector2.ZERO:
		motion = character.velocity
	if character and character.is_on_floor():
		motion.y = 0.0
	if absf(motion.x) > 1.0:
		sprite.flip_h = motion.x < 0.0
	var clip := &"idle"
	if motion.y < -30.0:
		clip = &"jump"
	elif motion.y > 30.0 and motion.y < 2000.0:
		clip = &"fall"
	elif absf(motion.x) > 1.0 and absf(motion.x) < 2000.0:
		clip = &"run"
	if sprite.animation != clip:
		sprite.play(clip)

## Labels get a dark outline so they are easy to read on the sky.
func label_at(at: Vector2, text: String, size: int = 20) -> Label:
	var label := super.label_at(at, text, size)
	label.add_theme_color_override(&"font_outline_color", Color("#1b2142"))
	label.add_theme_constant_override(&"outline_size", 6)
	return label
