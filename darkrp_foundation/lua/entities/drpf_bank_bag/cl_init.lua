include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	
	local Distance = LocalPlayer():GetPos():DistToSqr( self:GetPos() )

	if( Distance < DarkRPFoundation.CONFIG.GENERAL.DisplayDist3D2D ) then
		local ang = LocalPlayer():EyeAngles()
		local pos = self:GetPos() + Vector( 0, 0, self:OBBMaxs().z )

		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )
		
		surface.SetFont( "DarkRPFoundation_Font_Lvl_PlyNameS" )
		local TextX, TextY = surface.GetTextSize( DarkRP.formatMoney( self:GetMoney() ) )
		local W, H = TextX+25, 50
		local X, Y = -(W/2), -H-25
		cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.1 )
			local AlphaMulti = 1-(Distance/DarkRPFoundation.CONFIG.GENERAL.DisplayDist3D2D)
			surface.SetAlphaMultiplier( AlphaMulti )
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
			surface.DrawRect( X, Y, W, H )			
			
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
			surface.DrawOutlinedRect( X, Y, W, H )
			surface.SetAlphaMultiplier( 1 )
			
			draw.SimpleText( DarkRP.formatMoney( self:GetMoney() ), "DarkRPFoundation_Font_Lvl_PlyNameS", X+(W/2), Y+(H/2), Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		cam.End3D2D()
		
		local TextCol = Color( 255, 125, 125, AlphaMulti*255 )
		if( IsValid( self:GetVault() ) ) then
			local Distance = self:GetPos():DistToSqr( self:GetVault():GetPos() )
			if( Distance >= DarkRPFoundation.CONFIG.BANKVAULT.DistanceToUnlock ) then
				TextCol = Color( 125, 255, 125, AlphaMulti*255 )
			end
		else
			TextCol = Color( 125, 255, 125, AlphaMulti*255 )
		end
			
		render.SetMaterial( Material( "sprites/glow04_noz" ) )
		render.DrawSprite( self:GetPos() - (self:GetUp() * 0.5) + (self:GetForward() * 10), 3, 3, TextCol )
		render.DrawSprite( self:GetPos() - (self:GetUp() * 0.5) - (self:GetForward() * 10), 3, 3, TextCol )
	end
end
