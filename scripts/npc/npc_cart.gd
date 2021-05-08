extends Cart

export(float) var throttle_reverse: float = -0.5
var reversing: bool = false
var dir: Vector3

onready var groundCast:RayCast = $groundCast

func get_throttle():
	if !groundCast.is_colliding():
		return 0.0

	var target_pos = target.global_transform.origin
	dir = (global_transform.origin - target_pos).normalized()
	var throttle: float = dir.dot(global_transform.basis.z)
	if !reversing:
		if throttle < throttle_reverse:
			reversing = true
		else:
			throttle = max(0.5, throttle)
	else:
		if throttle > 0:
			reversing = false
		else:
			throttle = -0.8
	return throttle

func get_steer():
	if !reversing:
		return dir.dot(global_transform.basis.x)
	else:
		return steer_angle
