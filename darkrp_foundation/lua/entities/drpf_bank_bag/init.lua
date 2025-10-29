AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/props_c17/SuitCase_Passenger_Physics.mdl")

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(105)
	end
	
	self:SetMoney( math.random( DarkRPFoundation.CONFIG.BANKVAULT.MoneyBagAmount[1], DarkRPFoundation.CONFIG.BANKVAULT.MoneyBagAmount[2] ) )
end

function ENT:Use( ply )
	if( IsValid( ply ) ) then
		if( IsValid( self:GetVault() ) ) then
			local Distance = self:GetPos():DistToSqr( self:GetVault():GetPos() )
			if( Distance >= DarkRPFoundation.CONFIG.BANKVAULT.DistanceToUnlock ) then
				self:Remove()
				ply:addMoney( self:GetMoney() )
				DRPF_Functions.ChatNotify( ply, Color( 255, 125, 125 ), DRPF_Functions.L( "moneyBagEntBank" ), Color( 255, 255, 255 ), DRPF_Functions.L( "moneyBagEntCollected" ) .. " " .. DarkRP.formatMoney( self:GetMoney() ) .. " " .. DRPF_Functions.L( "moneyBagEntFromBag" ) )
			end
		else
			self:Remove()
			ply:addMoney( self:GetMoney() )
			DRPF_Functions.ChatNotify( ply, Color( 255, 125, 125 ), DRPF_Functions.L( "moneyBagEntBank" ), Color( 255, 255, 255 ), DRPF_Functions.L( "moneyBagEntCollected" ) .. " " .. DarkRP.formatMoney( self:GetMoney() ) .. " " .. DRPF_Functions.L( "moneyBagEntFromBag" ) )
		end
	end
end

function ENT:Think()

end

function ENT:OnRemove()

end

function ENT:StartTouch( Toucher )
	if( not IsValid( Toucher ) ) then return end
	
	if( Toucher:GetClass() == "drpf_bank_vault" ) then
		self:Remove()
		Toucher:SetMoneyBags( math.Clamp( Toucher:GetMoneyBags()+1, 0, DarkRPFoundation.CONFIG.BANKVAULT.MoneyBags ) )
	end
end

function ENT:AcceptInput(ply, caller)

end