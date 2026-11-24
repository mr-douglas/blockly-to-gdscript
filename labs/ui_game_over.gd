extends "res://ui_health.gd"

const RESTART_ICON := preload("res://art/pixel/button-restart.png")

var game_over_panel: PanelContainer

func _ready() -> void:
	super._ready()
	style_theme()
	# The menus must keep working while the rest of the game is paused.
	ui.process_mode = Node.PROCESS_MODE_ALWAYS
	game_over_panel = make_panel("Game over", "You ran out of hearts.", "Try again", RESTART_ICON, restart)

func out_of_health() -> void:
	completed = true
	show_panel(game_over_panel)

func show_panel(panel: PanelContainer) -> void:
	panel.show()
	get_tree().paused = true
	# Focus lets Enter or Space press the button as well as the mouse.
	panel.get_node("Column/Button").grab_focus()

func restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

## A centred panel with a title, a message and one button.
func make_panel(title: String, message: String, button_text: String, icon: Texture2D,
		on_pressed: Callable) -> PanelContainer:
	var panel := PanelContainer.new()
	var column := VBoxContainer.new()
	column.name = "Column"
	column.add_theme_constant_override("separation", 12)
	panel.add_child(column)

	var heading := Label.new()
	heading.name = "Title"
	heading.text = title
	heading.add_theme_font_size_override("font_size", 64)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(heading)

	var body := Label.new()
	body.name = "Message"
	body.text = message
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(body)

	var button := Button.new()
	button.name = "Button"
	button.text = button_text
	button.icon = icon
	button.expand_icon = true
	button.custom_minimum_size = Vector2(240, 60)
	button.pressed.connect(on_pressed)
	column.add_child(button)

	ui.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.hide()
	return panel

## Give panels and buttons rounded, coloured backgrounds.
func style_theme() -> void:
	ui_theme.set_stylebox("panel", "PanelContainer", rounded_box(Color("#262b44"), 28))
	ui_theme.set_stylebox("normal", "Button", rounded_box(Color("#3e8948"), 12))
	ui_theme.set_stylebox("hover", "Button", rounded_box(Color("#63c74d"), 12))
	ui_theme.set_stylebox("pressed", "Button", rounded_box(Color("#265c42"), 12))
	var focus := rounded_box(Color.TRANSPARENT, 12)
	focus.draw_center = false
	focus.set_border_width_all(3)
	focus.border_color = Color.WHITE
	ui_theme.set_stylebox("focus", "Button", focus)

func rounded_box(color: Color, padding: float) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(8)
	box.set_content_margin_all(padding)
	return box
