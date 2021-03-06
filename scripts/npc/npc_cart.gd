extends Cart

export(bool) var early_start = false
export(int) var cheat_lap = 256

export(float) var base_throttle: float = 0.6
export(float) var place_throttle_bonus: float = 0.25
export(float) var velocity_slow: float = 10.0
export(float) var velocity_slow_brake: float = 25
export(float) var min_throttle_slow: float = 0.1
export(float) var throttle_reverse: float = -0.3
export(float) var slow_slide: float = 1

export(float) var avoidance: float = 0.1
export(float) var avoidance_radius: float = 1.5
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
onready var anim = $body/AnimationTree

var max_throttle = base_throttle

var timer_no_progress = 0
var min_velocity = 1.0
var time_stopped_reset = 2.5
var in_dir = Vector2.ZERO


func _physics_process(delta):
	time_since_last_fired += delta
	if target:
		if linear_velocity.length() < min_velocity:
			timer_no_progress += delta
			if timer_no_progress > time_stopped_reset:
				timer_no_progress = -5
				reset(last_good_pos)
		else:
			timer_no_progress = 0
	var turn_blend = anim["parameters/turn/blend_position"]
	anim["parameters/turn/blend_position"] = turn_blend.linear_interpolate(in_dir, 0.1)

func update_target():
	if !target:
		return
	if temp_target != Vector3.ZERO:
		target_pos = temp_target
	else:
		target_pos = target.global_transform.origin
	dir = (target_pos - global_transform.origin).normalized()
	
	for racer in avoidance_area.get_overlapping_bodies():
		if racer != self:
			var diff = racer.global_transform.origin - global_transform.origin
			var c = -diff.slide(global_transform.basis.z).normalized()
			var q = clamp(avoidance_radius/(diff.length() + 0.0001), 0, avoidance_sensitivity)
			dir += c*q
	if $wallray.is_colliding():
		dir = global_transform.basis.z*6
	dir = dir.normalized()
	$MeshInstance.global_transform.origin = global_transform.origin + dir*4

func get_throttle():
	update_target()
	if !target or !groundCast.is_colliding():
		return 0.0
	var throttle: float = dir.dot(-global_transform.basis.z)
	in_dir.y = throttle
	if !reversing:
		if throttle < throttle_reverse:
			reversing = true
		else:
			var speed = linear_velocity.length()
			if slow:
				if speed < velocity_slow:
					throttle = max(throttle, 0.5)
				else:
					var vel_effect = velocity_slow/speed
					throttle = clamp(throttle*vel_effect, min_throttle_slow, 1)
			else:
				if speed < velocity_slow:
					throttle = 1
				else:
					throttle = max(0.5, throttle)
	else:
		if throttle > 0:
			reversing = false
		else:
			return -1
	return throttle*max_throttle

func on_rank(i):
	max_throttle = base_throttle + place_throttle_bonus*i

func get_steer():
	if !reversing:
		var base = dir.dot(-global_transform.basis.x)
		in_dir.x = -base
		return clamp(base*steer_angle*turn_aggression, -steer_angle, steer_angle)
	else:
		in_dir.x = -1
		return steer_angle

func get_slide():
	if !target:
		return 1.0
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

func should_shortcut():
	return lap >= cheat_lap

func on_range_entered(_enemy):
	if time_since_last_fired > fire_pause:
		time_since_last_fired = 0
		if weapon and !weapon.fire(self):
			weapon.queue_free()
			weapon = null
	
