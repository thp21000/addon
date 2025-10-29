hook.Add( "PostPlayerDraw", "DarkRPFoundationHooks_PostPlayerDraw_NamePlates", function( ply )
	if( !IsValid( ply ) ) then return end
	if( ply == LocalPlayer() or !ply:Alive() ) then return end
	local Distance = LocalPlayer():GetPos():DistToSqr( ply:GetPos() )

	if( Distance < DarkRPFoundation.CONFIG.GENERAL.DisplayDist3D2D ) then
		local ang = LocalPlayer():EyeAngles()
		local pos = ply:GetPos() + Vector( 0, 0, ply:OBBMaxs().z )

		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )
		
		local W, H = 200, 75
		local X, Y = -(W/2), -H-25
		cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.1 )
			local AlphaMulti = 1-(Distance/DarkRPFoundation.CONFIG.GENERAL.DisplayDist3D2D)
			surface.SetAlphaMultiplier( AlphaMulti )
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
			surface.DrawRect( X, Y, W, H )			
			
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
			surface.DrawOutlinedRect( X, Y, W, H )
			surface.DrawOutlinedRect( X+1, Y+1, W-2, H-2 )
			
			--[[ HEALTH BAR ]]--
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
			surface.DrawRect( X+2, Y+H-(H/3), W-4, 2 )
			
			surface.SetDrawColor( 252, 70, 70, 255 )
			surface.DrawRect( X+2, Y+H-(H/3)+2, math.Clamp((ply:Health()/ply:GetMaxHealth())*W, 0, W)-4, (H/3)-4 )			
			surface.SetAlphaMultiplier( 1 )
			
			draw.SimpleText( ply:Nick(), "DarkRPFoundation_Font_Lvl_PlyNameXXS", X+(W/2), Y+5, Color( 255, 255, 255, 255*AlphaMulti ), TEXT_ALIGN_CENTER, 0 )
			
			local TeamCol = team.GetColor( ply:Team() )
			draw.SimpleText( ply:getDarkRPVar( "job" ), "DarkRPFoundation_Font_Lvl_PlyNameXXXS", X+(W/2), Y+26, Color( TeamCol.r, TeamCol.g, TeamCol.b, AlphaMulti*255 ), TEXT_ALIGN_CENTER, 0 )
		cam.End3D2D()
	end
end )