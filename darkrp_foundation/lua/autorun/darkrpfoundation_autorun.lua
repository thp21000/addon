--[[ Global Variables/Tables ]]--
DarkRPFoundation = {}
DRPF_Functions = {}

--[[ Manual autoruns ]]--
AddCSLuaFile( "darkrpfoundation_config.lua" )
include( "darkrpfoundation_config.lua" )
AddCSLuaFile( "darkrpfoundation_dev_config.lua" )
include( "darkrpfoundation_dev_config.lua" )
AddCSLuaFile( "darkrpfoundation_inventory_config.lua" )
include( "darkrpfoundation_inventory_config.lua" )

--[[ Localization ]]--
DarkRPFoundation.Language = {}
for k, v in pairs( file.Find( "darkrpfoundation/localization/*", "LUA" ) ) do
	if( string.Replace( v, ".lua" ) == (DarkRPFoundation.CONFIG.GENERAL.Language or "") ) then
		AddCSLuaFile( "darkrpfoundation/localization/" .. v )
		include( "darkrpfoundation/localization/" .. v )
		
		print( "[DARKRPFOUNDATION] " .. DarkRPFoundation.CONFIG.GENERAL.Language .. " language loaded" )
	end
end

function DRPF_Functions.L( languageString )
	if( DarkRPFoundation.Language and DarkRPFoundation.Language[languageString] ) then
		return DarkRPFoundation.Language[languageString]
	else
		return "MISSING LANGUAGE"
	end
end

hook.Add( "Initialize", "DarkRPFoundationHooks_Initialize_DelayedConfig", function()
	AddCSLuaFile( "darkrpfoundation_delayed_config.lua" )
	include( "darkrpfoundation_delayed_config.lua" )
end )

if( SERVER ) then

elseif( CLIENT ) then

end

--[[ Automatic autoruns ]]--
local AutorunTable = {}
AutorunTable[1] = {
	Location = "darkrpfoundation/core/shared/",
	Type = "Shared",
	Enabled = true
}
AutorunTable[2] = {
	Location = "darkrpfoundation/core/server/",
	Type = "Server",
	Enabled = true
}
AutorunTable[3] = {
	Location = "darkrpfoundation/core/client/",
	Type = "Client",
	Enabled = true
}

for key, val in pairs( AutorunTable ) do
	if( val.Type == "Shared" and val.Enabled == true ) then
		for k, v in pairs( file.Find( val.Location .. "*.lua", "LUA" ) ) do
			AddCSLuaFile( val.Location .. v )
			include( val.Location .. v )
		end
	end
end
if( SERVER ) then
	for key, val in pairs( AutorunTable ) do
		if( val.Type == "Client" and val.Enabled == true ) then
			for k, v in pairs( file.Find( val.Location .. "*.lua", "LUA" ) ) do
				AddCSLuaFile( val.Location .. v )
			end
		elseif( val.Type == "Server" and val.Enabled == true ) then
			for k, v in pairs( file.Find( val.Location .. "*.lua", "LUA" ) ) do
				include( val.Location .. v )
			end
		end
	end	
elseif( CLIENT ) then
	for key, val in pairs( AutorunTable ) do
		if( val.Type == "Client" and val.Enabled == true ) then
			for k, v in pairs( file.Find( val.Location .. "*.lua", "LUA" ) ) do
				include( val.Location .. v )
			end
		end
	end
end

--[[ MODULES AUTORUN ]]--
local EnabledModules = {}
EnabledModules["hud"] = DarkRPFoundation.CONFIG.HUD.Enable
EnabledModules["levelling"] = DarkRPFoundation.CONFIG.LEVELING.Enable
EnabledModules["printers"] = DarkRPFoundation.CONFIG.PRINTERS.Enable
EnabledModules["inventory"] = DarkRPFoundation.CONFIG.INVENTORY.Enable

local files, directories = file.Find( "darkrpfoundation/modules/*", "LUA" )
for k, v in pairs( directories ) do
	if( EnabledModules[v] == true ) then
		local files2, directories2 = file.Find( "darkrpfoundation/modules/" .. v .. "/*", "LUA" )
		for key, val in pairs( directories2 ) do
			if( val == "shared" ) then
				for key2, val2 in pairs( file.Find( "darkrpfoundation/modules/" .. v .. "/" .. val .. "/*.lua", "LUA" ) ) do
					AddCSLuaFile( "darkrpfoundation/modules/" .. v .. "/" .. val .. "/" .. val2 )
					include( "darkrpfoundation/modules/" .. v .. "/" .. val .. "/" .. val2 )
				end
			elseif( val == "server" ) then
				for key2, val2 in pairs( file.Find( "darkrpfoundation/modules/" .. v .. "/" .. val .. "/*.lua", "LUA" ) ) do
					if( SERVER ) then
						include( "darkrpfoundation/modules/" .. v .. "/" .. val .. "/" .. val2 )
					end
				end
			elseif( val == "client" ) then
				for key2, val2 in pairs( file.Find( "darkrpfoundation/modules/" .. v .. "/" .. val .. "/*.lua", "LUA" ) ) do
					if( CLIENT ) then
						include( "darkrpfoundation/modules/" .. v .. "/" .. val .. "/" .. val2 )
					elseif( SERVER ) then
						AddCSLuaFile( "darkrpfoundation/modules/" .. v .. "/" .. val .. "/" .. val2 )
					end
				end
			end
		end
	end
end
