extends Area

export(PackedScene) var weapon

func body_entered(body):
	if body.has_method("set_weapon") and !body.weapon:
		body.set_weapon(weapon)
		$AnimationPlayer.play("reset")
