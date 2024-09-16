extends Node

var flowers: Array
var max_capacity: int

var slot_packed_scene : PackedScene = preload("res://Scenes/Inventory/InventorySlot.tscn")
var inventory_slot_amount : int = 6
var selected_slot_int : int = 0
var selected_slot : InventorySlot
var hovered_slot: InventorySlot

var inventory_empty : bool = true

@onready var container = $HBoxContainer

signal new_seed_selected(seed : Flower)
signal seeds_emptied

signal hovered_a_slot(slot)

func _ready():
	
	for slot in range(inventory_slot_amount):
		var new_slot = slot_packed_scene.instantiate()
		container.add_child(new_slot)
		new_slot.connect("hovered", on_inventory_slot_hovered)
		#select_slot(slot, true)
		#deselect_slot(slot)
	select_slot_from_position(selected_slot_int, true)

func _process(delta):
	if Input.is_action_just_pressed("scroll_up"):
		scroll_select(false)
	if Input.is_action_just_pressed("scroll_down"):
		scroll_select(true)
	if Input.is_action_just_released("left_click") and hovered_slot:
		click_select()
		print("Clicked Slot: ", hovered_slot)



func get_next_slot_int(current_slot_int : int, down : bool) -> int:
	if down:
		if current_slot_int == inventory_slot_amount - 1:
			return 0
		else: return current_slot_int + 1
	else:
		if current_slot_int == 0:
			return inventory_slot_amount - 1
		else: return current_slot_int - 1

func scroll_select(down : bool):
	deselect_slot_from_position(selected_slot_int)
	#get_next_slot_int()
	
	select_next_slot_with_seed(down)
	
	#selected_slot_int = get_next_slot_int(selected_slot_int, down)
	#if !selected_slot.slotted_flower and !inventory_empty:
		#while !selected_slot.slotted_flower:
			#deselect_slot_from_position(selected_slot_int)
			#selected_slot_int += 1
			#select_slot_from_position(get_next_slot_int(selected_slot_int, down), down)
	#else:
		#if selected_slot_int == 0:
			#selected_slot_int = inventory_slot_amount - 1
		#else: selected_slot_int -= 1
		#select_slot_from_position(selected_slot_int, false)
func click_select():
	deselect_slot_from_position(selected_slot_int)
	select_slot(hovered_slot)
	selected_slot_int = get_slot_position(selected_slot)

func select_next_slot_with_seed(down : bool):
	if inventory_empty:
		select_slot_from_position(get_next_slot_int(selected_slot_int, down), down)
		return
	
	#var i : int
	#if down: i = 1
	#else: i = -1
	
	deselect_slot_from_position(selected_slot_int)
	selected_slot_int = get_next_slot_int(selected_slot_int, down)
	select_slot_from_position(selected_slot_int, down)
	
	while !selected_slot.slotted_flower:
		deselect_slot_from_position(selected_slot_int)
		selected_slot_int = get_next_slot_int(selected_slot_int, down)
		select_slot_from_position(selected_slot_int, down)
	#else:
		#while !selected_slot.slotted_flower:
			#deselect_slot_from_position(selected_slot_int)
			#selected_slot_int -= 1
			#select_slot_from_position(get_next_slot_int(selected_slot_int, down), down)

func select_slot_from_position(slot: int, from_right: bool):
	select_slot(container.get_child(slot), from_right)
	selected_slot_int = slot
	pass
func select_slot(slot: InventorySlot, from_right: bool = true):
	slot.select(from_right)
	var selected_flower 
	if slot.slotted_flower:
		selected_flower = get_selected_flower()
	if selected_flower:
		#print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk", selected_flower)
		new_seed_selected.emit(selected_flower)
	#container.get_child(slot).find_child("Label").position.y = 69
	selected_slot = slot

func deselect_slot_from_position(slot: int):
	deselect_slot(container.get_child(slot))
	#container.get_child(slot).find_child("Label").position.y = 48
func deselect_slot(slot: InventorySlot):
	slot.deselect()

func get_slot_position(slot: InventorySlot):
	for i in range(container.get_child_count()):
		if container.get_child(i) == slot:
			return i



func add_flower(flower: Flower, amount: int):
	#print("added ", amount, " flower(s) : ", flower)
	#find the first empty inventory item, and add it there
	var empty_slot : InventorySlot = get_first_slot_with_flower(flower)
	if empty_slot == null:
		empty_slot = get_first_empty_slot()
	
	#empty_slot.slotted_flower = flower
	#empty_slot.slotted_flower.growth_stage = -1
	#empty_slot.seed_amount += 1
	#empty_slot.update_flower_texture_rect()
	empty_slot.add_flower_to_slot(flower, amount)
	#empty_slot.seed_amount += amount
	set_slot_amount(empty_slot)
	
	if empty_slot.currently_selected:
		new_seed_selected.emit(flower)
	
	inventory_empty = false

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
	container.get_child(selected_slot_int).remove_flower(all)
	set_slot_amount(container.get_child(selected_slot_int))
	if container.get_child(selected_slot_int).seed_amount == 0:
		seeds_emptied.emit()
		check_inventory_empty()

func remove_all_flowers_from_slot():
	container.get_child(selected_slot_int).remove_all_flowers_from_slot()
	check_inventory_empty()

func check_inventory_empty():
	for slot in container.get_children():
		if slot.slotted_flower:
			inventory_empty = false
			return
	inventory_empty = true

func get_selected_flower():
	return container.get_child(selected_slot_int).slotted_flower

func swap_flowers(index1: int, index2: int):
	pass


func on_inventory_slot_hovered(slot):
	#print("inventory slot to hover : ", slot)
	hovered_slot = slot
	hovered_a_slot.emit(hovered_slot)
	#print("slot now hovered = ", slot)
