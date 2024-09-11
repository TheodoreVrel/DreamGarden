extends Node2D

var planted_flowers: int = 0 #maybe redundant since planting zones will handle the flower info
var garden_planting_zones: Array


var garden_stats_total : Dictionary = {
	"love": 0.0, "relief": 0.0, "pride": 0.0, "lust": 0.0, "patience": 0.0, "joy": 0.0,
	"sorrow":0.0, "anger":0.0, "trust":0.0, "hope":0.0, "zeal":0.0, "contemplation": 0.0
}

var garden_stats_average : Dictionary = {
	"love": 0.0, "relief": 0.0, "pride": 0.0, "lust": 0.0, "patience": 0.0, "joy": 0.0,
	"sorrow": 0.0, "anger": 0.0, "trust": 0.0, "hope": 0.0, "zeal": 0.0, "contemplation": 0.0
}


signal seed_harvested(flower: Flower)
signal stats_updated(stats_average: Dictionary)

func _ready():
	for zone in $PlantingZones.get_children():
		new_planting_zone(zone)

func harvest_flower(zone: int):
	#gives you 2-4 seeds and removes the flower
	var new_seeds : Flower = garden_planting_zones[zone].flower_in_zone
	new_seeds.growth_stage = -1
	
	var amount = randi_range(2,4)
	
	seed_harvested.emit(new_seeds, amount)
	garden_planting_zones[zone].clear_zone()
	planted_flowers -= 1
	pass

func plant_flower(flower: Flower, zone: PlantingZone):
	#print("DFZGZEBGILHABGFLIAEB")
	#garden_planting_zones[zone]
	zone.add_flower_to_zone(flower)
	
	planted_flowers += 1
	

func on_plant_in_zone_growth_end():
	await get_tree().create_timer(1)
	calculate_garden_stats()

func calculate_garden_stats():
	for stat in garden_stats_total:
		garden_stats_total[stat] = 0
	
	for zone in $PlantingZones.get_children():
		var flower = zone.flower_in_zone
		if flower:
			#print("============= ", flower.info["stats"])
			for stat in flower.info["stats"]:
				garden_stats_total[stat] += flower.info["stats"][stat]
				#print("total_______________________",garden_stats_total[stat])
	for stat in garden_stats_average:
		garden_stats_average[stat] = garden_stats_total[stat] / planted_flowers
	#print(garden_stats_average, " = ", garden_stats_total, " / ",planted_flowers)
	stats_updated.emit(garden_stats_average)

func new_planting_zone(zone: PlantingZone):
	zone.connect("growth_end", on_plant_in_zone_growth_end)
	for current_zone in $PlantingZones.get_children():
		if zone == current_zone:
			return
	$PlantingZones.add_child(zone)
