extends Camera2D


func _process(delta):
	if Input.is_action_just_pressed("shift_scroll_up"):
		if zoom.x <= 5:
			zoom *= 1.2
	if Input.is_action_just_pressed("shift_scroll_down"):
		if zoom.x > 1:
			zoom /= 1.2
