extends Node2D

var planted_flowers: float = 0 #maybe redundant since planting zones will handle the flower info
var garden_planting_zones: Array


var garden_stats_total : Dictionary = {
	"love": 0.0, "relief": 0.0, "pride": 0.0, "lust": 0.0, "patience": 0.0, "joy": 0.0,
	"sorrow":0.0, "anger":0.0, "trust":0.0, "hope":0.0, "zeal":0.0, "contemplation": 0.0
}

var garden_stats_normalized : Dictionary = {
	"love": 0.0, "relief": 0.0, "pride": 0.0, "lust": 0.0, "patience": 0.0, "joy": 0.0,
	"sorrow": 0.0, "anger": 0.0, "trust": 0.0, "hope": 0.0, "zeal": 0.0, "contemplation": 0.0
}


signal seed_harvested(flower: Flower)
signal stats_updated(stats_average: Dictionary)
signal zone_hovered(zone: PlantingZone)
signal plant_planted
#signal stat_neutralized(stat: String) #, neutralized: bool)

func _ready():
	for zone in $PlantingZones.get_children():
		new_planting_zone(zone)

func harvest_flower_int(zone: int):
	#gives you 2-4 seeds and removes the flower
	var new_seeds : Flower = garden_planting_zones[zone].flower_in_zone
	new_seeds.growth_stage = -1
	
	var amount = randi_range(2,4)
	
	seed_harvested.emit(new_seeds, amount)
	garden_planting_zones[zone].clear_zone()
	planted_flowers -= 1
	pass
func harvest_flower_zone(zone: PlantingZone):
	#gives you 2-4 seeds and removes the flower
	var new_seeds : Flower = zone.flower_in_zone
	new_seeds.growth_stage = -1
	
	var amount = randi_range(2,4)
	
	seed_harvested.emit(new_seeds, amount)
	print(zone.flower_in_zone)
	zone.clear_zone()
	planted_flowers -= 1
	
	
	calculate_garden_stats()
	print("ZONE                                                         ",zone.flower_in_zone)

func plant_flower(flower: Flower, zone: PlantingZone):
	#print("DFZGZEBGILHABGFLIAEB")
	#garden_planting_zones[zone]
	if !zone.flower_in_zone or (zone.flower_in_zone and zone.flower_in_zone.growth_stage == 0 and 
	!(zone.flower_in_zone.is_fusion or flower.is_fusion)):
		zone.add_flower_to_zone(flower)
		planted_flowers += 1
		plant_planted.emit(flower)

func new_planting_zone(zone: PlantingZone):
	zone.connect("growth_end", on_plant_in_zone_growth_end)
	zone.connect("zone_hovered", on_zone_hovered)
	for current_zone in $PlantingZones.get_children():
		if zone == current_zone:
			return
	$PlantingZones.add_child(zone)

func on_zone_hovered(zone):
	zone_hovered.emit(zone)


func on_plant_in_zone_growth_end():
	#await get_tree().create_timer(0.2)
	calculate_garden_stats()

func calculate_garden_stats():
	for stat in garden_stats_total:
		garden_stats_total[stat] = 0
		garden_stats_normalized[stat] = 0
	
	var total_stats : float = 0.0
	
	for zone in $PlantingZones.get_children():
		var flower : Flower = zone.flower_in_zone
		if flower and flower.growth_stage == 3:
			var flower_stats_dict = flower.get_flower_stats_dict()
			#print("éééééééé   ", flower_stats_dict)
			#print(flower.get("plant_name"), " : Stat - ", flower_stats_dict)
			for stat in flower_stats_dict:
				#print(str(flower_stats_dict[stat]))
				if str(flower_stats_dict[stat]) != "Neutralizing" and str(garden_stats_total[stat]) != "Neutralizing":
					#print(flower_stats_dict[stat], "      ----    ",garden_stats_total[stat]) 
					garden_stats_total[stat] += flower_stats_dict[stat]
				else:
					garden_stats_total[stat] = "Neutralizing"
				
				#print("stat ", stat, " updated to ", garden_stats_total[stat])
				
	
	for stat in garden_stats_total:
		#print("__________________",typeof( garden_stats_total[stat]))
		#print(garden_stats_total[stat])
		if garden_stats_total[stat] is not String:
			total_stats += abs(garden_stats_total[stat])
			#print("_______________________ total stats value updated : ", total_stats)
	
	
	for stat in garden_stats_normalized:
		if garden_stats_total[stat] is not String:
			garden_stats_normalized[stat] = snappedf(float(garden_stats_total[stat] / total_stats) * 100.0, 0.0001)
			if abs(garden_stats_normalized[stat]) < 10.0:
				total_stats -= abs(garden_stats_total[stat])
				garden_stats_total[stat] = 0.0
		#print("(((((((1)))))))  ",garden_stats_normalized[stat])
	
	#for stat in garden_stats_normalized:
		#if garden_stats_total[stat] is not String and abs(garden_stats_normalized[stat]) < 10.0:
			#total_stats -= abs(garden_stats_total[stat])
			#garden_stats_total[stat] = 0.0
		#print("(((((((2)))))))  ",garden_stats_normalized[stat])
	
	for stat in garden_stats_normalized:
		if garden_stats_total[stat] is not String:
			garden_stats_normalized[stat] = snappedf(float(garden_stats_total[stat] / total_stats) * 100.0, 0.0001)
			#print("(((((((2.5)))))))  ",garden_stats_total[stat])
		else:
			garden_stats_normalized[stat] = "Neutralizing"
		#print("(((((((3)))))))  ",garden_stats_normalized[stat])
		#else:
			#garden_stats_normalized[stat] = 10000
		#print("cheking operation - ", garden_stats_normalized[stat], " | ", garden_stats_total[stat], " ---- ", total_stats, "  [",float(garden_stats_total[stat] / total_stats) * 100.0, "]")
	#print(": Total stats : ",total_stats)
	#print(": Normalized : ", garden_stats_normalized)
	#print(": Total : ", garden_stats_total)
	#print(": Number of flowers :", planted_flowers)
	stats_updated.emit(garden_stats_normalized)
