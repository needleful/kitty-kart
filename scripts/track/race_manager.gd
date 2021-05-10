extends Node

signal race_start(laps)
signal ranking_changed(order)
signal winner(racer, winners)

export (float) var time_to_start = 3.0

var start_timer = Timer.new() 

export(int) var laps
export(NodePath) var starting_line
export(Array, NodePath) var racers

onready var start = get_node(starting_line)
var winners = []

var _racers = []

func _ready():
	for node in racers:
		var r = get_node(node)
		assert(r)
		_racers.push_back(r)
		var _x = r.connect("mark_crossed", self, "sort_racers")
	start_countdown()

func start_countdown():
	emit_signal("race_start", laps)

func start_race():
	for r in _racers:
		r.set_target(start)

func sort_racers(r):
	if r.target == start.next:
		r.next_lap()
	if r.lap > laps and !(r in winners):
		winners.push_back(r)
		if r in _racers:
			_racers.remove(_racers.find(r))
			emit_signal("winner", r, winners)
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
	if a.lap == b.lap:
		if a.markers == b.markers:
			var da = a.global_transform.origin - a.target.global_transform.origin
			var db = b.global_transform.origin - b.target.global_transform.origin
			return da.length_squared() < db.length_squared()
		else:
			return a.markers > b.markers
	else:
		return a.lap > b.lap
