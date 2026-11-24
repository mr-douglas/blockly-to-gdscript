extends "res://racing_shared_camera.gd"

const LAPS_TO_WIN := 2
const GATE_COUNT := 4
var next_gate := [0, 0]
var laps := [0, 0]
var winner := -1
var score: Label

func _ready() -> void:
	super._ready()
	add_gate(0, Vector3(0, 0.3, -3.58), Vector3(0.38, 0.95, 2.7))
	add_gate(1, Vector3(6.04, 0.3, 0), Vector3(3.0, 0.95, 0.38))
	add_gate(2, Vector3(0, 0.3, 3.58), Vector3(0.38, 0.95, 2.7))
	add_gate(3, Vector3(-6.04, 0.3, 2.45), Vector3(3.0, 0.95, 0.38))
	score = label("")
	score.position.y = 44
	refresh_score()

func add_gate(index: int, at: Vector3, size: Vector3) -> void:
	var gate := Area3D.new()
	gate.position = at
	gate.collision_layer = 0
	var shape := BoxShape3D.new()
	shape.size = size
	add_shape(gate, shape)
	gate.body_entered.connect(register_gate.bind(index))
	add_child(gate)
	if index < GATE_COUNT - 1:
		paint(Vector3(at.x, 0.03, at.z), Vector3(size.x, 0.03, size.z), Color("#85dbb4"))

func register_gate(body: Node3D, index: int) -> void:
	var racer := [car_a, car_b].find(body)
	if winner != -1 or racer == -1 or index != next_gate[racer]:
		return
	next_gate[racer] += 1
	if next_gate[racer] == GATE_COUNT:
		next_gate[racer] = 0
		laps[racer] += 1
		if laps[racer] == LAPS_TO_WIN:
			winner = racer
	refresh_score()

func refresh_score() -> void:
	if winner == -1:
		score.text = "Laps · Gold %d / %d    Blue %d / %d" % [laps[0], LAPS_TO_WIN, laps[1], LAPS_TO_WIN]
	else:
		score.text = "%s wins! Press R to race again." % ("Gold" if winner == 0 else "Blue")

func _physics_process(delta: float) -> void:
	if winner == -1:
		super._physics_process(delta)
