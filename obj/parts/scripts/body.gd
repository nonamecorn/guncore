extends Item
class_name Body
var slot : String = "BODY"


func wear_down(damage):
	curr_durability -= damage
