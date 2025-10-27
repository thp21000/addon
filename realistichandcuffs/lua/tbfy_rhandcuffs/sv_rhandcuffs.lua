
local PLAYER = FindMetaTable("Player")

resource.AddWorkshop("761228248")

util.AddNetworkString("rhc_sendcuffs")
util.AddNetworkString("rhc_inspect")
util.AddNetworkString("rhc_send_inspect_information")
util.AddNetworkString("rhc_confiscate_weapon")
util.AddNetworkString("rhc_bonemanipulate")
util.AddNetworkString("rhc_update_jailtime")
util.AddNetworkString("rhc_jailed")
util.AddNetworkString("rhc_confiscate_item")
util.AddNetworkString("tbfy_surr")

hook.Add("Initialize", "rhc_init_folders", function()
	file.CreateDir("rhandcuffs")
	file.CreateDir("rhandcuffs/npcs")
	file.CreateDir("rhandcuffs/jaillocations")
	file.CreateDir("rhandcuffs/unjaillocations")
end)

hook.Add("bLogs_FullyLoaded","RHC_bLogsInit",function()
	if ((not GAS or not GAS.Logging) and bLogs) then
		local MODULE = bLogs:Module()

		MODULE.Category = "ToBadForYou"
		MODULE.Name     = "Realistic Handcuffs"
		MODULE.Colour   = Color(0,0,255)

		MODULE:Hook("RHC_restrain","rhc_toggle_restrain",function(vic, handcuffer)
			local LogText = "cuffed"
			if !vic.Restrained then
				LogText = "uncuffed"
			end
			MODULE:Log(bLogs:FormatPlayer(handcuffer) .. " " .. LogText .. " " .. bLogs:FormatPlayer(vic))
		end)

		MODULE:Hook("RHC_jailed","rhc_jailed_player",function(vic, jailer, time, reason)
			MODULE:Log(bLogs:FormatPlayer(jailer) .. " jailed " .. bLogs:FormatPlayer(vic) .. " for " .. time .. " seconds, reason: " .. reason)
		end)

		MODULE:Hook("RHC_confis_weapon","rhc_confis_w",function(vic, confis, wep)
			MODULE:Log(bLogs:FormatPlayer(confis) .. " confiscated a " .. wep .. " from " .. bLogs:FormatPlayer(vic) .. ".")
		end)

		MODULE:Hook("RHC_confis_item","rhc_confis_i",function(vic, confis, item)
			MODULE:Log(bLogs:FormatPlayer(confis) .. " confiscated a " .. item .. " from " .. bLogs:FormatPlayer(vic) .. ".")
		end)

		bLogs:AddModule(MODULE)
	end
end)

//To make it work with DarkRP unarrest stick
function PLAYER:onUnArrestStickUsed(Unarrester)
	if self:RHC_IsArrested() then
		if RHC_GetConf("JAIL_UnarrestRemoveCuffs") and self.Restrained and !Unarrester:IsRHCWhitelisted() then
			TBFY_Notify(Unarrester, 1, 4, RHC_GetLang("ReqLockpick"))
		else
			self:RHC_UnArrest(Unarrester)
		end
	end
end
//To make it work with DarkRP arrest stick
function PLAYER:onArrestStickUsed(Arrester)
	if RHC_GetConf("JAIL_MustBeCuffed") and !self.Restrained then
		TBFY_Notify(Arrester, 1, 4, RHC_GetLang("MustBeCuffed"))
  elseif RHC_GetConf("JAIL_NPCJailingOnly") then
		TBFY_Notify(Arrester, 1, 4, RHC_GetLang("JailerNPCArrest"))
	elseif !self:RHC_IsArrested() then
		local Time = GAMEMODE.Config.jailtimer or 120
		self:RHC_Arrest(Time, Arrester)
	else
		self:RHC_SendToUnJail()
	end
end

function PLAYER:RHCInspect(Player)
	if !self:IsRHCWhitelisted() then return end
	if !IsValid(self:GetActiveWeapon()) or self:GetActiveWeapon():GetClass() != "weapon_r_handcuffs" then return false end

	if !Player.Restrained then return end
	local Distance = self:EyePos():Distance(Player:GetPos());
	if Distance > 150 then return false; end

	local IllegalItems = {}
	if RHandcuffsConfig.InventoryIllegalItemsEnabled then
		if itemstore then
			for k, v in pairs(Player.Inventory:GetItems()) do
				local ToCheck = v.Class
				if v.Data.Class then
					ToCheck = v.Data.Class
				end
				if RHandcuffsConfig.InventoryIllegalItems[ToCheck] then
					IllegalItems[k] = {Name = v:GetName(), Model = v:GetModel()}
				end
			end
		elseif BRICKS_SERVER and BRICKS_SERVER.Func.IsSubModuleEnabled("essentials", "inventory") then
			for k, v in pairs(Player:GetInventory()) do
				local ItemTable = v[2]
				if RHandcuffsConfig.InventoryIllegalItems[ItemTable[3]] then
					IllegalItems[k] = {Name = ItemTable[3], Model = ItemTable[2]}
				end
			end
		end
	end

	local TotalWeps = #Player.StoreWTBL
	net.Start("rhc_send_inspect_information")
		net.WriteEntity(Player)
		net.WriteFloat(TotalWeps)
		for k,v in pairs(Player.StoreWTBL) do
			net.WriteFloat(k)
			net.WriteString(v.Class)
		end

		if (itemstore or BRICKS_SERVER) and RHandcuffsConfig.InventoryIllegalItemsEnabled then
			local TotalItems = table.Count(IllegalItems)
			net.WriteFloat(TotalItems)
			for k,v in pairs(IllegalItems) do
				net.WriteFloat(k)
				net.WriteString(v.Name)
				net.WriteString(v.Model)
			end
		end
	net.Send(self)
end

net.Receive("rhc_confiscate_weapon", function(len, Player)
	if !RHC_GetConf("INSPECT_AllowConfiscating") or !RHC_GetConf("INSPECT_AllowInspection") then return false end
	if !Player:IsRHCWhitelisted() then return end
	if !IsValid(Player:GetActiveWeapon()) or Player:GetActiveWeapon():GetClass() != "weapon_r_handcuffs" then return false end

	local ConfisFrom, WepTblID = net.ReadEntity(), net.ReadFloat()
	if !ConfisFrom.Restrained then return end
	local Distance = Player:EyePos():Distance(ConfisFrom:GetPos());
	if Distance > 150 then return false; end

	if ConfisFrom.StoreWTBL[WepTblID] then
		local Wep = ConfisFrom.StoreWTBL[WepTblID].Class
		if RHandcuffsConfig.BlackListedWeapons[Wep] then return end
		local jobTable = {}
		if DarkRP then
			jobTable = ConfisFrom:getJobTable()
		end
		if RHC_GetConf("INSPECT_AllowConfiscatingJobWeapons") or (jobTable.weapons and !table.HasValue(jobTable.weapons, Wep)) then
			ConfisFrom.StoreWTBL[WepTblID] = nil
			local Reward = RHC_GetConf("INSPECT_ConfiscateWeaponReward")
			if Reward > 0 then
				TBFY_Notify(Player, 1, 4, string.format(RHC_GetLang("ConfiscateReward"), Reward))
				Player:addMoney(Reward)
			else
				TBFY_Notify(Player, 1, 4, string.format(RHC_GetLang("ConfiscateWeapon"), Wep))
			end
			hook.Call("RHC_confis_weapon", GAMEMODE, ConfisFrom, Player, Wep)
		end
	end
end)

net.Receive("rhc_confiscate_item", function(len, Player)
	if !RHC_GetConf("INSPECT_AllowConfiscating") or !RHC_GetConf("INSPECT_AllowInspection") then return false end
	if !Player:IsRHCWhitelisted() then return end
	if !IsValid(Player:GetActiveWeapon()) or Player:GetActiveWeapon():GetClass() != "weapon_r_handcuffs" then return false end

	local ConfisFrom = net.ReadEntity()
	if !ConfisFrom.Restrained then return end
	local Distance = Player:EyePos():Distance(ConfisFrom:GetPos());
	if Distance > 150 then return false; end

	local ItemName
	if itemstore then
		local ItemSlot = net.ReadFloat()
		local ItemTable = ConfisFrom.Inventory:GetItem(ItemSlot)
		if ItemTable then
			local ItemClass = ItemTable.Class
			if ItemTable.Data.Class then
				ItemClass = ItemTable.Data.Class
			end
			if RHandcuffsConfig.InventoryIllegalItems[ItemClass] then
				if ItemTable.GetName then
					ItemName = ItemTable:GetName()
				else
					ItemName = ItemClass
				end
				ConfisFrom.Inventory:SetItem(ItemSlot, nil)
			else
				return
			end
		else
			return
		end
	elseif BRICKS_SERVER and BRICKS_SERVER.BASECONFIG.MODULES["essentials"][2]["inventory"] then
		local ItemID = net.ReadFloat()
		local InventoryTable = ConfisFrom:GetInventory()
		if InventoryTable[ItemID] then
			local ItemTable = InventoryTable[ItemID][2]
			if RHandcuffsConfig.InventoryIllegalItems[ItemTable[3]] then
				ItemName = ItemTable[3]
				InventoryTable[ItemID] = nil
				ConfisFrom:SetInventory(InventoryTable)
			else
				return
			end
		else
			return
		end
	end

	local Reward = RHC_GetConf("INSPECT_ConfiscateItemReward")
	if Reward > 0 then
		TBFY_Notify(Player, 1, 4, string.format(RHC_GetLang("ConfiscateRewardItem"), Reward, ItemName))
		Player:addMoney(Reward)
	else
		TBFY_Notify(Player, 1, 4, string.format(RHC_GetLang("ConfiscateItem"), ItemName))
	end
	hook.Call("RHC_confis_item", GAMEMODE, ConfisFrom, Player, Name)
end)

RHC_JailLocations = RHC_JailLocations or {}
RHC_UnJailLocations = RHC_UnJailLocations or {}
local CurrentMap = string.lower(game.GetMap())
if file.Exists("rhandcuffs/jaillocations/" .. CurrentMap .. ".txt" ,"DATA") then
	RHC_JailLocations = util.JSONToTable(file.Read( "rhandcuffs/jaillocations/" .. CurrentMap .. ".txt" ))
end

concommand.Add("add_rhc_jaillocation", function(Player, CMD, Args)
	if !Player:IsAdmin() then return end

	local Pos = Player:GetPos()
	table.insert(RHC_JailLocations, Pos)
	file.Write("rhandcuffs/jaillocations/" .. CurrentMap .. ".txt", util.TableToJSON(RHC_JailLocations))

	TBFY_Notify(Player, 1, 4, RHC_GetLang("AddedGlobalJailLocation"))
end)

concommand.Add("remove_rhc_jaillocations", function(Player, CMD, Args)
	if !Player:IsAdmin() then return end

	RHC_JailLocations = {}
	file.Write("rhandcuffs/jaillocations/" .. CurrentMap .. ".txt", util.TableToJSON(RHC_JailLocations))

	TBFY_Notify(Player, 1, 4, RHC_GetLang("RemovedAllGlobalJailLocations"))
end)

if file.Exists("rhandcuffs/unjaillocations/" .. CurrentMap .. ".txt" ,"DATA") then
	RHC_UnJailLocations = util.JSONToTable(file.Read( "rhandcuffs/unjaillocations/" .. CurrentMap .. ".txt" ))
end

concommand.Add("add_rhc_unjaillocation", function(Player, CMD, Args)
	if !Player:IsAdmin() then return end

	local Pos = Player:GetPos()
	table.insert(RHC_UnJailLocations, Pos)
	file.Write("rhandcuffs/unjaillocations/" .. CurrentMap .. ".txt", util.TableToJSON(RHC_UnJailLocations))

	TBFY_Notify(Player, 1, 4, RHC_GetLang("AddedGlobalUnjailLocation"))
end)

concommand.Add("remove_rhc_unjaillocations", function(Player, CMD, Args)
	if !Player:IsAdmin() then return end

	RHC_UnJailLocations = {}
	file.Write("rhandcuffs/unjaillocations/" .. CurrentMap .. ".txt", util.TableToJSON(RHC_UnJailLocations))

	TBFY_Notify(Player, 1, 4, RHC_GetLang("RemovedAllGlobalUnjailLocations"))
end)

function PLAYER:RHC_SendToJail(Arrester)
	local SafePos = nil
	local JailPoses = RHC_JailLocations or {}

	if Arrester and IsValid(Arrester) then
		local Jailer = Arrester.LastJailerNPC
		if IsValid(Jailer) and Jailer.JailPos then
			self.JailNPC = Jailer
			JailPoses = Jailer.JailPos
		end
	else
		local Jailer = self.JailNPC
		if IsValid(Jailer) and Jailer.JailPos then
			JailPoses = Jailer.JailPos
		end
	end

	for k, v in pairs(JailPoses) do
		local FilledSpot = false
		for _, ent in pairs(ents.FindInSphere(v, 75)) do
			if ent:IsPlayer() and ent != self then
				FilledSpot = true
			end
		end

		if (!FilledSpot) then
			SafePos = v
			break
		end
	end

	if SafePos then
		self:SetPos(SafePos)
	else
		if IsValid(Arrester) then
			TBFY_Notify(Arrester, 1, 4, RHC_GetLang("NoJailLocations"))
		end
	end
end

function PLAYER:RHC_SendToUnJail()
	local SafePos = nil
	local UnJailPoses = RHC_UnJailLocations or {}

	local Jailer = self.JailNPC
	if IsValid(Jailer) and Jailer.UnJailPos then
		UnJailPoses = Jailer.UnJailPos
	end

	for k, v in pairs(UnJailPoses) do
		local FilledSpot = false
		for _, ent in pairs(ents.FindInSphere(v, 75)) do
			if ent:IsPlayer() and ent != self then
				FilledSpot = true
			end
		end

		if (!FilledSpot) then
			SafePos = v
			break
		end
	end

	if SafePos then
		self:SetPos(SafePos)
	else
		TBFY_Notify(self, 1, 4, RHC_GetLang("NoUnjailLocations"))
		self:Spawn()
	end
end

function PLAYER:RHC_UnArrest(UnArrester, UnjailPos)
  self:StripWeapon("weapon_r_cuffed")

	if self.Restrained then
		self:CleanUpRHC(false)
  end
	self.StoreWTBL = {}

	if IsValid(UnArrester) then
		TBFY_Notify(self, 1, 4, string.format(RHC_GetLang("UnArrested"), UnArrester:Nick()))
		TBFY_Notify(UnArrester, 1, 4, string.format(RHC_GetLang("UnArrester"), self:Nick()))
	else
		TBFY_Notify(self, 1, 4, RHC_GetLang("UnArrestedNoPlayer"))
	end

	local SID = self:SteamID()
	net.Start("rhc_update_jailtime")
		net.WriteBool(false)
		net.WriteFloat(0)
		net.WriteString(SID)
		net.WriteString("")
	net.Broadcast()

	RHC_ArrestedPlayers[SID] = false
	if timer.Exists(self:SteamID64() .. "_jailtimer") then
		timer.Remove(self:SteamID64() .. "_jailtimer")
	end

	local OnArrest = RHandcuffsConfig.OnArrest
	if self.PreCArrestT then
		self:changeTeam(self.PreCArrestT, true, true)
		self.PreCArrestT = nil
	end
	if self.PreCArrestM then
		self:SetModel(self.PreCArrestM)
		self.PreCArrestM = nil
		if CLOTHESMOD then ply:CM_ResetMaterials() end
	end

	if DarkRP then
		self:setDarkRPVar("Arrested", nil)
		hook.Call("playerUnArrested", DarkRP.hooks, self, UnArrester)
	end

	if UnjailPos then
		//To make sure it calls hook but still overrides the unjail location
		timer.Simple(.5, function()
			self:RHC_SendToUnJail()
		end)
	end
end

function PLAYER:RHC_Arrest(Time, Arrester, Reason)
	if self:InVehicle() then self:ExitVehicle() end

	if DarkRP then
		if self:isWanted() then
			self:unWanted(Arrester)
		end
		self:setDarkRPVar("HasGunlicense", nil)
		//self:setDarkRPVar("Arrested", true)
		if IsValid(Arrester) then
			hook.Call("playerArrested", DarkRP.hooks, self, Time, Arrester)
		end
	end

  self:StripWeapons()
  self:StripAmmo()

  timer.Create(self:SteamID64() .. "_jailtimer", Time, 1, function()
    if IsValid(self) then
			self:RHC_UnArrest(nil, true)
		end
	end)

	self.Restrained = true
	self:CleanUpRHC(false, true)

	self.RHC_JailTime = Time

	local Nick = "None"
	if IsValid(Arrester) then
		Nick = Arrester:Nick()
		if RHC_GetConf("JAIL_JailReward") then
			local RAmount = RHC_GetConf("JAIL_JailRewardAmount")
			Arrester:addMoney(RAmount)
			TBFY_Notify(Arrester, 1, 4, string.format(RHC_GetLang("ArrestReward"), RAmount, self:Nick()))
		end
	end

	self.RHC_ArrestedBy = Nick

	if RHC_GetConf("JAIL_SetPrisonerJob") then
		self.PreCArrestT = self:Team()
		local PrisonTeam = RHC_GetConf("JAIL_PrisonJob")
		if PrisonTeam then
			self:changeTeam(PrisonTeam, true, true)
		end
	end

	RHC_ArrestedPlayers[self:SteamID()] = {ATime = Time, ANick = Nick}

	net.Start("rhc_update_jailtime")
		net.WriteBool(true)
		net.WriteFloat(self.RHC_JailTime)
		net.WriteString(self:SteamID())
		net.WriteString(Nick)
	net.Broadcast()

	net.Start("rhc_jailed")
	net.Send(self)

	self:RHC_SendToJail(Arrester)

	timer.Simple(.2, function()
		if RHC_GetConf("JAIL_CuffedInJail") then
			self.Restrained = true
			self:SetupCuffs()
			if RHC_GetConf("CUFFS_StarWarsCuffs") then
				self:SetupRHCBones("Cuffed_StarWars")
			else
				self:SetupRHCBones("Cuffed")
			end
			self:Give("weapon_r_cuffed")
		end
		local OnArrest = RHandcuffsConfig.OnArrest
		if OnArrest.SetModel then
			self.PreCArrestM = self:GetModel()
			local MInf = RHandcuffsConfig.ArrestModel
			self:SetModel(MInf.Model)
			self:SetSkin(MInf.Skin)
			if CLOTHESMOD then ply:CM_ResetMaterials() end
		end
		OnArrest.CustomFunction(self)
	end)

	Reason = Reason or "None"
	hook.Call("RHC_jailed", GAMEMODE, self, Arrester, Time, Reason)
end

function PLAYER:CanRHCDrag(CPlayer)
	if !CPlayer.Restrained or (CPlayer.DraggedBy or self.Dragging) and (self.Dragging != CPlayer or CPlayer.DraggedBy != self) then return end

	local DragPerm = RHC_GetConf("DRAG_Restriction")
  if DragPerm == "cuffer" and CPlayer.CuffedBy == self then
      return true
  elseif DragPerm == "whitelisted" and self:IsRHCWhitelisted() then
      return true
  elseif DragPerm == "anyone" then
      return true
  end
	return false
end

function PLAYER:CleanUpRHC(GWeapons, NoReset)
  self.Restrained = false
	if RHC_GetConf("CUFFS_StarWarsCuffs") then
		self:SetupRHCBones("Cuffed_StarWars", true)
	else
		self:SetupRHCBones("Cuffed", true)
	end
  if !NoReset then
	  local CBy = self.CuffedBy
	  if IsValid(CBy) then
	      CBy.CuffedPlayer = nil
	  end
	  self.CuffedBy = nil
  end
  self:SetupCuffs()
  self:CancelDrag()

  if GWeapons then
      self:SetupWeapons()
  end

	if self.RHC_Attatched then
		self:RHC_RemoveAttatch()
	end

	if timer.Exists("RHC_uncuff_" .. TBFY_SH:SID(self)) then
		timer.Destroy("RHC_uncuff_" .. TBFY_SH:SID(self))
	end
end

local RHC_BoneManipulations = {
	["Cuffed"] = {
		["ValveBiped.Bip01_R_UpperArm"] = Angle(-28,18,-21),
		["ValveBiped.Bip01_L_Hand"] = Angle(0,0,119),
		["ValveBiped.Bip01_L_Forearm"] = Angle(15,20,40),
		["ValveBiped.Bip01_L_UpperArm"] = Angle(15, 26, 0),
		["ValveBiped.Bip01_R_Forearm"] = Angle(0,50,0),
		["ValveBiped.Bip01_R_Hand"] = Angle(45,34,-15),
		["ValveBiped.Bip01_L_Finger01"] = Angle(0,50,0),
		["ValveBiped.Bip01_R_Finger0"] = Angle(10,2,0),
		["ValveBiped.Bip01_R_Finger1"] = Angle(-10,0,0),
		["ValveBiped.Bip01_R_Finger11"] = Angle(0,-40,0),
		["ValveBiped.Bip01_R_Finger12"] = Angle(0,-30,0)
	},
	["Cuffed_StarWars"] = {
		["ValveBiped.Bip01_L_Hand"] = Angle(0,0,119),
		["ValveBiped.Bip01_L_Forearm"] = Angle(0,25,40),
		["ValveBiped.Bip01_L_UpperArm"] = Angle(30, 26, 0),
		["ValveBiped.Bip01_R_UpperArm"] = Angle(-40,20, 0),
		["ValveBiped.Bip01_R_Forearm"] = Angle(5,50,0),
		["ValveBiped.Bip01_R_Hand"] = Angle(45,34,-15),
		["ValveBiped.Bip01_L_Finger01"] = Angle(0,50,0),
		["ValveBiped.Bip01_R_Finger0"] = Angle(10,2,0),
		["ValveBiped.Bip01_R_Finger1"] = Angle(-10,0,0),
		["ValveBiped.Bip01_R_Finger11"] = Angle(0,-40,0),
		["ValveBiped.Bip01_R_Finger12"] = Angle(0,-30,0)
	},
	["HandsUp"] = {
		["ValveBiped.Bip01_R_UpperArm"] = Angle(73,35,128),
		["ValveBiped.Bip01_L_Hand"] = Angle(-12,12,90),
		["ValveBiped.Bip01_L_Forearm"] = Angle(-28,-29,44),
		["ValveBiped.Bip01_R_Forearm"] = Angle(-22,1,15),
		["ValveBiped.Bip01_L_UpperArm"] = Angle(-77,-46,4),
		["ValveBiped.Bip01_R_Hand"] = Angle(33,39,-21),
		["ValveBiped.Bip01_L_Finger01"] = Angle(0,30,0),
		["ValveBiped.Bip01_L_Finger1"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger11"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger2"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger21"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger3"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger31"] = Angle(0,45,0),
		["ValveBiped.Bip01_R_Finger0"] = Angle(-10,0,0),
		["ValveBiped.Bip01_R_Finger11"] = Angle(0,30,0),
		["ValveBiped.Bip01_R_Finger2"] = Angle(20,25,0),
		["ValveBiped.Bip01_R_Finger21"] = Angle(0,45,0),
		["ValveBiped.Bip01_R_Finger3"] = Angle(20,35,0),
		["ValveBiped.Bip01_R_Finger31"] = Angle(0,45,0)
	}
}

function PLAYER:SetupRHCBones(Type, Reset)
    if RHandcuffsConfig.BoneManipulateClientside then
		net.Start("rhc_bonemanipulate")
			net.WriteEntity(self)
			net.WriteString(Type)
			net.WriteBool(Reset)
		net.Broadcast()
	else
		for k,v in pairs(RHC_BoneManipulations[Type]) do
			local Bone = self:LookupBone(k)
			if Bone then
				if Reset then
					self:ManipulateBoneAngles(Bone, Angle(0,0,0))
				else
					self:ManipulateBoneAngles(Bone, v)
				end
			end
		end
	end
	if RHandcuffsConfig.DisablePlayerShadow then
		self:DrawShadow(false)
	end
end

function PLAYER:TBFY_ToggleSurrender()
	if self.TBFY_Surrendered then
		self:SetupRHCBones("HandsUp", true)
		self.TBFY_Surrendered = false
		self:StripWeapon("tbfy_surrendered")
	else
		self:Give("tbfy_surrendered")
		//FA Support
		local Swep = self:GetActiveWeapon()
		if IsValid(Swep) and Swep.dt then
			Swep.dt.Status = 6
		end
		self:SelectWeapon("tbfy_surrendered")
		self:SetupRHCBones("HandsUp")
		self.TBFY_Surrendered = true
	end
end

local RHC_Surrendering = {}
hook.Add("Think", "TBFY_Surrender", function()
	for k,v in pairs(RHC_Surrendering) do
		local P, T = v.P, v.ST
		if T < CurTime() then
			RHC_Surrendering[P:SteamID()] = nil
			net.Start("tbfy_surr")
				net.WriteFloat(0)
			net.Send(P)
			P:TBFY_ToggleSurrender()
		end
	end
end)

hook.Add("PlayerDisconnected", "TBFY_Surrender", function(Player)
	if RHC_Surrendering[Player:SteamID()] then
		RHC_Surrendering[Player:SteamID()] = nil
	end
end)

hook.Add("PlayerButtonDown","TBFY_Surrender",function(Player, Key)
	if RHandcuffsConfig.SurrenderEnabled and Key == RHandcuffsConfig.SurrenderKey and Player:TBFY_CanSurrender() then
		local SurrTime = CurTime() + 2.5
		RHC_Surrendering[Player:SteamID()] = {P = Player, ST = SurrTime}
		net.Start("tbfy_surr")
			net.WriteFloat(SurrTime)
		net.Send(Player)
	end
end)

hook.Add("PlayerButtonUp","TBFY_Surrender",function(Player, Key)
	if Key == RHandcuffsConfig.SurrenderKey and RHC_Surrendering[Player:SteamID()] then
		RHC_Surrendering[Player:SteamID()] = nil
		net.Start("tbfy_surr")
			net.WriteFloat(0)
		net.Send(Player)
	end
end)

hook.Add("demoteTeam", "TBFY_pre_demote", function(Player)
	Player.being_demoted = true
end)

hook.Add("playerCanChangeTeam", "TBFY_NoChangeJobSurrender", function(Player, Team)
  if Player.TBFY_Surrendered and !Player.being_demoted then
		return false, ""
	end
	Player.being_demoted = false
end)

hook.Add("OnPlayerChangedTeam", "TBFY_NoChangeJobSurrender", function(Player, Team)
  if Player.TBFY_Surrendered then
		Player:TBFY_ToggleSurrender()
	end
end)

hook.Add("PlayerSwitchWeapon", "TBFY_NoSwitchWeaponSurrender", function(Player, OldSwep, NewSWEP)
	if Player.TBFY_Surrendered then return true end
end)

hook.Add("PlayerCanPickupWeapon", "TBFY_DisablePickupWeapon", function(Player, Wep)
	if Player.TBFY_Surrendered and Wep:GetClass() != "tbfy_surrendered" then return false end
end)

hook.Add("canDropWeapon", "TBFY_DisableDropWeapon", function(Player)
	if Player.TBFY_Surrendered then return false end
end)

hook.Add("CanPlayerEnterVehicle", "TBFY_CanPlayerEnterVehicle", function(Player, Vehicle)
	if Player.TBFY_Surrendered then return false end
end)

hook.Add("PlayerDeath", "TBFY_OnDeathSurrender", function( Player, Inflictor, Attacker )
    if Player.TBFY_Surrendered then
        Player:TBFY_ToggleSurrender()
    end
end)

hook.Add("PlayerUse", "TBFY_DisableUseSurrender", function(Player, Entity)
	if Player.TBFY_Surrendered then return false end
end)

function PLAYER:SetupCuffs()
	if RHC_GetConf("CUFFS_StarWarsCuffs") then
		TBFY_SH:TogglePEquip(self, "handcuffs_starwars", self.Restrained)
	else
		TBFY_SH:TogglePEquip(self, "handcuffs", self.Restrained)
	end
  self:SetNWBool("rhc_cuffed", self.Restrained)
end

function PLAYER:SetupWeapons()
  if self.Restrained then
    self.StoreWTBL = {}
    for k,v in pairs(self:GetWeapons()) do
			local WData = {Class = v:GetClass()}
			WData.PrometheusGiven = v.PrometheusGiven
			WData.IsFromArmory = v.IsFromArmory
			WData.isPermanent = v.isPermanent
			self.StoreWTBL[k] = WData
    end
    self:StripWeapons()
		self:Give("weapon_r_cuffed")
  elseif !self.Restrained then
  	self:StripWeapon("weapon_r_cuffed")
		for k,v in pairs(self.StoreWTBL) do
    	local SWEP = self:Give(v.Class)
			SWEP.IsFromArmory = v.IsFromArmory
			SWEP.PrometheusGiven = v.PrometheusGiven
			SWEP.isPermanent = v.isPermanent
			local SWEPTable = weapons.GetStored(v.Class)
			if SWEPTable then
				local DefClip = SWEPTable.Primary.DefaultClip
				local AmmoType = SWEPTable.Primary.Ammo
				local ClipSize = SWEPTable.Primary.ClipSize
				if (DefClip and DefClip > 0) and AmmoType and ClipSize then
					local AmmoToRemove = DefClip - ClipSize
					self:RemoveAmmo(AmmoToRemove, AmmoType)
				end
			end
    end
    self.StoreWTBL = {}
		self:SelectWeapon(RHC_GetConf("CUFFS_UncuffedForcedWeaponSelection"))
  end
end

function PLAYER:RHCRestrain(HandcuffedBy)
	if !self.Restrained then
		if self.TBFY_Surrendered then
			self:TBFY_ToggleSurrender()
		end
    self.Restrained = true
    self.CuffedBy = HandcuffedBy
    HandcuffedBy.CuffedPlayer = self
		if RHC_GetConf("CUFFS_StarWarsCuffs") then
			self:SetupRHCBones("Cuffed_StarWars")
		else
			self:SetupRHCBones("Cuffed")
		end
    self:SetupCuffs()
    self:SetupWeapons()
    TBFY_Notify(self, 1, 4, string.format(RHC_GetLang("CuffedBy"), HandcuffedBy:Nick()))
    TBFY_Notify(HandcuffedBy, 1, 4, string.format(RHC_GetLang("Cuffer"), self:Nick()))

		local UncuffTime = RHC_GetConf("CUFFS_AutoUncuffingTime")*60
		if UncuffTime != 0 then
			timer.Create("RHC_uncuff_" .. TBFY_SH:SID(self), UncuffTime, 1, function()
				if IsValid(self) then
					self:CleanUpRHC(true)
					TBFY_Notify(self, 1, 4, RHC_GetLang("AutoUncuff"))
				end
			end)
		end
  elseif self.Restrained then
    self:CleanUpRHC(true)
    TBFY_Notify(self, 1, 4, string.format(RHC_GetLang("ReleasedBy"), HandcuffedBy:Nick()))
    TBFY_Notify(HandcuffedBy, 1, 4, string.format(RHC_GetLang("Releaser"), self:Nick()))
  end

	hook.Call("RHC_restrain", GAMEMODE, self, HandcuffedBy)
end

local PGettingDragged = {}
function PLAYER:DragPlayer(TPlayer)
  if self == TPlayer.DraggedBy then
    TPlayer:CancelDrag()
  elseif !self.Dragging then
	TPlayer.DraggedBy = self
    TPlayer:Freeze(true)
    self.Dragging = TPlayer
    if !table.HasValue(PGettingDragged, TPlayer) then
        table.insert(PGettingDragged, TPlayer)
    end
  end
end

function PLAYER:CancelDrag()
  if table.HasValue(PGettingDragged, self) then
      table.RemoveByValue(PGettingDragged, self)
  end
	if IsValid(self) then
		local DraggedByP = self.DraggedBy
		if IsValid(DraggedByP) then
			DraggedByP.Dragging = nil
		end
		self.DraggedBy = nil
		self:Freeze(false)
	end
end

function PLAYER:RHC_RemoveAttatch(UnAttatchPlayer)
	local AttatchEnt = self.RHC_AEnt
	if IsValid(AttatchEnt) then
		AttatchEnt:Remove()
	end
	local AEnt = self.RHC_AttachtedTo
	if IsValid(AEnt) then
		self.RHC_AttachtedTo.AttatchedPlayer = nil
	end

	if IsValid(UnAttatchPlayer) then
		TBFY_Notify(UnAttatchPlayer, 1, 4, string.format(RHC_GetLang("UnAttatchedPlayer"), self:Nick()))
	end

	self.RHC_AEnt = nil
	self.RHC_Attatched = false
	self:SetNWEntity("RHC_AttatchEnt", nil)
	self:SetNWBool("RHC_Attatched", false)
end

function PLAYER:RHC_AttatchPlayer(APlayer, Pos, AEnt)
	if IsValid(AEnt) then
		if !RHC_GetConf("CUFFS_EnableAttachEntity") then
			TBFY_Notify(self, 1, 4, "Players may not be attached to entities.")
			return
		end
		if AEnt:IsVehicle() or AEnt:IsPlayer() or !IsValid(AEnt:GetPhysicsObject()) or RHandcuffsConfig.AttatchmentBlacklistEntities[AEnt:GetClass()] then return end
		if AEnt:GetPhysicsObject():IsMotionEnabled() then
			TBFY_Notify(self, 1, 4, RHC_GetLang("MustBeFrozen"))
			return
		end
	end

	APlayer:CancelDrag()

	local AttatchEnt = APlayer.RHC_AEnt
	if !IsValid(AttatchEnt) then
		AttatchEnt = ents.Create("rhc_attatch")
		AttatchEnt:Spawn()
	end

	AttatchEnt:SetPos(APlayer:GetPos())
	AttatchEnt:SetOwningPlayer(APlayer)
	AttatchEnt:SetAttatchedEntity(AEnt)
	AttatchEnt:SetAttatchPosition(Pos)
	AttatchEnt:SetParent(APlayer)

	APlayer.RHC_AEnt = AttatchEnt
	APlayer.RHC_AttachtedTo = AEnt
	AEnt.AttatchedPlayer = APlayer
	APlayer.RHC_Attatched = true

	APlayer:SetNWEntity("RHC_AttatchEnt", AttatchEnt)
	APlayer:SetNWBool("RHC_Attatched", true)

	TBFY_Notify(self, 1, 4, string.format(RHC_GetLang("AttatchedPlayer"), APlayer:Nick()))
end

hook.Add("PhysgunPickup", "RHC_PhysgunPickup", function(Player, Entity)
	if IsValid(Entity.AttatchedPlayer) then
		return false
	end
end)

hook.Add("CanPlayerUnfreeze", "RHC_CanUnFreezeEnt", function(Player, Entity)
	if IsValid(Entity.AttatchedPlayer) then
		return false
	end
end)

hook.Add("EntityRemoved", "RHC_EntityRemoved", function(Entity)
	if IsValid(Entity.AttatchedPlayer) then
		Entity.AttatchedPlayer:RHC_RemoveAttatch()
	end
end)

local KeyToCheck = RHandcuffsConfig.KEY
hook.Add("KeyPress", "RHC_AllowDragging", function(Player, Key)
	if Key == KeyToCheck and !Player:InVehicle() then
		local Trace = {}
		Trace.start = Player:GetShootPos();
		Trace.endpos = Trace.start + Player:GetAimVector() * 50;
		Trace.filter = Player;

		local Tr = util.TraceLine(Trace);
		local TEnt = Tr.Entity

		local ValidEnt = IsValid(TEnt)
		local DraggedP = Player.Dragging
		if ValidEnt and TEnt:IsPlayer() then
			if TEnt:GetNWBool("RHC_Attatched", false) then
				TEnt:RHC_RemoveAttatch(Player)
			elseif Player:CanRHCDrag(TEnt) then
				Player:DragPlayer(TEnt)
			end
		elseif IsValid(DraggedP) and RHC_GetConf("CUFFS_EnableAttach") then
			local Pos = Tr.HitPos
			if ValidEnt then
				Pos = TEnt:GetPos()
			end
			if Tr.HitWorld or IsValid(Tr.Entity) then
				if Pos:Distance(DraggedP:GetPos()) < 100 then
					Player:RHC_AttatchPlayer(DraggedP, Pos, TEnt)
				else
					TBFY_Notify(Player, 1, 4, RHC_GetLang("TooFarAway"))
				end
			end
		end
  end
end)

hook.Add("Think", "RHC_HandlePlayerDraggingRange", function()
	local DragRange = RHC_GetConf("DRAG_MaxRange")
	for k,v in pairs(PGettingDragged) do
    if !IsValid(v) then table.RemoveByValue(PGettingDragged, v) end
    local DPlayer = v.DraggedBy
    if IsValid(DPlayer) then
      local Distance = v:GetPos():Distance(DPlayer:GetPos());
      if Distance > DragRange then
        v:CancelDrag()
      end
    else
      v:CancelDrag()
    end
  end
end)

hook.Add("playerCanChangeTeam", "RHC_RestrictTeamChange", function(Player, Team)
    if Player.Dragging then
		return false, RHC_GetLang("CantChangeTeamDrag")
	elseif Player.Restrained then
		return false, RHC_GetLang("CantChangeTeam")
	elseif Player:RHC_IsArrested() then
		return false, RHC_GetLang("CantChangeTeamArrested")
	end
end)

hook.Add("canBuyCustomEntity", "RHC_NoBuyJailed", function(Player, Team)
  if Player:RHC_IsArrested() or Player.Restrained then
		return false, ""
	end
end)

hook.Add("PlayerDeath", "RHC_OnDeath", function(Player, Inflictor, Attacker)
	local draggedPlayer = Player.Dragging
	if IsValid(draggedPlayer) then
		draggedPlayer:CancelDrag()
		Player.Dragging = nil
	end

	if Player:RHC_IsArrested() and RHC_GetConf("JAIL_UnarrestOnDeath") then
		Player:RHC_UnArrest()
	elseif !Player:RHC_IsArrested() then
		if Player.Restrained then
			Player:CleanUpRHC(false)
		end
	end
end)

hook.Add("onLockpickCompleted", "OnSuccessPickCuffs", function(Player, Success, CuffedP)
  if IsValid(CuffedP) and CuffedP:GetNWBool("rhc_cuffed", false) and Success then
		CuffedP:CleanUpRHC(true)
		TBFY_Notify(CuffedP, 1, 4, string.format(RHC_GetLang("ReleasedBy"), Player:Nick()))
		TBFY_Notify(Player, 1, 4, string.format(RHC_GetLang("Releaser"), CuffedP:Nick()))
		if CuffedP:RHC_IsArrested() then
			CuffedP:RHC_UnArrest(Player, RHC_GetConf("JAIL_UnJailLockpickTeleport"))
		end
	end
end)

hook.Add("CanPlayerEnterVehicle", "RestrictEnteringVCuffs", function(Player, Vehicle)
	if (Player.Restrained and !Player.DraggedBy) or Player:RHC_IsArrested() then
        TBFY_Notify(Player, 1, 4, RHC_GetLang("CantEnterVehicle"))
        return false
	elseif Player.Dragging then
		return false
    end
end)

hook.Add("PlayerEnteredVehicle", "FixCuffsInVehicle", function(Player,Vehicle)
    if Player.Restrained then
        Player:CleanUpRHC(false, true)
        Player.Restrained = true
		if Vehicle.playerdynseat then
			Player:ExitVehicle()
		end
    end
end)

hook.Add("PlayerLeaveVehicle", "ReaddCuffsLVehicle", function(Player, Vehicle)
    if Player.Restrained then
        Player:SetupCuffs()
				if RHC_GetConf("CUFFS_StarWarsCuffs") then
					Player:SetupRHCBones("Cuffed_StarWars")
				else
        	Player:SetupRHCBones("Cuffed")
				end
    end
end)

hook.Add("CanExitVehicle", "RestrictLeavingVCuffs", function(Vehicle, Player)
    if Player.Restrained then
        TBFY_Notify(Player, 1, 4, RHC_GetLang("CantLeaveVehicle"))
        return false
    end
end)

hook.Add("PlayerDisconnected", "RHC_StopDragOnDC", function(Player)
	local Dragger = Player.DraggedBy
	if IsValid(Dragger) then
		if !table.HasValue(PGettingDragged, Player) then
			table.RemoveByValue(PGettingDragged, Player)
		end
		Dragger.Dragging = nil
	end
end)

local APIKey = 76561197989708503
hook.Add("PlayerInitialSpawn", "SendCuffInfo", function(Player)
  //Allow to intialize fully first
  timer.Simple(5, function()
    if IsValid(Player) then
			for k,v in pairs(player.GetAll()) do
				if v:RHC_IsArrested() then
					net.Start("rhc_update_jailtime")
						net.WriteBool(true)
						net.WriteFloat(v.RHC_JailTime or 60)
						net.WriteString(v:SteamID())
						net.WriteString(v.RHC_ArrestedBy or "None")
					net.Send(Player)
				end
			end
		end
  end)
end)

hook.Add("PlayerSpawnProp", "DisablePropSpawningCuffed", function(Player)
    if Player.Restrained or Player:RHC_IsArrested() then
        TBFY_Notify(Player, 1, 4, RHC_GetLang("CantSpawnProps"))
        return false
    end
end)

hook.Add("PlayerLoadout", "RHC_AddCuffsWToCP", function(Player)
	if RHC_GetConf("CUFFS_GrantToWhitelisted") and Player:IsRHCWhitelisted() then
		Player:Give("weapon_r_handcuffs")
	end
end)

hook.Add("canArrest", "RHC_MustbeCuffedArrest", function(Player, ArrestedPlayer)
    if RHC_GetConf("JAIL_MustBeCuffed") then
        if !ArrestedPlayer.Restrained then
            return false, RHC_GetLang("MustBeCuffed")
		elseif ArrestedPlayer:isArrested() or ArrestedPlayer:RHC_IsArrested() then
			return false, RHC_GetLang("AlreadyArrested")
        end
    end
end)

hook.Add("canUnarrest", "RestrictUnArrestCuffed", function(Player, UnarrestPlayer)
    if RHC_GetConf("JAIL_UnarrestRemoveCuffs") and UnarrestPlayer.Restrained and !Player:IsRHCWhitelisted() then
        return false, RHC_GetLang("ReqLockpick")
    end
end)

hook.Add("canDropWeapon", "RHC_DisableDropWeapon", function(Player)
	if Player.RHC_BeingCuffed or Player.Restrained or Player:RHC_IsArrested() then return false end
end)

hook.Add("onDarkRPWeaponDropped", "RHC_NoDrop", function(Player, Wep, EqpWep)
	if EqpWep:GetClass() == "weapon_r_handcuffs" then
		Wep:SetModel("models/tobadforyou/handcuffs.mdl")
	end
	if Player.RHC_BeingCuffed or Player.Restrained or Player:RHC_IsArrested() then
		timer.Simple(0.1, function() if IsValid(Wep) then Wep:Remove() end end)
	end
end)

hook.Add("PlayerCanPickupWeapon", "RHC_DisablePickingUpWeapons", function(Player, Wep)
	local WepClass = Wep:GetClass()
	if (Player.Restrained or Player:RHC_IsArrested()) and WepClass != "weapon_r_cuffed" and !RHC_GetConf("JAIL_AllowedSWEPs")[WepClass]  then
		return false
	end
end)

hook.Add("CanPlayerSuicide", "RHC_DisableSuicide", function(Player)
	if Player.Restrained or Player:RHC_IsArrested() then return false end
end)

hook.Add("NOVA_CanChangeSeat", "RHC_NovacarsDisableSeatChange", function(Player)
	if Player.Restrained then
		return false, RHC_GetLang("CantSwitchSeat")
	end
end)

hook.Add("VC_CanEnterPassengerSeat", "RHC_VCMOD_EnterSeat", function(Player, Seat, Vehicle)
  local DraggedPlayer = Player.Dragging
  if IsValid(DraggedPlayer) then
      DraggedPlayer:EnterVehicle(Seat)
      return false
  end
end)

hook.Add("VC_CanEnterDriveBy", "RHC_CanEnterDriveBy", function(Player, Seat, Ent)
	if Player.Restrained then
		return false
	end
end)

hook.Add("VC_CanSwitchSeat", "RHC_VCMOD_SwitchSeat", function(Player, SeatFrom, SeatTo)
	if Player.Restrained then
		return false
	end
end)

hook.Add("PlayerHasBeenTazed", "RHC_FixCuffTaze", function(Player)
  if Player.Restrained then
      Player:CleanUpRHC(false, true)
      Player.Restrained = true
	else
		local TazeRagdoll = Player.tazeragdoll
		if IsValid(TazeRagdoll) then
			TazeRagdoll:SetNWBool("CanRHCArrest", true)
		end
  end
end)

hook.Add("PlayerUnTazed", "RHC_FixCuffUnTaze", function(Player)
    if Player.TazedRHCRestrained then
		Player:RHCRestrain(Player.LastRHCCuffed)
		Player.TazedRHCRestrained = false
	elseif Player.Restrained then
        Player:SetupCuffs()
				if RHC_GetConf("CUFFS_StarWarsCuffs") then
					Player:SetupRHCBones("Cuffed_StarWars")
				else
        	Player:SetupRHCBones("Cuffed")
				end
    end
end)

concommand.Add("rhc_cuffplayer", function(Player, CMD, Args)
	if !Player:IsAdmin() then return end

	if !Args or !Args[1] then return end

	local Nick = string.lower(Args[1]);
	local PFound = false

	for k, v in pairs(player.GetAll()) do
		if (string.find(string.lower(v:Nick()), Nick)) then
			PFound = v;
			break;
		end
	end

	if PFound then
		PFound:RHCRestrain(Player)
	end
end)

concommand.Add("rhc_arrestplayer", function(Player, CMD, Args)
	if !Player:IsAdmin() then return end

	if !Args or !Args[1] then return end

	local Nick = string.lower(Args[1]);
	local PFound = false

	for k, v in pairs(player.GetAll()) do
		if (string.find(string.lower(v:Nick()), Nick)) then
			PFound = v;
			break;
		end
	end

	if PFound then
		local Time = tonumber(Args[2])
		if !Time then
			TBFY_Notify(Player, 1, 4, RHC_GetLang("ArrestCMDWrongInput"))
		else
			PFound:RHC_Arrest(Time, Player)
		end
	end
end)

concommand.Add("rhc_unarrestplayer", function(Player, CMD, Args)
	if !Player:IsAdmin() then return end

	if !Args or !Args[1] then return end

	local Nick = string.lower(Args[1]);
	local PFound = false

	for k, v in pairs(player.GetAll()) do
		if (string.find(string.lower(v:Nick()), Nick)) then
			PFound = v;
			break;
		end
	end

	if PFound then
		PFound:RHC_UnArrest()
	end
end)

hook.Add("PlayerUse", "RHC_DisableUse", function(Player, Entity)
	if RHC_GetConf("CUFFS_DisableUse") and Player.Restrained and !RHandcuffsConfig.WhitelistedEntitiesUse[Entity:GetClass()] then return false end
end)

hook.Add("onDarkRPWeaponDropped", "RHC_RemoveCuffsSurrOnDeath", function(Player, Ent, Wep)
	if Wep:GetClass() == "weapon_r_cuffed" or Wep:GetClass() == "tbfy_surrendered" then
		Ent:Remove()
	end
end)

hook.Add("PlayerSpawn", "RHC_RespawnInJail", function(Player)
	if Player:RHC_IsArrested() then
		Player:StripWeapons()
		Player:StripAmmo()

		if RHC_GetConf("JAIL_CuffedInJail") then
			Player.Restrained = true
			Player:SetupCuffs()
			if RHC_GetConf("CUFFS_StarWarsCuffs") then
				Player:SetupRHCBones("Cuffed_StarWars")
			else
				Player:SetupRHCBones("Cuffed")
			end
			Player:Give("weapon_r_cuffed")
		end
		timer.Simple(0.1, function()
			Player:RHC_SendToJail()
		end)
	end
end)

hook.Add("ShouldAllowSit", "RHC_ShouldAllowSit", function(Player)
	if Player.Restrained or Player:RHC_IsArrested() then return false end
end)
