extends Control

signal go

var winners = 0

func _ready():
	for c in $winners/list/labels.get_children():
		if c is Control:
			c.visible = false
	for c in $winners/list/names.get_children():
		if c is Control:
			c.visible = false

func _on_race_start():
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
	n.text = winner.racer_name


func _on_ranking_changed(order):
	for c in $stats/VBoxContainer.get_children():
		c.queue_free()
	for o in order:
		var l = Label.new()
		$stats/VBoxContainer.add_child(l)
		l.text = "%s, %d, %d"% [o.racer_name, o.lap, o.markers]

