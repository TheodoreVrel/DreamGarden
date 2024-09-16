extends Control

@onready var shop_grid = $Grid
@onready var close_button = $Button

var hovered_slot : InventorySlot
#@onready var shop_flower : Flower = $Flower


signal bought_flower
signal closed_shop

signal hovered_a_slot

func _ready():
	for slot in shop_grid.get_children():
		slot.connect("hovered", on_area_entered)
	close_button.connect("button_down", on_close_button_down)
	#add_flower_to_shop(shop_flower, 5)

func _process(delta):
	if Input.is_action_just_released("left_click") and hovered_slot:
		clicked_on_slot()

func on_close_button_down():
	#visible = false #handled in GameManager for clarity
	closed_shop.emit()

func on_area_entered(slot):
	hovered_slot = slot
	hovered_a_slot.emit(slot)
	#print("i", slot)

func clicked_on_slot():
	if hovered_slot.slotted_flower:
		bought_flower.emit(hovered_slot.slotted_flower)
		hovered_slot.remove_flower()

func empty_shop():
	for slot : InventorySlot in shop_grid.get_children():
		slot.remove_flower(true)

func add_flower_to_shop(flower : Flower, amount : int):
	get_first_empty_slot().add_flower_to_slot(flower, amount)

func get_first_empty_slot() :
	for slot_int in range(shop_grid.get_child_count()):
		#print("slot ", slot)
		if shop_grid.get_child(slot_int).slotted_flower == null:
			#print("found empty slot ", container.get_child(slot).slotted_flower, " | slot number ", slot)
			return shop_grid.get_child(slot_int)
	return null
