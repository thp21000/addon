
--[[
You can now disable attach system and restrict it to world surfaces only
Bug fixes

Config changes:
Added CUFFS_EnableAttach
Added CUFFS_EnableAttachEntity

]]
RHandcuffsConfig = RHandcuffsConfig or {}

--IF YOU WANNA REMOVE THE COMPUTER FROM BEING PURCHASEABLE REMOVE THIS FOLDER: addons\tbfy_shared_v2\lua\darkrp_modules

--Contact me on gmodstore for help to translate
--Languages available:
--[[
chinese
danish
dutch
english
french
german
korean
norwegian
polish
russian
turkish
]]
RHandcuffsConfig.LanguageToUse = "english"
//Who can access admin commands,menus etc
RHandcuffsConfig.AdminAccessCustomCheck = function(Player) return Player:IsAdmin() end

RHandcuffsConfig.NPCData = {
["rhc_bailer"] = {Text = "Bailer", Model = "models/Barney.mdl", TextFont = "rhc_npc_text", TextRotationSpeed = 80, TextColor = Color(255,255,255,255), TextBackgroundColor = Color(0,0,0,255)},
["rhc_jailer"] = {Text = "Jailer", Model = "models/player/Group01/Female_01.mdl", TextFont = "rhc_npc_text", TextRotationSpeed = 80, TextColor = Color(255,255,255,255), TextBackgroundColor = Color(0,0,0,255)},
}

RHandcuffsConfig.CuffSound = "weapons/357/357_reload1.wav"

//Displays if player is cuffed overhead while aiming at him
RHandcuffsConfig.DisplayOverheadCuffed = false
//Calculates Movement/Penalty, so 2 would make player move half as fast
//Moving penalty while cuffed
RHandcuffsConfig.RestrainedMovePenalty = 3
//Moving penalty while dragging
RHandcuffsConfig.DraggingMovePenalty = 3
//Setting this to true will cause the system to bonemanipulate clientside, might cause sync issues but won't require you to install all playermodels on the server
RHandcuffsConfig.BoneManipulateClientside = false

//Key to drag a player
//https://wiki.garrysmod.com/page/Enums/IN
RHandcuffsConfig.KEY = IN_USE

RHandcuffsConfig.SurrenderEnabled = true
//All keys can be found here -> https://wiki.garrysmod.com/page/Enums/KEY
//Key for surrendering
RHandcuffsConfig.SurrenderKey = KEY_T
//You can't surrender while holding these weapons
RHandcuffsConfig.SurrenderWeaponWhitelist = {
["weapon_arc_phone"] = true,
}

//Entities that you are allowed to interact with while cuffed (For example press plates)
//Add within the brackets, ["ENTITYNAME"] = true,
RHandcuffsConfig.WhitelistedEntitiesUse = {

}

//Entities that you aren't allowed to attatch players to
//Add within the brackets, ["ENTITYNAME"] = true,
RHandcuffsConfig.AttatchmentBlacklistEntities = {
["rhc_jailer"] = true,
["func_door"] = true,
["func_door_rotating"] = true,
["prop_door_rotating"] = true,
}

//On arrest configs
RHandcuffsConfig.OnArrest = {
	SetModel = false, --Set Model to config: .ArrestModel
	CustomFunction = function(Player) end, --Custom lua function, ran upon arrest
}

//Model to set upon arrest
RHandcuffsConfig.ArrestModel = {Model = "models/player/Group01/Female_01.mdl", Skin = 1}

function RHC_InitJobsConfig()
	timer.Simple(3, function()
		//Don't touch this unless you want to change handcuff model (this is for the one drawn on the cuffed player)
		local EData = {
			EID = "handcuffs", -- Don't change this
			Name = "Handcuffs",
			Ent = "prop_physics",
			Model = "models/tobadforyou/handcuffs.mdl",
			MScale = 1.2,
			MSkin = nil,
			MColor = nil,
			AdjPos = Vector(1, 6, 0.5),
			AdjAng = Angle(0, 25, 75),
			Bone = "ValveBiped.Bip01_R_Hand",
			ForPurchase = false,
		}
		TBFY_SH:RegisterEquip(EData)

		local EData = {
			EID = "handcuffs_starwars", -- Don't change this
			Name = "Handcuffs",
			Ent = "prop_physics",
			Model = "models/casual/handcuffs/handcuffs.mdl",
			MScale = .94,
			MSkin = nil,
			MColor = nil,
			AdjPos = Vector(0, 4.4, 0.3),
			AdjAng = Angle(0, 10, 45),
			Bone = "ValveBiped.Bip01_R_Hand",
			ForPurchase = false,
		}
		TBFY_SH:RegisterEquip(EData)
	end)
end

//Disables drawing player shadow
//Only use this if the shadows are causing issues
//This is a temp fix, will be fixed in the future
RHandcuffsConfig.DisablePlayerShadow = false

//If itemstore is installed, should confiscating illegal items be enabled?
RHandcuffsConfig.InventoryIllegalItemsEnabled = true
//Items that are illegal, defined by the entity class
//For bricks essentials, it uses the name of the item not the class
RHandcuffsConfig.InventoryIllegalItems = {
["money_printer"] = true,
["weapon_ak472"] = true,
}
RHandcuffsConfig.BlackListedWeapons = {
["gmod_tool"] = true,
["weapon_keypadchecker"] = true,
["vc_wrench"] = true,
["vc_jerrycan"] = true,
["vc_spikestrip_wep"] = true,
["laserpointer"] = true,
["remotecontroller"] = true,
["idcard"] = true,
["pickpocket"] = true,
["keys"] = true,
["pocket"] = true,
["driving_license"] = true,
["firearms_license"] = true,
["weapon_physcannon"] = true,
["gmod_camera"] = true,
["weapon_physgun"] = true,
["weapon_r_restrained"] = true,
["tbfy_surrendered"] = true,
["weapon_r_cuffed"] = true,
["collections_bag"] = true,
["weapon_fists"] = true,
["weapon_arc_atmcard"] = true,
["itemstore_pickup"] = true,
["weapon_checker"] = true,
["driving_license_checker"] = true,
["fine_list"] = true,
["weapon_r_handcuffs"] = true,
["door_ram"] = true,
["med_kit"] = true,
["stunstick"] = true,
["arrest_stick"] = true,
["unarrest_stick"] = true,
["weaponchecker"] = true,
["bricks_server_invpickup"] = true,
}

//Add all female models here or the handcuffs positioning will be weird
//It's case sensitive, make sure all letters are lowercase
RHandcuffsConfig.FEMALE_MODELS = {
    "models/player/group01/female_01.mdl",
    "models/player/group01/female_02.mdl",
    "models/player/group01/female_03.mdl",
    "models/player/group01/female_04.mdl",
    "models/player/group01/female_05.mdl",
    "models/player/group01/female_06.mdl",
    "models/player/group03/female_01.mdl",
    "models/player/group03/female_02.mdl",
    "models/player/group03/female_03.mdl",
    "models/player/group03/female_04.mdl",
    "models/player/group03/female_05.mdl",
    "models/player/group03/female_06.mdl",
}

hook.Add("DarkRPFinishedLoading", "RHC_InitJobs", function()
    if DCONFIG then
		hook.Add("DConfigDataLoaded", "RHC_InitJobs", RHC_InitJobsConfig)
	elseif ezJobs then
        hook.Add("ezJobsLoaded", "RHC_InitJobs", RHC_InitJobsConfig)
    else
        hook.Add("loadCustomDarkRPItems", "RHC_InitJobs", RHC_InitJobsConfig)
    end
end)
