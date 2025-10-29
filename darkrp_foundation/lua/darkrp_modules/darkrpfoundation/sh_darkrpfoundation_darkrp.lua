--[[ ADDS PRINTERS TO F4 MENU ]]--
if( DarkRPFoundation.CONFIG.PRINTERS.AddToF4Menu == true ) then
	for k, v in pairs( DarkRPFoundation.DEVCONFIG.Printers ) do
		local function CanBuy( ply )
			if( v.F4BuyGroups ) then
				return table.HasValue( v.F4BuyGroups, DRPF_Functions.GetAdminGroup( ply ) )
			else
				return true
			end
		end
		
		if( not v.F4BuyJobs ) then
			DarkRP.createEntity( v.PrinterTier .. " Tier Printer", {
				ent = k,
				model = "models/darkrpfoundation/money_printer.mdl",
				price = v.F4MenuPrice or 1500,
				max = v.F4MaxBuy or 1,
				cmd = "buydrpfprinter_" .. v.PrinterTier,
				category = v.F4Category or "Printers",
				allowed = v.F4BuyJobs,
				customCheck = function(ply) return CLIENT or CanBuy( ply ) end,
				CustomCheckFailMsg = "This printer is restricted to certain groups.",
			})
		else
			DarkRP.createEntity( v.PrinterTier .. " Tier Printer", {
				ent = k,
				model = "models/darkrpfoundation/money_printer.mdl",
				price = v.F4MenuPrice or 1500,
				max = v.F4MaxBuy or 1,
				cmd = "buydrpfprinter_" .. v.PrinterTier,
				category = v.F4Category or "Printers",
				customCheck = function(ply) return CLIENT or CanBuy( ply ) end,
				CustomCheckFailMsg = "This printer is restricted to certain groups.",
			})
		end
		
		if( v.F4Category ) then
			DarkRP.createCategory {
				name = v.F4Category,
				categorises = "entities",
				startExpanded = true,
				color = Color( 125, 125, 125 ),
				canSee = function(ply) return true end,
				sortOrder = 1
			}
		end
	end
	
	DarkRP.createCategory {
		name = "Printers",
		categorises = "entities",
		startExpanded = true,
		color = Color( 125, 125, 125 ),
		canSee = function(ply) return true end,
		sortOrder = 1
	}
end