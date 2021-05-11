extends Spatial

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$control/buttons/story.call_deferred("grab_focus")

func _on_story_pressed():
	$"/root/GameManager".start()

func _on_shuffle_pressed():
	$"/root/GameManager".start(true)

func _on_options_pressed():
	pass # Replace with function body.

func _on_quit_pressed():
	get_tree().quit()
