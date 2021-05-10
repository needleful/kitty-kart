extends RigidBody

export(PackedScene) var result
export(float) var time_inactive = 0.25

func activate():
	$Area.collision_layer = 4
	$Area.collision_mask = 4

func on_body_entered(_body):
	for c in $destruction.get_overlapping_bodies():
		c.destroy()
	var r = result.instance()
	get_tree().current_scene.add_child(r)
	r.global_transform.origin = global_transform.origin
	queue_free()


func on_timeout():
	activate()
