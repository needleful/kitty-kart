extends Node

signal race_start(laps)
signal ranking_changed(order)
signal winner(racer, winners)

export(String) var track_name = "Track"

var start_timer = Timer.new() 

export(int) var laps
export(NodePath) var starting_line
export(Array, NodePath) var racers

onready var start = get_node(starting_line)
var winners = []

var _racers = []
var race_started = false

func _input(event):
	if event.is_action_pressed("ui_accept"):
		start_countdown()
		set_process_input(false)
	else:
		get_tree().set_input_as_handled()

func _ready():
	$"/root/GameManager".clear_results()
	for node in racers:
		var r = get_node(node)
		assert(r)
		_racers.push_back(r)
		var _x = r.connect("mark_crossed", self, "sort_racers")
	get_tree().call_group("race_ui", "set_race_stats", track_name, laps, _racers)

func start_countdown():
	emit_signal("race_start", laps)

func start_race():
	race_started = true
	for r in _racers:
		if !r.target:
			r.set_target(start)

func sort_racers(r):
	if r.target == start.next:
		r.next_lap()
	if r.lap > laps and !(r in winners):
		winners.push_back(r)
		if r in _racers:
			_racers.remove(_racers.find(r))
			emit_signal("winner", r, winners)
		$"/root/GameManager".add_winner(r.racer_name)
	for i in range(1, _racers.size()):
		var a = _racers[i]
		var j = i
		while j > 0 and racer_ahead(a, _racers[j-1]):
			j -= 1
		var t = _racers[j]
		_racers[j] = a
		_racers[i] = t
	emit_signal("ranking_changed", _racers)

# True if A is ahead of B
func racer_ahead(a: Cart, b: Cart):
	if a.lap != b.lap:
		return a.lap > b.lap
	if a.mandatory_markers != b.mandatory_markers:
		return a.mandatory_markers > b.mandatory_markers
	if a.markers != b.markers:
		return a.markers > b.markers
	else:
		var da = a.global_transform.origin - a.target.global_transform.origin
		var db = b.global_transform.origin - b.target.global_transform.origin
		return da.length_squared() < db.length_squared()

func _on_next_track():
	$"/root/GameManager".next_scene()

func _on_restart():
	var _x = get_tree().reload_current_scene()

func _on_start_crossed(racer):
	if !race_started:
		$"/root/GameManager".add_cheat_event({
				"cheat":"early_start",
				"racer":racer.racer_name
			})
	start_race()
