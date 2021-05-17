extends Control

func _input(event):
	if event.is_pressed():
		get_tree().quit()
