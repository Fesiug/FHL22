GM.Name = "Fesiug's Half-Life 2 2"
GM.Author = "N/A"
GM.Email = "N/A"
GM.Website = "N/A"

include( "player_class/player_freeman.lua" )
DEFINE_BASECLASS( "gamemode_base" )

function GM:Initialize()
	if SERVER then
		game.ConsoleCommand("sv_defaultdeployspeed 1\n")
		game.ConsoleCommand("sv_falldamage 1\n")
	end
end

function GM:PlayerSpawn( ply, tran )
	--[[if !tran then
		timer.Simple(0, function()
			game.CleanUpMap()
		end)
	end]]

	ply:UnSpectate()

	ply:SetSlowWalkSpeed(150)
	ply:SetWalkSpeed(190)
	ply:SetRunSpeed(320)
	ply:AllowFlashlight(true)

	player_manager.OnPlayerSpawn( ply, tran )
	player_manager.RunClass( ply, "Spawn" )

	-- If we are in transition, do not touch player's weapons
	if ( !tran ) then
		-- Call item loadout function
		hook.Call( "PlayerLoadout", GAMEMODE, ply )
		--self:LoadPlayer( ply )
		--[[timer.Simple(0, function()
			self:SavePlayer( ply )
		end)]]
	end

	-- Set player model
	hook.Call( "PlayerSetModel", GAMEMODE, ply )
	ply:SetupHands()
end

function GM:DoPlayerDeath(ply, att, dmg)
	--[[self:SavePlayer( ply )
	plyinfo[ply].hp = math.max(plyinfo[ply].hp, 1)]]
end

function GM:SavePlayer( ply )
	--[[plyinfo[ply] = {}
	plyinfo[ply].ammo = ply:GetAmmo()

	local wlist = {}
	local clip1 = {}
	for i, v in pairs(ply:GetWeapons()) do
		table.insert(wlist, v:GetClass())
		table.insert(clip1, v:Clip1())
	end
	plyinfo[ply].weapons = wlist
	plyinfo[ply].weaponsinfo = {}
	plyinfo[ply].weaponsinfo.clip1 = clip1
	plyinfo[ply].pos = ply:GetPos()
	plyinfo[ply].vel = ply:GetVelocity()
	plyinfo[ply].hp = ply:Health()
	plyinfo[ply].ar = ply:Armor()

	print("Saved ", ply, "!")
	PrintTable(plyinfo)]]
end

function GM:LoadPlayer( ply )
	--[[if true then return false end
	local ql = plyinfo[ply]
	if !plyinfo or !ql then
		print("FUCK " .. ply:Nick() )
		return
	end
	ply:StripWeapons()
	ply:StripAmmo()

	for i, v in ipairs(ql.ammo) do
		ply:GiveAmmo(v, i)
	end
	for i, v in ipairs(ql.weapons) do
		local wep = ply:Give(v)
		wep:SetClip1(ql.weaponsinfo.clip1[i])
	end

	ply:SetPos(ql.pos)
	ply:SetAbsVelocity(ql.vel)

	ply:SetHealth(ql.hp)
	ply:SetArmor(ql.ar)

	print("Loaded ", ply, "!")
	PrintTable(plyinfo)]]
end

--[[function GM:PlayerSetHandsModel( pl, ent )
	local info = { model = "models/weapons/c_arms_hev.mdl", skin = 0, body = "00000000" }

	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end
end]]
function GM:PlayerSetModel( pl )
	player_manager.RunClass( pl, "SetModel" )
end
function GM:PlayerSetHandsModel( pl, ent )
	local info = player_manager.RunClass( pl, "GetHandsModel" )
	if ( !info ) then
		local playermodel = player_manager.TranslateToPlayerModelName( pl:GetModel() )
		info = player_manager.TranslatePlayerHands( playermodel )
	end

	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end
end

local lasttime = CurTime()
function GM:PlayerNoClip( ply, mode )
	if !mode then
		return true
	elseif mode and ( CurTime() <= lasttime ) then
		ply:ConCommand("lastinv")
		return true
	else
		if ply:GetActiveWeapon() != NULL and ply:GetActiveWeapon():GetClass() == "weapon_physcannon" then
			ply:ConCommand("lastinv")
		else
			if SERVER then
				ply:SelectWeapon("weapon_physcannon")
			elseif CLIENT then
				input.SelectWeapon(ply:GetWeapon("weapon_physcannon"))
			end
		end
		lasttime = CurTime() + 0.2
	end
end