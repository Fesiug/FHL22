
-- Thinking

function SWEP:Think()
	local p = self:GetOwner()
	local w = self

	if IsValid(p) then

		if !p:KeyDown(IN_ATTACK) and w:GetBurstCount() > 0 then
			w:SetBurstCount(0)
		end

		do -- Accels
			local doo = ( self:GetFireDelay() >= ( CurTime() - engine.TickInterval() ) )-- or ( self:GetFireRecoveryDelay() >= ( CurTime() - engine.TickInterval() ) )
			local don = doo and 1 or 0

			local accelrange = self.Stats["Function"]["Fire acceleration time"]
			if accelrange then
				self:SetAccelFirerate( math.Approach(self:GetAccelFirerate(), don, FrameTime() / ( doo and accelrange.min or accelrange.max ) ) )
			end

			local inaccrange = self.Stats["Bullet"]["Spread time"]
			if inaccrange then
				self:SetAccelInaccuracy( math.Approach(self:GetAccelInaccuracy(), don, FrameTime() / ( doo and inaccrange.min or inaccrange.max ) ) )
			end

			if self.Stats["Recoil"] then
				local recrange = self.Stats["Recoil"]["Recoil acceleration time"]
				if recrange then
					self:SetAccelRecoil( math.Approach(self:GetAccelRecoil(), don, FrameTime() / ( doo and recrange.min or recrange.max ) ) )
				end
			end
		end

		-- Melee strike
		if self:GetMeleeStrikeDelay() != 0 and self:GetMeleeStrikeDelay() < CurTime() then self:SetMeleeStrikeDelay(0) self:MeleeStrike() end

		do -- Reloading
			if self:GetReloadLoadDelay() != 0 and self:GetReloadLoadDelay() <= CurTime() then
				self:SetReloadLoadDelay(0)
				self:Load()
			end
				
			if self:GetReloadingState() and self:Clip1() > 0 and p:KeyDown(IN_ATTACK) then
				self:FinishReload()
				self:SetReloadDelay(0)
				self:PrimaryAttack()
			end

			if self:GetReloadingState() and self:GetReloadDelay() < CurTime() then
				if self.qa["reload_insert"] and self:Clip1() < self.Stats["Magazine"]["Ammo loaded max"] and self:Ammo1() > 0 then
					self:InsertReload()
				else
					self:FinishReload()
				end
			end
		end

		-- Recoil
		if CLIENT and p.randv then
			local fft = FrameTime() * ( self.Stats["Appearance"]["Recoil decay"] or 8 )
			p.randv.x = math.Approach(p.randv.x, 0, fft)
			p.randv.y = math.Approach(p.randv.y, 0, fft)
			p.randv.z = math.Approach(p.randv.z, 0, fft)
		end
		
		-- Events
		for i, v in ipairs(self.EventTable) do
			for ed, bz in pairs(v) do
				if ed <= CurTime() then
					self:PlayEvent(bz)
					self.EventTable[i][ed] = nil
					if table.IsEmpty(v) and i != 1 then self.EventTable[i] = nil end
				end
			end
		end

	end
end