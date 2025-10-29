ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= DRPF_Functions.L( "moneyBagEntName" )
ENT.Category		= "DarkRP Foundation"
ENT.Author			= "Brick Wall"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable		= true

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "Money" )
	self:NetworkVar( "Entity", 0, "Vault" )
end