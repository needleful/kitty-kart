extends Node

export(Array, Resource) var messages

func _ready():
	var r = preload("res:///scripts/npc/message.gd").new(0,0,"Your Text here")
	var e = ResourceSaver.save("res://scripts/npc/message_template.tres", r)
	assert(e == OK)

func get_conversation():
	return messages
