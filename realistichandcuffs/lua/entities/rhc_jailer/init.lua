AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	local Data = RHandcuffsConfig.NPCData[self:GetClass()]
	self:SetModel(Data.Model)
	self:SetSolid(SOLID_BBOX);
	self:PhysicsInit(SOLID_BBOX);
	self:SetMoveType(MOVETYPE_NONE);
	self:DrawShadow(true);
	self:SetUseType(SIMPLE_USE);

	self:SetFlexWeight( 10, 0 )
	self:ResetSequence(3)
end

function ENT:Use( activator, caller )
    if self.Touched and self.Touched > CurTime() then return ; end
	self.Touched = CurTime() + 2;
	local Allowed = false

	if (RHC_GetConf("JAIL_RestrictJailing") and activator:CanRHCJail()) then
		Allowed = true
	elseif (!RHC_GetConf("JAIL_RestrictJailing") and activator:IsRHCWhitelisted()) then
		Allowed = true
	end

	if Allowed then
		activator.LastJailerNPC = self
		net.Start("RHC_Jailer_Menu")
			net.WriteEntity(activator.Dragging)
		net.Send(activator)
	else
		TBFY_Notify(activator, 1, 4, RHC_GetLang("NotAllowedToUseJailer"))
	end
end

function ENT:Think()
end
