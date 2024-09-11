extends Area2D
class_name Flower

var sprite_directory : String = "res://Assets/Prototypes/"
@export var id: int

@export_range(-1, 3, 1) var growth_stage : int = 0
var growing: bool
#@onready var growth_timer : Timer = $CycleTimer

signal flower_grew

var is_fusion : bool = false

@export var info: Dictionary = {
		"flower_name": "", "stats": 
		{
			"love": 0, "relief": 0, "pride": 0, "lust": 0, "patience": 0, "joy": 0,
			"sorrow":0, "anger":0, "trust":0, "hope":0, "zeal":0, "contemplation":0
		},
		"growth_time": 5.0, "sun_multiplier": 1.5, "rain_multiplier": 1.3
	}

func _ready():
	$Sprite2D.texture = load(sprite_directory + str(id) + ".png")
	#$Sprite2D.frame = growth_stage
	#print($CycleTimer.is_inside_tree())
	#$CycleTimer.wait_time = info.get("growth_time")/4 * 5
	#print("time: ", info.get("growth_time")/2, "    ", $CycleTimer.wait_time)
	#if $CycleTimer.wait_time == 0:
		#$CycleTimer.wait_time = 5
	



func generate_fused_flower(fuse_with: Flower):
	pass
	

func generate_seeds():
	#simple idea, is seeds in inventory = growth_stage -1.
	#Not handled here, handled in garden
	pass
#func generate_held_flower(id: int):
	#var temp_flower 
	#Globals.held_flower = generic_flower.instantiate()
	#Globals.held_flower.id = id
	#print(Globals.held_flower)
	#holding_flower = true



func grow():
	if growth_stage < 3:
		growth_stage += 1
		#print("F????????????????????????")
		growing = true
		
		print("growth stage : ", growth_stage)
		flower_grew.emit()

#func flower_growth_cycle():
	##$CycleTimer.start()
	#pass
#
#func _on_cycle_timer_timeout():
	#grow()
	#if growth_stage != 3:
		#flower_growth_cycle()
		#print("+1 (", growth_stage, ")")
