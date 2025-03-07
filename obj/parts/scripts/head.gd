extends Item
class_name Head


func _init():
	slot = "HEAD"

func wear_down(damage):
	curr_durability -= damage
