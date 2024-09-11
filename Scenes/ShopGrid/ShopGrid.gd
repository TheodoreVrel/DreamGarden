extends GridContainer




func _ready():
	for slot in get_children():
		slot.connect("hovered", on_area_entered)


func on_area_entered(slot):
	print("i", slot)
