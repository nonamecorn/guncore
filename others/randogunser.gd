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

func get_gun() -> Dictionary:
	recievers.shuffle()
	mags.shuffle()
	barrels.shuffle()
	gun_preset.RECIEVER = recievers[0]
	gun_preset.BARREL = barrels[0]
	gun_preset.MAG = mags[0]
	return gun_preset
