// Custom Notifications
util.AddNetworkString("DarkRPFoundationNet_LevelNotify")
function DRPF_Functions.AddLvlNotify( ply, message, length, reason )
	net.Start( "DarkRPFoundationNet_LevelNotify" )
		net.WriteString( message )
		net.WriteInt( length, 8 )
		net.WriteString( reason )
	net.Send( ply )
end

local playerMeta = FindMetaTable("Player")

util.AddNetworkString("DarkRPFoundationNet_SetExperience")
util.AddNetworkString("DarkRPFoundationNet_SetLevel")
util.AddNetworkString("DarkRPFoundationNet_SendLevelupEffect")

// Experience
function playerMeta:SetExperience(amount, nosave)
	if( amount == nil ) then return end
	net.Start("DarkRPFoundationNet_SetExperience")
		net.WriteInt(amount, 32)
	net.Send(self)
	self.i_experience = amount
	if( not nosave ) then
		self:SavePlayersStats()
	end
end

function playerMeta:CheckLevelUp()
	if( self:GetLevel() < DarkRPFoundation.CONFIG.LEVELING.MaxLevel ) then
		if( self:GetExperience() >= DarkRPFoundation.CONFIG.LEVELING.OrignalEXPRequired*(DarkRPFoundation.CONFIG.LEVELING.EXPRequiredIncrease^(self:GetLevel()) ) ) then
			self:SetExperience( self:GetExperience() - DarkRPFoundation.CONFIG.LEVELING.OrignalEXPRequired*(DarkRPFoundation.CONFIG.LEVELING.EXPRequiredIncrease^(self:GetLevel()) ) )
			self:AddLevel( 1 )
			self:CheckLevelUp()
		end
	end
end

function playerMeta:AddExperience( amount, reason )
	if( self:GetLevel() < DarkRPFoundation.CONFIG.LEVELING.MaxLevel ) then
		self:SetExperience( self:GetExperience() + amount )
		DRPF_Functions.AddLvlNotify( self, "+" .. amount .. " Experience", 2, reason )
		self:CheckLevelUp()
		
		hook.Call( "DarkRPFoundationBuiltInHooks_ExperienceIncrease", GAMEMODE, self, amount, reason )
	end
end

function playerMeta:TakeExperience( amount, reason )
	if( not ( ( self:GetExperience() ) <= 0 and self:GetLevel() <= 0 )) then
		if( ( self:GetExperience() - amount ) < 0 and self:GetLevel() > 0 ) then
			DRPF_Functions.AddLvlNotify( self, "-" .. ( amount ) .. " Experience", 2, reason )
			self:SetExperience( self:GetExperience() - amount )
			self:SetExperience( (DarkRPFoundation.CONFIG.LEVELING.OrignalEXPRequired*(DarkRPFoundation.CONFIG.LEVELING.EXPRequiredIncrease^(self:GetLevel()-1) ))+self:GetExperience() )
			self:TakeLevel( 1 )
		elseif( ( self:GetExperience() - amount ) > 0 ) then
			DRPF_Functions.AddLvlNotify( self, "-" .. ( amount ) .. " Experience", 2, reason )
			self:SetExperience( math.Clamp(self:GetExperience() - amount, 0, DarkRPFoundation.CONFIG.LEVELING.OrignalEXPRequired*(DarkRPFoundation.CONFIG.LEVELING.EXPRequiredIncrease^(self:GetLevel()) ) ) )
		elseif( ( self:GetExperience() - amount ) <= 0 and self:GetLevel() == 0 ) then
			DRPF_Functions.AddLvlNotify( self, "-" .. ( self:GetExperience() ) .. " Experience", 2, reason )
			self:SetExperience( math.Clamp(self:GetExperience() - amount, 0, DarkRPFoundation.CONFIG.LEVELING.OrignalEXPRequired*(DarkRPFoundation.CONFIG.LEVELING.EXPRequiredIncrease^(self:GetLevel()) ) ) )
		end
	end
end

function playerMeta:GetExperience()
	return (self.i_experience or 0)
end

// Levels
function playerMeta:SetLevel(amount, nosave)
	if( amount == nil ) then return end
	net.Start("DarkRPFoundationNet_SetLevel")
		net.WriteInt(math.Clamp( amount, 0, DarkRPFoundation.CONFIG.LEVELING.MaxLevel ), 32)
	net.Send(self)
	self.i_level = math.Clamp( amount, 0, DarkRPFoundation.CONFIG.LEVELING.MaxLevel )
	if( not nosave ) then
		self:SavePlayersStats()
	end
end

function playerMeta:AddLevel(amount)
	self:SetLevel(self:GetLevel() + amount)
	DRPF_Functions.AddLvlNotify( self, "+" .. amount .. " Level", 2, "LEVEL INCREASED" )
	
	hook.Call( "DarkRPFoundationBuiltInHooks_LevelUp", GAMEMODE, self, amount )
end

function playerMeta:TakeLevel(amount)
	self:SetLevel( self:GetLevel() - amount )
	DRPF_Functions.AddLvlNotify( self, "-" .. amount .. " Level", 2, "LEVEL DECREASED" )
end

function playerMeta:GetLevel()
	return (self.i_level or 0)
end

// Server Stuff
function playerMeta:RestoreLeveling()
	self.i_experience = 0
	self.i_level = 0
	
	local drpfstats = self:DRPFGetStats()
	
	local expVal = drpfstats["experience"]
	if( expVal ) then
		self:SetExperience(tonumber(expVal), true)
	else
		self:SetExperience( 0, true )
	end

	local lvlVal = drpfstats["level"]
	if( lvlVal ) then
		self:SetLevel(tonumber(lvlVal), true)
	else
		self:SetLevel( 0, true )
	end
end

--[[ Saving Stats ]]--
-- Sets player's stats table
function playerMeta:DRPFSetStats( stats )
	self.DRPFStats = stats
end

-- Gets player's stats table
function playerMeta:DRPFGetStats()
	return self.DRPFStats
end

-- Saves player's stats
function playerMeta:SavePlayersStats()
	if( timer.Exists( self:SteamID64() .. "_drpf_timer_savestats" ) ) then
		timer.Remove( self:SteamID64() .. "_drpf_timer_savestats" )
	end

	timer.Create( self:SteamID64() .. "_drpf_timer_savestats", 5, 1, function()
		if( IsValid( self ) ) then
			local drpfstats = self:DRPFGetStats()
			if( not drpfstats ) then
				drpfstats = {}
			end
			drpfstats["experience"] = (self:GetExperience() or 0)
			drpfstats["level" ] = (self:GetLevel() or 0)
			
			if( DarkRPFoundation.CONFIG.GENERAL.UseMySQL != true ) then
				if( not file.Exists( "darkrpfoundation/mainstats", "DATA" ) ) then
					file.CreateDir( "darkrpfoundation/mainstats" )
				end
				file.Write( "darkrpfoundation/mainstats/" .. self:SteamID64() .. ".txt", util.TableToJSON( drpfstats ) )
			else
				self:DRPF_UpdateDBValue( "experience", drpfstats["experience"] )
				self:DRPF_UpdateDBValue( "level", drpfstats["level"] )
			end
		else
			timer.Remove( self:SteamID64() .. "_drpf_timer_bankinginterest" )
		end
	end )
end

-- Loads player's stats
hook.Add( "PlayerInitialSpawn", "DarkRPFoundationHooks_PlayerInitialSpawn_LevellingLoading", function( ply ) 
	if( DarkRPFoundation.CONFIG.GENERAL.UseMySQL != true ) then
		if( not file.Exists( "darkrpfoundation/mainstats", "DATA" ) ) then
			file.CreateDir( "darkrpfoundation/mainstats" )
		end

		if( file.Exists( "darkrpfoundation/mainstats/" .. ply:SteamID64() .. ".txt", "DATA" ) ) then
			ply:DRPFSetStats( util.JSONToTable( file.Read( "darkrpfoundation/mainstats/" .. ply:SteamID64() .. ".txt", "DATA" ) ) )
		else
			ply:DRPFSetStats( {} )
		end
		
		ply:RestoreLeveling()
	else		
		ply:DRPF_FetchDBValue( "level", function( level )
			ply:DRPF_FetchDBValue( "experience", function( experience )
				local drpfstats = {}
				if( level != nil ) then
					drpfstats["level"] = level
				else
					drpfstats["level"] = 0
				end
				
				if( experience != nil ) then
					drpfstats["experience"] = experience
				else
					drpfstats["experience"] = 0
				end

				ply:DRPFSetStats( drpfstats )

				ply:RestoreLeveling()
			end )
		end )
	end
end )
