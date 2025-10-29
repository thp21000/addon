AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/breen.mdl")

	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid( SOLID_BBOX )
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
end

util.AddNetworkString( "DarkRPFoundationNet_NPCLevelingUse" )
function ENT:AcceptInput(ply, caller)
	if( IsValid( caller ) ) then
		if( caller:IsPlayer() ) then
			local LevelPlayers = {}
			for k, v in pairs( player.GetAll() ) do
				LevelPlayers[v:SteamID64()] = { v.i_level or 0, v.i_experience or 0 }
			end
			
			net.Start( "DarkRPFoundationNet_NPCLevelingUse" )
				net.WriteTable( LevelPlayers )
			net.Send( caller )
		end
	end
end

-- Leveling Rewards --
local plyMeta = FindMetaTable( "Player" )

/*util.AddNetworkString( "DarkRPFoundationNet_SendBanking" )
function plyMeta:DRPF_BankingUpdate()
	net.Start( "DarkRPFoundationNet_SendBanking" )
		net.WriteTable( self:DRPF_BankingGet() )
	net.Send( self )
end*/

function plyMeta:DRPF_LvlRewardsSaveData()
	local LvlRewardsData = self:DRPF_LvlRewardsGet()
	
	if( LvlRewardsData != nil ) then
		local LvlRewardsDataJSON = util.TableToJSON( LvlRewardsData )
	
		if( DarkRPFoundation.CONFIG.GENERAL.UseMySQL != true ) then
			if( not file.Exists( "darkrpfoundation/leveling_rewards", "DATA" ) ) then
				file.CreateDir( "darkrpfoundation/leveling_rewards" )
			end
		
			file.Write( "darkrpfoundation/leveling_rewards/" .. self:SteamID64() .. ".txt", LvlRewardsDataJSON )
		else
			self:DRPF_UpdateDBValue( "leveling_rewards", LvlRewardsDataJSON )
		end
	end
end	

hook.Add( "PlayerInitialSpawn", "DarkRPFoundationHooks_PlayerInitialSpawn_LoadLvlRewards", function( ply )
	local LvlRewardsData = {}

	if( DarkRPFoundation.CONFIG.GENERAL.UseMySQL != true ) then
		if( not file.Exists( "darkrpfoundation/leveling_rewards", "DATA" ) ) then
			file.CreateDir( "darkrpfoundation/leveling_rewards" )
		end
		
		if( file.Exists( "darkrpfoundation/leveling_rewards/" .. ply:SteamID64() .. ".txt", "DATA" ) ) then
			local FileTable = file.Read( "darkrpfoundation/leveling_rewards/" .. ply:SteamID64() .. ".txt", "DATA" )
			FileTable = util.JSONToTable( FileTable )

			if( FileTable != nil ) then
				if( istable( FileTable ) ) then
					LvlRewardsData = FileTable
				end
			end
		end
		
		ply:DRPF_LvlRewardsSet( LvlRewardsData, true )
	else
		ply:DRPF_FetchDBValue( "leveling_rewards", function( leveling_rewards )
			local LvlRewardsDataTable = util.JSONToTable( leveling_rewards or "" )

			if( LvlRewardsDataTable != nil ) then
				if( istable( LvlRewardsDataTable ) ) then
					LvlRewardsData = LvlRewardsDataTable
				end
			end
			
			ply:DRPF_LvlRewardsSet( LvlRewardsData, true )
		end )
	end
end )

function plyMeta:DRPF_LvlRewardsSet( LvlRewardsData, DontSave )
	self.DRPFLvlRewards = LvlRewardsData
	
	--self:DRPF_BankingUpdate()
	
	if( not DontSave ) then
		self:DRPF_LvlRewardsSaveData()
	end
end	

function plyMeta:DRPF_LvlRewardsGet()
	return self.DRPFLvlRewards
end

function plyMeta:DRPF_LevelUpGiveReward( level )
	if( (self.i_level or 0) < level ) then return end
	
	local PlyLvlRewards = (self:DRPF_LvlRewardsGet() or {})
	local Anyrewards = false
	
	if( DarkRPFoundation.CONFIG.LEVELING.Rewards[level] ) then
		local Reward = DarkRPFoundation.CONFIG.LEVELING.Rewards[level]
		local RewardCount = table.Count( Reward )
		if( Reward.Instant ) then
			RewardCount = RewardCount-1
		end
		
		if( Reward.Instant ) then
			if( Anyrewards != true ) then Anyrewards = true end
			table.insert( PlyLvlRewards, level )
			
			for key, val in pairs( Reward ) do
				if( DarkRPFoundation.DEVCONFIG.LevelRewards[key] ) then
					DarkRPFoundation.DEVCONFIG.LevelRewards[key].OnReward( self, val, level )
				end
			end
		else
			DRPF_Functions.ChatNotify( self, Color( 0, 0, 0 ), DRPF_Functions.L( "lvlNpcEntServer" ) .. " ", Color( 255, 255, 255 ), "You have " .. RewardCount .. " reward(s) to collect!" )
		end
	end

	
	if( DarkRPFoundation.CONFIG.LEVELING.VIPRewards[level] ) then
		local VIPReward = DarkRPFoundation.CONFIG.LEVELING.VIPRewards[level]
		local VIPRewardCount = table.Count( VIPReward )
		if( VIPReward.Instant ) then
			VIPRewardCount = VIPRewardCount-1
		end
		
		if( table.HasValue( DarkRPFoundation.CONFIG.LEVELING.VIPRanks, DRPF_Functions.GetAdminGroup( self ) ) ) then
			if( VIPReward.Instant ) then
				if( Anyrewards != true ) then Anyrewards = true end
				table.insert( PlyLvlRewards, "V" .. level )
				
				for key, val in pairs( VIPReward ) do
					if( DarkRPFoundation.DEVCONFIG.LevelRewards[key] ) then
						DarkRPFoundation.DEVCONFIG.LevelRewards[key].OnReward( self, val, level, true )
					end
				end
			else
				DRPF_Functions.ChatNotify( self, Color( 0, 0, 0 ), DRPF_Functions.L( "lvlNpcEntServer" ) .. " ", Color( 255, 255, 255 ), "You have " .. VIPRewardCount .. " VIP reward(s) to collect!" )
			end
		else
			DRPF_Functions.ChatNotify( self, Color( 0, 0, 0 ), DRPF_Functions.L( "lvlNpcEntServer" ) .. " ", Color( 255, 255, 255 ), "You can receive " .. VIPRewardCount .. " extra reward(s) with VIP!" )
		end
	end
	
	if( Anyrewards == true ) then
		self:DRPF_LvlRewardsSet( PlyLvlRewards )
	end
end

util.AddNetworkString( "DarkRPFoundationNet_NPCLevelingCollectRewards" )
net.Receive( "DarkRPFoundationNet_NPCLevelingCollectRewards", function( len, ply )
	local PlyLvlRewards = (ply:DRPF_LvlRewardsGet() or {})
	local Anyrewards = false
	
	for k, v in pairs( DarkRPFoundation.CONFIG.LEVELING.Rewards ) do
		if( (ply.i_level or 0) >= k ) then
			if( not table.HasValue( PlyLvlRewards, k ) ) then
				if( Anyrewards != true ) then Anyrewards = true end
				table.insert( PlyLvlRewards, k )
				
				for key, val in pairs( v ) do
					if( DarkRPFoundation.DEVCONFIG.LevelRewards[key] ) then
						DarkRPFoundation.DEVCONFIG.LevelRewards[key].OnReward( ply, val, k )
					end
				end
			end
		else
			break
		end
	end	
	
	if( table.HasValue( DarkRPFoundation.CONFIG.LEVELING.VIPRanks, DRPF_Functions.GetAdminGroup( ply ) ) ) then
		for k, v in pairs( DarkRPFoundation.CONFIG.LEVELING.VIPRewards ) do
			if( (ply.i_level or 0) >= k ) then
				if( not table.HasValue( PlyLvlRewards, "V" .. k ) ) then
					if( Anyrewards != true ) then Anyrewards = true end
					table.insert( PlyLvlRewards, "V" .. k )
					
					for key, val in pairs( v ) do
						if( DarkRPFoundation.DEVCONFIG.LevelRewards[key] ) then
							DarkRPFoundation.DEVCONFIG.LevelRewards[key].OnReward( ply, val, k, true )
						end
					end
				end
			else
				break
			end
		end
	end
	
	if( Anyrewards == true ) then
		DarkRP.notify( ply, 0, 5, "[Leveling] Поздравляем, вы получили свои награды!" )
		
		ply:DRPF_LvlRewardsSet( PlyLvlRewards )
	else
		DarkRP.notify( ply, 1, 5, "[Leveling] У вас нет никаких наград!" )
	end
end )