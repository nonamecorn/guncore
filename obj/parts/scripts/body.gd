extends Item
class_name Body
var slot : String = "BODY"
var broken = false

func wear_down(damage):
	curr_durability -= damage
	
	broken = (curr_durability<=0)
	print(curr_durability, broken)
