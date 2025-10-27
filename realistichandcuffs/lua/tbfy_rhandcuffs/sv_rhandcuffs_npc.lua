
util.AddNetworkString("RHC_Jailer_Menu")
util.AddNetworkString("RHC_jail_player")
util.AddNetworkString("RHC_Bailer_Menu")
util.AddNetworkString("RHC_bail_player")
util.AddNetworkString("RHC_add_npc_jailpos")
util.AddNetworkString("RHC_add_npc_unjailpos")

hook.Add("canArrest", "MustBeArrestAtJailerNPC", function(Player, ArrestedPlayer)
    if RHC_GetConf("JAIL_NPCJailingOnly") then
        return false,"Talk with the jailer NPC while dragging a player in order to arrest."
    end
end)

local RHC_DCAPlayers = {}
net.Receive("RHC_jail_player", function(len, Player)
	local APlayer, Time, Reason = net.ReadEntity(), net.ReadFloat(), net.ReadString()
	if (RHC_GetConf("JAIL_RestrictJailing") and !Player:CanRHCJail()) or (!RHC_GetConf("JAIL_RestrictJailing") and !Player:IsRHCWhitelisted()) then return end
	if APlayer != Player.Dragging or !APlayer.Restrained then return end
	if APlayer:RHC_IsArrested() then TBFY_Notify(Player, 1, 4, "This player is already arrested!")   return end

	Time = math.Clamp(math.Round(Time), 1, RHC_GetConf("JAIL_MaxJailTime"))
	Time = Time*60

	APlayer:RHC_Arrest(Time, Player, Reason, true)

	TBFY_Notify(APlayer, 1, 4, "You were jailed by " .. Player:Nick() .. " for " .. Time .. " seconds. Reason: " .. Reason)

	hook.Call("rhc_jailed_player", GAMEMODE, APlayer, Player, Time, Reason)
end)

hook.Add("PlayerInitialSpawn", "RHC_RejailIfJailTime", function(Player)
	//So player can fully load in first
	timer.Simple(10, function()
		if IsValid(Player) then
			local SID = Player:SteamID()
			local DCTable = RHC_DCAPlayers[SID]
			if DCTable then
				if DCTable.JTL > 0 then
					Player.JailNPC = DCTable.NPC
					Player:RHC_Arrest(DCTable.JTL, nil)
					RHC_DCAPlayers[SID] = nil
				else
					net.Start("rhc_update_jailtime")
						net.WriteBool(false)
						net.WriteFloat(0)
						net.WriteString(SID)
						net.WriteString("")
					net.Broadcast()
				end
			end
		end
	end)
end)

hook.Add("PlayerDisconnected", "RHC_SaveJailTime", function(Player)
	if Player:RHC_IsArrested() then
		local JailTimeLeft = Player:RHC_GetATime()
		if JailTimeLeft > 0 then
			RHC_DCAPlayers[Player:SteamID()] = {JTL = JailTimeLeft, NPC = Player.JailNPC}
		end
	end
end)

net.Receive("RHC_add_npc_jailpos", function(len, Player)
	if !Player:IsAdmin() then return end

	local Ent, Pos = Player.LastEntC, net.ReadVector()

	Ent.JailPos = Ent.JailPos or {}
	table.insert(Ent.JailPos, Pos)

	TBFY_Notify(Player, 1, 4, "Successfully added jailposition to last placed Jailer NPC.")
end)

net.Receive("RHC_add_npc_unjailpos", function(len, Player)
	if !Player:IsAdmin() then return end

	local Ent, Pos = Player.LastEntC, net.ReadVector()

	Ent.UnJailPos = Ent.UnJailPos or {}
	table.insert(Ent.UnJailPos, Pos)

	TBFY_Notify(Player, 1, 4, "Successfully added unjailposition to last placed Jailer NPC.")
end)

net.Receive("RHC_bail_player", function(len, Player)
	local ToBailP = net.ReadEntity()
	if !IsValid(ToBailP) or !ToBailP:IsPlayer() or !ToBailP:RHC_IsArrested() then return end
	if RHC_GetConf("BAIL_RestrictBailing") and !Player:CanRHCBail() then return end

	local BailCost = ToBailP:RHC_GetATime()/60 * RHC_GetConf("BAIL_PriceForEach")
	if Player:canAfford(BailCost) then
		ToBailP:RHC_UnArrest()
		Player:addMoney(-BailCost)
		ToBailP.RHC_JailTime = nil
		TBFY_Notify(Player, 1, 4, "You successfully bailed " .. ToBailP:Nick() .. " out of jail.")
	end
end)

local TGBlacklist = {"rhandcuffsent","rhc_jailer", "rhc_bailer"}
hook.Add("CanTool", "RHC_CanTool", function(Player, trace, tool)
    local ent = trace.Entity
	if table.HasValue(TGBlacklist, ent:GetClass()) then
		if !Player:IsAdmin() then
			return false
		end
	end
end)

hook.Add("CanProperty", "RHC_CanPropery", function(Player, stringproperty, ent)
	if table.HasValue(TGBlacklist, ent:GetClass()) then
		if !Player:IsAdmin() then
			return false
		end
	end
end)

hook.Add("canPocket", "RHC_CanPocketing", function(Player, Ent)
    if table.HasValue(TGBlacklist, Ent:GetClass()) then
	    return false, "You can't put that in your pocket!"
	end
end)
