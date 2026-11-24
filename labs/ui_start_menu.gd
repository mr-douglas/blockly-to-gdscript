extends "res://ui_game_over.gd"

const PLAY_ICON := preload("res://art/pixel/button-play.png")

var start_menu: PanelContainer

func _ready() -> void:
	super._ready()
	var how_to_play := "Collect %d coins, then reach the trophy.\nArrows move. Space jumps." % REQUIRED_COINS
	start_menu = make_panel("Frog Run", how_to_play, "Play", PLAY_ICON, start_game)
	# The game waits, paused, until the player presses Play.
	show_panel(start_menu)

func start_game() -> void:
	start_menu.hide()
	get_tree().paused = false
