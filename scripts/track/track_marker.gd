extends Area

export (NodePath) var next_marker


func _on_marker_body_entered(body):
	if body.has_method("mark_next"):
		body.mark_next(self, get_node(next_marker))
