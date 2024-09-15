extends InteractiveObject

# hyacinth, lavender, rose, sage, sunflower, tansy
var starting_seed_stock : Array = [7, 9, 21, 23, 25, 26] 

var seed_stock : Array = []

signal open_shop(bool)
signal seed_stock_updated(stock: Array)
signal test_stock_updated

func interact_with():
	#print("hello shop")
	open_shop.emit(true)

func _ready():
	get_parent().connect("game_manager_ready", on_game_manager_ready)
	#await get_tree().create_timer(0.35).timeout
	

func on_game_manager_ready():
	initialize_shop_flowers()

func initialize_shop_flowers():
	var new_flower : Flower
	for flower_id in starting_seed_stock:
		new_flower = Flower.new(flower_id)
		print("---------------------   ", new_flower.info.get("plant_name"))
		seed_stock.append(new_flower)
	
	print("emit seed stock : ", seed_stock)
	seed_stock_updated.emit(seed_stock)
	test_stock_updated.emit()

#func update_seed_stock():
	
