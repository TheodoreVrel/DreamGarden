extends Node

@onready var garden = $Garden
@onready var gardenUI = $CanvasLayer/GardenUI
@onready var inventory = $CanvasLayer/Inventory
@onready var player = $Player
#@onready var npc = $Sandman
@onready var shop = $Shop
@onready var shopUI = $CanvasLayer/ShopGrid

var packed_flower_scene : PackedScene = preload("res://Scenes/Flower/flower.tscn")

var currently_cast_object: Node2D
var currently_held_seed: Flower = null


signal game_manager_ready

func _ready():
	garden.connect("seed_harvested", on_seed_gain)
	garden.connect("stats_updated", on_garden_stats_updated)
	player.connect("player_interact", on_interact)
	player.connect("cast_hit_object", on_cast_hit_object)
	player.connect("cast_exit_object", on_cast_exit_object)
	inventory.connect("new_seed_selected", on_new_seed_selected)
	inventory.connect("seeds_emptied", on_seeds_emptied)
	#npc.connect("give_flower_to_player", on_seed_gain)
	shop.connect("open_shop", on_shop_open)
	shop.connect("seed_stock_updated", on_seed_stock_updated)
	shopUI.connect("bought_flower", on_seed_buy)
	shopUI.connect("closed_shop", on_shop_close)
	
	
	game_manager_ready.emit()
	
	#print(shop.get_signal_connection_list("seed_stock_updated"))

func on_cast_hit_object(obj: Node):
	if obj:
		if obj.get_parent().has_method("zone_cast"):
			obj.get_parent().zone_cast()
			#print("cast hit ", obj)
		currently_cast_object = obj.get_parent()
	
	#if obj.get_parent() is PlantingZone:
		#obj.get_parent().zone_cast()
		##print("cast hit ", obj)
		#currently_cast_object = obj.get_parent()
	#elif obj.get_parent() is NPC:
		#obj.get_parent().zone_cast()
		##print("cast hit ", obj)
		#currently_cast_object = obj.get_parent()

func on_cast_exit_object(obj):
	if obj:
		if obj.has_method("zone_exit"):
			obj.get_parent().zone_exit()
		currently_cast_object = null
	#if obj.get_parent() is PlantingZone:
		#obj.get_parent().zone_exit()
		##print("cast exit ", obj)
		#currently_cast_object = null
	#elif obj.get_parent() is NPC:
		#obj.get_parent().zone_exit()
		##print("cast exit ", obj)
		#currently_cast_object = null




func on_new_seed_selected(flower_seed: Flower):
	currently_held_seed = flower_seed
func on_seeds_emptied():
	currently_held_seed = null

func on_interact():
	#print("checking if npc or plot: ", currently_cast_object)
	#print (currently_held_seed, currently_cast_object is PlantingZone)
	
	if currently_held_seed and currently_cast_object is PlantingZone:
		if !currently_cast_object.zone_full:
			garden.plant_flower(currently_held_seed, currently_cast_object)
			#.add_flower_to_zone()
			inventory.remove_flower()
	
	elif currently_cast_object and currently_cast_object.has_method("interact_with"):
		#print(currently_cast_object)
		currently_cast_object.interact_with()
	



func on_seed_gain(flower: Flower, amount: int):
	inventory.add_flower(flower, amount)

func on_garden_stats_updated(stats: Dictionary):
	var stat_names = stats.keys()
	var stat_values = stats.values()
	
	#for i in range(stats.size()):
		#print("stat  ", i, "   ", stat_names[i], " ", stat_values[i])
	gardenUI.update_all_stats(stat_values)

func on_seed_buy(flower: Flower):
	#separate in case I add an economy (probably will to incentivise doing missions)
	on_seed_gain(flower, 1)

func on_shop_open(open: bool):
	shopUI.visible = open
	player.can_move = false
	player.can_interact = false

func on_shop_close():
	shopUI.visible = false
	player.can_move = true
	await get_tree().create_timer(0.2).timeout
	player.can_interact = true

func on_seed_stock_updated(stock: Array):
	print("seed stock received: ", stock)
	shopUI.empty_shop()
	
	var new_seed : Flower = packed_flower_scene.instantiate()
	print("Empty Seed : ", new_seed)
	for seed in stock:
		new_seed = seed
		print("seed = ", new_seed)
		shop.add_child(new_seed)
		shopUI.add_flower_to_shop(new_seed, 10)

func _on_shop_seed_stock_updated(stock):
	print("???????????? This only works if manually linked")
	pass # Replace with function body.
