extends Node

var flowers_json_path : String = "res://Assets/JSON/flowers.json"

var data_array : Array

func _init():
	var file = FileAccess.open(flowers_json_path, FileAccess.READ)
	
	var json_string = file.get_as_text()
	var json : JSON = JSON.new()
	var data = json.parse(json_string)
	data_array = json.data
	
	#print("data ((((()))))", data_array )
	#print("json ((((()))))", json )
	#print("json_string ((((()))))", json_string )
