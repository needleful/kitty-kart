extends Container

signal resume
signal restart
signal exit

export(int) var page = 0 setget set_page

onready var labels:VBoxContainer = $tabs/VBoxContainer/labels
onready var content:Control = $tabs/content/subpage/tabs

var buttons = []
var subpages = []

func _ready():
	buttons.clear()
	subpages.clear()
	
	for c in labels.get_children():
		if c is Control:
			buttons.push_back(c)
	for c in content.get_children():
		if c is Control:
			subpages.push_back(c)

func next_page():
	set_page( (page+ 1) % buttons.size())

func previous_page():
	set_page( (page + buttons.size() - 1) % buttons.size())

func refresh():
	set_page(page)

func set_page(p: int):
	assert(p >= 0 and p < buttons.size())
	page = p
	assert(buttons.size() == subpages.size())
	buttons[page].call_deferred("grab_focus")
	for i in range(buttons.size()):
		var button: Button = buttons[i]
		var spage: Control = subpages[i]
		spage.visible = i == page

func _on_music_toggled(button_pressed):
	var i = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_mute(i, !button_pressed)

func _on_effects_toggled(button_pressed):
	var i = AudioServer.get_bus_index("Effects")
	AudioServer.set_bus_mute(i, !button_pressed)

func _on_master_toggled(button_pressed):
	var i = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(i, !button_pressed)

func _on_resume_pressed():
	emit_signal("resume")

func _on_restart_pressed():
	emit_signal("restart")

func _on_exit_pressed():
	emit_signal("exit")
