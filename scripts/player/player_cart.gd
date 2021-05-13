extends Cart
class_name PlayerCart

export(bool) var force_brake = false
onready var debug_marker = $debug_marker

onready var anim = $kitty_herself/AnimationTree

var input: Vector2 = Vector2.ZERO

func _ready():
	if force_brake:
		set_process_input(false)

func _input(event):
	if weapon and event.is_action_pressed("vh_fire"):
		if !weapon.fire(self):
			weapon.queue_free()
			weapon = null

func _process(_delta):
	$Label2.text = "Speed: %.1f" % linear_velocity.length()
	var turn_blend = anim["parameters/turn/blend_position"]
	anim["parameters/turn/blend_position"] = turn_blend.linear_interpolate(input, 0.1)

func get_throttle():
	input.y = Input.get_action_strength("vh_accel") - Input.get_action_strength("vh_brake")
	return input.y

func get_steer():
	var s = Input.get_action_strength("vh_left") - Input.get_action_strength("vh_right")
	input.x = -s
	return s

func mark_next(current:Spatial, p_target:Spatial, p_mandatory:Spatial):
	if .mark_next(current, p_target, p_mandatory) and current.mandatory:
		debug_marker.get_parent().remove_child(debug_marker)
		p_mandatory.add_child(debug_marker)
		debug_marker.visible = true

func get_slide():
	if force_brake:
		return 1.0
	else:
		return Input.get_action_strength("vh_slide")

func set_slow(slow):
	$Label.visible = slow

func _on_race_start(_laps):
	set_process_input(true)
	force_brake = false
	$Listener.make_current()
