extends Control

@onready var stat_values = $HBoxContainer/StatValueVBoxContainer
@onready var stat_labels = $HBoxContainer/StatNameVBoxContainer

#var current_number_of_stats : int = 1
var current_total : float = 0.0

var values : Dictionary = {
	0: ["Love", "Loneliness"], 
	1: ["Relief", "Anxiety"], 
	2: ["Pride", "Shame"],
	3: ["Lust", "Frustration"],
	4: ["Patience", "Annoyance"],
	5: ["Joy", "Misery"],
	6: ["Sorrow", "Numbness"],
	7: ["Anger", "Suppression"],
	8: ["Trust", "Doubt"],
	9: ["Hope", "Despair"],
	10: ["Zeal", "Boredom"],
	11: ["Contemplation", "Stagnation"],
}

func _ready():
	for progressBar in stat_values.get_children():
		progressBar.value = 0
		hide_or_show_stat(progressBar)
	#print(get_dictionary_value($HBoxContainer/StatValueVBoxContainer/LustProgressBar,1))
	
	#on_stat_changed($HBoxContainer/StatValueVBoxContainer/PrideProgressBar, 30)
	#on_stat_changed($HBoxContainer/StatValueVBoxContainer/SorrowProgressBar, -12)


func change_stat(bar : ProgressBar, new_value: Variant):
	print("This is the new value: ", new_value)
	if new_value is not String:
		bar.value = new_value
	else: bar.value = 500
	#print(bar, "   ",new_value,"    --- Updated the statbar")
	handle_stat_bar(bar)

func update_all_stats(new_stats : Array):
	#current_number_of_stats = 0
	current_total = 0.0
	var num = stat_values.get_child_count()
	for i in range(num):
		change_stat(stat_values.get_child(i), new_stats[i])

#func neutralize_stat(stat):
	#change_stat()

func handle_stat_bar(statBar : ProgressBar):
	#if current_number_of_stats != 0:
	#statBar.value = i
	#print(i, "   ","    --- Updated the statbar")
	if statBar.value < 0:
		change_stat_label(get_label_from_progress_bar(statBar), false)
		statBar.value = abs(statBar.value)
	
	#elif statBar.value >= 110:
		#statBar.value = 0
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
	elif statBar.value >= 110:
		statBar.visible = true
		label.visible = true
		statBar.value = 0
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
