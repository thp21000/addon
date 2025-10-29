
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Printer Base"
ENT.Category		= "DarkRP Foundation"
ENT.Author			= "Brick Wall"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable		= true

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "owning_ent" )
	self:NetworkVar( "Int", 0, "Holding" )
	self:NetworkVar( "Int", 1, "Ink" )
	
	self:NetworkVar( "Bool", 0, "UpgradeSpeed" )
	self:NetworkVar( "Bool", 1, "UpgradeAmount" )
	self:NetworkVar( "Bool", 2, "UpgradeStorage" )
	self:NetworkVar( "Bool", 3, "Overheated" )
	self:NetworkVar( "Bool", 4, "Status" )
end

ENT.ConfigTable = {}
ENT.ConfigTable.PrinterColor = Color( 255, 255, 255 )
ENT.ConfigTable.ScreenColor = Color( 21, 184, 253 )
ENT.ConfigTable.PrinterTier = "Base"
ENT.ConfigTable.PrinterHealth = 150
ENT.ConfigTable.MaxInk = 150

ENT.ConfigTable.PrintAmount = 150
ENT.ConfigTable.MoneyStorage = 1500
ENT.ConfigTable.PrintSpeed = 1


ENT.ConfigTable.UpgradedPrintAmount = 250
ENT.ConfigTable.UpgradedMoneyStorage = 2500
ENT.ConfigTable.UpgradedPrintSpeed = 0.5