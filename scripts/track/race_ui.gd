extends Control

signal go
signal next_track
signal restart

var winners = 0
var laps = 1

func _input(event):
	if event.is_action_pressed("ui_accept"):
		emit_signal("next_track")
	elif event.is_action_pressed("ui_cancel"):
		emit_signal("restart")

func _ready():
	set_process_input(false)
	for c in $winners/list/labels.get_children():
		if c is Control:
			c.visible = false
	for c in $winners/list/names.get_children():
		if c is Control:
			c.visible = false

func set_race_stats(track_name, p_laps, racers):
	$stats.visible = true
	laps = p_laps
	$stats/track.text = track_name
	$stats/panel/box/laps/value.text = str(laps)
	for c in $stats/panel/box/racers/value.get_children():
		c.queue_free()
	for r in racers:
		var l = Label.new()
		l.text = r.racer_name
		$stats/panel/box/racers/value.add_child(l)

func _on_race_start(_l):
	$stats.visible = false
	$AnimationPlayer.play("Start")

func countdown_end():
	emit_signal("go")

func _on_winner(winner, _winners):
	var l: Control
	var n: Label
	winners += 1
	if winners == 1:
		$winners.visible = true
		l = $winners/list/labels/Label
		n = $winners/list/names/racer
	elif winners > 1:
		l = get_node("winners/list/labels/Label"+str(winners))
		n = get_node("winners/list/names/racer"+str(winners))
	l.visible = true
	n.visible = true
	if winner is PlayerCart:
		set_process_input(true)
		$winners/player_options.visible = true
	n.text = winner.racer_name

func on_pause(pause):
	visible = !pause

func _on_ranking_changed(order):
	var i = 0
	for o in order:
		i += 1
		if o is PlayerCart:
			$player_place.visible = true
			$player_place.bbcode_text = rich_encode(i)
			$player_place/laps.text = "Lap %d/%d" %[o.lap, laps]

func rich_encode(order:int):
	var th = "th"
	
	if order < 10 or order > 20:
		var x = order % 10
		match x:
			1:
				th = "st"
			2:
				th = "nd"
			3:
				th = "rd"
			_:
				th = "th"
	return "[b]%d[/b]%s" %[order, th]
