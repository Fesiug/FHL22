
-- Necessities
SWEP.Base					= "fhl22_base"

-- Information
SWEP.Spawnable				= true
SWEP.Category				= "FHL22"
SWEP.PrintName				= "Pistol"
SWEP.Slot					= 1
SWEP.SlotPos				= 0

-- Appearance
SWEP.ViewModel				= "models/weapons/c_pistol.mdl"
SWEP.WorldModel				= "models/weapons/w_pistol.mdl"
SWEP.ViewModelFOV			= 65

-- Stats
SWEP.Stats = {}

SWEP.Stats["Magazine"] = {}
SWEP.Stats["Magazine"]["Ammo reloaded"] 	= 18
SWEP.Stats["Magazine"]["Ammo loaded max"]	= 18

SWEP.Stats["Function"] = {}
SWEP.Stats["Function"]["Maximum burst"]		= 1
SWEP.Stats["Function"]["Firing delay"]		= 0.15
SWEP.Stats["Function"]["Ammo used"] 		= 1
SWEP.Stats["Function"]["Ammo required"]		= 1

SWEP.Stats["Appearance"] = {}
SWEP.Stats["Appearance"]["Firing sound"]	= ")weapons/pistol/pistol_fire2.wav"

SWEP.Stats["Bullet"] = {
	["Damage"] = Range(5, 5),
	["Range"] = Range(0, 0),
	["Spread"] = Range(1, 7),
	["Spread time"] = Range(1, 0.3),
	["Force"] = 1,
	["Count"] = 1
}

SWEP.Stats["Animation"] = {
	["draw"] = {
		seq = "draw",
	},
	["holster"] = {
		seq = "holster",
	},
	["reload"] = {
		seq = "reload",
		time_load = 1
	},
}