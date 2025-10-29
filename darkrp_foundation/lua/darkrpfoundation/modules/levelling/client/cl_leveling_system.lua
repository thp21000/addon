local playerMeta = FindMetaTable("Player")

i_experience = 0
net.Receive("DarkRPFoundationNet_SetExperience", function(length)
	local amount = net.ReadInt(32)

	i_experience = amount
end)

i_level = 0
net.Receive("DarkRPFoundationNet_SetLevel", function(length)
	local amount = net.ReadInt(32)

	i_level = amount
end)

net.Receive("DarkRPFoundationNet_SendLevelupEffect", function(length)
	local FireworkDisplay = vgui.Create( "moat_fireworks" )
	FireworkDisplay:SetSize( ScrW(), ScrH() )
	FireworkDisplay:Center()	
	FireworkDisplay:SetBackgroundColor( Color( 0, 0, 0, 0 ) )
	
	local LevelUpTexture = vgui.Create( "DPanel", FireworkDisplay )
	LevelUpTexture:SetSize( 714, 293 )
	LevelUpTexture:SetPos( -LevelUpTexture:GetWide(), (ScrH()/2)-(LevelUpTexture:GetTall()/2) )
	LevelUpTexture:MoveTo( (ScrW()/2)-(LevelUpTexture:GetWide()/2), (ScrH()/2)-(LevelUpTexture:GetTall()/2), 1, 0, 1 )
	LevelUpTexture.Paint = function( self, w, h )
		surface.SetMaterial( DarkRPFoundation.MATERIALS.LevelingEffect )
		surface.SetDrawColor( 255, 255, 255 )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	
	timer.Simple( 3, function()
		if( IsValid( FireworkDisplay ) ) then
			if( IsValid( LevelUpTexture ) ) then
				LevelUpTexture:MoveTo( ScrW(), (ScrH()/2)-(LevelUpTexture:GetTall()/2), 1, 0, 1 )
			end
			FireworkDisplay:AlphaTo( 0, 1, 0, function()
				if( IsValid( FireworkDisplay ) ) then
					FireworkDisplay:Remove()
				end
			end )
		end
	end )
	
	surface.PlaySound( "darkrpfoundation/chipquest.wav" )
end)