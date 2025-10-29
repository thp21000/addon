local Host = ""
local Username = ""
local Password = ""
local DatabaseName = ""
local DatabasePort = 3306

--[[

	DONT TOUCH ANYTHING BELOW THIS LINE!
	
]]--


if( (DarkRPFoundation.CONFIG.GENERAL.UseMySQL or false) == true ) then
	local MYSQL_PLAYERS = true
	local MYSQL_BANKINGDATA = true
	
	--[[ PLAYER DATA ]]--
	if( (MYSQL_PLAYERS or false) == true ) then
		local column_names = { 
			["level"] = "integer",	
			["experience"] = "integer",
			["inventory"] = "string",
			["banking_data"] = "string",
			["leveling_rewards"] = "string",
		}

		// MYSQL CODE
		local player_meta = FindMetaTable("Player")
		require( "mysqloo" )

		local function ConnectToDatabase()
			darkrpfoundation_db = mysqloo.connect( Host, Username, Password, DatabaseName, DatabasePort )
			darkrpfoundation_db.onConnected = function()	print( "[DarkRPFoundation SQL] DarkRPFoundation database has connected!" )	end
			darkrpfoundation_db.onConnectionFailed = function( err )	print( "[DarkRPFoundation SQL] Connection to DarkRPFoundation Database failed! Error: " ) PrintTable( err )	end
			darkrpfoundation_db:connect()
			
			local query = darkrpfoundation_db:query("CREATE TABLE DarkRPFoundation ( steamid64 varchar(17) NOT NULL UNIQUE, level int, experience int, inventory varchar(20000), banking_data varchar(1000), leveling_rewards varchar(500) );")
			function query:onSuccess(data)
				print( "[DarkRPFoundation SQL] DarkRPFoundation table validated!" )
			end

			function query:onError(err)
				print("[DarkRPFoundation SQL] An error occured while executing the query: " .. err)
			end

			query:start()
		end

		ConnectToDatabase()

		function player_meta:DRPF_UpdateDBValue( key, value )
			local PlySteamID64 = self:SteamID64()
			if( not column_names[key] ) then return end
			
			if( column_names[key] == "string" ) then
				value = string.Replace( value, "'", "" )
			end
			
			local query = darkrpfoundation_db:query("SELECT * FROM DarkRPFoundation WHERE steamid64 = '" .. PlySteamID64 .. "'")
			function query:onSuccess(data)
				if( not data[1] ) then
					local queryinner = darkrpfoundation_db:query("INSERT INTO DarkRPFoundation (`steamid64`, `" .. key .. "`) VALUES( '" .. PlySteamID64 .. "', '" .. value .. "')")
					function queryinner:onSuccess(data)
					
					end
					function queryinner:onError(err)
						local queryinner2 = darkrpfoundation_db:query("UPDATE DarkRPFoundation SET " .. key .. " = '" .. value .. "' WHERE steamid64 = '" .. PlySteamID64 .. "';")
						function queryinner2:onSuccess(data)
						end
						function queryinner2:onError(err) print("[DarkRPFoundation SQL] An error occured while executing the queryinner2: " .. err) end
						queryinner2:start()
						print("[DarkRPFoundation SQL] An error occured while executing the queryinner: " .. err) 
					end
					queryinner:start()
				else
					local queryinner2 = darkrpfoundation_db:query("UPDATE DarkRPFoundation SET " .. key .. " = '" .. value .. "' WHERE steamid64 = '" .. PlySteamID64 .. "';")
					function queryinner2:onSuccess(data)
					end
					function queryinner2:onError(err) print("[DarkRPFoundation SQL] An error occured while executing the queryinner2: " .. err) end
					queryinner2:start()
				end
			end
			function query:onError(err)
				print("[DarkRPFoundation SQL] An error occured while executing the query: " .. err)
			end
			query:start()
			
		end

		function player_meta:DRPF_FetchDBValue( key, func )
			local PlySteamID64 = self:SteamID64()
			if( not column_names[key] ) then return end
			local query = darkrpfoundation_db:query("SELECT " .. key .. " FROM DarkRPFoundation WHERE steamid64 = '" .. PlySteamID64 .. "'")
			function query:onSuccess(data)
				if( data[1] ) then
					if( data[1][key] ) then
						if( column_names[key] == "integer" ) then
							func( tonumber(data[1][key]) )
						else
							func( data[1][key] )
						end
					else
						if( column_names[key] == "integer" ) then
							func()
						else
							func()
						end
					end
				else
					if( column_names[key] == "integer" ) then
						func()
					else
						func()
					end
				end
			end
			function query:onError(err)
				print("[DarkRPFoundation SQL] An error occured while executing the query: " .. err)
			end
			query:start()
		end
	end

	--[[ BANKING GROUP ACCOUNTS ]]--
	if( (MYSQL_BANKINGDATA or false) == true and DarkRPFoundation.CONFIG.ATM.Enabled == true ) then
		local column_names = { 
			["printname"] = "string",
			["accountbalance"] = "integer",
			["accountmembers"] = "string",
		}
		
		// MYSQL CODE
		local function ConnectToDatabase()
			drpf_bankingdata_db = mysqloo.connect( Host, Username, Password, DatabaseName, DatabasePort )
			drpf_bankingdata_db.onConnected = function()	print( "[DarkRPFoundation BD SQL] DarkRPFoundation database has connected!" )	end
			drpf_bankingdata_db.onConnectionFailed = function( err )	print( "[DarkRPFoundation BD SQL] Connection to DarkRPFoundation Database failed! Error: " ) PrintTable( err )	end
			drpf_bankingdata_db:connect()
			
			local query = drpf_bankingdata_db:query("CREATE TABLE DarkRPFoundation_BD ( groupid varchar(17) NOT NULL UNIQUE,  printname varchar(100), accountbalance int, accountmembers varchar(10000) );")
			function query:onSuccess(data)
				print( "[DarkRPFoundation BD SQL] DarkRPFoundation table validated!" )
			end

			function query:onError(err)
				print("[DarkRPFoundation BD SQL] An error occured while executing the query: " .. err)
			end

			query:start()
		end
		ConnectToDatabase()

		function DRPF_UpdateGroupAccountDB( groupid, key, value )
			if( not column_names[key] ) then return end
			
			if( column_names[key] == "string" ) then
				value = string.Replace( value, "'", "" )
			end
			
			local query = darkrpfoundation_db:query("SELECT * FROM DarkRPFoundation_BD WHERE groupid = '" .. groupid .. "'")
			function query:onSuccess(data)
				if( not data[1] ) then
					local queryinner = darkrpfoundation_db:query("INSERT INTO DarkRPFoundation_BD (`groupid`, `" .. key .. "`) VALUES( '" .. groupid .. "', '" .. value .. "')")
					function queryinner:onSuccess(data)
					
					end
					function queryinner:onError(err)
						local queryinner2 = darkrpfoundation_db:query("UPDATE DarkRPFoundation_BD SET " .. key .. " = '" .. value .. "' WHERE groupid = '" .. groupid .. "';")
						function queryinner2:onSuccess(data)
						end
						function queryinner2:onError(err) print("[DarkRPFoundation BD SQL] An error occured while executing the queryinner2: " .. err) end
						queryinner2:start()
						print("[DarkRPFoundation BD SQL] An error occured while executing the queryinner: " .. err) 
					end
					queryinner:start()
				else
					local queryinner2 = darkrpfoundation_db:query("UPDATE DarkRPFoundation_BD SET " .. key .. " = '" .. value .. "' WHERE groupid = '" .. groupid .. "';")
					function queryinner2:onSuccess(data)
					end
					function queryinner2:onError(err) print("[DarkRPFoundation BD SQL] An error occured while executing the queryinner2: " .. err) end
					queryinner2:start()
				end
			end
			function query:onError(err)
				print("[DarkRPFoundation BD SQL] An error occured while executing the query: " .. err)
			end
			query:start()
		end
		
		function DRPF_FetchGroupAccountDB( return_func )
			local query = darkrpfoundation_db:query("SELECT * FROM DarkRPFoundation_BD")
			function query:onSuccess(data)
				return_func( data or {} )
			end
			function query:onError(err)
				print("[DarkRPFoundation BD SQL] An error occured while executing the query: " .. err)
			end
			query:start()
		end
	end
end