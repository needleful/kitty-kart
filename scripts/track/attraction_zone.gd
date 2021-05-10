extends Area

func _ready():
	var _x = connect("body_exited", self, "on_exit")

func _physics_process(_delta):
	for body in get_overlapping_bodies():
		if body.has_method("set_temp_target"):
			if body.target:
				var o = body.global_transform.origin
				var center = global_transform.origin - o
				var target = body.target.global_transform.origin - o
				var z = body.global_transform.basis.z
				if center.dot(-z)*target.dot(-z) > 0:
					body.set_temp_target(o + center, priority)
				else:
					body.set_temp_target(Vector3.ZERO, priority)

func on_exit(body):
	if body.has_method("set_temp_target"):
		body.set_temp_target(Vector3.ZERO)
