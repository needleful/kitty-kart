extends Area

export(float) var radius

func _ready():
	var _x = connect("body_exited", self, "on_exit")

func _physics_process(_delta):
	for body in get_overlapping_bodies():
		if body.has_method("set_temp_target"):
			if body.target:
				var o = body.global_transform.origin
				var center = global_transform.origin - o
				var target = (body.target.global_transform.origin - o).normalized()
				
				var z = body.global_transform.basis.z
				if center.dot(z)*target.dot(z) < 0:
					body.set_temp_target(Vector3.ZERO, priority)
					return
				else:
					var inner_r = center.length()
					var r = clamp(inner_r/radius, 0, 1)
					var b_out = -center.normalized()*radius + global_transform.origin
					# Interpolate between directly backing up and going past based on
					# how far from the center of the obstacle the cart is
					var n: Vector3 = b_out.linear_interpolate(target*radius + o, r)
					body.set_temp_target(n, priority)

func on_exit(body):
	if body.has_method("set_temp_target"):
		body.set_temp_target(Vector3.ZERO, priority)
