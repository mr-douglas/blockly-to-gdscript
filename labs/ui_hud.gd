extends "res://platformer_coin_gate.gd"

const PIXEL_FONT := preload("res://art/ui/kenney-pixel.ttf")
const FONT_SIZE := 32

# A CanvasLayer draws its children on top of the level, and they stay put
# even if a camera moves around the level.
var hud := CanvasLayer.new()
var ui := Control.new()
var ui_theme := Theme.new()
var score_bar := HBoxContainer.new()

func _ready() -> void:
	super._ready()
	add_child(hud)
	# Every Control inside ui uses this Theme unless it overrides a setting.
	ui_theme.default_font = PIXEL_FONT
	ui_theme.default_font_size = FONT_SIZE
	ui.theme = ui_theme
	ui.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(ui)
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Move the two labels from the level into the HUD. Their old font size
	# override would beat the Theme, so remove it.
	for text in [status, coin_label]:
		text.remove_theme_font_size_override("font_size")
	status.reparent(ui)
	status.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	status.position.y = 60
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	build_score_bar()

func build_score_bar() -> void:
	var icon := TextureRect.new()
	var first_frame := AtlasTexture.new()
	first_frame.atlas = APPLE
	first_frame.region = Rect2(0, 0, 32, 32)
	icon.texture = first_frame
	icon.custom_minimum_size = Vector2(48, 48)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	score_bar.add_child(icon)
	coin_label.reparent(score_bar)
	coin_label.text = "%d / %d" % [coins, REQUIRED_COINS]
	ui.add_child(score_bar)
	# Pin the bar to the top-right corner, 16 pixels in from the edges.
	score_bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 16)
	score_bar.grow_horizontal = Control.GROW_DIRECTION_BEGIN

func collect_coin(body: Node2D, coin: Area2D) -> void:
	super.collect_coin(body, coin)
	coin_label.text = "%d / %d" % [coins, REQUIRED_COINS]
