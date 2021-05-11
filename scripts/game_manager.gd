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

func shuffle():
	tracks.shuffle()

func start(shuffle:bool = false):
	get_tree().paused = false
	if shuffle:
		mode = Mode.Shuffle
	else:
		mode = Mode.Story
	get_scene(0)

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
