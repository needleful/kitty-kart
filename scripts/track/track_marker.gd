extends Area

signal crossed(racer)

export(bool) var mandatory = false

export (NodePath) var next_marker
export (NodePath) var next_mandatory_marker
export (NodePath) var next_shortcut

onready var next = get_node(next_marker)
onready var next_mandatory setget set_mandatory, get_mandatory

func _ready():
	if mandatory:
		assert(has_node(next_mandatory_marker))

func _on_marker_body_entered(body):
	if body.has_method("mark_next"):
		emit_signal("crossed", body)
		body.mark_next(self)

func has_shortcut():
	return has_node(next_shortcut)

func shortcut():
	return get_node(next_shortcut)

func get_mandatory():
	 return get_node(next_mandatory_marker)

func set_mandatory(_v):
	pass
