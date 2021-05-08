extends Node

signal ranking_changed(order)

export(int) var laps
export(NodePath) var starting_line
export(Array, NodePath) var racers

var _racers = []

func _ready():
	for node in racers:
		var r = get_node(node)
		assert(r)
		_racers.push_back(r)
		var _x = r.connect("mark_crossed", self, "sort_racers")

func sort_racers(_r):
	print("Sorting racers...")
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
	if a.lap > b.lap:
		return true
	elif a.lap == b.lap:
		return a.markers > b.markers
	else:
		return false
