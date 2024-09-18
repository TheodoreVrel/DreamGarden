extends Node2D
class_name InteractiveObject

var movable : bool = false
var dragging : bool = false

signal drag_signal

func zone_cast():
	zone_interaction(zone_interaction_type.HOVERED)
	#print(npc_inventory.get_child(0).info)

func zone_exit():
	zone_interaction(zone_interaction_type.EXITED)
	#print("interaction : exited")


#func _ready():
	#connect("dragsignal", set_drag)
func _process(delta):
	#if selected and Input.is_action_pressed("left_click"):
		#dragging = true
	#else:
		#dragging = false
	#
	if movable and dragging and Globals.current_mode == Globals.mode.ARRANGE:
		var mousepos = get_viewport().get_mouse_position()
		self.position = Vector2(mousepos.x, mousepos.y)

func interact_with():
	pass


enum zone_interaction_type{HOVERED, CLICKED,EXITED}
func zone_interaction(interaction: zone_interaction_type):
	match interaction:
		zone_interaction_type.HOVERED:
			#print("hovered")
			pass
		zone_interaction_type.EXITED:
			#print("exited")
			pass
		zone_interaction_type.CLICKED:
			#print("clicked")
			pass
