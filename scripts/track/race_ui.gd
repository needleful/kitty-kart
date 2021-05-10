extends Control

signal go

var winners = 0
var laps = 1

func _ready():
	for c in $winners/list/labels.get_children():
		if c is Control:
			c.visible = false
	for c in $winners/list/names.get_children():
		if c is Control:
			c.visible = false

func _on_race_start(p_laps):
	$AnimationPlayer.play("Start")
	laps = p_laps

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
	n.text = winner.racer_name

func on_pause(pause):
	visible = !pause

func _on_ranking_changed(order):
	for c in $stats/VBoxContainer.get_children():
		c.queue_free()
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
