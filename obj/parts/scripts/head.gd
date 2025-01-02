extends Item
class_name Head

var slot : String = "HEAD"
var broken = false

func wear_down(damage):
	curr_durability -= damage
	broken = (curr_durability<=0)
