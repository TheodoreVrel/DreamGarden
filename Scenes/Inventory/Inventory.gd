extends Node

var flowers: Array
var max_capacity: int

var slot_packed_scene : PackedScene = preload("res://Scenes/Inventory/InventorySlot.tscn")
var inventory_slot_amount : int = 6
var selectedSlot : int = 0

@onready var container = $HBoxContainer

signal new_seed_selected(seed : Flower)
signal seeds_emptied

func _ready():
	
	for slot in range(inventory_slot_amount):
		var new_slot = slot_packed_scene.instantiate()
		container.add_child(new_slot)
		#select_slot(slot, true)
		#deselect_slot(slot)
	select_slot(selectedSlot, true)

func _process(delta):
	if Input.is_action_just_pressed("scroll_up"):
		scroll_select(false)
	if Input.is_action_just_pressed("scroll_down"):
		scroll_select(true)

func scroll_select(down : bool):
	deselect_slot(selectedSlot)
	if down:
		if selectedSlot == inventory_slot_amount - 1:
			selectedSlot = 0
		else: selectedSlot += 1
		select_slot(selectedSlot, true)
	else:
		if selectedSlot == 0:
			selectedSlot = inventory_slot_amount - 1
		else: selectedSlot -= 1
		select_slot(selectedSlot, false)
	

func select_slot(slot: int, from_right: bool):
	container.get_child(slot).select(from_right)
	var selected_flower 
	if container.get_child(slot).slotted_flower:
		selected_flower = get_selected_flower()
	if selected_flower:
		#print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk", selected_flower)
		new_seed_selected.emit(selected_flower)
	#container.get_child(slot).find_child("Label").position.y = 69

func deselect_slot(slot: int):
	container.get_child(slot).deselect()
	#container.get_child(slot).find_child("Label").position.y = 48
	



func add_flower(flower: Flower, amount: int):
	#print("added ", amount, " flower(s) : ", flower)
	#find the first empty inventory item, and add it there
	var empty_slot : InventorySlot = get_first_slot_with_flower(flower)
	if empty_slot == null:
		empty_slot = get_first_empty_slot()
	
	empty_slot.slotted_flower = flower
	empty_slot.slotted_flower.growth_stage = -1
	empty_slot.seed_amount += 1
	empty_slot.update_flower_texture_rect()
	set_slot_amount(empty_slot)
	
	if empty_slot.currently_selected:
		new_seed_selected.emit(flower)

func get_first_empty_slot() :
	for slot in range(inventory_slot_amount):
		#print("slot ", slot)
		if container.get_child(slot).slotted_flower == null:
			#print("found empty slot ", container.get_child(slot).slotted_flower, " | slot number ", slot)
			return container.get_child(slot)
	return null

func get_first_slot_with_flower(flower : Flower) :
	for slot in range(inventory_slot_amount):
		#print("slot ", slot)
		if container.get_child(slot).slotted_flower == flower:
			#print("found slot with ", flower, " (", container.get_child(slot).seed_amount, ") : ", container.get_child(slot).slotted_flower, " | slot number ", slot)
			return container.get_child(slot)
	return null

func set_slot_amount(slot):
	var lab = slot.find_child("Label")
	lab.text = str(slot.seed_amount)
	if lab.text == str(0):
		lab.text = ""

func remove_flower(all: bool = false):
	#print("removing from ", container.get_child(selectedSlot).seed_amount)
	if !all:
		container.get_child(selectedSlot).seed_amount -= 1
		#print("removed 1")
		if container.get_child(selectedSlot).seed_amount == 0:
			remove_all_flowers_from_slot(selectedSlot)
			#print("removed last")
		set_slot_amount(container.get_child(selectedSlot))
	else:
		container.get_child(selectedSlot).seed_amount = 0
		remove_all_flowers_from_slot(selectedSlot)
		#print("removed all")

func remove_all_flowers_from_slot(slot: int):
	container.get_child(selectedSlot).slotted_flower = null
	container.get_child(selectedSlot).update_flower_texture_rect()
	seeds_emptied.emit()

func get_selected_flower():
	return container.get_child(selectedSlot).slotted_flower

func swap_flowers(index1: int, index2: int):
	pass


