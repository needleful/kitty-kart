extends Cart

export(float) var max_throttle: float = 1.0
export(float) var velocity_slow: float = 7.0
export(float) var velocity_slow_brake: float = 25
export(float) var min_throttle_slow: float = 0.1
export(float) var throttle_reverse: float = -0.5
export(float) var slow_slide: float = 1

export(float) var avoidance: float = 0.1
export(float) var avoidance_radius: float = 1.0
export(float) var avoidance_sensitivity:float = 1.5

export(float) var velocity_brake: float = -5
export(float) var turn_aggression: float = 1.0

export(float) var fire_pause = 1.0
var time_since_last_fired = 0
var reversing: bool = false
var slow:bool = false
var temp_target:Vector3 = Vector3.ZERO setget set_temp_target
var temp_priority: int = 0
var target_pos: Vector3
var dir: Vector3

onready var groundCast:RayCast = $groundCast
onready var avoidance_area:Area = $avoidance_area

var timer_no_progress = 0
var min_velocity = 3.0

func _physics_process(delta):
	time_since_last_fired += delta
	if target:
		if linear_velocity.length() < min_velocity:
			timer_no_progress += delta
			if timer_no_progress > time_to_reset:
				timer_no_progress = -5
				reset(last_good_pos)
		else:
			timer_no_progress = 0

func update_target():
	if !target:
		return
	if temp_target != Vector3.ZERO:
		target_pos = temp_target
	else:
		target_pos = target.global_transform.origin
	dir = (target_pos - global_transform.origin ).normalized()
	
	for racer in avoidance_area.get_overlapping_bodies():
		if racer != self:
			var diff = racer.global_transform.origin - global_transform.origin
			var c = -diff.slide(global_transform.basis.z).normalized()
			var q = clamp(avoidance_radius/(diff.length()), 0, avoidance_sensitivity)
			dir += c*q
	dir = dir.normalized()
	$MeshInstance.transform.origin = dir*4

func get_throttle():
	update_target()
	if !target or !groundCast.is_colliding():
		return 0.0
	var throttle: float = dir.dot(-global_transform.basis.z)
	if !reversing:
		if throttle < throttle_reverse:
			reversing = true
		else:
			if slow:
				var speed = linear_velocity.length()
				if speed < velocity_slow:
					throttle = max(throttle, 0.5)
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
		var base = dir.dot(-global_transform.basis.x)*turn_aggression
		return clamp(base*steer_angle, -steer_angle, steer_angle)
	else:
		return steer_angle

func get_brake():
	if dir.dot(linear_velocity) <= velocity_brake:
		return 1.0
	elif slow and linear_velocity.length_squared() > velocity_slow_brake*velocity_slow_brake:
		return slow_slide
	else:
		return 0.0

func set_temp_target(t, pri = 0):
	temp_target = t
	if t == Vector3.ZERO:
		temp_priority = 0
	else:
		temp_priority = pri

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

func on_range_entered(_enemy):
	if time_since_last_fired > fire_pause:
		time_since_last_fired = 0
		if weapon and !weapon.fire(self):
			weapon.queue_free()
			weapon = null
	
