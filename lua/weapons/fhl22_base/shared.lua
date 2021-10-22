
-- Necessities
SWEP.FHL22					= true
SWEP.Base					= "weapon_base"
SWEP.BobScale				= 0
SWEP.SwayScale				= 0
SWEP.UseHands				= true

function Range( m, a )
	return { min = m, max = a }
end

-- Information
SWEP.Spawnable				= true
SWEP.PrintName				= "FHL22 Base"
SWEP.Category				= "FHL22"
SWEP.Slot					= 1
SWEP.SlotPos				= 0

-- Appearance
SWEP.ViewModel				= "models/weapons/c_pistol.mdl"
SWEP.WorldModel				= "models/weapons/w_pistol.mdl"
SWEP.ViewModelFOV			= 65

-- Function
SWEP.Primary.ClipSize		= 0
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Ammo			= ""
SWEP.Primary.Automatic		= true

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Ammo			= ""
SWEP.Secondary.Automatic	= true

-- Stats
SWEP.Stats = {}

SWEP.Stats["Magazine"] = {}
SWEP.Stats["Magazine"]["Ammo reloaded"] 	= 18
SWEP.Stats["Magazine"]["Ammo loaded max"]	= 18
SWEP.Stats["Magazine"]["Ammo type"]			= "pistol"

SWEP.Stats["Function"] = {}
SWEP.Stats["Function"]["Maximum burst"]		= 1
SWEP.Stats["Function"]["Firing delay"]		= 0.15
SWEP.Stats["Function"]["Ammo used"] 		= 1
SWEP.Stats["Function"]["Ammo required"]		= 1

SWEP.Stats["Appearance"] = {}
SWEP.Stats["Appearance"]["Firing sound"]	= ")weapons/pistol/pistol_fire2.wav"
SWEP.Stats["Appearance"]["Recoil mult"]		= 3
SWEP.Stats["Appearance"]["Recoil decay"]	= 5

SWEP.Stats["Bullet"] = {
	["Damage"] = Range(5, 5),
	["Range"] = Range(0, 0),
	["Spread"] = Range(1, 7),
	["Spread time"] = Range(1, 0.3),
	["Force"] = 1,
	["Count"] = 1
}

SWEP.Stats["Animation"] = {
}

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "FireDelay")
	self:NetworkVar("Float", 1, "GrenDelay")
	self:NetworkVar("Float", 2, "NextIdle")
	self:NetworkVar("Float", 3, "ReloadDelay")
	self:NetworkVar("Float", 4, "ReloadLoadDelay")
	self:NetworkVar("Float", 5, "Holster_Time")
		self:NetworkVar("Entity", 0, "Holster_Entity")
	self:NetworkVar("Float", 6, "MeleeStrikeDelay")
	self:NetworkVar("Float", 7, "AccelFirerate")
	self:NetworkVar("Float", 8, "AccelInaccuracy")

	self:NetworkVar("Int", 0, "BurstCount")

	self:NetworkVar("Bool", 0, "ReloadingState")
end

function SWEP:Initialize()
	self.Primary.Ammo = self.Stats["Magazine"]["Ammo type"]
	self.Primary.ClipSize = self.Stats["Magazine"]["Ammo loaded max"]
	self:SetClip1( self.Stats["Magazine"]["Ammo loaded max"] )
	self.qa = self.Stats["Animation"]
end

function SWEP:OnReloaded()
	self:Initialize()
end

function SWEP:OnRestore()
	self:SetFireDelay(0)
	self:SetGrenDelay(0)
	self:SetMeleeStrikeDelay(0)
	self:SetReloadDelay(0)
	self:SetReloadLoadDelay(0)
	self:SetHolster_Time(0)
end

function SWEP:Deploy()
	if self.Stats["Appearance"] and self.Stats["Appearance"]["Holdtypes"] then
		self:SetHoldType( self.Stats["Appearance"]["Holdtypes"]["Active"] or "pistol" )
	else
		self:SetHoldType( "pistol" )
	end
	--self:SetReloadDelay(CurTime())

	if self.qa["draw"] then
		local playa = self:SendAnim( self.qa["draw"] )
		--self:SetReloadDelay( CurTime() + playa[1] )
	end
	self:SetReloadDelay( CurTime() + 0.5 )

	return true
end

function SWEP:Holster(wep)
	if wep == self then return false end
	if self:GetHolster_Time() > CurTime() then self:SetHolster_Entity(wep) return false end

	if !self.qa["holster"] or (self:GetHolster_Time() != 0 and self:GetHolster_Time() <= CurTime()) or !IsValid(wep) then
		self:SetHolster_Time(0)
		self:SetHolster_Entity(NULL)

		return true
	else
		self:SetHolster_Entity(wep)

		local at = self:SendAnim( self.qa["holster"] )
		self:SetReloadLoadDelay(0)
		self:SetReloadingState( false )
		self:SetBurstCount(0)
		self:SetHolster_Time( CurTime() + at[1] )
		self:SetNextIdle(math.huge)
	end
end

hook.Add("StartCommand", "FHL22_StartCommand", function( ply, cmd )
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep.FHL22 then
		if wep:GetHolster_Time() != 0 and wep:GetHolster_Time() <= CurTime() then
			if IsValid(wep:GetHolster_Entity()) then
				wep:SetHolster_Time(-math.huge)
				cmd:SelectWeapon(wep:GetHolster_Entity())
			end
		end
	end
end)

-- Shared
AddCSLuaFile	("sh_firing.lua")
include			("sh_firing.lua")
AddCSLuaFile	("sh_reload.lua")
include			("sh_reload.lua")
AddCSLuaFile	("sh_think.lua")
include			("sh_think.lua")
AddCSLuaFile	("sh_anim.lua")
include			("sh_anim.lua")

-- Client
AddCSLuaFile	("cl_hud.lua")
if CLIENT then
include			("cl_hud.lua")
end






if CLIENT then

local pvel = 0

local yaaa = Angle()
local laaa = Angle()

function SWEP:PreDrawViewModel(vm, wep, p)
	if vm == p:GetViewModel(0) then
		yaaa = LerpAngle( FrameTime() * 4, yaaa, Angle( ( p:EyeAngles().x - laaa.x ), ( p:EyeAngles().y - laaa.y ), 0 ) )
		laaa.x = p:EyeAngles().x
		laaa.y = p:EyeAngles().y
	end
end

function SWEP:GetViewModelPosition(pos, ang)
	local p = LocalPlayer()
	local offset = Vector()
	local affset = Angle()
	
	if IsValid(p) then
		pvel = math.Approach(pvel, p:OnGround() and p:GetVelocity():Length2D() or 0, FrameTime() * ( p:GetWalkSpeed() * 10 ) )
	else
		pvel = 0
	end

	if self.Stats["Appearance"]["Viewmodel"] then -- Offset
		offset:Add(self.Stats["Appearance"]["Viewmodel"].pos)
		affset:Add(self.Stats["Appearance"]["Viewmodel"].ang)
	end

	do -- Idle
		local mult = 1
		offset.x = offset.x + ( math.pow( math.sin( CurTime() * math.pi * 0.5 * 2 ), 2 ) * 0 * mult )
		offset.y = offset.y + ( math.sin( CurTime() ) * 0 * mult )
		offset.z = offset.z + ( math.pow( math.sin( CurTime() * math.pi * 0.5 ), 2 ) * 0.125 * mult )

		affset.x = affset.x + ( math.pow( math.sin( CurTime() * math.pi * 0.25 * 2 ), 2 ) * -0.125 * mult )
		affset.y = affset.y + ( math.pow( math.sin( CurTime() * math.pi * 0.25 * 1 ), 2 ) * -0.25 * mult )
		affset.z = affset.z + ( math.pow( math.sin( CurTime() * math.pi * 0.5 ), 4 ) * -0.5 * mult )
	end

	do -- Moving
		local mult = Lerp( 0, 0.8, 0.4 ) * ( pvel / p:GetWalkSpeed() )
		local spe = 1
		offset.x = offset.x + ( math.pow( math.sin( CurTime() * math.pi * 0.5 * 2 * spe ), 4 ) * 0.25 * mult )
		offset.y = offset.y + ( math.pow( math.sin( CurTime() * math.pi * 2 * spe ), 4 ) * 0 * mult )
		offset.z = offset.z + ( math.pow( math.sin( CurTime() * math.pi * 2 * spe ), 4 ) * -0.325 * mult )

		affset.x = affset.x + ( math.pow( math.sin( CurTime() * math.pi * 0.5 * 4 * spe ), 4 ) * 0.5 * mult )
		affset.y = affset.y + ( math.pow( math.sin( CurTime() * math.pi * 0.5 * 2 * spe ), 4 ) * -0.5 * mult )
		affset.z = affset.z + ( math.pow( math.sin( CurTime() * math.pi * 2 * spe ), 4 ) * 0 * mult )
	end

	do -- Sway
		local mult = Lerp( 0, 0.4, 0.01 )
		offset.z = offset.z + (-1*yaaa.x) * -2.5 * mult
		affset.x = affset.x + yaaa.x * -3.5 * mult
		affset.z = affset.z + math.abs(yaaa.x) * -4 * mult

		offset.x = offset.x + yaaa.y * -1 * mult
		affset.y = affset.y + yaaa.y * 2 * mult
		
		affset.z = affset.z + (-1*yaaa.y) * -1 * mult
		offset.x = offset.x + yaaa.y * 1.5 * mult
		offset.z = offset.z + (-1*yaaa.y) * -0.0022 * mult

	end

	ang:RotateAroundAxis( ang:Right(),		affset.x )
	ang:RotateAroundAxis( ang:Up(),			affset.y )
	ang:RotateAroundAxis( ang:Forward(),	affset.z )
	pos = pos + offset.x * ang:Right()
	pos = pos + offset.y * ang:Forward()
	pos = pos + offset.z * ang:Up()
	if p.randv then
		pos = pos + p.randv
	end
	
	return pos, ang
end

function SWEP:CalcView(p, pos, ang, fov)
	if p.randv then
		pos = pos + p.randv
	end

	return pos, ang, fov
end

end