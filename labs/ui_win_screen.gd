extends "res://ui_start_menu.gd"

var run_time := 0.0
var win_panel: PanelContainer

func _ready() -> void:
	super._ready()
	win_panel = make_panel("You win!", "", "Play again", RESTART_ICON, restart)

func _physics_process(delta: float) -> void:
	# _physics_process does not run while the game is paused, so the menu
	# time is not counted.
	run_time += delta
	super._physics_process(delta)

func _on_goal_entered(body: Node2D) -> void:
	super._on_goal_entered(body)
	if completed and body == player:
		win()

func win() -> void:
	var message: Label = win_panel.get_node("Column/Message")
	message.text = "Coins: %d\nHearts left: %d\nTime: %.1f seconds" % [coins, health, run_time]
	show_panel(win_panel)
