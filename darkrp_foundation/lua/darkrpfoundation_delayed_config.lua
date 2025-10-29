DarkRPFoundation.CONFIG.GENERAL.PoliceJobs = { TEAM_COMMISSAIRE, TEAM_CHEFGIGN, TEAM_SNIPERGIGN, TEAM_GIGN, TEAM_NEGOCI, TEAM_AGENTSECRET, TEAM_ANTIRIOT, TEAM_ENQUETEUR, TEAM_POLICE, TEAM_RECRUE } -- Jobs which are police and should be counted towards police requirements
DarkRPFoundation.CONFIG.BANKVAULT.RobberTeams = { TEAM_COORD, TEAM_QM, TEAM_SABOTEUR }  -- Jobs which can rob the bank vault
DarkRPFoundation.CONFIG.ARMORY.RobberTeams = { TEAM_COORD } -- Jobs which can rob the armory

--[[ TEMPORARY UNTIL CONFIG ADDED INGAME ]]--
DarkRPFoundation.CONFIG.ARMORY.Weapons[5] = {
	Name = "AR2",
	Weapon = "weapon_ar2",
	Model = "models/weapons/w_IRifle.mdl",
	Level = 0,
	Restrictions = { TEAM_COMMISSAIRE, TEAM_CHEFGIGN }
}

DarkRPFoundation.CONFIG.ARMORY.Ammo[4] = {
	Name = "Rifle Ammo",
	AmmoType = "AR2",
	Amount = 60,
	MaxAmount = 160,
	Model = "models/items/boxmrounds.mdl",
	Level = 0,
	Restrictions = { TEAM_COMMISSAIRE, TEAM_CHEFGIGN }
}

DarkRPFoundation.CONFIG.ARMORY.Gear[4] = {
	Name = "Juggernaut Armor",
	Amount = 255,
	Model = "models/Items/battery.mdl",
	Level = 0,
	Restrictions = { TEAM_COMMISSAIRE, TEAM_CHEFGIGN }
}