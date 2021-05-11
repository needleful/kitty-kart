extends Area

signal crossed

export (NodePath) var next_marker
export (NodePath) var short_marker

onready var next = get_node(next_marker)

func _on_marker_body_entered(body):
	if body.has_method("mark_next"):
		emit_signal("crossed")
		body.mark_next(self, get_node(next_marker))

func get_shortcut():
	if short_marker:
		return get_node(short_marker)
	else:
		return null
