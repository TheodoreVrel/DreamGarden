extends TextureRect

@onready var original_position : Vector2 = position

func _on_resized():
	#original_position = position
	#print(resized)
	set_new_pivot_offset()

func set_new_pivot_offset():
	pivot_offset = size/2
	#print("pivot set to ", size/2)

func rotate_selected(right: bool):
	var tween = get_tree().create_tween()
	var deg: int
	if right:
		deg = 360
	else:
		deg = -360
	tween.tween_property($".", "rotation", deg_to_rad(deg), 1).set_trans(Tween.TRANS_ELASTIC)
	rotation = deg_to_rad(0)
