extends Node

func _ready() -> void:
	var gun = Randogunser.get_gun()
	var t1 = load(gun.RECIEVER)
	t1.picked_up = true
	var t2 = load(gun.MAG)
	t2.picked_up = true
	var t3 = load(gun.BARREL)
	t3.picked_up = true
	items.append(load(gun.RECIEVER))
	items.append(load(gun.MAG))
	items.append(load(gun.BARREL))
	var shop_strs = Randogunser.get_shop()
	for path in shop_strs:
		if !path: continue
		var shop_res = load(path)
		shop.append(shop_res)


const item_base = preload("res://ui/item_base.tscn")



var items = [
	#load("res://obj/parts/guns/akm.tres"),
	#load("res://obj/parts/barrels/long_barrel.tres"),
	#load("res://obj/parts/mags/akmag.tres"),
	#load("res://obj/parts/guns/PPsH.tres"),
	#load("res://obj/parts/mags/PPsH_mag.tres"),
	#load("res://obj/parts/barrels/AK_barrel.tres"),
	#load("res://obj/parts/barrels/PPsH_barrel.tres"),
	#load("res://obj/parts/barrels/MG_barrel.tres"),
	#load("res://obj/parts/guns/MG.tres"),
	#load("res://obj/parts/mags/MG_mag.tres"),
	#load("res://obj/parts/muzzles/grater.tres"),
	#load("res://obj/parts/muzzles/Muzzel_Brake.tres"),
	#load("res://obj/parts/barrels/GausBarrel.tres"),
	#load("res://obj/parts/guns/SKS.tres"),
	#load("res://obj/parts/barrels/SKS_barrel.tres"),
	#load("res://obj/parts/mags/SKS_mag.tres"),
	#load("res://obj/parts/guns/shotgun.tres"),
	#load("res://obj/parts/mags/shotgun_mag.tres"),
	#load("res://obj/parts/barrels/shotgun_barrel.tres"),
	#load("res://obj/parts/guns/Luty.tres"),
	#load("res://obj/parts/mags/Luty_mag.tres"),
	#load("res://obj/parts/barrels/Luty_barrel.tres"),
	#load("res://obj/parts/guns/PipeRifle.tres"),
	#load("res://obj/parts/mags/PipeRifle_mag.tres"),
	#load("res://obj/parts/barrels/PipeRifle_barrel.tres"),
	#load("res://obj/parts/guns/PauzaP50.tres"),
	#load("res://obj/parts/mags/PauzaP50_mag.tres"),
	#load("res://obj/parts/barrels/PauzaP50_barrel.tres"),
	#load("res://obj/parts/barrels/AR-180_barrel.tres"),
	#load("res://obj/parts/guns/AR-180.tres"),
	#load("res://obj/parts/mags/AR-180_mag.tres"),
	#load("res://obj/parts/barrels/CAWS_barrel.tres"),
	#load("res://obj/parts/guns/CAWS.tres"),
	#load("res://obj/parts/mags/CAWS_mag.tres"),
	#load("res://obj/parts/barrels/SMGll_barrel.tres"),
	#load("res://obj/parts/guns/SMGll.tres"),
	#load("res://obj/parts/mags/SMGll_mag.tres"),
]
var fullscreen = false
var money = 100
var shop = []
