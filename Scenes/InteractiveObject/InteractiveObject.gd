extends Node2D
class_name InteractiveObject


func zone_cast():
	zone_interaction(zone_interaction_type.HOVERED)
	#print(npc_inventory.get_child(0).info)

func zone_exit():
	zone_interaction(zone_interaction_type.EXITED)


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
