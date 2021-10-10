
-- Firing

function SWEP:CanPrimaryAttack()
	if CurTime() < self:GetFireDelay() then
		return false
	end

	if CurTime() < self:GetReloadDelay() then
		return false
	end

	if CurTime() < self:GetHolster_Time() then
		return false
	end

	if self:Clip1() < self.Stats["Function"]["Ammo required"] then
		return false
	end

	if self.Stats["Function"]["Maximum burst"] > 0 and self:GetBurstCount() >= self.Stats["Function"]["Maximum burst"] then
		return false
	end

	return true
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return false end
	local p = self:GetOwner()
	
	self:SetFireDelay( CurTime() + self.Stats["Function"]["Firing delay"] )

	self:SetClip1( math.max( self:Clip1() - self.Stats["Function"]["Ammo used"], 0 ) )
	self:EmitSound(self.Stats["Appearance"]["Firing sound"])

	self:ShootBullet()

	if self.qa["fire"] then self:SendAnim( self.qa["fire"] ) end

	self:SetBurstCount( self:GetBurstCount() + 1 )

	self:CallOnClient("PrimaryFUCK")
end

function SWEP:PrimaryFUCK()
	LocalPlayer().randv = VectorRand() * ( self.Stats["Appearance"]["Recoil mult"] or 1 )
end

function SWEP:ShootBullet()
	for i=1, self.Stats["Bullet"]["Count"] do
		local devi = Angle(0, 0, 0)

		local rnd = util.SharedRandom(CurTime()/11, 0, 360, i)
		local rnd2 = util.SharedRandom(CurTime()/22, 0, 1, i*2)

		local spread = self.Stats["Bullet"]["Spread"]
		if istable(spread) then
			spread = Lerp( self:GetAccelInaccuracy(), spread.min, spread.max )
		end
		local deviat = Angle( math.cos(rnd), math.sin(rnd), 0 ) * ( rnd2 * spread )
		
		local bullet = {}
		bullet.Num		= 1
		bullet.Attacker = self:GetOwner()
		bullet.Src		= self:GetOwner():GetShootPos()
		bullet.Dir		= ( self:GetOwner():EyeAngles() + deviat ):Forward()
		bullet.Spread	= vector_origin
		bullet.Tracer	= 0
		bullet.Force	= self.Stats["Bullet"]["Force"] or 1
		bullet.Damage	= 0
		bullet.AmmoType = self.Primary.Ammo
		bullet.Callback = function( atk, tr, dmg )
			local ent = tr.Entity

			dmg:SetDamage( self.Stats["Bullet"]["Damage"].max )
			dmg:SetDamageType( self.Stats["Function"]["Damage type"] or DMG_BULLET )

			if IsValid(ent) then
				local d = dmg:GetDamage()
				local min, max = self.Stats["Bullet"]["Range"].min, self.Stats["Bullet"]["Range"].max
				local range = atk:GetPos():Distance(ent:GetPos())
				local XD = 0
				if range < min then
					XD = 0
				else
					XD = math.Clamp((range - min) / (max - min), 0, 1)
				end

				dmg:SetDamage( Lerp(XD, self.Stats["Bullet"]["Damage"].max, self.Stats["Bullet"]["Damage"].min) )

				if false and CLIENT and IsValid(dmg:GetAttacker()) and dmg:GetAttacker():IsPlayer() then
					dmg:GetAttacker():ChatPrint( 100-math.Round(XD*100) .. "% range, " .. math.Round(dmg:GetDamage()) .. " dmg" )
				end
			end
		end

		self:FireBullets( bullet )
	end
end

local gnade = 10--game.GetAmmoID("grenade")
function SWEP:ThrowGrenade()
	local p = self:GetOwner()

	if CurTime() < self:GetGrenDelay() then
		return false
	end
	
	if p:GetAmmoCount( gnade ) <= 0 then
		return false
	end
	self:SetReloadingState(false)

	do
		local ply = self:GetOwner()
		local wow = ents.Create("npc_grenade_frag")
		wow:SetParent(ply)
		wow:SetSaveValue("m_hThrower",ply)
		wow:SetNoDraw(true)
		wow:Spawn()

		wow:SetNotSolid( true )
		wow:SetHealth(99999) --without this the grenade can get blow up by another one
		wow.timer = CurTime()

		local frag = wow

		frag:SetParent(nil)
		frag:SetNoDraw(false)
		frag:SetNotSolid( false )
		wow:SetPos( ply:EyePos() + ( ply:GetAimVector() * -16 ) + ( ply:GetRight() * -4 ) )
		wow:SetAngles( ply:EyeAngles() )

		frag.timer = frag.timer-CurTime()
		frag.phys = frag:GetPhysicsObject()
		frag.velocity = ( ply:GetAimVector():Angle() + Angle(-10, 0, 0) ):Forward() * 700
		frag.phys:ApplyForceCenter( frag.velocity )
		frag.phys:AddAngleVelocity(Vector(500,600,0))
		frag:SetOwner(ply)

		wow:Fire("SetTimer",3,0)
	end

	p:SetAmmo( p:GetAmmoCount( gnade ) - 1, gnade )
	self:SetGrenDelay( CurTime() + 1 )
	if self.qa["throw_grenade"] then self:SendAnim( self.qa["throw_grenade"] ) end

	if p:HasWeapon("weapon_frag") and p:GetAmmoCount( gnade ) <= 0 then
		p:StripWeapon("weapon_frag")
	end
end



hook.Add("Move", "FHL22_Move", function( ply, mv )
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep.FHL22 then
		--ply:SetCanZoom(false)
		-- Throw grenade
		if mv:KeyDown(IN_GRENADE1) then
			wep:ThrowGrenade()
		end

	else
		--ply:SetCanZoom(true)
	end
end)

function SWEP:SecondaryAttack()
	return self:Melee()
end

function SWEP:Melee()
	if !self.Stats["Melee"] then return false end
	if CurTime() < self:GetGrenDelay() then
		return false
	end
	self:SetReloadingState(false)

	if self.qa["melee"] then self:SendAnim( self.qa["melee"] ) end

	self:SetGrenDelay( CurTime() + 1 )
	self:SetMeleeStrikeDelay( CurTime() + 0.1 )
end

function SWEP:MeleeStrike()
	local bz = 8

	self:GetOwner():LagCompensation(true)
	local tr = util.TraceHull( {
		start = self:GetOwner():EyePos(),
		endpos = self:GetOwner():EyePos() + ( self:GetOwner():EyeAngles():Forward() * self.Stats["Melee"]["Range"] ),
		filter = self:GetOwner(),
		mins = vector_origin,
		maxs = Vector( bz, bz, bz ),
		mask = MASK_SHOT_HULL
	} )
	self:GetOwner():LagCompensation(false)

	if tr.Hit then
		if tr.Entity:IsValid() then
			local ent = tr.Entity

			if ent:Health() > 0 then
				local effectdata = EffectData()
				effectdata:SetOrigin( tr.HitPos )
				util.Effect( "BloodImpact", effectdata )
			end

			if SERVER then
				local dmg = DamageInfo()
				dmg:SetAttacker( self:GetOwner() or self )
				ent:EmitSound( "physics/body/body_medium_break2.wav" )
				dmg:SetDamage( self.Stats["Melee"]["Damage"] )
				dmg:SetDamageType( DMG_CLUB )
				dmg:SetDamageForce( self:GetOwner():GetAngles():Forward()*30000 )

				ent:TakeDamageInfo( dmg )
			end
		end

		self:EmitSound("Flesh.ImpactHard")
		
		if !tr.HitSky and IsFirstTimePredicted() then
			local effectdata = EffectData()
			effectdata:SetOrigin( tr.HitPos )
			effectdata:SetStart( tr.StartPos )
			effectdata:SetEntity( IsValid(tr.Entity) and tr.Entity or tr.HitWorld and game.GetWorld() )
			effectdata:SetDamageType( DMG_CLUB )
			effectdata:SetSurfaceProp( tr.SurfaceProps )
			util.Effect( "Impact", effectdata )
		end
	end

end