
local PLAYER = FindMetaTable("Player")
RHC_ArrestedPlayers = RHC_ArrestedPlayers or {}

local CatName = "Realistic Handcuffs"
local CatID = "rhandcuffs"

TBFY_SH:RegisterLanguage(CatID)
local Language = RHandcuffsConfig.LanguageToUse
include("tbfy_rhandcuffs/language/" .. Language .. ".lua");
if SERVER then
	AddCSLuaFile("tbfy_rhandcuffs/language/" .. Language .. ".lua");
end

function RHC_GetLang(ID)
	return TBFY_SH:GetLanguage(CatID, ID)
end

function RHC_GetConf(ID)
	return TBFY_SH:FetchConfig(CatID, ID)
end

function PLAYER:RHC_IsArrested()
	if RHC_ArrestedPlayers[self:SteamID()] then
		return true
	else
		return false
	end
end

function PLAYER:RHC_GetATime()
	local SteamID = self:SteamID()
	if RHC_ArrestedPlayers[SteamID] then
		return RHC_ArrestedPlayers[SteamID].ATime
	else
		return 0
	end
end

function PLAYER:RHC_GetANick()
	local SteamID = self:SteamID()
	if RHC_ArrestedPlayers[SteamID] then
		return RHC_ArrestedPlayers[SteamID].ANick
	else
		return "None"
	end
end

function PLAYER:IsRHCWhitelisted()
	if !RHC_GetConf("CUFFS_RestrictCuffs") then
		return true
	else
		return RHC_GetConf("CUFFS_WhitelistedJobs")[self:Team()]
	end
end

function PLAYER:IsRHCImmune()
	return RHC_GetConf("CUFFS_BlacklistedJobs")[self:Team()]
end

function PLAYER:CanRHCJail()
	return RHC_GetConf("JAIL_JailingJobs")[self:Team()]
end

function PLAYER:CanRHCBail()
	return RHC_GetConf("BAIL_BailingJobs")[self:Team()]
end

function PLAYER:TBFY_CanSurrender()
	if !self:Alive() or self:InVehicle() or self.Restrained or self.RKRestrained then return false end

	local Wep = self:GetActiveWeapon()
	if !IsValid(Wep) or RHandcuffsConfig.SurrenderWeaponWhitelist[Wep:GetClass()] then
		return false
	else
		return true
	end
end

hook.Add("canLockpick", "AllowCuffPicking", function(Player, CuffedP, Trace)
	if CuffedP:GetNWBool("rhc_cuffed", false) then
		return true
	end
end)

hook.Add("lockpickTime", "SetupCuffPickTime", function(Player, Entity)
	if Entity:GetNWBool("rhc_cuffed", false) then
		return RHC_GetConf("CUFFS_LockPickTime")
	end
end)

hook.Add("canRequestHit", "RHC_RestrictHitMenu", function(Hitman, Player)
	if Hitman:GetNWBool("rhc_cuffed", false) then
		return false
	end
end)

local CMoveData = FindMetaTable("CMoveData")

function CMoveData:RemoveKeys(keys)
	-- Using bitwise operations to clear the key bits.
	local newbuttons = bit.band(self:GetButtons(), bit.bnot(keys))
	self:SetButtons(newbuttons)
end

hook.Add("SetupMove", "rhc_setupmove", function(Player, mv)
  local CuffedPlayer = Player.Dragging
	local AProp = Player:GetNWEntity("RHC_AttatchEnt", nil)

	if Player:GetNWBool("rhc_cuffed",false) or Player.Restrained then
		mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() / RHandcuffsConfig.RestrainedMovePenalty)
		if mv:KeyDown(IN_JUMP) then
			mv:RemoveKeys(IN_JUMP)
		end
	elseif Player.Dragging then
	    mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() / RHandcuffsConfig.DraggingMovePenalty)
	end

	if Player:GetNWBool("RHC_Attatched", false) and IsValid(AProp) then
		local PlayerPos = Player:GetPos()
		local EntPos = AProp:GetAttatchPosition()
		local AEnt = AProp:GetAttatchedEntity()
		if IsValid(AEnt) then
			EntPos = AEnt:GetPos()
		end

		local EntDir = (EntPos - PlayerPos):GetNormal()
		local MaxDistance = 100
		local MaxPos = EntPos - (EntDir*MaxDistance)

		local EntX, EntY, MaxX, MaxY = EntPos.x, EntPos.y, MaxPos.x, MaxPos.y
		local PlyX, PlyY = PlayerPos.x, PlayerPos.y
		if (EntX > PlyX and MaxX > PlyX) or (EntX < PlyX and MaxX < PlyX) or (EntY > PlyY and MaxY > PlyY) or (EntY < PlyY and MaxY < PlyY) then
			local Vel = EntDir*25

			mv:SetOrigin(MaxPos)
			mv:SetVelocity(Vel)
		end
  elseif IsValid(CuffedPlayer) and Player == CuffedPlayer.DraggedBy then
		local DragerPos = Player:GetPos()
		local DraggedPos = CuffedPlayer:GetPos()
		local Distance = DragerPos:Distance(DraggedPos)

		if Distance < RHC_GetConf("DRAG_MaxRange") then
			local DragPosNormal = DragerPos:GetNormal()
			local Difx = math.abs(DragPosNormal.x)
			local Dify = math.abs(DragPosNormal.y)

			local Speed = (Difx + Dify)*math.Clamp(Distance/RHC_GetConf("DRAG_RangeForce"),0,RHC_GetConf("DRAG_MaxForce"))

			local ang = mv:GetMoveAngles()
		  local pos = mv:GetOrigin()
		  local vel = mv:GetVelocity()

		  vel.x = vel.x * Speed
		  vel.y = vel.y * Speed
			vel.z = 15

		  pos = pos + vel + ang:Right() + ang:Forward() + ang:Up()

			if Distance > 55 then
				CuffedPlayer:SetVelocity(vel)
			end
		else
			CuffedPlayer:CancelDrag()
		end
  end
end)

hook.Add("tbfy_InitSetup","RHC_InitSetup",function()
	local NPCData = RHandcuffsConfig.NPCData
	local ESaveInfo = {
		["rhc_jailer"] = {Class = "rhc_jailer", Folder = "jailer_npc", Cond = function(Ent) return true end, ModelS = NPCData["rhc_jailer"].Model, NameS = "Jailer", SaveS = "Save Jailer NPC", SavedS = "Saved Jailer NPC",
		LoadFunc = function(Data)
			local Jailer = ents.Create("rhc_jailer")
			Jailer:SetPos(Data.Pos)
			Jailer:SetAngles(Data.Angles)
			Jailer:Spawn()

			if Data.JailPos then
				Jailer.JailPos = Data.JailPos
			end
			if Data.UnJailPos then
				Jailer.UnJailPos = Data.UnJailPos
			end
		end,
		SaveFunc = function(Ent, Tbl)
			if Ent.JailPos then
				Tbl.JailPos = Ent.JailPos
			end
			if Ent.UnJailPos then
				Tbl.UnJailPos = Ent.UnJailPos
			end
			return Tbl
		end},
		["rhc_bailer"] = {Class = "rhc_bailer", Folder = "bailer_npc", Cond = function(Ent) return true end, ModelS = NPCData["rhc_bailer"].Model, NameS = "Bailer", SaveS = "Save Bailer NPC", SavedS = "Saved Bailer NPC"},
	}

	TBFY_SH:SetupConfig(CatID, "BAIL_PriceForEach", "The bail price for each value in JAIL_MaxJailTime, (JAIL_MaxJailTime*ThisConfig)", "Number", {Val = 500, Decimals = 0, Max = 5000, Min = 1}, true)
	TBFY_SH:SetupConfig(CatID, "BAIL_RestrictBailing", "Restrict bailing to jobs set in the config", "Bool", false, false)
	TBFY_SH:SetupConfig(CatID, "BAIL_BailingJobs", "The jobs that are allowed to bail players", "Jobs", {}, true)

	TBFY_SH:SetupConfig(CatID, "CUFFS_HandcuffsJailing", "Should the handcuffs jail players instead of cuffing?", "Bool", false, false)
	TBFY_SH:SetupConfig(CatID, "CUFFS_JailTime", "How long a player should be jailed (Only if you have Handcuffs jailing enabled)", "Number", {Val = 5, Decimals = 0, Max = 600, Min = 1}, false)
	TBFY_SH:SetupConfig(CatID, "CUFFS_LockPickTime", "How long it takes to lockpick the cuffs", "Number", {Val = 15, Decimals = 0, Max = 60, Min = 1}, false)
	TBFY_SH:SetupConfig(CatID, "CUFFS_CuffingTime", "How long it takes to cuff a player (Set to 0 to disable)", "Number", {Val = 2, Decimals = 0, Max = 10, Min = 0}, true)
	TBFY_SH:SetupConfig(CatID, "CUFFS_AutoUncuffingTime", "How long before a player is automaticly uncuffed (Counted in minutes, set to 0 to disable)", "Number", {Val = 0, Decimals = 0, Max = 20, Min = 0}, false)
	TBFY_SH:SetupConfig(CatID, "CUFFS_CuffRange", "How long range should cuffing have?", "Number", {Val = 75, Decimals = 0, Max = 300, Min = 50}, false)
	TBFY_SH:SetupConfig(CatID, "CUFFS_DisableUse", "Should players E (+Use) be blocked while handcuffed?", "Bool", true, false)
	TBFY_SH:SetupConfig(CatID, "CUFFS_RestrictCuffs", "Restrict handcuffs to jobs set in the config", "Bool", false, true)
	TBFY_SH:SetupConfig(CatID, "CUFFS_GrantToWhitelisted", "Grants handcuffs to jobs set in the config", "Bool", false, false)
	TBFY_SH:SetupConfig(CatID, "CUFFS_WhitelistedJobs", "The jobs that are allowed to use the handcuffs, if CUFFS_RestrictCuffs is enabled", "Jobs", {}, true)
	TBFY_SH:SetupConfig(CatID, "CUFFS_BlacklistedJobs", "The jobs that aren't allowed to be handcuffed", "Jobs", {}, true)
	TBFY_SH:SetupConfig(CatID, "CUFFS_UncuffedForcedWeaponSelection", "The SWEP that should be selected upon uncuffed", "SWEP", "keys", false)
	TBFY_SH:SetupConfig(CatID, "CUFFS_StarWarsCuffs", "Should Star Wars cuffs be used?", "Bool", false, true)
	TBFY_SH:SetupConfig(CatID, "CUFFS_FreezeCuffed", "Should the player be frozen while being cuffed?", "Bool", false, false)
	TBFY_SH:SetupConfig(CatID, "CUFFS_EnableAttach", "Should it be possible to attach players to surfaces/props?", "Bool", true, false)
	TBFY_SH:SetupConfig(CatID, "CUFFS_EnableAttachEntity", "Should it be possible to attach players to props?", "Bool", true, false)

	TBFY_SH:SetupConfig(CatID, "DRAG_MaxRange", "Maximum range for dragging, will cancel if player is futher away than this", "Number", {Val = 175, Decimals = 0, Max = 300, Min = 50}, false)
	TBFY_SH:SetupConfig(CatID, "DRAG_MaxForce", "Maximum velocity for dragging (increase this if dragging is slow)", "Number", {Val = 30, Decimals = 0, Max = 500, Min = 1}, false)
	TBFY_SH:SetupConfig(CatID, "DRAG_RangeForce", "Range force for dragging (lower this if dragging is slow)", "Number", {Val = 100, Decimals = 0, Max = 100, Min = 1}, false)
	TBFY_SH:SetupConfig(CatID, "DRAG_Restriction", "Restriction for who is allowed to drag cuffed players", "TextOptions", {Val = "anyone", Options = {{Name = "Anyone can drag", ID = "anyone"}, {Name = "Whitelisted Only", ID = "whitelisted"}, {Name = "Cuffer only", ID = "cuffer"}}}, false)

	TBFY_SH:SetupConfig(CatID, "INSPECT_AllowInspection", "Enable inspecting players", "Bool", true, false)
	TBFY_SH:SetupConfig(CatID, "INSPECT_AllowConfiscating", "Enable confiscation of weapons and items", "Bool", true, true)
	TBFY_SH:SetupConfig(CatID, "INSPECT_AllowConfiscatingJobWeapons", "Enable confiscation of weapons given through jobs", "Bool", true, true)
	TBFY_SH:SetupConfig(CatID, "INSPECT_ConfiscateWeaponReward", "Reward for confiscating a weapon (Set to 0 to disable)", "Number", {Val = 250, Decimals = 0, Max = 3000, Min = 0}, false)
	TBFY_SH:SetupConfig(CatID, "INSPECT_ConfiscateItemReward", "Reward for confiscating an item (Set to 0 to disable)", "Number", {Val = 150, Decimals = 0, Max = 3000, Min = 0}, false)

	TBFY_SH:SetupConfig(CatID, "JAIL_JailReward", "Enable rewards when jailing players", "Bool", true, false)
	TBFY_SH:SetupConfig(CatID, "JAIL_JailRewardAmount", "Reward amount for jailing players", "Number", {Val = 250, Decimals = 0, Max = 3000, Min = 1}, false)
	TBFY_SH:SetupConfig(CatID, "JAIL_UnarrestRemoveCuffs", "Does the player has to be uncuffed before unarrested?", "Bool", true, false)
	TBFY_SH:SetupConfig(CatID, "JAIL_UnJailLockpickTeleport", "Should lockpicking the cuffs teleport the player to the unarrest position?", "Bool", false, false)
	TBFY_SH:SetupConfig(CatID, "JAIL_NPCJailingOnly", "Should jailing be restricted to Jailer NPC?", "Bool", true, false)
	TBFY_SH:SetupConfig(CatID, "JAIL_UnarrestOnDeath", "Should players get unarrested if they die while jailed?", "Bool", true, false)
	TBFY_SH:SetupConfig(CatID, "JAIL_MaxJailTime", "Maximum amount of time a player can be put in jail (1 = 60 seconds)", "Number", {Val = 10, Decimals = 0, Max = 60, Min = 1}, true)
	TBFY_SH:SetupConfig(CatID, "JAIL_MustBeCuffed", "Does the player has to be handcuffed to be jailed?", "Bool", true, false)
	TBFY_SH:SetupConfig(CatID, "JAIL_RestrictJailing", "Restrict jailing to jobs set in the config", "Bool", true, false)
	TBFY_SH:SetupConfig(CatID, "JAIL_CuffedInJail", "Should arrested players be cuffed while in jail?", "Bool", true, false)
	TBFY_SH:SetupConfig(CatID, "JAIL_JailingJobs", "The jobs that are allowed to jail players", "Jobs", {}, true)
	TBFY_SH:SetupConfig(CatID, "JAIL_SetPrisonerJob", "Should it set jailed players to a specific prison job?", "Bool", false, false)
	TBFY_SH:SetupConfig(CatID, "JAIL_PrisonJob", "The job the player is set to during jailtime, if JAIL_SetPrisonerJob is enabled", "Job", nil, false)
	TBFY_SH:SetupConfig(CatID, "JAIL_AmountType", 'What it should display as "punishment amount", for example years', "Text", "Years", true)
	TBFY_SH:SetupConfig(CatID, "JAIL_AllowedSWEPs", "The SWEPs that are allowed to be picked up while jailed", "SWEPs", {}, false)

	if SERVER then
		TBFY_SH:LoadConfigs(CatID)
		TBFY_SH:SetupAddonInfo(CatID, RHandcuffsConfig.AdminAccessCustomCheck, ESaveInfo)
	else
		TBFY_SH:RequestConfig(CatID)
		TBFY_SH:SetupCategory(CatName)
		TBFY_SH:SetupCMDButton(CatName, "Configs", nil, function() local Configs = vgui.Create("tbfy_edit_config") Configs:SetConfigs(CatID, CatName) end)

		for k,v in pairs(ESaveInfo) do
			TBFY_SH:SetupEntity(CatName, v.NameS, v.Class, v.ModelS, v.OffSet, v.SEnts, v.NoGEnt)
			if !v.NoSave then
				TBFY_SH:SetupCMDButton(CatName, v.SaveS, "save_tbfy_ent " .. CatID .. " " .. k)
			end
		end

		TBFY_SH:SetupCustomFunctionL(CatName, "rhc_jailer", function(SWEP)
			if SWEP.CurStage == 1 then
				if IsValid(SWEP.GhostEnt) then
					SWEP.CurStage = 2
					net.Start("tbfy_spawn_entity")
						net.WriteString(SWEP.CurEnt)
						net.WriteVector(SWEP.GhostEnt:GetPos())
						net.WriteAngle(SWEP.GhostEnt:GetAngles())
					net.SendToServer()
				end
			elseif SWEP.CurStage == 2 then
				local PTrace = LocalPlayer():GetEyeTrace()
				net.Start("RHC_add_npc_jailpos")
					net.WriteVector(PTrace.HitPos)
				net.SendToServer()
			elseif SWEP.CurStage == 3 then
				local PTrace = LocalPlayer():GetEyeTrace()
				net.Start("RHC_add_npc_unjailpos")
					net.WriteVector(PTrace.HitPos)
				net.SendToServer()
			end
		end)
		TBFY_SH:SetupCustomFunctionR(CatName, "rhc_jailer", function(SWEP)
			if SWEP.CurStage == 2 then
				SWEP.CurStage = 3
			elseif SWEP.CurStage == 3 then
				SWEP.CurStage = 1
			end
		end)
		TBFY_SH:SetupCustomFunctionDraw(CatName, "rhc_jailer", function(SWEP)
			if SWEP.CurStage == 2 then
				draw.SimpleTextOutlined("Left Click: Set jail position for NPC (Where you are aiming)","Trebuchet24",ScrW()/2,5,Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,2,Color(0,0,0,255))
				draw.SimpleTextOutlined("Right Click: Finish setting jail positions","Trebuchet24",ScrW()/2,30,Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,2,Color(0,0,0,255))
			elseif SWEP.CurStage == 3 then
				draw.SimpleTextOutlined("Left Click: Set unjail position for NPC (Where you are aiming)","Trebuchet24",ScrW()/2,5,Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,2,Color(0,0,0,255))
				draw.SimpleTextOutlined("Right Click: Finish setting unjail positions","Trebuchet24",ScrW()/2,30,Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,2,Color(0,0,0,255))
			end
		end)

		TBFY_SH:SetupCMDButton(CatName, "Add Jail Position", "add_rhc_jaillocation")
		TBFY_SH:SetupCMDButton(CatName, "Remove All Jail Positions", "remove_rhc_jaillocations")
		TBFY_SH:SetupCMDButton(CatName, "Add Unjail Position", "add_rhc_unjaillocation")
		TBFY_SH:SetupCMDButton(CatName, "Remove All Unjail Positions", "remove_rhc_unjaillocations")
	end
end)
