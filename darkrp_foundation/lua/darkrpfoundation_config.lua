DarkRPFoundation.CONFIG = {}

--[[ GENERAL CONFIG ]]--
DarkRPFoundation.CONFIG.GENERAL = {}
DarkRPFoundation.CONFIG.GENERAL.AdminMod = "ULX/FAdmin/More" -- The admin mod in use, options: "Serverguard", "ULX/FAdmin/More"
DarkRPFoundation.CONFIG.GENERAL.AdminPermissions = {"superadmin", "admin"} -- What admin groups can use the admin tools.
DarkRPFoundation.CONFIG.GENERAL.ServerName = "ConflictRP" -- The server name that appears on certain UI
DarkRPFoundation.CONFIG.GENERAL.DisplayDist3D2D = 500000 -- What distance should 3D2D start fading out, if you get a lot of lag try decreasing this.
DarkRPFoundation.CONFIG.GENERAL.UseMySQL = false -- Whether or not MySQL should be used (enter your details in lua/darkrpfoundation/core/server/darkrpfoundation_sql.lua)
DarkRPFoundation.CONFIG.GENERAL.Language = "english" -- english/russian

--[[ THEME CONFIG ]]--
DarkRPFoundation.CONFIG.THEME = {}
DarkRPFoundation.CONFIG.THEME.Highlight = Color( 254, 211, 41 ) -- Default: Color( 254, 211, 41 )
DarkRPFoundation.CONFIG.THEME.PrimaryColor = Color( 52, 73, 94 ) -- Default: Color( 52, 73, 94 )
DarkRPFoundation.CONFIG.THEME.SecondaryColor = Color( 44, 62, 80 ) -- Default: Color( 44, 62, 80 )
DarkRPFoundation.CONFIG.THEME.TertiaryColor = Color( 38, 54, 68 ) -- Default: Color( 44, 62, 80 )

--[[ INVENTORY ]]--
DarkRPFoundation.CONFIG.INVENTORY = {}
DarkRPFoundation.CONFIG.INVENTORY.Enable = true -- Whether or not the Inventory should be enabled.
DarkRPFoundation.CONFIG.INVENTORY.InvWidth = 6 -- How many slots wide is one page on the inventory.
DarkRPFoundation.CONFIG.INVENTORY.InvHeight = 2 -- How many slots tall is one page on  the inventory.
DarkRPFoundation.CONFIG.INVENTORY.InvPages = 3 -- How many pages are in the inventory
DarkRPFoundation.CONFIG.INVENTORY.ListType = "Blacklist" -- Options: "Blacklist" or "Whitelist"
DarkRPFoundation.CONFIG.INVENTORY.ListEntries = { "drpf_armory", "drpf_atm_wall", "drpf_bank_vault", "drpf_npc_leveling", "drpf_bank_bag" }

DarkRPFoundation.CONFIG.INVENTORY.Conditions = {} -- These are different levels of rarity
DarkRPFoundation.CONFIG.INVENTORY.Conditions["Common"] = Color( 189, 189, 189 )
DarkRPFoundation.CONFIG.INVENTORY.Conditions["Uncommon"] = Color( 49, 146, 54 )
DarkRPFoundation.CONFIG.INVENTORY.Conditions["Rare"] = Color( 76, 81, 247 )
DarkRPFoundation.CONFIG.INVENTORY.Conditions["Epic"] = Color( 157, 77, 187 )
DarkRPFoundation.CONFIG.INVENTORY.Conditions["Legendary"] = Color( 243, 175, 25 )

DarkRPFoundation.CONFIG.INVENTORY.RareityTypes = {}
DarkRPFoundation.CONFIG.INVENTORY.RareityTypes.DefaultSWEP = "Common" -- The default rarity of any SWEP
DarkRPFoundation.CONFIG.INVENTORY.RareityTypes.DefaultENT = "Common" -- The default rarity of any entity
DarkRPFoundation.CONFIG.INVENTORY.RareityTypes.SWEPS = { -- Add the SWEP class and its rarity here
	["weapon_mac102"] = "Common",
	["weapon_mp52"] = "Uncommon",
	["weapon_m42"] = "Rare",
	["ls_sniper"] = "Epic",
	["weapon_deagle2"] = "Legendary",
}
DarkRPFoundation.CONFIG.INVENTORY.RareityTypes.ENTS = {	-- Add the entity class and its rarity here
	["sent_ball"] = "Rare",
}

--[[ PRINTERS ]]--
DarkRPFoundation.CONFIG.PRINTERS = {}
DarkRPFoundation.CONFIG.PRINTERS.Enable = true -- Should printers be enabled
DarkRPFoundation.CONFIG.PRINTERS.AddToF4Menu = true -- Should printers be added to the F4 menu
DarkRPFoundation.CONFIG.PRINTERS.InkLostPerPrint = 10 -- How much ink is lost per print

--[[ HUD ]]--
DarkRPFoundation.CONFIG.HUD = {}
DarkRPFoundation.CONFIG.HUD.Enable = true -- Whether or not the HUD should be enabled.
DarkRPFoundation.CONFIG.HUD.TimeleftNotifications = true -- Whether or not the time left bar should be shown on a notification.
DarkRPFoundation.CONFIG.HUD.WeaponSelectClose = 1 -- How long after opening the weapon selector should it automatically close.

--[[ LEVELING ]]--
DarkRPFoundation.CONFIG.LEVELING = {}
DarkRPFoundation.CONFIG.LEVELING.Enable = false -- Whether or not the leveling system should be enabled.
DarkRPFoundation.CONFIG.LEVELING.LevelupNotification = true -- Whether or not the leveling up notification should be enabled.
DarkRPFoundation.CONFIG.LEVELING.MaxLevel = 100 -- The max level a person can reach.
DarkRPFoundation.CONFIG.LEVELING.OrignalEXPRequired = 150 -- The experience required to level up from 0 to 1.
DarkRPFoundation.CONFIG.LEVELING.EXPRequiredIncrease = 1.1 -- How much the previous experience required to level up is multiplied by.
DarkRPFoundation.CONFIG.LEVELING.NPCEXPGain = 50 -- The experience gained when killing an NPC.
DarkRPFoundation.CONFIG.LEVELING.EXPServerTime = 300 -- How often should a player be given experience for playing on the server, in seconds.
DarkRPFoundation.CONFIG.LEVELING.EXPServerAmount = 50 -- How much experience should be given for playing on the server.
DarkRPFoundation.CONFIG.LEVELING.LockPickEXPGain = 4 -- How much experience should be given for a successful lockpick.
DarkRPFoundation.CONFIG.LEVELING.EnteredLotteryEXPGain = 10 -- How much experience should be given for entering the lottery.
DarkRPFoundation.CONFIG.LEVELING.WonLotteryEXPGain = 100 -- How much experience should be given for winning the lottery.
DarkRPFoundation.CONFIG.LEVELING.HitSuccessEXPGain = 25 -- How much experience should be given for completing a hit.
DarkRPFoundation.CONFIG.LEVELING.FirstJoinEXPGain = 45 -- How much experience should be given for first join.
DarkRPFoundation.CONFIG.LEVELING.TeamKillPenalty = 25 -- How much experience should be taken from the player if they team kill.
DarkRPFoundation.CONFIG.LEVELING.TeamKillGroups = { -- Which teams will recieve a penalty when killing each other.
}
DarkRPFoundation.CONFIG.LEVELING.PlayerKillGroups = { -- Which jobs receive a reward for killing each other, if someone in Team1 kills someone in Team2, then they will get the Reward as experience.
	PoliceVsCriminals = {
		Reward = 50, -- The experience reward
		Team1 = { "Civil Protection", "Civil Protection Chief" }, -- The first team
		Team2 = { "Thief", "Gangster" }, -- The second team
	},
	RussiansVsUSVsOutlaws = {
		Reward = 100,
		Russians = { "Russian Soldier", "Russian Captain" },
		US = { "US Soldier", "US General" },
		Outlaws = { "Outlaw bandit", "Outlaw" }
	}
}

-- REWARDS --
DarkRPFoundation.CONFIG.LEVELING.Rewards = {}
DarkRPFoundation.CONFIG.LEVELING.Rewards[1] = { -- '1' is the level at which the player gets these rewards
	Instant = true, -- Whether or not the player gets the rewards instantly or they have to collect them
	Money = 25000, -- Gives the player $25,000 DarkRP cash
	Weapons = { "weapon_crossbow", "weapon_rpg" }, -- Gives the player these two weapons
	Items = { -- Gives the player items in their inventory
		["drpf_printer_black"] = { -- Gives the player a Black Printer
			Name = "Black Printer",
			Description = "A black printer!",
			Model = "models/darkrpfoundation/money_printer.mdl",
		}
	}
}
DarkRPFoundation.CONFIG.LEVELING.Rewards[3] = {
	Instant = true,
	Money = 25000,
	Weapons = { "weapon_crossbow", "weapon_rpg" },
}
DarkRPFoundation.CONFIG.LEVELING.Rewards[4] = {
	Items = {
		["drpf_printer_black"] = {
			Name = "Black Printer",
			Description = "A black printer!",
			Model = "models/darkrpfoundation/money_printer.mdl",
		}
	}
}
DarkRPFoundation.CONFIG.LEVELING.Rewards[7] = {
	Weapons = { "weapon_crossbow", "weapon_rpg" },
}
DarkRPFoundation.CONFIG.LEVELING.Rewards[8] = {
	Money = 15000,
	Weapons = { "weapon_crossbow", "weapon_rpg" },
}
DarkRPFoundation.CONFIG.LEVELING.Rewards[9] = {
	Weapons = { "weapon_crossbow", "weapon_rpg" },
	Items = {
		["drpf_printer_base"] = {
			Name = "Base Printer",
			Description = "A basic printer!",
			Model = "models/darkrpfoundation/money_printer.mdl",
		},
		["drpf_printer_vip"] = {
			Name = "VIP Printer",
			Description = "A vip printer!",
			Model = "models/darkrpfoundation/money_printer.mdl",
		}
	},
}
DarkRPFoundation.CONFIG.LEVELING.Rewards[10] = {
	Items = {
		["drpf_printer_base"] = {
			Name = "Base Printer",
			Description = "A basic printer!",
			Model = "models/darkrpfoundation/money_printer.mdl",
		}
	}
}

-- VIP REWARDS --
DarkRPFoundation.CONFIG.LEVELING.VIPRanks = { "superadmin", "vip" } -- The ranks which can get VIP rewards
DarkRPFoundation.CONFIG.LEVELING.VIPRewards = {}
DarkRPFoundation.CONFIG.LEVELING.VIPRewards[1] = {
	Money = 50000,
}
DarkRPFoundation.CONFIG.LEVELING.VIPRewards[3] = {
	Instant = true,
	Money = 25000,
}

--[[ ATM ]]--
DarkRPFoundation.CONFIG.ATM = {}
DarkRPFoundation.CONFIG.ATM.Enabled = true -- Whether the ATM is enabled or not
DarkRPFoundation.CONFIG.ATM.MinimumDeposit = 1 -- The minimum ATM deposit
DarkRPFoundation.CONFIG.ATM.MinimumWithdrawl = 1 -- The minimum ATM withdrawl
DarkRPFoundation.CONFIG.ATM.InterestTime = 900 -- How often a player receives interest
DarkRPFoundation.CONFIG.ATM.TransactionBackLog = 10 -- How many transaction logs are kept
DarkRPFoundation.CONFIG.ATM.AccountTypes = {
	[1] = {
		Title = "Standard", -- Title of the account type
		Requirement = 0, -- Money required to get account
		DisplayColor = Color( 125, 125, 125 ), -- The display color
		InterestRate = 1, -- The interest rate in percentage
	},
	[2] = {
		Title = "Gold",
		Requirement = 10000,
		DisplayColor = Color( 218, 165, 32 ),
		InterestRate = 2,
	},
	[3] = {
		Title = "Diamond",
		Requirement = 1000000,
		DisplayColor = Color( 75, 75, 255 ),
		InterestRate = 3,
	},	
	[4] = {
		Title = "Black Diamond",
		Requirement = 100000000,
		DisplayColor = Color( 0, 0, 75 ),
		InterestRate = 5,
	},
}


--[[ BANK VAULT ]]--
DarkRPFoundation.CONFIG.BANKVAULT = {}
DarkRPFoundation.CONFIG.BANKVAULT.MoneyBags = 6 -- How many money bags spawn from the bank
DarkRPFoundation.CONFIG.BANKVAULT.PoliceRequirement = 1 -- The required police to rob the bank
DarkRPFoundation.CONFIG.BANKVAULT.RobberyCooldown = 15 -- Time between successful robberies
DarkRPFoundation.CONFIG.BANKVAULT.AlarmDuration = 5 -- How long the alarm lasts for (tripped on failed break in)
DarkRPFoundation.CONFIG.BANKVAULT.OpenTime = 45 -- How long the vault stays open for after a break in
DarkRPFoundation.CONFIG.BANKVAULT.MoneyBagAmount = { 10000, 50000 } -- The minimum and the maximum possible reward from a money bag
DarkRPFoundation.CONFIG.BANKVAULT.DistanceToUnlock = 100000 -- How far the money bag must be moved from the vault to use it
DarkRPFoundation.CONFIG.BANKVAULT.Pins = 4 -- How many pins need to be unlocked to unlock the vault
DarkRPFoundation.CONFIG.BANKVAULT.MinHeight = 65 -- The minimum height of the puzzle area, the smaller this is the harder it will be (max should not be below the min)
DarkRPFoundation.CONFIG.BANKVAULT.MaxHeight = 85 -- The maximum height of the puzzle area, the smaller this is the harder it will be (max should not be below the min)
DarkRPFoundation.CONFIG.BANKVAULT.SliderSpeed = 2 -- The speed of the line to unlock the pins, the higher this is, the harder it will be.


--[[ ARMORY ]]--
DarkRPFoundation.CONFIG.ARMORY = {}
DarkRPFoundation.CONFIG.ARMORY.PoliceRequirement = 5 -- The police required to rob the armory
DarkRPFoundation.CONFIG.ARMORY.RobberyCooldown = 160 -- How long between robberies
DarkRPFoundation.CONFIG.ARMORY.OpenTime = 5 -- How long does it take to rob the armory
DarkRPFoundation.CONFIG.ARMORY.RewardExperience = 20 -- The experience reward from robbing the armory
DarkRPFoundation.CONFIG.ARMORY.RewardMoneyMin = 10000 -- The minimum money reward from robbing the armory
DarkRPFoundation.CONFIG.ARMORY.RewardMoneyMax = 100000	-- The maximum money reward from robbing the armory
DarkRPFoundation.CONFIG.ARMORY.RewardShipmentMin = 2 -- The minimum amount of shipments that will spawn from the armory
DarkRPFoundation.CONFIG.ARMORY.RewardShipmentMax = 5 -- The maximum amount of shipments that will spawn from the armory
DarkRPFoundation.CONFIG.ARMORY.RewardShipments = { "AK47", "Desert eagle" } -- The names of the shipments that can spawn from a robbery
DarkRPFoundation.CONFIG.ARMORY.FailCooldown = 60 -- How long the player has to wait to retry a robbery if they die or walk to far away
DarkRPFoundation.CONFIG.ARMORY.Weapons = {
	[1] = {
		Name = "AK-47 Rifle",
		Weapon = "weapon_ak472",
		Model = "models/weapons/w_rif_ak47.mdl",
		Level = 0
	},
	[2] = {
		Name = "M4 Rifle",
		Weapon = "weapon_m42",
		Model = "models/weapons/w_rif_m4a1.mdl",
		Level = 0
	},
	[3] = {
		Name = "Pump Shotgun",
		Weapon = "weapon_pumpshotgun2",
		Model = "models/weapons/w_shot_m3super90.mdl",
		Level = 0
	},
	[4] = {
		Name = "Deagle",
		Weapon = "weapon_deagle2",
		Model = "models/weapons/w_pist_deagle.mdl",
		Level = 0
	},
}
DarkRPFoundation.CONFIG.ARMORY.Ammo = {
	[1] = {
		Name = "Pistol Ammo",
		AmmoType = "Pistol",
		Amount = 30,
		MaxAmount = 90,
		Model = "models/items/boxsrounds.mdl",
		Level = 0
	},
	[2] = {
		Name = "SMG Ammo",
		AmmoType = "SMG1",
		Amount = 45,
		MaxAmount = 90,
		Model = "models/items/boxsrounds.mdl",
		Level = 0
	},
	[3] = {
		Name = "Buckshot",
		AmmoType = "Buckshot",
		Amount = 12,
		MaxAmount = 36,
		Model = "models/items/boxbuckshot.mdl",
		Level = 0
	},
}
DarkRPFoundation.CONFIG.ARMORY.Gear = {
	[1] = {
		Name = "Light Armor",
		Amount = 50,
		Model = "models/Items/battery.mdl",
		Level = 0
	},
	[2] = {
		Name = "Medium Armor",
		Amount = 100,
		Model = "models/Items/battery.mdl",
		Level = 0
	},
	[3] = {
		Name = "Heavy Armor",
		Amount = 150,
		Model = "models/Items/battery.mdl",
		Level = 0
	},
}

