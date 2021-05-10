extends Spatial

func _input(event):
	if event.is_action_pressed("pause"):
		set_pause(!get_tree().paused)
	elif event.is_action_pressed("ui_right"):
		$control_anim.stop()
		$control_anim.play("ui_right")
	elif event.is_action_pressed("ui_left"):
		$control_anim.stop()
		$control_anim.play("ui_left")
	elif event.is_action_pressed("ui_up"):
		$control_anim.stop()
		$control_anim.play("ui_up")
		$menu.previous_page()
	elif event.is_action_pressed("ui_down"):
		$control_anim.stop()
		$control_anim.play("ui_down")
		$menu.next_page()
	elif event.is_action_pressed("ui_accept"):
		$control_anim.stop()
		$control_anim.play("ui_accept")
	elif event.is_action_pressed("ui_cancel"):
		$control_anim.stop()
		$control_anim.play("ui_cancel")

func set_pause(pause):
	get_tree().paused = pause
	if pause:
		$AnimationPlayer.play("pause")
	else:
		$AnimationPlayer.play("unpause")
	get_tree().call_group("pause_reactive", "on_pause", pause)

func _on_resume():
	set_pause(false)

func _on_restart():
	set_pause(false)
	var _x = get_tree().reload_current_scene()

func _on_exit():
	get_tree().quit()
