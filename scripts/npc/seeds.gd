extends Resource
class_name Seeds
export(Array, Resource) var seeds

func _init(s):
	seeds = s
	seeds.shuffle()
