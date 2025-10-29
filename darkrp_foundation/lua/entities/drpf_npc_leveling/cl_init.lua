include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	
	local Distance = LocalPlayer():GetPos():DistToSqr( self:GetPos() )

	if( Distance < DarkRPFoundation.CONFIG.GENERAL.DisplayDist3D2D ) then
		local ang = LocalPlayer():EyeAngles()
		local pos = self:GetPos() + Vector( 0, 0, self:OBBMaxs().z )

		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )
		
		local W, H = 200, 50
		local X, Y = -(W/2), -H-25
		cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.1 )
			local AlphaMulti = 1-(Distance/DarkRPFoundation.CONFIG.GENERAL.DisplayDist3D2D)
			surface.SetAlphaMultiplier( AlphaMulti )
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
			surface.DrawRect( X, Y, W, H )			
			
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
			surface.DrawOutlinedRect( X, Y, W, H )
			surface.SetAlphaMultiplier( 1 )
			
			draw.SimpleText( self.PrintName, "DarkRPFoundation_Font_Lvl_PlyNameXXS", X+(W/2), Y+(H/2), Color( 255, 255, 255, AlphaMulti*255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		cam.End3D2D()
	end
end

net.Receive( "DarkRPFoundationNet_NPCLevelingUse", function()
	local LevelPlayers = net.ReadTable()
	
	for k, v in pairs( LevelPlayers ) do
		local ply = player.GetBySteamID64( k )
		if( IsValid( ply ) ) then
			ply.i_level = v[1]
			ply.i_experience = v[2]
		end
	end

	if( not IsValid( DRPF_NPCMENU_LEVELING ) ) then
		DRPF_NPCMENU_LEVELING = vgui.Create( "drpf_npc_leveling_menu" )
	else
		DRPF_NPCMENU_LEVELING:SetVisible( true )
	end
end )
