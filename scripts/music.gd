extends AudioStreamPlayer

func on_pause(pause):
	var i = AudioServer.get_bus_index("Music")
	var ef = AudioServer.get_bus_effect(i, 0)
	if pause:
		ef.cutoff_hz = 1000
	else:
		ef.cutoff_hz = 20000
