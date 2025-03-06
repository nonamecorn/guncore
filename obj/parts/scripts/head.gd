extends Item
class_name Head

var slot : String = "HEAD"

func wear_down(damage):
	curr_durability -= damage
