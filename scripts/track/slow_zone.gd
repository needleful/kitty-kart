extends Area

func _ready():
	var _x = connect("body_entered", self, "on_body_entered")
	_x = connect("body_exited", self, "on_body_exited")

func on_body_entered(body):
	if body.has_method("set_slow"):
		body.set_slow(true)

func on_body_exited(body):
	if body.has_method("set_slow"):
		body.set_slow(false)
