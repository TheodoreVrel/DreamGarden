extends Control

@onready var stat_values = $HBoxContainer/StatValueVBoxContainer
@onready var stat_labels = $HBoxContainer/StatNameVBoxContainer

#var current_number_of_stats : int = 1
var current_total : float = 0.0

var values : Dictionary = {
	0: ["Love", "Loneliness", 0.0], 
	1: ["Relief", "Anxiety", 0.0], 
	2: ["Pride", "Shame", 0.0],
	3: ["Lust", "Frustration", 0.0],
	4: ["Patience", "Annoyance", 0.0],
	5: ["Joy", "Misery", 0.0],
	6: ["Sorrow", "Numbness", 0.0],
	7: ["Anger", "Suppression", 0.0],
	8: ["Trust", "Doubt", 0.0],
	9: ["Hope", "Despair", 0.0],
	10: ["Zeal", "Boredom", 0.0],
	11: ["Contemplation", "Stagnation", 0.0],
}

func _ready():
	for progressBar in stat_values.get_children():
		progressBar.value = 0
		hide_or_show_stat(progressBar)
	#print(get_dictionary_value($HBoxContainer/StatValueVBoxContainer/LustProgressBar,1))
	
	#on_stat_changed($HBoxContainer/StatValueVBoxContainer/PrideProgressBar, 30)
	#on_stat_changed($HBoxContainer/StatValueVBoxContainer/SorrowProgressBar, -12)


func change_stat(bar : ProgressBar, new_value: float):
	#update_value_dict(bar, new_value)
	
	
	bar.value = new_value
	print(bar, "   ",new_value,"    --- Updated the statbar")
	#await get_tree().create_timer(0.1)
	handle_stat_bar(bar)

func update_all_stats(new_stats : Array):
	#current_number_of_stats = 0
	current_total = 0.0
	var num = stat_values.get_child_count()
	for i in range(num):
		change_stat(stat_values.get_child(i), new_stats[i])

func handle_stat_bar(statBar : ProgressBar):
	#if current_number_of_stats != 0:
	#statBar.value = i
	#print(i, "   ","    --- Updated the statbar")
	if statBar.value < 0:
		change_stat_label(get_label_from_progress_bar(statBar), false)
		statBar.value = abs(statBar.value)
	else:
		change_stat_label(get_label_from_progress_bar(statBar), true)
	#print(statBar.value)
	
	hide_or_show_stat(statBar)
	#if statBar.value < 0:
		#invert_stat_label(get_label_from_progress_bar(statBar))

func hide_or_show_stat(statBar : ProgressBar):
	var label = get_label_from_progress_bar(statBar)
	if statBar.value == 0:
		statBar.visible = false
		label.visible = false
	else:
		statBar.visible = true
		label.visible = true

func change_stat_label(statLabel : Label, positive: bool):
	for i in range(values.size()):
		#print("EEEEEEEEEEE  ", i)
		if !positive and statLabel.text == values.get(i)[0]:
			statLabel.text = values.get(i)[1]
			return
		elif positive and statLabel.text == values.get(i)[1]:
			statLabel.text = values.get(i)[0]
			return

func get_label_from_progress_bar(bar : ProgressBar):
	#print(statBars.get_child(0))
	return stat_labels.get_child(get_dict_key(bar))

func get_dict_key(bar: ProgressBar) -> int:
	for i in range(stat_values.get_child_count()):
		if stat_values.get_child(i) == bar:
			return i
	return -1

func get_dictionary_value(bar: ProgressBar, dict_value : int = -1) :
	if dict_value != -1:
		return values.get(get_dict_key(bar))[dict_value]
	
	return values.get(get_dict_key(bar))

#func update_value_dict(bar: ProgressBar, new_value: int):
	#var current_value : int = get_dictionary_value(bar, 2)
	#var new_total_value : int = new_value
	#values[get_dict_key(bar)][2]= new_total_value
	##print(values)
