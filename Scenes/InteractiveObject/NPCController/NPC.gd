extends InteractiveObject
class_name NPC


@onready var npc_inventory = $Inventory

signal give_flower_to_player(flower: Flower, amount: int)



func interact_with():
	#print("Do you want this ", npc_inventory.get_child(0).info.get("flower_name"), "?")
	give_flower(npc_inventory.get_child(0))

func give_flower(flower: Flower):
	give_flower_to_player.emit(flower, 1)
