extends Control
class_name InventorySlot

var sprite_directory : String = "res://Assets/Prototypes/"
@onready var flower_texture_rect = $TextureRectBox/TextureRectFlower

var currently_selected : bool = false

var slotted_flower : Flower = null
var seed_amount : int = 0

signal hovered

func select(from_right: bool):
	size = Vector2(85,85)
	$TextureRectBox.size = Vector2(85,85)
	currently_selected = true
	size_flags_stretch_ratio = 2
	$TextureRectBox.rotate_selected(from_right)
	find_child("Label").position.y += 69
	#print(self)
	
func deselect():
	size = Vector2(50,50)
	$TextureRectBox.size = Vector2(50,50)
	currently_selected = false
	size_flags_stretch_ratio = 1
	find_child("Label").position.y = 48

func _on_texture_rect_box_resized():
	pass # Replace with function body.

func update_flower_texture_rect():
	if slotted_flower:
		var flower_id = slotted_flower.id
		print("adding texture for seed : ", slotted_flower, " - texture = ", slotted_flower.seed_texture)
		flower_texture_rect.texture = slotted_flower.seed_texture #load(sprite_directory + str(flower_id) + "_seed.png")
	else:
		flower_texture_rect.texture = null


func _on_mouse_entered():
	hovered.emit(self)
	#print(self)
func _on_mouse_exited():
	hovered.emit(null)


func add_flower_to_slot(flower: Flower, amount : int = 1):
	slotted_flower = flower
	slotted_flower.growth_stage = -1
	seed_amount += amount
	update_flower_texture_rect()
	pass

func remove_flower(all: bool = false):
	#print("removing from ", container.get_child(selectedSlot).seed_amount)
	if !all:
		seed_amount -= 1
		#print("removed 1")
		if seed_amount == 0:
			remove_all_flowers_from_slot()
			#print("removed last")
	else:
		seed_amount = 0
		remove_all_flowers_from_slot()
		#print("removed all")
func remove_all_flowers_from_slot():
	slotted_flower = null
	update_flower_texture_rect()
