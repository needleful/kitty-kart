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
var mandatory_markers = 0

var pitch_shift_min = 1
var pitch_shift_max = 5.5

var speed_factor = 35
var throttle_min_factor = 0.3
var speed_skid = 2
var speed_downshift = 10
var speed_upshift = 20
var speed_upshift2 = 32
var speed_downshift2 = 24
var gear = 0
var gear_factor = 0.3

var mandatory_next:Spatial = null

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

func mark_next(current:Spatial, p_target:Spatial, p_mandatory:Spatial):
	if current == target or current == mandatory_next and (mandatory_next == current or  mandatory_next == null):
		markers += 1
		if current.mandatory:
			markers = 1
			mandatory_next = p_mandatory
			mandatory_markers += 1
			if current != target and target != null:
				$"/root/GameManager".add_cheat_event({
					"cheat":"shortcut",
					"racer":racer_name
				})
		target = p_target
		last_good_pos = current.global_transform.origin
		emit_signal("mark_crossed", self)
		return true
	return false

func on_rank(_i):
	pass

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
	
	var speed = linear_velocity.length()
	if gear == 0 and speed > speed_upshift:
		gear = 1
	elif gear == 1 and speed < speed_downshift:
		gear = 0
	elif gear == 1 and speed > speed_upshift2:
		gear = 2
	elif gear == 2 and speed < speed_downshift2:
		gear = 1
	var pi = (1-gear_factor*gear)*clamp(
		(abs(throttle) + throttle_min_factor)*speed/speed_factor, 0, 1)
	engine_audio.pitch_scale = lerp(pitch_shift_min, pitch_shift_max, pi)

	engine_force = -throttle*horsepower
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
	var skid = abs(linear_velocity.dot(global_transform.basis.x)) > speed_skid
	$Particles.emitting = skid and $wheel_bl.is_in_contact()
	$Particles2.emitting = skid and $wheel_br.is_in_contact()

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
