extends "res://ui_hud.gd"

const HEART_FULL := preload("res://art/ui/heart-full.png")
const HEART_EMPTY := preload("res://art/ui/heart-empty.png")
const MAX_HEALTH := 3
const SCREEN_BOTTOM := 432.0

var health := MAX_HEALTH
var hearts := HBoxContainer.new()

func _ready() -> void:
	super._ready()
	for i in MAX_HEALTH:
		var heart := TextureRect.new()
		heart.custom_minimum_size = Vector2(36, 36)
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hearts.add_child(heart)
	ui.add_child(hearts)
	hearts.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE, 16)
	update_hearts()

func update_hearts() -> void:
	for i in hearts.get_child_count():
		var heart: TextureRect = hearts.get_child(i)
		heart.texture = HEART_FULL if i < health else HEART_EMPTY

func on_hazard(body: Node2D) -> void:
	if body == player and not completed:
		lose_heart.call_deferred()

func lose_heart() -> void:
	if completed:
		return
	health -= 1
	update_hearts()
	# Flash the player red, then fade back to normal over half a second.
	player.modulate = Color(1, 0.3, 0.3)
	create_tween().tween_property(player, "modulate", Color.WHITE, 0.5)
	if health > 0:
		respawn()
	else:
		out_of_health()

func out_of_health() -> void:
	completed = true
	status.text = "Out of hearts! Press R to try again."
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	# Falling off the bottom of the screen also costs a heart.
	if player.position.y > SCREEN_BOTTOM:
		lose_heart()
	super._physics_process(delta)
