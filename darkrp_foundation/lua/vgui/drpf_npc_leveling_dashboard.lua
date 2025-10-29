local PANEL = {}
	
function PANEL:Init()
	local W, H = DRPF_NPCMENU_LEVELING_W-75, DRPF_NPCMENU_LEVELING_H-(DRPF_NPCMENU_LEVELING_H*0.3)

	local BackPanel = vgui.Create( "DPanel", self )
	BackPanel:SetSize( W, H )
	BackPanel:SetPos( 0, 0 )
	BackPanel.Paint = function( self2, w, h )

	end
	
	local InfoBack = vgui.Create( "DPanel", BackPanel )
	InfoBack:Dock( FILL )
	InfoBack:DockMargin( 75, 50, 75, 50 )
	InfoBack.Paint = function( self2, w, h )
		surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "TertiaryColor" ) )
		--surface.DrawRect( 0, 0, w, h )
		
		draw.SimpleText( LocalPlayer():Nick(), "DarkRPFoundation_Font_Lvl_PlyName", 0, 0, Color( 245, 245, 245 ), 0, 0 )
		
		surface.SetFont( "DarkRPFoundation_Font_Lvl_PlyName" )
		local NameX, NameY = surface.GetTextSize( LocalPlayer():Nick() )
		
		-- Level progess --
		local percent = i_experience/(DarkRPFoundation.CONFIG.LEVELING.OrignalEXPRequired*(DarkRPFoundation.CONFIG.LEVELING.EXPRequiredIncrease^(i_level) ))
		percent = math.Clamp( percent, 0, (DarkRPFoundation.CONFIG.LEVELING.OrignalEXPRequired*(DarkRPFoundation.CONFIG.LEVELING.EXPRequiredIncrease^(i_level) )) )
		
		surface.SetDrawColor( 245, 245, 245, 50 )
		surface.DrawRect( 3, NameY+20, w*0.55, 35 )		
		
		surface.SetDrawColor( 245, 245, 245, 255 )
		surface.DrawRect( 3, NameY+20, (w*0.55)*percent, 35 )
		
		draw.SimpleText( math.Clamp( i_level+1, 0, DarkRPFoundation.CONFIG.LEVELING.MaxLevel ), "DarkRPFoundation_Font_Lvl_PlyName", 3+(w*0.55)+60, NameY+20+(35/2), Color( 245, 245, 245 ), 0, TEXT_ALIGN_CENTER )
		
		-- Experience/Level --
		local NewYPos = NameY+20+35+30
		local SpaceLeft = h-NewYPos
		
		local ExperienceX, ExperienceY = surface.GetTextSize( i_experience )
		local LevelX, LevelY = surface.GetTextSize( i_level )
		
		local NumTitleX = ExperienceX+45
		if( LevelX > ExperienceX ) then
			NumTitleX = LevelX+45
		end
		
		draw.SimpleText( i_experience, "DarkRPFoundation_Font_Lvl_PlyName", 0, NewYPos+((SpaceLeft/4)*1), Color( 245, 245, 245 ), 0, TEXT_ALIGN_CENTER )
		draw.SimpleText( DRPF_Functions.L( "lvlNpcTotalExp" ), "DarkRPFoundation_Font_Lvl_PlyName", NumTitleX, NewYPos+((SpaceLeft/4)*1), Color( 245, 245, 245 ), 0, TEXT_ALIGN_CENTER )
		
		draw.SimpleText( i_level, "DarkRPFoundation_Font_Lvl_PlyName", 0, NewYPos+((SpaceLeft/4)*3), Color( 245, 245, 245 ), 0, TEXT_ALIGN_CENTER )
		draw.SimpleText( DRPF_Functions.L( "lvlNpcCurrentLvl" ), "DarkRPFoundation_Font_Lvl_PlyName", NumTitleX, NewYPos+((SpaceLeft/4)*3), Color( 245, 245, 245 ), 0, TEXT_ALIGN_CENTER )
	end
end

function PANEL:Paint( w, h )

end

vgui.Register( "drpf_npc_leveling_dasboard", PANEL, "DPanel" )