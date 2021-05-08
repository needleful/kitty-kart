extends Spatial

export(PackedScene) var stone
export(bool) var unlimited = false
func fire() -> bool:
	var i = stone.instance()
	get_tree().current_scene.add_child(i)
	i.global_transform = $Position3D.global_transform
	return unlimited
