extends VehicleBody
class_name Cart

signal mark_crossed(cart)

export(String) var racer_name
export (NodePath) var target_node

export(float) var horsepower: float = 300.0
export(float) var steer_angle:float = PI/5
export(float) var slide_brake:float = 10.0

onready var target:Spatial = get_node(target_node)
onready var wheels = [$wheel_bl, $wheel_br, $wheel_fl, $wheel_fr]

onready var last_good_pos:Vector3 = global_transform.origin

var flipped_time = 0
var time_to_reset = 3

var lap = 0
var markers = 0

func cam_target() -> Vector3:
	return $cam_target.global_transform.origin

func set_target(p_target:Spatial):
	target = p_target
	last_good_pos = global_transform.origin

func mark_next(current:Spatial, p_target:Spatial):
	if target == current:
		target = p_target
		last_good_pos = current.global_transform.origin
		markers += 1
		emit_signal("mark_crossed", self)

func get_throttle() -> float:
	return 0.0

func get_steer() -> float:
	return 0.0

func get_slide() -> float:
	return 0.0

func _physics_process(delta):
	var throttle = get_throttle()
	var steer = get_steer()
	var slide = get_slide()
	
	engine_force = throttle*horsepower
	steering = steer*steer_angle
	for wheel in wheels:
		wheel.brake = slide*slide_brake

	if global_transform.origin.y < 0:
		reset(last_good_pos+ Vector3.UP)
	if global_transform.basis.y.y < 0:
		flipped_time += delta
		if flipped_time > time_to_reset:
			reset(global_transform.origin + Vector3.UP*5)
	else:
		flipped_time = 0

func reset(pos: Vector3):
	global_transform.origin = pos
	global_transform = global_transform.looking_at(target.global_transform.origin, Vector3.UP)
	apply_central_impulse(-linear_velocity*mass/2)
