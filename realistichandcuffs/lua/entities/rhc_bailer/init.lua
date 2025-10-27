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

function ENT:Use(activator, caller)
  if self.Touched and self.Touched > CurTime() then return ; end
	self.Touched = CurTime() + 2;

	if (RHC_GetConf("BAIL_RestrictBailing") and activator:CanRHCBail()) or !RHC_GetConf("BAIL_RestrictBailing") then
		net.Start("RHC_Bailer_Menu")
		net.Send(activator)
	else
		TBFY_Notify(activator, 1, 4, RHC_GetLang("NotAllowedToUseBailer"))
	end
end

function ENT:Think()
end
