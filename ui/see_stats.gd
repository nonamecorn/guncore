extends TextureRect

var stats = {}
var desc_text = ""


func calc_diff(mod_stats: Dictionary) -> String:
	var keys = stats.keys()
	keys = keys.filter(func(key): return mod_stats.has(key))
	var strings = ""
	for key in keys:
		strings += (key + ": " + str(stats[key]) + " -> " + str(mod_stats[key]) + "\n")
	return strings
