class_name NPC_Params
extends Resource

export(float) var velocity_slow: float = 7.0
export(float) var velocity_slow_brake: float = 25.0
export(float) var min_throttle_slow: float = 0.1
export(float) var throttle_reverse: float = -0.5
export(float) var slow_slide: float = 1.0

export(float) var avoidance: float = 0.5
export(float) var avoidance_radius: float = 3.0

export(float) var cutoff: float = 0.5
export(float) var cutoff_radius: float = 3.0

var keys = [
	"velocity_slow",
	"velocity_slow_brake",
	"min_throttle_slow",
	"throttle_reverse",
	"slow_slide",
	"avoidance",
	"avoidance_radius",
	"cutoff",
	"cutoff_radius"
]

func random_mutate(percent: float):
	var n = duplicate()
	for k in keys:
		print(k, " = ", self[k])
		n[k] = rand_range(self[k]*(1.0-percent), self[k]*(1.0+percent))
	return n

func random_combine(b, weight:float):
	var n = duplicate()
	for k in keys:
		if randf() >= weight:
			n[k] = b[k]
	return n
