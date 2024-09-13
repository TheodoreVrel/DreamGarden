extends Control


var hovered_slot : InventorySlot
@onready var shop_flower : Flower = $Flower


signal bought_flower

func _ready():
	for slot in find_child("Grid").get_children():
		slot.connect("hovered", on_area_entered)
	add_flower_to_shop(shop_flower)

func _process(delta):
	if Input.is_action_just_released("left_click") and hovered_slot:
		clicked_on_slot()

func on_area_entered(slot):
	hovered_slot = slot
	#print("i", slot)

func clicked_on_slot():
	if hovered_slot.slotted_flower:
		bought_flower.emit(hovered_slot.slotted_flower)
		hovered_slot.remove_flower()


func add_flower_to_shop(flower : Flower):
	get_first_empty_slot().add_flower_to_slot(flower)

func get_first_empty_slot() :
	for slot_int in range($Grid.get_child_count()):
		#print("slot ", slot)
		if $Grid.get_child(slot_int).slotted_flower == null:
			#print("found empty slot ", container.get_child(slot).slotted_flower, " | slot number ", slot)
			return $Grid.get_child(slot_int)
	return null
