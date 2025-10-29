hook.Add( "DarkRPFoundationBuiltInHooks_LevelUp", "DarkRPFoundationHooks_DarkRPFoundationBuiltInHooks_LevelUp_Actions", function( ply, amount )
	if( DarkRPFoundation.CONFIG.LEVELING.LevelupNotification == true ) then
		net.Start( "DarkRPFoundationNet_SendLevelupEffect" )
		net.Send( ply )
	end
	
	ply:DRPF_LevelUpGiveReward( (ply.i_level or 0) )
end )