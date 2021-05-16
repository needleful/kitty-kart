extends Node

enum Mode {
	Story,
	Shuffle
}

export(PackedScene) var main_menu
export(Array, PackedScene) var story
export(Array, PackedScene) var tracks

var current_scene:int = 0
var mode = Mode.Story

var race_results = []
var race_cheat_events = {}

func shuffle():
	tracks.shuffle()

func start(shuffle:bool = false):
	get_tree().paused = false
	if shuffle:
		mode = Mode.Shuffle
	else:
		mode = Mode.Story
	get_scene(0)

func clear_results():
	race_results = []
	race_cheat_events = {}

func add_cheat_event(cheat:Dictionary):
	print("CHEATER! %s for %s" % [cheat["cheat"], cheat["racer"]])
	if !cheat["racer"] in race_cheat_events:
		race_cheat_events[cheat["racer"]] = []
	race_cheat_events[cheat["racer"]].push_back(cheat["cheat"])

func add_winner(racer_name):
	print("Winner: ", racer_name)
	race_results.push_back(racer_name)

func next_scene():
	get_scene(current_scene + 1)

func get_scene(sc: int):
	current_scene = sc
	var new_sc = main_menu
	if sc >= 0:
		if mode == Mode.Story and sc < story.size():
			new_sc = story[sc]
		elif mode == Mode.Shuffle and sc < tracks.size():
			new_sc = tracks[sc]
	var _x = get_tree().change_scene_to(new_sc)
