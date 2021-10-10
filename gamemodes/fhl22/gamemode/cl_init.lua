include( "shared.lua" )

plyinfo = {}
hook.Add( "PlayerInitialSpawn", "FHL2_PlayerInitialSpawn", function( ply, tran )
	if tran then
		--self:SavePlayer( ply )
	end
	plyinfo[ply] = { ammo = ply:GetAmmo() }
end)

local offsets = {
	["weapon_crowbar"] = {
		Vector(0, 3, 1),
		Angle(0, 0, 0)
	},
	["weapon_physcannon"] = {
		Vector(0, 0, -1),
		Angle(0, 0, 0)
	},
	["weapon_physgun"] = {
		Vector(0, 0, -1),
		Angle(0, 0, 0)
	},
	["weapon_stunstick"] = {
		Vector(0, 3, 0),
		Angle(0, 0, 0)
	},
	["weapon_pistol"] = {
		Vector(0, 0, -1),
		Angle(0, 0, 0)
	},
	["weapon_357"] = {
		Vector(1, 1, -2),
		Angle(0, 0, 0)
	},
	["weapon_smg1"] = {
		Vector(0, 0, -1.5),
		Angle(0, 0, 0)
	},
	["weapon_ar2"] = {
		Vector(0, -2, -1),
		Angle(0, 0, 0)
	},
	["weapon_shotgun"] = {
		Vector(0, 0, 0),
		Angle(0, 0, 0)
	},
	["weapon_crossbow"] = {
		Vector(-1, 1, -1),
		Angle(0, 0, 0)
	},
	["weapon_frag"] = {
		Vector(-1, 0, -1),
		Angle(0, 0, 0)
	},
	["weapon_rpg"] = {
		Vector(4, 4, -1),
		Angle(0, 0, 0)
	},
	["gmod_tool"] = {
		Vector(1, 1, -2),
		Angle(0, 0, 0)
	},
}

hook.Add("CalcViewModelView", "FHL2_CalcViewModelView", function( wep, vm, oldpos, oldang, pos, ang )
	if offsets[wep:GetClass()] then
		local o = offsets[wep:GetClass()]
		pos = pos + o[1].x * ang:Right()
		pos = pos + o[1].y * ang:Forward()
		pos = pos + o[1].z * ang:Up()
		return pos, ang
	end
end)


function GM:OnSpawnMenuOpen()
	LocalPlayer():ConCommand("lastinv")
end
function GM:OnContextMenuOpen()
	LocalPlayer():ConCommand("impulse 50")
end

local SS = ScreenScale(1)

local colors = {}
local co = Material("color")
colors.box = Color(0, 0, 0, 255*0.4)
colors.meter = Color(255, 255, 255, 255)
colors.text_1 = Color(255, 255, 255, 255)

local scale = 0.75
SS = SS * scale

local so_w = 1
local so_h = 1

local br = {}
br.x = ScrW() * (1-so_w)
br.y = ScrH() * (1-so_h)
br.w = ScrW() * (so_w)
br.h = ScrH() * (so_h)
br.bord = SS*8
br.bordy = SS*10
br.gap = SS*2

local bog = {}

bog.big = {}
bog.big.w = SS*80
bog.big.h = SS*32

bog.sml = {}
bog.sml.w = SS*60
bog.sml.h = SS*28

do
	local fonts = {
		["F_1"] = {
			font = "Ebrima",
			size = SS*36,
			weight = 0,
			antialias = true,
		},
		["F_2"] = {
			font = "Ebrima",
			size = SS*16,
			weight = 0,
			antialias = true,
		},
		["F_3"] = {
			font = "CarbonBold",
			size = SS*32,
			weight = 0,
			antialias = true,
			italic = false,
		},
		["F_4"] = {
			font = "Ebrima",
			size = SS*16,
			weight = 1000,
			antialias = true,
		},
	}
	for i, v in pairs(fonts) do
		surface.CreateFont( i, v )
	end
	function FHL22_DrawText(tbl)
		local x = tbl.x
		local y = tbl.y
		surface.SetFont(tbl.font)

		if tbl.a_x or tbl.a_y then
			local w, h = surface.GetTextSize(tbl.text)
			if tbl.a_x then
				x = x - (w * tbl.a_x)
			end
			if tbl.a_y then
				y = y - (h * tbl.a_y)
			end
		end

		if tbl.shadow then
			surface.SetTextColor(Color(0, 0, 0, 127))
			surface.SetTextPos(x + tbl.shadow, y + tbl.shadow)
			surface.SetFont(tbl.font)
			surface.DrawText(tbl.text)
		end

		surface.SetTextColor(tbl.col)
		surface.SetTextPos(x, y)
		surface.SetFont(tbl.font)
		surface.DrawText(tbl.text)
	end
end

hook.Add("HUDPaint", "FHL2_HUDPaint", function()
	local p = LocalPlayer()
	local w = p:GetActiveWeapon()

	if IsValid(p) then
		surface.SetMaterial( co )

		if p:GetMoveType() == MOVETYPE_NOCLIP then
			local tobl = {
				x = br.x + br.w*0.5,
				y = br.y + (br.h*0) + (SS*18),
				text = "☁",
				font = "F_3",
				col = colors.text_1,
				a_x = 0.5,
				a_y = 0.5,
			}
			FHL22_DrawText(tobl)
		end

		if p:Health() > 0 then
			surface.SetDrawColor( colors.box )
			surface.DrawTexturedRect( br.x + br.bord, br.h - br.bordy - (SS*32), bog.big.w, bog.big.h )

			surface.SetDrawColor( colors.meter )
			surface.DrawTexturedRect( br.x + br.bord, br.h - br.bordy - (SS*32) + (SS*34), SS*80 * ( p:Health() / p:GetMaxHealth() ), SS*2 )

			do
				local tobl = {
					x = br.x + br.bord + (SS*40),
					y = br.h - br.bordy - (bog.big.h/2),
					text = math.Round( ( p:Health() / p:GetMaxHealth() ) * 100 ),
					font = "F_3",
					col = colors.text_1,
					a_x = 0.5,
					a_y = 0.5,
				}
				FHL22_DrawText(tobl)

				tobl.text = "+"
				tobl.font = "F_2"
				tobl.x = br.x + br.bord + (SS*2)
				tobl.y = br.h - br.bordy - (SS*28)
				tobl.a_x = 0
				FHL22_DrawText(tobl)
			end
		end

		if p:Armor() > 0 then
			surface.SetDrawColor( colors.box )
			surface.DrawTexturedRect( br.x + br.bord + (SS*82), br.h - br.bordy - (SS*32), bog.sml.w, bog.sml.h )

			surface.SetDrawColor( colors.meter )
			surface.DrawTexturedRect( br.x + br.bord + (SS*82), br.h - br.bordy - (SS*32) + (SS*34), SS*60 * ( p:Armor() / p:GetMaxArmor() ), SS*2 )

			do
				local tobl = {
					x = br.x + br.bord + (SS*30) + (SS*82),
					y = br.h - br.bordy - (SS*16),
					text = math.Round( ( p:Armor() / p:GetMaxArmor() ) * 100 ),
					font = "F_3",
					col = colors.text_1,
					a_x = 0.5,
					a_y = 0.5,
				}
				FHL22_DrawText(tobl)

				tobl.text = "⚡"
				tobl.font = "F_2"
				tobl.x = (SS*8) + (SS*2) + (SS*82)
				tobl.y = br.h - br.bordy - (SS*28)
				tobl.a_x = 0
				FHL22_DrawText(tobl)
			end
		end

		if IsValid(w) then

			-- ammo
			if w:GetPrimaryAmmoType() > 0 then
				surface.SetDrawColor( colors.box )
				surface.DrawTexturedRect( br.w - br.bord - (bog.big.w + br.gap), br.h - br.bordy - (SS*32), SS*80, SS*32 )

				surface.SetDrawColor( colors.meter )
				surface.DrawTexturedRect( br.w - br.bord - (SS*82), br.h - br.bordy - (SS*32) + (SS*34), SS*80 * math.min( p:GetAmmoCount( w:GetPrimaryAmmoType() ) / game.GetAmmoMax(w:GetPrimaryAmmoType() ), 1 ), SS*2 )

				do
					local tobl = {
						x = br.w - br.bord + (SS*40) - (SS*82),
						y = br.h - br.bordy - (SS*16),
						text = p:GetAmmoCount(w:GetPrimaryAmmoType()),
						font = "F_3",
						col = colors.text_1,
						a_x = 0.5,
						a_y = 0.5,
					}
					FHL22_DrawText(tobl)

					tobl.text = "="
					tobl.font = "F_2"
					tobl.x = br.w - br.bord + (SS*2) - (SS*82)
					tobl.y = br.h - br.bordy - (SS*28)
					tobl.a_x = 0
					FHL22_DrawText(tobl)
				end
			end
		
			-- clip
			if w:GetMaxClip1() > 0 then
				surface.SetDrawColor( colors.box )
				surface.DrawTexturedRect( br.w - br.bord - (SS*80) - (SS*64), br.h - br.bordy - (SS*32), SS*60, SS*32 )

				surface.SetDrawColor( colors.meter )
				surface.DrawTexturedRect( br.w - br.bord - (SS*80) - (SS*64), br.h - br.bordy - (SS*32) + (SS*34), SS*60 * ( w:Clip1() / w:GetMaxClip1() ), SS*2 )

				do
					local tobl = {
						x = br.w - br.bord + (SS*30) - (SS*62) - (SS*82),
						y = br.h - br.bordy - (SS*16),
						text = w:Clip1(),
						font = "F_3",
						col = colors.text_1,
						a_x = 0.5,
						a_y = 0.5,
					}
					FHL22_DrawText(tobl)

					tobl.text = "-"
					tobl.font = "F_2"
					tobl.x = br.w - br.bord + (SS*2) - (SS*62) - (SS*82)
					tobl.y = br.h - br.bordy - (SS*28)
					tobl.a_x = 0
					FHL22_DrawText(tobl)
				end
			end
		
			-- clip2
			if w:GetSecondaryAmmoType() > 0 then
				surface.SetDrawColor( colors.box )
				surface.DrawTexturedRect( br.w - br.bord - (SS*60) - (SS*2), br.h - br.bordy - (SS*32) - (SS*38), SS*60, SS*32 )

				surface.SetDrawColor( colors.meter )
				surface.DrawTexturedRect( br.w - br.bord - (SS*60) - (SS*2), br.h - br.bordy - (SS*32) + (SS*34) - (SS*38), SS*60 * ( p:GetAmmoCount( w:GetSecondaryAmmoType() ) / game.GetAmmoMax( w:GetSecondaryAmmoType() ) ), SS*2 )

				do
					local tobl = {
						x = br.w - br.bord + (SS*30) - (SS*62),
						y = br.h - br.bordy - (SS*16) - (SS*38),
						text = p:GetAmmoCount( w:GetSecondaryAmmoType() ),
						font = "F_3",
						col = colors.text_1,
						a_x = 0.5,
						a_y = 0.5,
					}
					FHL22_DrawText(tobl)

					tobl.text = "x"
					tobl.font = "F_2"
					tobl.x = br.w - br.bord + (SS*2) - (SS*62)
					tobl.y = br.h - br.bordy - (SS*28) - (SS*38)
					tobl.a_x = 0
					FHL22_DrawText(tobl)
				end
			end
		

			do -- nades
				local gc = p:GetAmmoCount( 10 )
				local gce = math.min( p:GetAmmoCount( 10 ) / game.GetAmmoMax( 10 ), 1 )
				surface.SetDrawColor( colors.box )
				surface.DrawTexturedRect( br.x + br.bord, br.y + (SS*8), bog.sml.w, bog.sml.h )

				surface.SetDrawColor( colors.meter )
				surface.DrawTexturedRect( br.x + br.bord, br.y + (SS*8) + bog.sml.h + (SS*2), bog.sml.w * ( gce ), SS*2 )

				do
					local tobl = {
						x = br.x + br.bord + (SS*30),
						y = br.y + (SS*8) + (bog.sml.h*0.5),
						text = gc,
						font = "F_3",
						col = colors.text_1,
						a_x = 0.5,
						a_y = 0.5,
					}
					FHL22_DrawText(tobl)

					tobl.text = "*"
					tobl.font = "F_2"
					tobl.x = br.x + br.bord + (SS*2)
					tobl.y = br.y + (SS*14)
					tobl.a_x = 0
					FHL22_DrawText(tobl)
				end
			end

		end

	end
end)

local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true
}
hook.Add( "HUDShouldDraw", "FHL22_HideHUD", function( name )
	if ( hide[ name ] ) then return false end
end )