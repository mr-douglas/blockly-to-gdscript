extends "res://scene_3d.gd"

const KNIGHT := preload("res://art/knight.glb")
const IDLE := &"HumanArmature|Idle"
const WALK := &"HumanArmature|Walking"
const PLAYBACK_RATE := 1.0
const MOVE_SPEED := 2.0

var knight: Node3D
var animator: AnimationPlayer
var status: Label

func _ready() -> void:
	stage(Vector3(3, 4, 8), Vector3(0, 1.15, 0), 5.6)
	block(Vector3(0, -0.15, 0), Vector3(8, 0.3, 4.5), Color("#487a86"))
	knight = KNIGHT.instantiate()
	knight.scale = Vector3.ONE * 0.42
	add_child(knight)
	animator = knight.get_node("AnimationPlayer")
	animator.get_animation(IDLE).loop_mode = Animation.LOOP_LINEAR
	animator.get_animation(WALK).loop_mode = Animation.LOOP_LINEAR
	status = label("")
	play_clip(IDLE)

func play_clip(wanted: StringName) -> void:
	if animator.current_animation != wanted:
		animator.play(wanted, 0.18, PLAYBACK_RATE)
		status.text = "Clip: %s · Hold Left or Right" % wanted.get_slice("|", 1)

func _process(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	if direction != 0:
		knight.rotation.y = direction * PI / 2.0
		knight.position.x = clampf(knight.position.x + direction * MOVE_SPEED * delta, -2.6, 2.6)
	play_clip(WALK if direction != 0 else IDLE)
