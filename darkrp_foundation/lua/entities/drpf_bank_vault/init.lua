AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/darkrpfoundation/bank/vault_door.mdl")

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	self:GetPhysicsObject():EnableMotion( false )
	
	self:SetRobber( nil )
	self:SetMoneyBags( DarkRPFoundation.CONFIG.BANKVAULT.MoneyBags )
	self:SetRobberyCooldown( CurTime()+DarkRPFoundation.CONFIG.BANKVAULT.RobberyCooldown )
	self:SetAlarmCooldown( 0 )
	self:SetUnlockTimer( 0 )
	self:SetLocked( true )
	self:SetAlarm( false )
end

util.AddNetworkString( "DarkRPFoundationNet_BankUse" )
function ENT:Use( ply )
	if( IsValid( ply ) ) then
		if( CurTime() < self:GetUseCooldown() ) then return end
		
		self:SetUseCooldown( CurTime()+1 )
		
		if( IsValid( self:GetRobber() ) ) then return end
		
		if( table.HasValue( DarkRPFoundation.CONFIG.BANKVAULT.RobberTeams, ply:Team() ) ) then
			local PoliceCount = 0
			for k, v in pairs( player.GetAll() ) do
				if( table.HasValue( DarkRPFoundation.CONFIG.GENERAL.PoliceJobs, v:Team() ) ) then
					PoliceCount = PoliceCount+1
				end
			end

			if( self:GetLocked() == true and CurTime() >= self:GetRobberyCooldown() and PoliceCount >= DarkRPFoundation.CONFIG.BANKVAULT.PoliceRequirement and self:GetAlarm() == false ) then
				self:SetRobber( ply )
				
				net.Start( "DarkRPFoundationNet_BankUse" )
					net.WriteEntity( self )
				net.Send( ply )
			elseif( self:GetLocked() == false and self:GetMoneyBags() > 0 ) then
				self:SpawnMoneyBag()
			elseif( self:GetLocked() == true and CurTime() >= self:GetRobberyCooldown() and PoliceCount < DarkRPFoundation.CONFIG.BANKVAULT.PoliceRequirement and self:GetAlarm() == false ) then
				DarkRP.notify( ply, 1, 3, DRPF_Functions.L( "bankValueEntNotifyRobbed" ) .. " " .. DarkRPFoundation.CONFIG.BANKVAULT.PoliceRequirement .. ")!" )
			end
		end
	end
end

function ENT:SpawnMoneyBag()
	if( self:GetMoneyBags() <= 0 ) then return end

	self:SetMoneyBags( self:GetMoneyBags()-1 )
	
	local bankbag = ents.Create( "drpf_bank_bag" )
	if ( !IsValid( bankbag ) ) then return end
	bankbag:SetPos( self:GetPos() + self:GetForward()*30 + Vector( 0, 0, 20 ) )
	bankbag:SetAngles( self:GetAngles() )
	bankbag:SetVault( self )
	bankbag:Spawn()
end

function ENT:LockVault()
	self:SetLocked( true )
	self:SetUnlockTimer( 0 )
	self:SetRobberyCooldown( CurTime()+DarkRPFoundation.CONFIG.BANKVAULT.RobberyCooldown )
	self:DoMyAnimationThing( "close", 1 )
	self:SetMoneyBags( DarkRPFoundation.CONFIG.BANKVAULT.MoneyBags )
end

function ENT:UnlockVault()
	self:SetRobber( nil )
	self:SetLocked( false )
	self:SetUnlockTimer( CurTime()+DarkRPFoundation.CONFIG.BANKVAULT.OpenTime )
	self:DoMyAnimationThing( "open", 1 )
	self:EmitSound( "ambient/materials/creaking.wav" )
end

function ENT:TripAlarm()
	if( DarkRPFoundation.CONFIG.BANKVAULT.AlarmDuration <= 0 ) then return end

	self:SetAlarmCooldown( CurTime()+DarkRPFoundation.CONFIG.BANKVAULT.AlarmDuration )
	self:SetAlarm( true )
	
    self.AlarmSound = CreateSound( self, Sound( "ambient/alarms/alarm1.wav" ) )
    self.AlarmSound:SetSoundLevel( 65 )
    self.AlarmSound:PlayEx( 1, 100 )
end

function ENT:StopAlarm()
	if( self.AlarmSound ) then
		self.AlarmSound:Stop()
		self.AlarmSound = nil
	end
	self:SetAlarm( false )
end

function ENT:Think()
	if( self:GetLocked() == false ) then
		if( CurTime() >= self:GetUnlockTimer() ) then
			self:LockVault()
		end
	else
		
	end	
	
	if( self:GetAlarm() == true ) then
		if( CurTime() >= self:GetAlarmCooldown() ) then
			self:StopAlarm()
		end
	else
		
	end
	
	if( IsValid( self:GetRobber() ) ) then
		if( self:GetRobber():GetPos():DistToSqr( self:GetPos() ) > 10000 ) then
			self:SetRobber( nil )
		elseif( not self:GetRobber():Alive() ) then
			self:SetRobber( nil )
		end
	end
	
	self:NextThink( CurTime() ) 
	return true
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
		MsgN(DRPF_Functions.L( "armoryErrorSequence" ), SequenceName)
		return CurTime()
	end
end

function ENT:OnRemove()
	if( self.AlarmSound ) then
		self.AlarmSound:Stop()
	end
end

util.AddNetworkString( "DarkRPFoundationNet_BankFail" )
net.Receive( "DarkRPFoundationNet_BankFail", function( len, ply ) 
	local ReceivedEnt = net.ReadEntity()
	
	if( not ReceivedEnt ) then return end
	if( not IsValid( ReceivedEnt ) ) then return end
	if( ReceivedEnt:GetClass() != "drpf_bank_vault" ) then return end
	
	if( not IsValid( ReceivedEnt:GetRobber() ) ) then return end
	if( ReceivedEnt:GetRobber() != ply ) then return end
	
	ReceivedEnt:SetRobber( nil )
	
	if( ReceivedEnt:GetAlarm() == false and ReceivedEnt:GetLocked() == true ) then
		ReceivedEnt:TripAlarm()
	end
end )

util.AddNetworkString( "DarkRPFoundationNet_BankUnlock" )
net.Receive( "DarkRPFoundationNet_BankUnlock", function( len, ply ) 
	local ReceivedEnt = net.ReadEntity()
	
	if( not ReceivedEnt ) then return end
	if( not IsValid( ReceivedEnt ) ) then return end
	if( ReceivedEnt:GetClass() != "drpf_bank_vault" ) then return end
	
	if( not IsValid( ReceivedEnt:GetRobber() ) ) then return end
	if( ReceivedEnt:GetRobber() != ply ) then return end
	
	ReceivedEnt:UnlockVault()
end )