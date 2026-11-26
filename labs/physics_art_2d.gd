extends "res://scene_2d.gd"

# Shared art for the 2D physics lessons. The images are from Physics Assets by
# Kenney (CC0). art/physics2d/fetch.sh downloads them, and runner/build.sh runs
# it when the website is built. The helpers below only draw things: each lesson
# makes its own bodies and collision shapes.
const BACKGROUND := preload("res://art/physics2d/background.png")
const GRASS := preload("res://art/physics2d/grass.png")
const DIRT := preload("res://art/physics2d/dirt.png")
# Square, plank (wide) and post (tall) pieces for each material.
const BLOCKS := {
	"wood": [preload("res://art/physics2d/wood-square.png"),
		preload("res://art/physics2d/wood-plank.png"), preload("res://art/physics2d/wood-post.png")],
	"stone": [preload("res://art/physics2d/stone-square.png"),
		preload("res://art/physics2d/stone-plank.png"), preload("res://art/physics2d/stone-post.png")],
}
const ALIENS := {
	"green": preload("res://art/physics2d/alien-green.png"),
	"pink": preload("res://art/physics2d/alien-pink.png"),
}
## The y position of the top of the ground.
const FLOOR_Y := 380.0
const TILE := 70.0

## Sky and hills behind everything.
func backdrop() -> void:
	var art := TextureRect.new()
	art.texture = BACKGROUND
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_SCALE
	art.size = Vector2(768, 768)
	art.position = Vector2(0, FLOOR_Y + 40 - 768)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(art)

## A solid, grass-topped ground along the bottom of the screen.
func ground() -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = Vector2(384, FLOOR_Y + 100)
	add_box(body, Vector2(2000, 200))
	add_child(body)
	tiles(GRASS, Rect2(-TILE, FLOOR_Y, 768 + 2 * TILE, TILE))
	tiles(DIRT, Rect2(-TILE, FLOOR_Y + TILE, 768 + 2 * TILE, TILE))
	return body

func tiles(tile: Texture2D, area: Rect2) -> void:
	var art := TextureRect.new()
	art.texture = tile
	art.stretch_mode = TextureRect.STRETCH_TILE
	art.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	art.position = area.position
	art.size = area.size
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(art)

## Draw a wood or stone block on `body`, stretched to `size` pixels. Wide
## sizes use a plank, tall sizes use a post, and the rest use a square.
func block_art(body: Node2D, size: Vector2, material := "wood") -> Sprite2D:
	var pieces: Array = BLOCKS[material]
	var texture: Texture2D = pieces[0]
	if size.x > size.y * 1.8:
		texture = pieces[1]
	elif size.y > size.x * 1.8:
		texture = pieces[2]
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.scale = size / texture.get_size()
	body.add_child(sprite)
	return sprite

## Draw an alien `radius` pixels across from its centre to its edge.
func alien_art(body: Node2D, radius: float, colour := "green") -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = ALIENS[colour]
	sprite.scale = Vector2.ONE * (2.0 * radius / sprite.texture.get_width())
	body.add_child(sprite)
	return sprite

## Labels get a dark outline so they are easy to read on the sky.
func label_at(at: Vector2, text: String, size: int = 20) -> Label:
	var label := super.label_at(at, text, size)
	label.add_theme_color_override(&"font_outline_color", Color("#1b2142"))
	label.add_theme_constant_override(&"outline_size", 6)
	return label
