function DRPF_Functions.GetAdminGroup( ply )
	if( DarkRPFoundation.CONFIG.GENERAL.AdminMod == "Serverguard" ) then
		return serverguard.player:GetRank(ply)
	else
		return ply:GetNWString("usergroup")
	end
end

function DRPF_Functions.HasAdminAccess( ply )
	return table.HasValue( DarkRPFoundation.CONFIG.GENERAL.AdminPermissions, DRPF_Functions.GetAdminGroup( ply ) )
end

concommand.Add( "drpf_test", function( ply, cmd, args )
	if( CLIENT ) then
		print( "Oi, stop that!" )
	end
end )

if( SERVER ) then
	util.AddNetworkString( "DarkRPFoundationNet_ChatNotify" )
	function DRPF_Functions.ChatNotify( ply, TagCol, Tag, TextCol, Text )
		if( IsValid( ply ) ) then
			net.Start( "DarkRPFoundationNet_ChatNotify" )
				net.WriteTable( { TagCol, Tag, TextCol, Text } )
			net.Send( ply )
		end
	end
elseif( CLIENT ) then
	net.Receive( "DarkRPFoundationNet_ChatNotify", function()
		local InfoTable = net.ReadTable()
		
		chat.AddText( InfoTable[1], InfoTable[2] .. " ", InfoTable[3], InfoTable[4] )
	end )
end