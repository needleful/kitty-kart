extends Spatial

export(PackedScene) var projectile
export(float) var force = 100

func fire(var owner: RigidBody):
	var rb: RigidBody = projectile.instance()
	get_tree().current_scene.add_child(rb)
	rb.global_transform = global_transform
	rb.apply_central_impulse(-global_transform.basis.z*force
		+ 0.5*rb.mass*owner.linear_velocity)
