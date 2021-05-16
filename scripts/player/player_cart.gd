extends Cart
class_name PlayerCart

export(bool) var force_brake = false
onready var debug_marker = $debug_marker

onready var anim = $kitty_herself/AnimationTree

var input: Vector2 = Vector2.ZERO
var reset_timer = 0
const manual_reset_time = 3

func _ready():
	if force_brake:
		set_process_input(false)

func _input(event):
	if weapon and event.is_action_pressed("vh_fire"):
		if !weapon.fire(self):
			weapon.queue_free()
			weapon = null

func _process(delta):
	$Label2.text = "Speed: %.1f" % linear_velocity.length()
	var turn_blend = anim["parameters/turn/blend_position"]
	anim["parameters/turn/blend_position"] = turn_blend.linear_interpolate(input, 0.1)
	
	if Input.is_action_pressed("vh_reset"):
		reset_timer += delta
		$reset.visible = true
		$reset/ProgressBar.value = reset_timer*100.0/manual_reset_time
		if reset_timer > manual_reset_time:
			reset_timer = 0
			reset(last_good_pos + Vector3.UP*2)
	else:
		reset_timer = 0
		$reset.visible = false

func get_throttle():
	input.y = Input.get_action_strength("vh_accel") - Input.get_action_strength("vh_brake")
	return input.y

func get_steer():
	var s = Input.get_action_strength("vh_left") - Input.get_action_strength("vh_right")
	input.x = -s
	return s

func mark_next(current:Spatial):
	if .mark_next(current) and current.mandatory:
		debug_marker.get_parent().remove_child(debug_marker)
		var c = current.next_mandatory
		if c:
			c.add_child(debug_marker)
			debug_marker.visible = true

func get_slide():
	if force_brake:
		return 1.0
	else:
		return Input.get_action_strength("vh_slide")

func set_slow(slow):
	$Label.visible = slow

func _on_race_start(_laps):
	set_physics_process(true)
	set_process_input(true)
	force_brake = false
	$Listener.make_current()
