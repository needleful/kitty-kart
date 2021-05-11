extends Cart
class_name PlayerCart

export(bool) var force_brake = false

func _input(event):
	if weapon and event.is_action_pressed("vh_fire"):
		if !weapon.fire(self):
			weapon.queue_free()
			weapon = null

func _process(_delta):
	$Label2.text = "Speed: %.1f" % linear_velocity.length()

func get_throttle():
	return Input.get_action_strength("vh_accel") - Input.get_action_strength("vh_brake")

func get_steer():
	return Input.get_action_strength("vh_left") - Input.get_action_strength("vh_right")

func get_slide():
	if force_brake:
		return 1.0
	else:
		return Input.get_action_strength("vh_slide")

func set_slow(slow):
	$Label.visible = slow

func _on_race_start(_laps):
	force_brake = false
	$Listener.make_current()
