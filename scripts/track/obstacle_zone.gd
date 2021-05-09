extends Area

export(float) var radius

func _ready():
	var _x = connect("body_exited", self, "on_exit")

func _physics_process(_delta):
	for body in get_overlapping_bodies():
		if body.has_method("set_temp_target"):
			if body.target:
				var b_out = body.global_transform.origin - global_transform.origin
				b_out.y = 0
				var t_out = body.target.global_transform.origin - global_transform.origin
				t_out.y = 0
				var r = b_out.length_squared()/(radius*radius)
				# Interpolate between directly backing up and going past based on
				# how far from the center of the obstacle the cart is
				b_out = b_out.normalized()
				t_out = t_out.normalized()
				
				var n: Vector3 = b_out.linear_interpolate(t_out, r).normalized()
				
				body.set_temp_target(global_transform.origin + n*radius)

func on_exit(body):
	if body.has_method("set_temp_target"):
		body.set_temp_target(Vector3.ZERO)
