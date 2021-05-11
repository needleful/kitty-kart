extends Area

signal crossed(racer)

export(bool) var mandatory = false

export (NodePath) var next_marker
export (NodePath) var next_mandatory_marker

onready var next = get_node(next_marker)

func _on_marker_body_entered(body):
	if body.has_method("mark_next"):
		emit_signal("crossed", body)
		var man_next = null
		if has_node(next_mandatory_marker):
			man_next = get_node(next_mandatory_marker)
		body.mark_next(self, next, man_next)
