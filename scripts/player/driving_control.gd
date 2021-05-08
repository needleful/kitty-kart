extends Cart

onready var rear_wheels = [$wheel_bl, $wheel_br]
onready var front_wheels = [$wheel_fl, $wheel_fr]

func get_throttle():
	return Input.get_action_strength("vh_accel") - Input.get_action_strength("vh_brake")

func get_steer():
	return Input.get_action_strength("vh_left") - Input.get_action_strength("vh_right")

func get_slide():
	return Input.get_action_strength("vh_slide")
