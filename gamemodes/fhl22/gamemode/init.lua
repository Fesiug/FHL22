AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

hook.Add("EntityTakeDamage", "FHL2_TeamDamage", function( target, dmginfo )
	if dmginfo:GetAttacker():IsPlayer() and IsFriendEntityName(target:GetClass()) then
		dmginfo:ScaleDamage( 0 )
	end
end )