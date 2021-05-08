extends VehicleBody

export (NodePath) var target_node

onready var target:Spatial = get_node(target_node)

const horsepower: float = 300.0
const steer_angle:float = PI/6
const slide_brake:float = 10.0

onready var rear_wheels = [$wheel_bl, $wheel_br]
onready var front_wheels = [$wheel_fl, $wheel_fr]
onready var wheels = [$wheel_bl, $wheel_br, $wheel_fl, $wheel_fr]

func _physics_process(delta):
	var target_pos = target.global_transform.origin
	var basis = global_transform.basis
	var dir = (global_transform.origin - target_pos).normalized()
	var throttle: float  = dir.dot(basis.z)
	var steer: float = dir.dot(basis.x)
	var slide = 0
	
	engine_force = throttle*horsepower
	steering = steer*steer_angle
	for wheel in wheels:
		wheel.brake = slide*slide_brake


func cam_target() -> Vector3:
	return $cam_target.global_transform.origin
