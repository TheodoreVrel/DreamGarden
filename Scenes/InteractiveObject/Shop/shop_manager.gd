extends InteractiveObject

# hyacinth, lavender, rose, sage, sunflower, tansy
var starting_seed_stock : Array = [7, 9, 21, 23, 25, 26] 

var seed_stock : Array = []

signal open_shop(bool)
signal seed_stock_updated(stock: Array)

func interact_with():
	open_shop.emit(true)

func _ready():
	initialize_shop_flowers()
	
func initialize_shop_flowers():
	var new_flower : Flower
	for flower_id in starting_seed_stock:
		new_flower = Flower.new(flower_id)
		print("---------------------   ", new_flower.info.get("plant_name"))
		seed_stock.append(new_flower)
	
	print("emit seed stock : ", seed_stock)
	seed_stock_updated.emit(seed_stock)

#func update_seed_stock():
	
