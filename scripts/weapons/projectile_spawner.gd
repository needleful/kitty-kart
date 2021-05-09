extends Spatial

signal range_entered(body)

export(PackedScene) var projectile
export(int) var count = 3
export(float) var force = 100

func fire(var owner: RigidBody):
	var rb: RigidBody = projectile.instance()
	get_tree().current_scene.add_child(rb)
	rb.global_transform = global_transform
	rb.apply_central_impulse(-global_transform.basis.z*force
		+ 0.5*rb.mass*owner.linear_velocity)
	count -= 1
	return count > 0


func _on_range_entered(body):
	if body is Cart:
		emit_signal("range_entered", body)
		print("range_entered by: ", body.name)
