extends Node2D
class_name Flower


var sprite_directory : String = "res://Assets/Prototypes/"
@export var id: int

var seed_texture : Texture2D #= load(sprite_directory + str(id) + "_seed.png")
var plant_texture : Texture2D #= load(sprite_directory + str(id) + ".png")

@export_range(-1, 3, 1) var growth_stage : int = 0
var growing: bool
#@onready var growth_timer : Timer = $CycleTimer

signal flower_grew

var is_fusion : bool = false

@export var info: Dictionary = {
		"plant_name": "", 
			"love": 0, "relief": 0, "pride": 0, "lust": 0, "patience": 0, "joy": 0,
			"sorrow":0, "anger":0, "trust":0, "hope":0, "zeal":0, "contemplation":0,
		"growth_time": 5.0, "sun_multiplier": 1.5, "water_needs": 1
	}

func _ready():
	#print("flower ", self, " exists with textures : ", seed_texture, " and ", plant_texture)
	pass
	#$Sprite2D.frame = growth_stage
	#print($CycleTimer.is_inside_tree())
	#$CycleTimer.wait_time = info.get("growth_time")/4 * 5
	#print("time: ", info.get("growth_time")/2, "    ", $CycleTimer.wait_time)
	#if $CycleTimer.wait_time == 0:
		#$CycleTimer.wait_time = 5
	

func _init(new_id: int = id):
	id = new_id
	#print("¨ Initialization of the flower from data: id = ",id)
	
	initialize_all_stats_from_json()
	
	seed_texture = load(sprite_directory + str(id) + "_seed.png")
	plant_texture = load(sprite_directory + str(id) + ".png")
	#if !seed_texture:
		#seed_texture = load(sprite_directory + "0_seed.png")
		#plant_texture = load(sprite_directory + "0.png")
	
	#Debug.print(get_relevant_flower_info())
	#print("plant texture = ", plant_texture)
	#print(info)
	#$Sprite2D.texture = load(sprite_directory + str(id) + ".png")
	
	#info["flower_name"] = "A"
	#info["love"] = 0
	#info["relief"] = 0
	#info["pride"] = 0
	#info["lust"] = 0
	#info["patience"] = 0
	#info["joy"] = 0
	#info["sorrow"] = 0
	#info["anger"] = 0
	#info["trust"] = 0
	#info["hope"] = 0
	#info["zeal"] = 0
	#info["contemplation"] = 0
	#info["growth_time"] = 4
	#info["sun_multiplier"] = 4
	#info["water_needs"] = 2
	
	pass
	
func initialize_stat_from_json(stat_name, new_id: int = id):
	var flower_data : float = 0
	
	#print("- initialize_stat_from_json()")
	#print("- initializing stat ", stat_name, " for flower with id ", id, " from json")
	#print("- Stat value is  ", GlobalFlowersData.data_array[new_id].get(stat_name))
	#print("stat_name ", stat_name)
	var stat_value = GlobalFlowersData.data_array[new_id].get(stat_name)
	
	#for flower in GlobalFlowersData.data_array:
		#var stat_value1 = flower.get(stat_name)
	#print(stat_name, " : ", stat_value)
	initialize_stat(stat_name, stat_value)
	pass
func initialize_all_stats_from_json():
	#print("/ initialize_all_stats_from_json()")
	for stat in info:
		#print("/ Iterating through all stats of the flower. Currently stat ", stat)
		
		initialize_stat_from_json(stat)
		#print("/ Stat value = ", info.get(stat))

func initialize_stat(stat, value):
	#print("__________________________")
	#print("° Setting stat ", stat, " to the value of ", value)
	info[stat] = value
	#print("° Stat ", stat, " is now of value ", info[stat])

func generate_fused_flower(fuse_with: Flower):
	Debug.print(self.info, "\n", fuse_with.info)
	info["plant_name"] = info["plant_name"] + "-"+ fuse_with.info["plant_name"]
	info["growth_time"] = (info["growth_time"] + fuse_with.info["growth_time"])/2
	if fuse_with.info["sun_multiplier"] > info["sun_multiplier"]:
		info["sun_multiplier"] = fuse_with.info["sun_multiplier"]
	if fuse_with.info["water_needs"] > info["water_needs"]:
		info["water_needs"] = fuse_with.info["water_needs"]
	
	var f1_stats : Dictionary = get_flower_stats_dict()
	var f2_stats : Dictionary = fuse_with.get_flower_stats_dict()
	
	var fourth_rule_array : Array = []
	
	for stat in f1_stats:
		Debug.print(stat, " : ", f1_stats[stat], " % ", f2_stats[stat])
		if (f1_stats[stat] == 0.0 or f2_stats[stat] == 0.0) and !(f1_stats[stat] == 0.0 and f2_stats[stat] == 0.0):
			Debug.print("One of the flowers has a value of 0")
			f1_stats[stat] += f2_stats[stat]
			if f1_stats[stat] > 1.0:
				f1_stats[stat] -= 1.0
		
		elif f1_stats[stat] > 0 and f2_stats[stat] > 0:
			var addition = f1_stats[stat] + f2_stats[stat]
			var addition_diff = maxf(f1_stats[stat], f2_stats[stat])*2 - minf(f1_stats[stat], f2_stats[stat])
			f1_stats[stat] = maxf(addition, addition_diff)
		
		#fifth rule : Two negatives neutralize the stat for the whole garden
		elif f1_stats[stat] < 0 and f2_stats[stat] < 0:
			f1_stats[stat] = 10000.0
		
		#swapped places for order of operations, but this was originally below and so 4th rule
		elif f1_stats[stat] > 0 and f2_stats[stat] < 0:
			var value1 = f1_stats[stat]
			var value2 = f2_stats[stat]
			var rand_multiplier : Array = [1, 1, 1, -1]
			
			f1_stats[stat] = 0.0
			var assign_later = (abs(value1) + abs(value2)) * rand_multiplier.pick_random()
			
			fourth_rule_array.append([stat, assign_later])
			f1_stats[get_random_stat(f1_stats, stat, true)] = (abs(value1) + abs(value2)) * rand_multiplier.pick_random()
		
		#third rule
		elif f1_stats[stat] < 0.0 and f2_stats[stat] > 0.0:
			f1_stats[stat] += f2_stats[stat] * 2.0
			f1_stats[get_random_stat(f1_stats, stat)] -= 1.0
		
		
		
		info[stat] = f1_stats[stat]
		#print("--------- stat (((((((1)))))))",info[stat])
		Debug.print("Value changed to ", f1_stats[stat])
	
	#rule 4 has to be treated after everything
	for stat in f1_stats:
		for i in fourth_rule_array:
			#print(fourth_rule_array)
			#print(i, " - ", i[0])
			if i[0] == stat:
				info[get_random_stat(f1_stats, stat, true)] = i[1]
			#print("--------- stat (((((((2)))))))",info[stat])
	
	for stat in f1_stats:
		#print("--------- stat (((((((3)))))))",info[stat])
		if f1_stats[stat] > 5000.0:
			info[stat] = "Neutralizing"
	
	is_fusion = true
	Debug.print(info)
	pass

func get_random_stat(stats: Dictionary, exempted_stat, equal_to_zero : bool = false) :
	var dict : Dictionary = stats.duplicate()
	dict.erase(exempted_stat)
	
	var dict_to_array : Array
	
	
	if !equal_to_zero:
		for stat in dict:
			dict_to_array.append(stat)	
	else:
		for stat in dict:
			if dict[stat] == 0:
				dict_to_array.append(stat)
	
	return dict_to_array.pick_random()

func generate_seeds():
	#simple idea, is seeds in inventory = growth_stage -1.
	#Not handled here, handled in garden
	pass



func grow():
	if growth_stage < 3:
		growth_stage += 1
		#print("F????????????????????????")
		growing = true
		
		#print("growth stage : ", growth_stage)
		#flower_grew.emit()

#func flower_growth_cycle():
	##$CycleTimer.start()
	#pass
#
#func _on_cycle_timer_timeout():
	#grow()
	#if growth_stage != 3:
		#flower_growth_cycle()
		#print("+1 (", growth_stage, ")")
func get_flower_seed_sprite() -> Sprite2D:
	var seed_sprite = Sprite2D.new() 
	
	seed_sprite.texture = seed_texture
	return seed_sprite
	
func get_flower_plant_sprite() -> Sprite2D:
	var flower_sprite = Sprite2D.new()
	
	flower_sprite.offset.y = -2
	flower_sprite.hframes = 4
	flower_sprite.region_enabled = true
	flower_sprite.set_region_rect(Rect2(0, 0, 16, 6))
	flower_sprite.scale = Vector2(4, 4)
	flower_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	flower_sprite.texture = load(sprite_directory + str(id) + ".png")
	return flower_sprite

func get_flower_stats_dict() -> Dictionary:
	var stat_dict : Dictionary 
	#if growth_stage == 3:
	stat_dict = info.duplicate()
	stat_dict.erase("plant_name")
	stat_dict.erase("sun_multiplier")
	stat_dict.erase("growth_time")
	stat_dict.erase("water_needs")
	return stat_dict

func get_relevant_flower_info() -> Dictionary:
	var stat_dict_1 : Dictionary 
	stat_dict_1 = info.duplicate()
	
	var to_remove: Array
	for data_point in info:
		
		#if str(stat_dict_1.get(data_point)) == "0":
			#to_remove.append(data_point)
		if str(stat_dict_1.get(data_point)) == "0":
			to_remove.append(data_point)
		
		#print(data_point, "   ", stat_dict_1[data_point])
		#print(typeof(stat_dict_1[data_point]))
		#if stat_dict_1[data_point] is float and stat_dict_1[data_point] >= 5000 :
			#stat_dict_1[data_point] = "Neutralizing"
			
	for i in to_remove:
		stat_dict_1.erase(i)
	#print("-------------------", stat_dict)
	return stat_dict_1
