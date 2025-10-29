AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/darkrpfoundation/armory/armory.mdl")

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	self:GetPhysicsObject():EnableMotion( false )
	
	self:SetBodygroup( 1, 1 )
	self:LockArmory()
end

util.AddNetworkString( "DarkRPFoundationNet_ArmoryUse" )
function ENT:Use( ply )
	if( ply:GetNWInt( "drpf_nw_armorycooldown", 0 ) > CurTime() ) then return end
	
	ply:SetNWInt( "drpf_nw_armorycooldown", CurTime()+1 )

	if( table.HasValue( DarkRPFoundation.CONFIG.ARMORY.RobberTeams, ply:Team() ) ) then
		if( not IsValid( self:GetRobber() ) and self:GetLocked() == true and CurTime() >= self:GetRobberyCooldown() ) then
			local PoliceCount = 0
			for k, v in pairs( player.GetAll() ) do
				if( table.HasValue( DarkRPFoundation.CONFIG.GENERAL.PoliceJobs, v:Team() ) ) then
					PoliceCount = PoliceCount+1
				end
			end
			
			if( PoliceCount >= DarkRPFoundation.CONFIG.ARMORY.PoliceRequirement ) then
				self:StartRobbery( ply )
			else
				DarkRP.notify( ply, 1, 3, DRPF_Functions.L( "armoryNotifyPolice" ) .. ": " .. DarkRPFoundation.CONFIG.ARMORY.PoliceRequirement .. ")!" )
			end
		else
			DarkRP.notify( ply, 1, 3, DRPF_Functions.L( "armoryNotifyColdown" ) .. "!" )
		end
	elseif( table.HasValue( DarkRPFoundation.CONFIG.GENERAL.PoliceJobs, ply:Team() ) ) then
		net.Start( "DarkRPFoundationNet_ArmoryUse" )
		net.Send( ply )
	end
end

function ENT:Think()
	if( IsValid( self:GetRobber() ) ) then
		if( self:GetRobber():GetPos():DistToSqr( self:GetPos() ) > 10000 ) then
			self:RobberyFail()
		elseif( not self:GetRobber():Alive() ) then
			self:RobberyFail()
		end
	end
	
	if( IsValid( self:GetRobber() ) and self:GetLocked() == true and CurTime() >= self:GetRobberyCooldown() ) then
		if( CurTime() >= self:GetUnlockTimer() ) then
			timer.Simple( 5, function() 
				if( IsValid( self ) ) then
					self:LockArmory()
				end
			end )
			self:RobberySuccess()
			self:UnlockArmory()
		end
	end
	
	if( CurTime() >= self:GetRobberyCooldown() and self:GetLocked() == true ) then
		if( (self:GetMoneyValue() == 0 and DarkRPFoundation.CONFIG.ARMORY.RewardMoneyMin != 0) or (self:GetShipmentValue() == 0 and DarkRPFoundation.CONFIG.ARMORY.RewardShipmentMin != 0) ) then
			self:ResetContents()
			self:SetRobberyCooldown( 0 )
		end
	end
end

function ENT:OnTakeDamage( dmgInfo )

end

function ENT:DoMyAnimationThing( SequenceName, PlaybackRate )
	PlaybackRate = PlaybackRate or 1
	local sequenceID, sequenceDuration = self:LookupSequence( SequenceName )
	if (sequenceID != -1) then
		self:ResetSequence(sequenceID)
		self:SetPlaybackRate(PlaybackRate)
		self:ResetSequenceInfo()
		self:SetCycle(0)
		return CurTime() + sequenceDuration * (1 / PlaybackRate) 
	else
		MsgN(DRPF_Functions.L( "armoryErrorSequence" ) .. " ", SequenceName)
		return CurTime()
	end
end

function ENT:OnRemove()

end

function ENT:RobberyFail()
	if( IsValid( self:GetRobber() ) ) then
		DarkRP.notify( self:GetRobber(), 1, 3, DRPF_Functions.L( "armoryRobberyFailed" ) )
	end
	
	self:SetRobber( nil )
	self:SetUnlockTimer( 0 )
	self:SetFailCooldown( CurTime()+DarkRPFoundation.CONFIG.ARMORY.FailCooldown )
end

function ENT:RobberySuccess()
	if( IsValid( self:GetRobber() ) ) then
		self:GetRobber():addMoney( (self:GetMoneyValue() or 0) )
		self:GetRobber():AddExperience( DarkRPFoundation.CONFIG.ARMORY.RewardExperience, "ROBBERY" )
		DarkRP.notify( self:GetRobber(), 1, 10, DRPF_Functions.L( "armoryRobberySuccessful" ) .. ": +" .. DarkRP.formatMoney(self:GetMoneyValue()) .. ", +" .. string.Comma(DarkRPFoundation.CONFIG.ARMORY.RewardExperience) .. " " .. DRPF_Functions.L( "armoryExpAnd" ) .. " +" .. self:GetShipmentValue() .. " " .. DRPF_Functions.L( "armoryShipments" ) .. "." )
	
		for i=1, self:GetShipmentValue() do
			local ShipKey = table.Random( DarkRPFoundation.CONFIG.ARMORY.RewardShipments )

			local found, foundKey = DarkRP.getShipmentByName(ShipKey)
			local crate = ents.Create(found.shipmentClass or "spawned_shipment")
			crate.SID = self:GetRobber().SID
			crate:Setowning_ent(self:GetRobber())
			crate:SetContents(foundKey,10)

			crate:SetPos(self:GetPos()+(self:GetForward()*30))
			crate.nodupe = true
			crate.ammoadd = found.spareammo
			crate.clip1 = found.clip1
			crate.clip2 = found.clip2
			crate:Spawn()
			crate:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
			crate:SetPlayer(self:GetRobber())
		end
	end

	self:SetMoneyValue( 0 )
	self:SetShipmentValue( 0 )
	self:SetBodygroup( 1, 1 )
end

function ENT:LockArmory()
	self:SetLocked( true )
	self:SetUnlockTimer( 0 )
	self:SetRobberyCooldown( CurTime()+DarkRPFoundation.CONFIG.ARMORY.RobberyCooldown )
	self:DoMyAnimationThing( "closed", 1 )
end

function ENT:UnlockArmory()
	self:SetRobber( nil )
	self:SetLocked( false )
	self:SetUnlockTimer( 0 )
	self:DoMyAnimationThing( "opened", 1 )
	self:EmitSound( "ambient/materials/creaking.wav" )
end

function ENT:StartRobbery( robber )
	if( IsValid( self:GetRobber() ) or self:GetLocked() != true or CurTime() < self:GetRobberyCooldown() ) then return end

	self:SetRobber( robber )
	self:SetUnlockTimer( CurTime()+DarkRPFoundation.CONFIG.ARMORY.OpenTime )
end

function ENT:ResetContents()
	local MoneyValue = math.random( (DarkRPFoundation.CONFIG.ARMORY.RewardMoneyMin or 1), (DarkRPFoundation.CONFIG.ARMORY.RewardMoneyMax or 100) )
	self:SetMoneyValue( MoneyValue )
	
	local ShipmentValue = math.random( (DarkRPFoundation.CONFIG.ARMORY.RewardShipmentMin or 1), (DarkRPFoundation.CONFIG.ARMORY.RewardShipmentMax or 5) )
	self:SetShipmentValue( ShipmentValue )
	
	self:SetBodygroup( 1, 0 )
end

--[[ POLICE FUNCTONS ]]--
util.AddNetworkString( "DarkRPFoundationNet_ArmoryEquipWeapon" )
net.Receive( "DarkRPFoundationNet_ArmoryEquipWeapon", function( len, ply )
	local ItemKey = net.ReadInt( 32 )
	
	if( not ItemKey or not DarkRPFoundation.CONFIG.ARMORY.Weapons[ItemKey] ) then return end
	if( not table.HasValue( DarkRPFoundation.CONFIG.GENERAL.PoliceJobs, ply:Team() ) ) then return end
	
	local ItemTable = DarkRPFoundation.CONFIG.ARMORY.Weapons[ItemKey]
	
	if( ply:HasWeapon( ItemTable.Weapon ) ) then
		ply:SelectWeapon( ItemTable.Weapon )
		return
	end
	
	if( (ply:GetLevel() or 0) >= (ItemTable.Level or 0) ) then
		if( not ItemTable.Restrictions or table.HasValue( ItemTable.Restrictions, ply:Team() ) ) then
			ply:Give( ItemTable.Weapon )
			ply:SelectWeapon( ItemTable.Weapon )
		else
			DarkRP.notify( ply, 1, 10, DRPF_Functions.L( "armoryNotifyNotJobs" ) )
		end
	else
		DarkRP.notify( ply, 1, 10, DRPF_Functions.L( "armoryNotifyEquipWeapon1" ) .. " " .. (ItemTable.Level or 0) .. " " .. DRPF_Functions.L( "armoryNotifyEquipWeapon2" ) )
	end
end )

util.AddNetworkString( "DarkRPFoundationNet_ArmoryEquipAmmo" )
net.Receive( "DarkRPFoundationNet_ArmoryEquipAmmo", function( len, ply )
	local ItemKey = net.ReadInt( 32 )
	
	if( not ItemKey or not DarkRPFoundation.CONFIG.ARMORY.Ammo[ItemKey] ) then return end
	if( not table.HasValue( DarkRPFoundation.CONFIG.GENERAL.PoliceJobs, ply:Team() ) ) then return end
	
	local ItemTable = DarkRPFoundation.CONFIG.ARMORY.Ammo[ItemKey]
	
	if( ply:GetAmmoCount( ItemTable.AmmoType ) >= ItemTable.MaxAmount ) then 
		DarkRP.notify( ply, 1, 10, DRPF_Functions.L( "armoryNotifyMaxAmmo" ) )
		return
	end
	
	if( (ply:GetLevel() or 0) >= (ItemTable.Level or 0) ) then
		if( not ItemTable.Restrictions or table.HasValue( ItemTable.Restrictions, ply:Team() ) ) then
			ply:GiveAmmo( ItemTable.Amount, ItemTable.AmmoType )
		else
			DarkRP.notify( ply, 1, 10, DRPF_Functions.L( "armoryNotifyDontJobsAmmo" ) )
		end
	else
		DarkRP.notify( ply, 1, 10, DRPF_Functions.L( "armoryNotifyEquipAmmo1" ) .. " " .. (ItemTable.Level or 0) .. " " .. DRPF_Functions.L( "armoryNotifyEquipAmmo2" ) )
	end
end )

util.AddNetworkString( "DarkRPFoundationNet_ArmoryEquipGear" )
net.Receive( "DarkRPFoundationNet_ArmoryEquipGear", function( len, ply )
	local ItemKey = net.ReadInt( 32 )
	
	if( not ItemKey or not DarkRPFoundation.CONFIG.ARMORY.Gear[ItemKey] ) then return end
	if( not table.HasValue( DarkRPFoundation.CONFIG.GENERAL.PoliceJobs, ply:Team() ) ) then return end
	
	local ItemTable = DarkRPFoundation.CONFIG.ARMORY.Gear[ItemKey]
	
	if( ply:Armor() >= ItemTable.Amount ) then
		DarkRP.notify( ply, 1, 10, DRPF_Functions.L( "armoryNotifyEquipGear" ) )
		return
	end
	
	if( (ply:GetLevel() or 0) >= (ItemTable.Level or 0) ) then
		if( not ItemTable.Restrictions or table.HasValue( ItemTable.Restrictions, ply:Team() ) ) then
			ply:SetArmor( ItemTable.Amount )
		else
			DarkRP.notify( ply, 1, 10, DRPF_Functions.L( "armoryNotifyDontJobsGear" ) )
		end
	else
		DarkRP.notify( ply, 1, 10, DRPF_Functions.L( "armoryNotifyEquipGear1" ) .. " " .. (ItemTable.Level or 0) .. " " .. DRPF_Functions.L( "armoryNotifyEquipGear2" ) )
	end
end )

hook.Add( "canDropWeapon", "DarkRPFoundationHooks_canDropWeapon_Armory", function( ply, wep )
	if( IsValid( ply ) ) then
		if( table.HasValue( DarkRPFoundation.CONFIG.GENERAL.PoliceJobs, ply:Team() ) ) then
			for k, v in pairs( DarkRPFoundation.CONFIG.ARMORY.Weapons ) do
				if( wep:GetClass() == v.Weapon ) then
					return false
				end
			end
		end
	end
end )