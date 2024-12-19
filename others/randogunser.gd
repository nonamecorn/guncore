extends Node


var recievers = [
	"res://obj/parts/guns/akm.tres",
	"res://obj/parts/guns/Luty.tres",
	"res://obj/parts/guns/MG.tres",
	"res://obj/parts/guns/PauzaP50.tres",
	"res://obj/parts/guns/PipeRifle.tres",
	"res://obj/parts/guns/PPsH.tres",
	"res://obj/parts/guns/shotgun.tres",
	"res://obj/parts/guns/SKS.tres",
]

var mags = [
	"res://obj/parts/mags/akmag.tres",
	"res://obj/parts/mags/Luty_mag.tres",
	"res://obj/parts/mags/MG_mag.tres",
	"res://obj/parts/mags/PauzaP50_mag.tres",
	"res://obj/parts/mags/PipeRifle_mag.tres",
	"res://obj/parts/mags/PPsH_mag.tres",
	"res://obj/parts/mags/shotgun_mag.tres",
	"res://obj/parts/mags/SKS_mag.tres",
]

var barrels = [
	"res://obj/parts/barrels/AK_barrel.tres",
	"res://obj/parts/barrels/GausBarrel.tres",
	"res://obj/parts/barrels/long_barrel.tres",
	"res://obj/parts/barrels/Luty_barrel.tres",
	"res://obj/parts/barrels/MG_barrel.tres",
	"res://obj/parts/barrels/PauzaP50_barrel.tres",
	"res://obj/parts/barrels/PipeRifle_barrel.tres",
	"res://obj/parts/barrels/PPsH_barrel.tres",
	"res://obj/parts/barrels/shotgun_barrel.tres",
	"res://obj/parts/barrels/SKS_barrel.tres",
]
var gun_preset = {
	"RECIEVER": null,
	"BARREL": null,
	"MAG": null,
	"MUZZLE": null,
	"MOD1": null,
	"MOD2": null,
	}

var shop_pool = [
	"res://obj/parts/muzzles/Muzzel_Brake.tres",
	"res://obj/parts/muzzles/grater.tres",
	"res://obj/parts/guns/CAWS.tres",
	"res://obj/parts/guns/AR-180.tres",
	"res://obj/parts/guns/PauzaP50.tres",
	"res://obj/parts/guns/SMGll.tres",
	"res://obj/parts/mags/CAWS_mag.tres",
	"res://obj/parts/mags/AR-180_mag.tres",
	"res://obj/parts/mags/SMGll_mag.tres",
	"res://obj/parts/mags/PauzaP50_mag.tres",
	"res://obj/parts/barrels/AR-180_barrel.tres",
	"res://obj/parts/barrels/CAWS_barrel.tres",
	"res://obj/parts/barrels/SMGll_barrel.tres",
	"res://obj/parts/barrels/Autoaim_barrel.tres",
	"res://obj/parts/attach/airburst_module.tres",
	"res://obj/parts/mags/athlete_mag.tres",
	"res://obj/parts/mags/AirBurst_mag.tres",
	#"res://obj/parts/body/light_armor.tres",
	"res://obj/parts/muzzles/silencer.tres",
	"res://obj/parts/guts/Firerate_Spring.tres",
	"res://obj/parts/guts/Fun_switch.tres",
]

var corp_guns = [
	"res://obj/parts/guns/CAWS.tres",
	"res://obj/parts/guns/AR-180.tres",
	"res://obj/parts/guns/SMGll.tres",
]
var corp_mags = [
	"res://obj/parts/mags/AR-180_mag.tres",
	"res://obj/parts/mags/CAWS_mag.tres",
	"res://obj/parts/mags/SMGll_mag.tres",
]
var corp_barrels = [
	"res://obj/parts/barrels/AR-180_barrel.tres",
	"res://obj/parts/barrels/CAWS_barrel.tres",
	"res://obj/parts/barrels/SMGll_barrel.tres",
]


func get_gun() -> Dictionary:
	recievers.shuffle()
	mags.shuffle()
	barrels.shuffle()
	gun_preset.RECIEVER = recievers[0]
	gun_preset.BARREL = barrels[0]
	gun_preset.MAG = mags[0]
	return gun_preset


func get_corp_gun() -> Dictionary:
	corp_guns.shuffle()
	corp_mags.shuffle()
	corp_barrels.shuffle()
	gun_preset.RECIEVER = corp_guns[0]
	gun_preset.BARREL = corp_barrels[0]
	gun_preset.MAG = corp_mags[0]
	return gun_preset

func get_shop() -> Array:
	var shop = []
	for i in 3:
		shop_pool.shuffle()
		shop.append(shop_pool[0])
	#print(shop)
	return shop
	
