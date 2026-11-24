extends Node2D

func rectangle(parent: Node, at: Vector2, size: Vector2, color: Color) -> void:
	var art := Polygon2D.new()
	var half := size / 2
	art.polygon = PackedVector2Array([-half, Vector2(half.x, -half.y), half, Vector2(-half.x, half.y)])
	art.color = color
	art.position = at
	parent.add_child(art)

func wall(at: Vector2, size: Vector2, color: Color) -> void:
	var body := StaticBody2D.new()
	body.position = at
	rectangle(body, Vector2.ZERO, size, color)
	add_box(body, size)
	add_child(body)

func add_box(body: CollisionObject2D, size: Vector2) -> void:
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)

func label_at(at: Vector2, text: String, size: int = 20) -> Label:
	var label := Label.new()
	label.position = at
	label.text = text
	label.add_theme_font_size_override(&"font_size", size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label
