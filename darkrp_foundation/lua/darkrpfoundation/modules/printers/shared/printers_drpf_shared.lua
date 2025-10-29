--[[ CREATES PRINTERS ]]--
for k, v in pairs( DarkRPFoundation.DEVCONFIG.Printers ) do
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "drpf_printer_base"
	ENT.Category		= "DarkRP Foundation - Printers"
	ENT.PrintName = v.PrinterTier .. " Printer"
	ENT.Spawnable = true
	ENT.AdminSpawnable = true
	ENT.ConfigTable = v
	scripted_ents.Register( ENT, k )
end