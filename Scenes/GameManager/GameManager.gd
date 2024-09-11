extends Node

@onready var garden = $Garden
@onready var gardenUI = $CanvasLayer/GardenUI
@onready var inventory = $CanvasLayer/Inventory
@onready var player = $Player
@onready var npc = $Sandman



var currently_cast_object: Node2D
var currently_held_seed: Flower = null

func _ready():
	garden.connect("seed_harvested", on_seed_gain)
	garden.connect("stats_updated", on_garden_stats_updated)
	player.connect("player_interact", on_interact)
	player.connect("cast_hit_object", on_cast_hit_object)
	player.connect("cast_exit_object", on_cast_exit_object)
	inventory.connect("new_seed_selected", on_new_seed_selected)
	inventory.connect("seeds_emptied", on_seeds_emptied)
	npc.connect("give_flower_to_player", on_seed_gain)


func on_cast_hit_object(obj: Node):
	if obj.get_parent() is PlantingZone:
		obj.get_parent().zone_cast()
		#print("cast hit ", obj)
		currently_cast_object = obj.get_parent()
	elif obj.get_parent() is NPC:
		obj.get_parent().zone_cast()
		#print("cast hit ", obj)
		currently_cast_object = obj.get_parent()

func on_cast_exit_object(obj):
	if obj.get_parent() is PlantingZone:
		obj.get_parent().zone_exit()
		#print("cast exit ", obj)
		currently_cast_object = null
	elif obj.get_parent() is NPC:
		obj.get_parent().zone_exit()
		#print("cast exit ", obj)
		currently_cast_object = null




func on_new_seed_selected(flower_seed: Flower):
	currently_held_seed = flower_seed
func on_seeds_emptied():
	currently_held_seed = null

func on_interact():
	print("checking if npc or plot: ", currently_cast_object)
	#print (currently_held_seed, currently_cast_object is PlantingZone)
	if currently_cast_object is NPC:
		print("discussion:")
		currently_cast_object.interact_with()
	elif currently_held_seed and currently_cast_object is PlantingZone:
		
		if !currently_cast_object.zone_full:
			garden.plant_flower(currently_held_seed, currently_cast_object)
			#.add_flower_to_zone()
			inventory.remove_flower()
	



func on_seed_gain(flower: Flower, amount: int):
	inventory.add_flower(flower, amount)

func on_garden_stats_updated(stats: Dictionary):
	var stat_names = stats.keys()
	var stat_values = stats.values()
	
	#for i in range(stats.size()):
		#print("stat  ", i, "   ", stat_names[i], " ", stat_values[i])
	gardenUI.update_all_stats(stat_values)
