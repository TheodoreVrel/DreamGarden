extends Control


var hovered_slot : InventorySlot

signal bought_flower

func _ready():
	for slot in find_child("Grid").get_children():
		slot.connect("hovered", on_area_entered)

func _process(delta):
	if Input.is_action_just_released("left_click") and hovered_slot:
		clicked_on_slot()
	pass

func on_area_entered(slot):
	hovered_slot = slot
	#print("i", slot)

func clicked_on_slot():
	hovered_slot.remove_flower()
	bought_flower.emit(hovered_slot.flower_in_slot)
