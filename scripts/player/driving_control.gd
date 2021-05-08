extends VehicleBody

const horsepower: float = 300.0
const steer_angle:float = PI/6
const slide_brake:float = 10.0

onready var rear_wheels = [$wheel_bl, $wheel_br]
onready var front_wheels = [$wheel_fl, $wheel_fr]
onready var wheels = [$wheel_bl, $wheel_br, $wheel_fl, $wheel_fr]

func _physics_process(delta):
	var throttle = Input.get_action_strength("vh_accel") - Input.get_action_strength("vh_brake")
	var steer = Input.get_action_strength("vh_left") - Input.get_action_strength("vh_right")
	var slide = Input.get_action_strength("vh_slide")
	
	engine_force = throttle*horsepower
	steering = steer*steer_angle
	for wheel in wheels:
		wheel.brake = slide*slide_brake


func cam_target() -> Vector3:
	return $cam_target.global_transform.origin
