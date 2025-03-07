extends Item
class_name Body
 

func _init():
	slot = "BODY"

func wear_down(damage):
	curr_durability -= damage
