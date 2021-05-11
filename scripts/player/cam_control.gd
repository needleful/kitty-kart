extends Spatial

export(NodePath) var body_node

onready var arm: SpringArm = $SpringArm
onready var cam: Camera = $SpringArm/cam_target/Camera

onready var body: RigidBody = get_node(body_node)

var camRotAccum: Vector2 = Vector2.ZERO
var camRot: Vector2 = Vector2(0,0)

# Radians per second
const CAM_REORIENT_MIN = 0.5
const CAM_REORIENT_MAX = 15

# tolerances in radians
const CAM_ROLL_TOLERANCE = 0.5
const CAM_PITCH_TOLERANCE = 1

const CAMERA_VELOCITY_YAW = 0.5
const CAM_ROTATE_FOLLOW = 0.75
const CAM_MAX_ROTATE_FOLLOW = PI

const SPRING_LEN_BASE = 2
const SPRING_LEN_ADD = 0.1
const SPRING_LEN_MIN = 1
const SPRING_LEN_MAX = 8

const CAM_TILT = 2
const SNS_MOUSE = Vector2(0.001, -0.0005)
const SNS_CONTROLLER = Vector2(0.1, -0.07)

const SPEED_STOPPED = 2

func _input(event):
	if event is InputEventMouseMotion:
		camRotAccum += event.relative

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	global_transform.origin = body.cam_target()
	var newCamRot = camRot + get_camera_rot()
	newCamRot.y = clamp(newCamRot.y, -PI/2 + 0.5, PI/2 - 0.01)
	var c = newCamRot - camRot
	
	rotate_y(-c.x)
	arm.rotate_x(c.y)
	camRot = newCamRot
	
	var vel: Vector3 = body.linear_velocity
	var speed: float = body.linear_velocity.length()
	
	# Pull out camera based on speed
	arm.spring_length = clamp(
		speed*SPRING_LEN_ADD+SPRING_LEN_BASE,
		SPRING_LEN_MIN,
		SPRING_LEN_MAX)

	# Look ahead of the player
	var camUp = Vector3.UP
	cam.global_transform = cam.global_transform.looking_at(
		arm.global_transform.origin + vel*delta*CAM_TILT,
		camUp)
	
	#Yaw based on velocity
	var cz = -global_transform.basis.z
	if c == Vector2.ZERO and vel.dot(cz) > 0:
		var v2 = MoveMath.reject(vel, Vector3.UP)
		var yawZaxis = cz.cross(v2).normalized()
		if yawZaxis.is_normalized():
			var yaw = cz.angle_to(v2)
			var fyaw = sqrt(v2.length())*(abs(yaw) + 0.3)/PI
			var cam_speed = CAMERA_VELOCITY_YAW*min(CAM_MAX_ROTATE_FOLLOW, fyaw*CAM_ROTATE_FOLLOW)
			var yaw2 = sign(yaw)*min(abs(yaw), cam_speed*delta)
			rotate_y(yawZaxis.dot(Vector3.UP)*yaw2)

func get_camera_rot()->Vector2:
	var ret = camRotAccum*SNS_MOUSE
	camRotAccum = Vector2(0,0)
	var c = Vector2(
		Input.get_action_strength("cam_right") - Input.get_action_strength("cam_left"),
		Input.get_action_strength("cam_up") - Input.get_action_strength("cam_down")
	)
	c = Vector2(
		sign(c.x)*pow(abs(c.x), 2.6),
		-sign(c.y)*pow(abs(c.y), 2.6)
	)
	return ret + c*SNS_CONTROLLER

func _on_race_start(_laps):
	cam.current = true
