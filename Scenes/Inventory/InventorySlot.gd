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
		flower_texture_rect.texture = load(sprite_directory + str(flower_id) + "_seed.png")
	else:
		flower_texture_rect.texture = null


func _on_mouse_entered():
	hovered.emit(self)
	#print(self)
func _on_mouse_exited():
	hovered.emit(null)
