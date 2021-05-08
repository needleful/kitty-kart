extends RigidBody

export(PackedScene) var result

func on_body_entered(_body):
	var r = result.instance()
	get_tree().current_scene.add_child(r)
	r.global_transform.origin = global_transform.origin
	queue_free()
