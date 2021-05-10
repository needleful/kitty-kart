extends VehicleBody
class_name Cart

signal mark_crossed(cart)

export(String) var racer_name
export (NodePath) var target_node
export (PackedScene) var starting_weapon

export(float) var horsepower: float = 250.0
export(float) var steer_angle:float = PI/5
export(float) var slide_brake:float = 10.0

onready var target:Spatial
onready var wheels = [$wheel_bl, $wheel_br, $wheel_fl, $wheel_fr]

onready var last_good_pos:Vector3 = global_transform.origin

var weapon: Node

var flipped_time = 0
var time_to_reset = 3

var lap = 0
var markers = 0

var pitch_shift_min = 1
var pitch_shift_max = 5.5

var speed_factor = 60
var throttle_min_factor = 0.3

var possible_shortcut = null

onready var engine_audio:AudioStreamPlayer3D = $engine_audio

func _ready():
	engine_audio.play(randf()*0.2)
	if target_node:
		target = get_node(target_node)
	if starting_weapon:
		set_weapon(starting_weapon)

func cam_target() -> Vector3:
	return $cam_target.global_transform.origin

func set_target(p_target:Spatial):
	target = p_target
	last_good_pos = global_transform.origin

func mark_next(current:Spatial, p_target:Spatial):
	if current == target or current == possible_shortcut:
		target = p_target
		last_good_pos = current.global_transform.origin
		markers += 1
		var s = current.get_shortcut()
		if s:
			possible_shortcut = s
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
	var pi = clamp((abs(throttle) + throttle_min_factor)*linear_velocity.length()/speed_factor, 0, 1)
	engine_audio.pitch_scale = lerp(pitch_shift_min, pitch_shift_max, pi)

	engine_force = throttle*horsepower
	steering = steer*steer_angle
	for wheel in wheels:
		wheel.brake = slide*slide_brake

	if global_transform.origin.y < 0 or global_transform.origin.y > 1000:
		reset(last_good_pos+ Vector3.UP)
	if global_transform.basis.y.y < 0:
		flipped_time += delta
		if flipped_time > time_to_reset:
			reset(global_transform.origin + Vector3.UP*5)
	else:
		flipped_time = 0

func reset(pos: Vector3):
	global_transform.origin = pos
	if target:
		global_transform = global_transform.looking_at(target.global_transform.origin, Vector3.UP)
	linear_velocity = Vector3.DOWN
	angular_velocity = Vector3.ZERO
	sleeping = false

func set_weapon(wep: PackedScene):
	weapon = wep.instance()
	$weapon_slot.add_child(weapon)
	var _x = weapon.connect("range_entered", self, "on_range_entered")

func on_range_entered(_x):
	pass

func next_lap():
	lap += 1
	markers = 1
	possible_shortcut = null
