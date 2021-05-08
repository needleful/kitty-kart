extends VBoxContainer

func _on_ranking_changed(order):
	for c in get_children():
		c.queue_free()
	for o in order:
		var l = Label.new()
		add_child(l)
		l.text = "%s, %d, %d"% [o.racer_name, o.lap, o.markers]
