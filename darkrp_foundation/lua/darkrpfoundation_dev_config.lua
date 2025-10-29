DarkRPFoundation.DEVCONFIG = {}

DarkRPFoundation.DEVCONFIG.Printers = {}
DarkRPFoundation.DEVCONFIG.Printers["drpf_printer_black"] = {
	PrinterTier = "Black", -- The name of the PrinterTier of the printer.
	F4MenuPrice = 15000, -- The price of the printer in the f4 menu.
	
	PrinterColor = Color( 0, 0, 0 ), -- The color of the printer.
	ScreenColor = Color( 75, 75, 75 ), -- The color of the screen on the printer.
	PrinterHealth = 150, -- The health of the printer.
	MaxInk = 150, -- How much MaxInk the printer has.

	PrintAmount = 150, -- How much money is created per print.
	MoneyStorage = 1500, -- The maximum amount of money able to be held at one point.
	PrintSpeed = 1, -- How often the printer prints money.

	UpgradedPrintAmount = 150, -- The upgraded version of PrintAmount.
	UpgradedMoneyStorage = 1500, -- The upgraded version of MoneyStorage.
	UpgradedPrintSpeed = 1, -- The upgraded version of PrintSpeed.
}

DarkRPFoundation.DEVCONFIG.Printers["drpf_printer_red"] = {
	PrinterTier = "Red",
	F4MenuPrice = 25000,

	PrinterColor = Color( 255, 0, 0 ),
	ScreenColor = Color( 255, 125, 125 ),
	PrinterHealth = 150,
	MaxInk = 150,

	PrintAmount = 150,
	MoneyStorage = 1500,
	PrintSpeed = 1,

	UpgradedPrintAmount = 150,
	UpgradedMoneyStorage = 1500,
	UpgradedPrintSpeed = 1,
}

DarkRPFoundation.DEVCONFIG.Printers["drpf_printer_vip"] = {
	PrinterTier = "VIP",
	F4MenuPrice = 35000,
	F4BuyGroups = {"superadmin"},
	F4BuyJobs = { TEAM_GANGSTER },
	F4MaxBuy = 3,
	F4Category = "Printers",

	PrinterColor = Color( 125, 255, 125 ),
	ScreenColor = Color( 255, 125, 125 ),
	PrinterHealth = 150,
	MaxInk = 150,

	PrintAmount = 150,
	MoneyStorage = 1500,
	PrintSpeed = 1,

	UpgradedPrintAmount = 150,
	UpgradedMoneyStorage = 1500,
	UpgradedPrintSpeed = 1,
}

--[[ COMING SOON, I PROMISE ]]--
DarkRPFoundation.DEVCONFIG.LevelRewards = {}
DarkRPFoundation.DEVCONFIG.LevelRewards.Money = {
	Icon = { "RewardsMoney", (122/150) },
	FormatVal = function( val )
		return "Money: " .. DarkRP.formatMoney( val )
	end,
	OnReward = function( ply, val, level, vip  )
		ply:addMoney( val )
		if( not vip ) then
			DRPF_Functions.ChatNotify( ply, Color( 247, 215, 109 ), "[Rewards] ", Color( 255, 255, 255 ), "You received " .. DarkRP.formatMoney( val ) .. " for reaching level " .. level .. "." )
		else
			DRPF_Functions.ChatNotify( ply, Color( 99, 255, 239 ), "[VIP Rewards] ", Color( 255, 255, 255 ), "You received " .. DarkRP.formatMoney( val ) .. " for reaching level " .. level .. "." )
		end
	end,
}
DarkRPFoundation.DEVCONFIG.LevelRewards.Weapons = {
	Icon = { "RewardsWeapon", (475/138) },
	FormatVal = function( val )
		local FormattedVal = "Weapons: "
		for k, v in pairs( val ) do
			if( FormattedVal != "Weapons: " ) then
				FormattedVal = FormattedVal .. ", " .. v
			else
				FormattedVal = FormattedVal .. v
			end
		end
	
		return FormattedVal
	end,
	OnReward = function( ply, val, level, vip )
		for k, v in pairs( val ) do
			ply:Give( v )
			if( not vip ) then
				DRPF_Functions.ChatNotify( ply, Color( 247, 215, 109 ), "[Rewards] ", Color( 255, 255, 255 ), "You received '" .. v .. "' for reaching level " .. level .. "." )
			else
				DRPF_Functions.ChatNotify( ply, Color( 99, 255, 239 ), "[VIP Rewards] ", Color( 255, 255, 255 ), "You received '" .. v .. "' for reaching level " .. level .. "." )
			end
		end
	end,
}
DarkRPFoundation.DEVCONFIG.LevelRewards.Items = {
	Icon = { "RewardsInventory", (447/316) },
	FormatVal = function( val )
		local FormattedVal = "Items: "
		for k, v in pairs( val ) do
			if( FormattedVal != "Items: " ) then
				FormattedVal = FormattedVal .. ", " .. v.Name
			else
				FormattedVal = FormattedVal .. v.Name
			end
		end
	
		return FormattedVal
	end,
	OnReward = function( ply, val, level, vip  )
		for k, v in pairs( val ) do
			local ItemTable = {}
			ItemTable.Class = k
			ItemTable.Model = v.Model
			
			ItemTable.Name = v.Name
			ItemTable.Description = v.Description
			
			ply:DRPF_InventoryInsertItem( ItemTable )
			
			if( not vip ) then
				DRPF_Functions.ChatNotify( ply, Color( 247, 215, 109 ), "[Rewards] ", Color( 255, 255, 255 ), "You received '" .. v.Name .. "' in your inventory for reaching level " .. level .. "." )
			else
				DRPF_Functions.ChatNotify( ply, Color( 99, 255, 239 ), "[VIP Rewards] ", Color( 255, 255, 255 ), "You received '" .. v.Name .. "' in your inventory for reaching level " .. level .. "." )
			end
		end
	end,
}



--[[ DONT TOUCH UNLESS YOU ARE A MASTER HACKER ]]--
DarkRPFoundation.DEVCONFIG.EntityTypes = { 
	["drpf_atm_wall"] = { 
		PrintName = "ATM Machine",
		AngleToSurface = true
	},	
	
	["drpf_bank_vault"] = { 
		PrintName = "Bank Vault",
		AngleToSurface = true
	},	
	
	["drpf_armory"] = { 
		PrintName = "Armory",
		AngleToPlayer = true
	},
	
	["drpf_npc_leveling"] = { 
		PrintName = "Leveling NPC",
		AngleToPlayer = true
	}
}