extends Node2D
class_name NPC


@onready var npc_inventory = $Inventory

signal give_flower_to_player(flower: Flower, amount: int)

func zone_cast():
	zone_interaction(zone_interaction_type.HOVERED)
	#print(npc_inventory.get_child(0).info)

func zone_exit():
	zone_interaction(zone_interaction_type.EXITED)

func interact_with():
	#print("Do you want this ", npc_inventory.get_child(0).info.get("flower_name"), "?")
	give_flower(npc_inventory.get_child(0))

func give_flower(flower: Flower):
	give_flower_to_player.emit(flower, 1)

enum zone_interaction_type{HOVERED, CLICKED,EXITED}
func zone_interaction(interaction: zone_interaction_type):
	match interaction:
		zone_interaction_type.HOVERED:
			print("hovered")
		zone_interaction_type.EXITED:
			print("exited")
		zone_interaction_type.CLICKED:
			print("clicked")
