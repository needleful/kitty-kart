extends Cart

export(float) var max_throttle: float = 1.0
export(float) var velocity_slow: float = 7.0
export(float) var velocity_slow_brake: float = 25
export(float) var min_throttle_slow: float = 0.1
export(float) var throttle_reverse: float = -0.5
export(float) var slow_slide: float = 1

export(float) var avoidance: float = 0.5
export(float) var avoidance_radius: float = 3.0

export(float) var cutoff: float = 0.5
export(float) var cutoff_radius: float = 3.0

var reversing: bool = false
var dir: Vector3
var slow:bool = false

onready var groundCast:RayCast = $groundCast
onready var avoidance_area:Area = $avoidance_area

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
			if slow:
				var speed = linear_velocity.length()
				if speed < velocity_slow:
					throttle = max(0.5, throttle)
				else:
					var vel_effect = velocity_slow/speed
					throttle = clamp(throttle*vel_effect, min_throttle_slow, 1)
			else:
				throttle = max(0.5, throttle)
	else:
		if throttle > 0:
			reversing = false
		else:
			throttle = -1
	return throttle*max_throttle

func get_steer():
	if !reversing:
		var base = dir.dot(global_transform.basis.x)
		for c in avoidance_area.get_overlapping_bodies():
			var n = c.global_transform.origin - global_transform.origin
			if n.dot(global_transform.basis.z) < 0:
				var a = n*avoidance_radius/(1+ n.length_squared())
				base += (avoidance*a).dot(global_transform.basis.x)
			else:
				var b = n/cutoff_radius
				base += (cutoff*b).dot(-global_transform.basis.x)
		return clamp(base*steer_angle, -steer_angle, steer_angle)
	else:
		return steer_angle

func get_brake():
	if slow and linear_velocity.length_squared() > velocity_slow_brake*velocity_slow_brake:
		return slow_slide
	else:
		return 0.0
		

func set_slow(s):
	slow = s

func apply_params(p):
	for k in p.keys:
		set(k, p[k])
		assert(self[k] == p[k])

func get_params():
	var n = NPC_Params.new()
	for k in n.keys:
		n[k] = get(k)
	return n
