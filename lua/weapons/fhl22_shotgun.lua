
-- Necessities
SWEP.Base					= "fhl22_base"

-- Information
SWEP.Spawnable				= true
SWEP.Category				= "FHL22"
SWEP.PrintName				= "Shotgun"
SWEP.Slot					= 3
SWEP.SlotPos				= 0

-- Appearance
SWEP.ViewModel				= Model("models/fhl22/weap/shotgun.mdl")
SWEP.WorldModel				= Model("models/weapons/w_shotgun.mdl")
SWEP.ViewModelFOV			= 50

-- Stats
SWEP.Stats = {}

SWEP.Stats["Magazine"] = {}
SWEP.Stats["Magazine"]["Ammo reloaded"] 	= 1
SWEP.Stats["Magazine"]["Ammo loaded max"]	= 6
SWEP.Stats["Magazine"]["Ammo type"]			= "buckshot"

SWEP.Stats["Function"] = {}
SWEP.Stats["Function"]["Maximum burst"]		= 1
SWEP.Stats["Function"]["Firing delay"]		= 0.8
SWEP.Stats["Function"]["Ammo used"] 		= 1
SWEP.Stats["Function"]["Ammo required"]		= 1
SWEP.Stats["Function"]["Damage type"]		= DMG_BULLET + DMG_BUCKSHOT

SWEP.Stats["Appearance"] = {}
SWEP.Stats["Appearance"]["Firing sound"]	= "FHL22.Shotgun.Fire"
SWEP.Stats["Appearance"]["Recoil mult"]		= 16
SWEP.Stats["Appearance"]["Recoil decay"]	= 32

SWEP.Stats["Melee"] = {}
SWEP.Stats["Melee"]["Damage"]				= 20
SWEP.Stats["Melee"]["Range"]				= 64

SWEP.Stats["Bullet"] = {
	["Damage"] = Range(8, 8),
	["Range"] = Range(0, 0),
	["Spread"] = Range(7, 7),
	["Spread time"] = Range(1, 0.3),
	["Force"] = 5,
	["Count"] = 7
}

SWEP.Stats["Animation"] = {
	["idle"] = {
		seq = "idle",
	},
	["draw"] = {
		seq = "ready",
		events = { { t = 0.2, s = "FHL22.Shotgun.Pump" } }
	},
	["holster"] = {
		seq = "holster",
		rate = 2,
	},
	["fire"] = {
		seq = "fire",
		events = { { t = 0.45, s = "FHL22.Shotgun.Forearm_Back" }, { t = 0.45+0.25, s = "FHL22.Shotgun.Forearm_Forward" } }
	},
	["melee"] = {
		{
			seq = "melee1",
			events = { { t = 0, s = "FHL22.Shotgun.Melee1" }, { t = 0.8, s = "FHL22.Shotgun.MeleeRecovery" } }
		},
		{
			seq = "melee2",
			events = { { t = 0, s = "FHL22.Shotgun.Melee2" }, { t = 0.8, s = "FHL22.Shotgun.MeleeRecovery" } }
		},
	},
	["throw_grenade"] = {
		seq = "throw_grenade",
		events = { { t = 0, s = "FHL22.Grenade.Throw" } }
	},
	["reload_enter"] = {
		seq = "reload_start",
		events = { { t = 0, s = "FHL22.Shotgun.MeleeRecovery" } }
	},
	["reload_insert"] = {
		seq = "reload_load",
		time_load = 0.16,
		events = { { t = 0.1, s = "FHL22.Shotgun.ReloadLoad" } }
	},
	["reload_exit"] = {
		seq = "reload_end",
		events = { { t = 0.4, s = "FHL22.Shotgun.Forearm_Back" }, { t = 0.6, s = "FHL22.Shotgun.Forearm_Forward" } }
	},
}

local pn = {100, 100}
sound.Add({
	name = "FHL22.Grenade.Throw",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 140,
	pitch = pn,
	sound = {
		")fhl22/weap/grenade_throw.wav",
	},
})

sound.Add({
	name = "FHL22.Shotgun.Fire",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 140,
	pitch = pn,
	sound = {
		")fhl22/weap/shotgun/fire1.wav",
		")fhl22/weap/shotgun/fire2.wav",
		")fhl22/weap/shotgun/fire3.wav",
	},
})

sound.Add({
	name = "FHL22.Shotgun.Pump",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 140,
	pitch = pn,
	sound = {
		")fhl22/weap/shotgun/pump.wav",
	},
})

sound.Add({
	name = "FHL22.Shotgun.Forearm_Back",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 140,
	pitch = pn,
	sound = ")fhl22/weap/shotgun/forearm_back.wav",
})

sound.Add({
	name = "FHL22.Shotgun.Forearm_Forward",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 140,
	pitch = pn,
	sound = ")fhl22/weap/shotgun/forearm_forward.wav",
})

sound.Add({
	name = "FHL22.Shotgun.Melee1",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 140,
	pitch = pn,
	sound = {
		")fhl22/weap/shotgun/melee1_1.wav",
		")fhl22/weap/shotgun/melee1_3.wav",
		--")fhl22/weap/shotgun/melee1_1.wav",
		--")fhl22/weap/shotgun/melee1_2.wav",
		--")fhl22/weap/shotgun/melee1_3.wav",
	},
})

sound.Add({
	name = "FHL22.Shotgun.Melee2",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 140,
	pitch = pn,
	sound = {
		")fhl22/weap/shotgun/melee2_2.wav",
		--")fhl22/weap/shotgun/melee2_1.wav",
		--")fhl22/weap/shotgun/melee2_2.wav",
		--")fhl22/weap/shotgun/melee2_3.wav",
	},
})

sound.Add({
	name = "FHL22.Shotgun.ReloadLoad",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 140,
	pitch = pn,
	sound = {
		")fhl22/weap/shotgun/rl1.wav",
		")fhl22/weap/shotgun/rl2.wav",
		")fhl22/weap/shotgun/rl3.wav",
		")fhl22/weap/shotgun/rl4.wav",
		")fhl22/weap/shotgun/rl5.wav",
		")fhl22/weap/shotgun/rl6.wav",
		")fhl22/weap/shotgun/rl7.wav",
		")fhl22/weap/shotgun/rl8.wav",
	},
})

sound.Add({
	name = "FHL22.Shotgun.MeleeRecovery",
	channel = CHAN_STATIC,
	volume = 0.2,
	level = 140,
	pitch = pn,
	sound = {
		")fhl22/weap/shotgun/melee.wav",
	},
})