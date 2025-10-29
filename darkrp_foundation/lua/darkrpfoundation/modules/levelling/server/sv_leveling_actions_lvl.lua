// NPCKill Reward
hook.Add( "OnNPCKilled", "DarkRPFoundationHooks_OnNPCKilled_Levelling", function( npc, attacker, inflictor )
	if( attacker:IsPlayer() ) then
		attacker:AddExperience( DarkRPFoundation.CONFIG.LEVELING.NPCEXPGain, "NPC Killed" )
	end
end )

// PlayingOnServer Reward
hook.Add( "PlayerInitialSpawn", "DarkRPFoundationHooks_PlayerInitialSpawn_Levelling", function( ply )
	timer.Create( tostring( ply ) .. "ServerTimerEXPGive", DarkRPFoundation.CONFIG.LEVELING.EXPServerTime, 0, function() 
		if( IsValid( ply ) ) then
			ply:AddExperience( DarkRPFoundation.CONFIG.LEVELING.EXPServerAmount, "Playing On Server" )
		else
			if( timer.Exists( tostring( ply ) .. "ServerTimerEXPGive" ) ) then
				timer.Remove( tostring( ply ) .. "ServerTimerEXPGive" )
			end
		end
	end )
end )

// LockPick Reward
hook.Add( "onLockpickCompleted", "DarkRPFoundationHooks_onLockpickCompleted_Levelling", function( ply, success, ent)
	if( ent:isDoor() or ent:IsVehicle() or ent.isFadingDoor ) then
		if( ent:isLocked() ) then
			if( success == true ) then
				ply:AddExperience( DarkRPFoundation.CONFIG.LEVELING.LockPickEXPGain, "LockPick Success" )
			end
		end
	end
end )

// LotteryEnter Reward
hook.Add( "playerEnteredLottery", "DarkRPFoundationHooks_playerEnteredLottery_Levelling", function( ply )
	if( ply:IsPlayer() ) then
		ply:AddExperience( DarkRPFoundation.CONFIG.LEVELING.EnteredLotteryEXPGain, "Entered Lottery" )
	end
end )

// LotteryWon Reward
hook.Add( "lotteryEnded", "DarkRPFoundationHooks_lotteryEnded_Levelling", function( participants,  chosen, amount )
	if( chosen:IsPlayer() ) then
		chosen:AddExperience( DarkRPFoundation.CONFIG.LEVELING.WonLotteryEXPGain, "Won Lottery" )
	end
end )

// HitCompleted Reward
hook.Add( "onHitCompleted", "DarkRPFoundationHooks_onHitCompleted_Levelling", function( hitman, target, customer )
	if( hitman:IsPlayer() ) then
		hitman:AddExperience( DarkRPFoundation.CONFIG.LEVELING.HitSuccessEXPGain, "Hit Success" )
	end
end )

// FirstJoin Reward
hook.Add( "onPlayerFirstJoined", "DarkRPFoundationHooks_onPlayerFirstJoined_Levelling", function( ply, data )
	if( ply:IsPlayer() ) then
		ply:AddExperience( DarkRPFoundation.CONFIG.LEVELING.FirstJoinEXPGain, "First Join" )
	end
end )

// TeamKill Penalty/Reward
hook.Add( "PlayerDeath", "DarkRPFoundationHooks_PlayerDeath_Levelling", function( victim, inflictor, attacker )
	if( attacker:IsPlayer() and victim:IsPlayer() and attacker != victim ) then
		for k, v in pairs( DarkRPFoundation.CONFIG.LEVELING.TeamKillGroups ) do
			for key, val in pairs( DarkRPFoundation.CONFIG.LEVELING.TeamKillGroups[k] ) do
				if( attacker:Team() == val ) then
					for key2, val2 in pairs( DarkRPFoundation.CONFIG.LEVELING.TeamKillGroups[k] ) do
						if( victim:Team() == val2 ) then
							attacker:TakeExperience( DarkRPFoundation.CONFIG.LEVELING.TeamKillPenalty, "Team Kill" )
						end
					end
				end
			end
		end
		
		for k, v in pairs( DarkRPFoundation.CONFIG.LEVELING.PlayerKillGroups ) do
			for key, val in pairs( v ) do
				if( key != "Reward" ) then
					if( table.HasValue( val, attacker:getDarkRPVar( "job" ) ) ) then
						for key2, val2 in pairs( v ) do
							if( val != val2 and key2 != "Reward" ) then
								if( table.HasValue( val2, victim:getDarkRPVar( "job" ) ) ) then
									attacker:AddExperience( DarkRPFoundation.CONFIG.LEVELING.PlayerKillGroups[k].Reward, "PLAYER KILLS" )
								end
							end
						end
					end
				end
			end
		end
	end
end )

// Level Change Team
hook.Add( "playerCanChangeTeam", "DarkRPFoundationHooks_playerCanChangeTeam_Levelling", function( ply, job, force )
	if( RPExtraTeams[job].level ) then
		if( ply.i_level >= RPExtraTeams[job].level ) then
			return true
		else
			return false, "You are not the right level for this job (Level " .. RPExtraTeams[job].level .. ")."
		end
	end
end )

// Level Buy Shipment
hook.Add( "canBuyShipment", "DarkRPFoundationHooks_canBuyShipment_Levelling", function( ply, shipments )
	if( shipments.level ) then
		if( ply.i_level >= shipments.level ) then
			return true
		else
			return false, false, "You are not the right level to buy this shipment (Level " .. shipments.level .. ")."
		end
	end
end )

// Level Buy Entity
hook.Add( "canBuyCustomEntity", "DarkRPFoundationHooks_canBuyCustomEntity_Levelling", function( ply, entity )
	if( entity.level ) then
		if( ply.i_level >= entity.level ) then
			return true
		else
			return false, false, "You are not the right level to buy this entity (Level " .. entity.level .. ")."
		end
	end
end )