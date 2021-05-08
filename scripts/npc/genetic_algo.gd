extends Node

export (String, FILE, "*.tres") var seed_file
export(Array, NodePath) var vehicles

var seeds: Array = []
var racers = []

func _ready():
	for v in vehicles:
		racers.push_back(get_node(v))
	
	var s: Seeds = load(seed_file) as Seeds
	if s:
		seeds = s.seeds
		seeds.shuffle()
	else:
		seeds = []
		generate([racers[0], racers[1], racers[2]])
	for i in range(seeds.size()):
		racers[i].apply_params(seeds[i])

func winner(_r, winners):
	if winners.size() >= 3:
		generate(winners)
		reset()

func generate(winners):
	var f = File.new()
	f.open(seed_file, f.WRITE)
	f.store_8(0)
	f.close()
	
	seeds.clear()
	for w in winners:
		seeds.push_back(w.get_params())
	seeds.push_back(seeds[0].random_mutate(0.05))
	seeds.push_back(seeds[1].random_mutate(0.1))
	seeds.push_back(seeds[2].random_mutate(0.25))
	
	seeds.push_back(seeds[0].random_combine(seeds[1], 0.5))
	seeds.push_back(seeds[0].random_combine(seeds[2], 0.25))
	seeds.push_back(seeds[1].random_combine(seeds[2], 0.5))
	var s = ResourceSaver.save(seed_file, Seeds.new(seeds))
	assert(s == OK)

func reset():
	var _x = get_tree().reload_current_scene()
