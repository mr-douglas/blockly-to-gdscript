extends "res://racing_shared_camera.gd"

const LAPS_TO_WIN := 2
const GATE_COUNT := 4
var next_gate := [0, 0]
var laps := [0, 0]
var winner := -1
var score: Label

func _ready() -> void:
	super._ready()
	# Gates are placed by how far round the lap they are: 0.25 is a quarter lap.
	add_gate(0, 0.25)
	add_gate(1, 0.5)
	add_gate(2, 0.75)
	add_gate(3, 0.0)  # The finish line.
	score = label("")
	score.position.y = 44
	refresh_score()

func add_gate(index: int, lap_fraction: float) -> void:
	var gate := Area3D.new()
	gate.transform = track_frame(lap_fraction)
	gate.position.y = 0.035
	gate.collision_layer = 0
	var shape := BoxShape3D.new()
	shape.size = Vector3(ROAD_WIDTH + 2.0 * KERB_WIDTH, 1.0, 0.4)
	add_shape(gate, shape)
	gate.body_entered.connect(register_gate.bind(index))
	add_child(gate)
	if index < GATE_COUNT - 1:
		var strip := BoxMesh.new()
		strip.size = Vector3(ROAD_WIDTH, 0.02, 0.3)
		add_mesh(gate, strip, Color("#5fe0a8"))

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
		score.text = "Laps · Orange %d / %d    Green %d / %d" % [laps[0], LAPS_TO_WIN, laps[1], LAPS_TO_WIN]
	else:
		score.text = "%s wins! Press R to race again." % ("Orange" if winner == 0 else "Green")

func _physics_process(delta: float) -> void:
	if winner == -1:
		super._physics_process(delta)
