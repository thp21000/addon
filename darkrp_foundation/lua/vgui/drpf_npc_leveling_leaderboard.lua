local PANEL = {}
	
function PANEL:Init()
	local W, H = DRPF_NPCMENU_LEVELING_W-75, DRPF_NPCMENU_LEVELING_H-(DRPF_NPCMENU_LEVELING_H*0.3)

	local BackPanel = vgui.Create( "DPanel", self )
	BackPanel:SetSize( W, H )
	BackPanel:SetPos( 0, 0 )
	BackPanel.Paint = function( self2, w, h )

	end
	
	local LeaderboardTable = {}
	for k, v in pairs( player.GetAll() ) do
		local PlyTable = { v:SteamID(), v.i_level }
		table.insert( LeaderboardTable, PlyTable )
	end
	
	table.sort( LeaderboardTable, function( a, b ) return (a[2] or 0) > (b[2] or 0) end )
	
	local InfoBack = vgui.Create( "DPanel", BackPanel )
	InfoBack:Dock( FILL )
	InfoBack:DockMargin( 125, 20, 75, 50 )
	InfoBack.Paint = function( self2, w, h )
		local XMove = 75
	
		draw.SimpleText( LocalPlayer():Nick(), "DarkRPFoundation_Font_Lvl_PlyNameS", XMove, 0, Color( 245, 245, 245 ), 0, 0 )
		
		surface.SetFont( "DarkRPFoundation_Font_Lvl_PlyNameS" )
		local NameX, NameY = surface.GetTextSize( LocalPlayer():Nick() )
		
		draw.SimpleText( DRPF_Functions.L( "lvlNpcCurrentLvl" ) .. "		" .. i_level, "DarkRPFoundation_Font_Lvl_CurLevel", XMove, NameY+10, Color( 245, 245, 245 ), 0, TEXT_ALIGN_CENTER )
		
		-- Leaderboards --
		local HeightToTake = NameY+25
		local HeightLeft = h-HeightToTake
		local BarsToShow = 6
		
		for i = 1, BarsToShow do
			local BarSpacing = 5
			local BarW, BarH = w-XMove, (HeightLeft-5-((BarsToShow-1)*BarSpacing))/BarsToShow
			local BarX, BarY = XMove, HeightToTake+5+((i-1)*(BarH+BarSpacing))
			local LeadertableEntry = LeaderboardTable[i]
			
			local leaderboard_ply
			if( LeadertableEntry ) then
				leaderboard_ply = player.GetBySteamID( LeadertableEntry[1] )
			end
			
			draw.SimpleText( i, "DarkRPFoundation_Font_Lvl_LeaderboardHeader", BarX-20, BarY+(BarH/2), DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			
			if( i == 1 ) then
				surface.SetDrawColor( 203,189,78 )
			elseif( i == 2 ) then
				surface.SetDrawColor( 222,222,222 )
			elseif( i == 3 ) then
				surface.SetDrawColor( 183,155,106 )
			else
				surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
			end
			surface.DrawRect( BarX, BarY, BarW, BarH )				
			
			if( IsValid( leaderboard_ply ) ) then
				draw.SimpleText( leaderboard_ply:Nick(), "DarkRPFoundation_Font_Lvl_PlyNameM", BarX+20, BarY+(BarH/2), Color( 245, 245, 245 ), 0, TEXT_ALIGN_CENTER )
				draw.SimpleText( (leaderboard_ply.i_level or 0), "DarkRPFoundation_Font_Lvl_PlyNameM", BarX+(BarW/2), BarY+(BarH/2), Color( 245, 245, 245 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( string.Comma(math.Round(leaderboard_ply.i_experience or 0)) .. " " .. DRPF_Functions.L( "lvlNpcExp" ), "DarkRPFoundation_Font_Lvl_PlyNameM", BarX+BarW-20, BarY+(BarH/2), Color( 245, 245, 245 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			else
				draw.SimpleText( DRPF_Functions.L( "lvlNpcUnknown" ), "DarkRPFoundation_Font_Lvl_PlyNameM", BarX+20, BarY+(BarH/2), Color( 245, 245, 245 ), 0, TEXT_ALIGN_CENTER )
				draw.SimpleText( 0, "DarkRPFoundation_Font_Lvl_PlyNameM", BarX+(BarW/2), BarY+(BarH/2), Color( 245, 245, 245 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( DRPF_Functions.L( "lvlNpcZeroExp" ), "DarkRPFoundation_Font_Lvl_PlyNameM", BarX+BarW-20, BarY+(BarH/2), Color( 245, 245, 245 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			end
		end
	end
	
	/*local TopPanel = vgui.Create( "DPanel", self )
	TopPanel:SetSize( W*0.55, H-BackPanel:GetTall()-(W-(W*0.9)) )
	TopPanel:SetPos( (W/2)-(TopPanel:GetWide()/2), H-BackPanel:GetTall()-(W-(W*0.9))/2-TopPanel:GetTall() )
	TopPanel.Paint = function( self2, w, h )
		local BorderDist = 3
	
		-- Background --
		surface.SetDrawColor( 179, 180, 233, 175 )
		surface.DrawRect( 0, 0, w, h )
		
		-- Border --
		surface.SetDrawColor( 255, 255, 255, 175 )
		surface.DrawRect( (w/2)-(w/2)+BorderDist, BorderDist, w-(2*BorderDist), 1 )
		surface.DrawRect( BorderDist, BorderDist, 1, h )
		surface.DrawRect( w-1-BorderDist, BorderDist, 1, h )
		
		-- Username --
		surface.SetDrawColor( 255, 255, 255, 175 )
		surface.DrawRect( (w/2)-(w*0.8/2), h*0.4, w*0.8, 3 )
		
		draw.SimpleText( LocalPlayer():Nick(), "DarkRPFoundation_FontPurLight40", w/2, (h*0.4)/2, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		
		-- Level --
		surface.SetFont( "DarkRPFoundation_FontPur40" )
		local LevelX, LevelY = surface.GetTextSize( DRPF_Functions.L( "lvlNpcYour" ) .. " " .. [lvlNpcLevel] .. " " .. i_level )
		
		surface.SetFont( "DarkRPFoundation_FontPurLight40" )
		surface.SetTextColor( 255, 255, 255 )
		surface.SetTextPos( (w/2)-(LevelX/2), (h*0.4)+5 )
		surface.DrawText( DRPF_Functions.L( "lvlNpcYour" ) .. " " )
		surface.SetTextColor( DarkRPFoundation.DRAW.GetTheme( "Highlight" ) )
		surface.SetFont( "DarkRPFoundation_FontPur40" )
		surface.DrawText( [lvlNpcLevel] .. " " )		
		surface.SetTextColor( 255, 255, 255 )
		surface.SetFont( "DarkRPFoundation_FontPurBold44" )
		surface.DrawText( i_level )
	end
	
	BackPanel.Paint = function( self2, w, h )
		local BorderDist = 3
	
		-- Background --
		surface.SetDrawColor( 179, 180, 233, 175 )
		surface.DrawRect( 0, 0, w, h )
		
		-- Border --
		surface.SetDrawColor( 255, 255, 255, 175 )
		
		surface.DrawRect( BorderDist, BorderDist, (w-TopPanel:GetWide())/2+1, 1 )
		surface.DrawRect( BorderDist+(w-TopPanel:GetWide())/2, 0, 1, BorderDist )		
		
		surface.DrawRect( w-(w-TopPanel:GetWide())/2-BorderDist-1, BorderDist, (w-TopPanel:GetWide())/2+1, 1 )
		surface.DrawRect( w-BorderDist-(w-TopPanel:GetWide())/2-1, 0, 1, BorderDist )
		
		surface.DrawRect( BorderDist, BorderDist, 1, h-(2*BorderDist) )
		surface.DrawRect( w-1-BorderDist, BorderDist, 1, h-(2*BorderDist) )
		
		surface.DrawRect( BorderDist, h-1-BorderDist, w-(2*BorderDist), 1 )
	end	
	
	local SpacingSide = 25
	local PlayerBoardBack = vgui.Create( "drpf_element_dscrollpanel", BackPanel )
	PlayerBoardBack:Dock( FILL )
	PlayerBoardBack:DockMargin( SpacingSide, SpacingSide, SpacingSide, SpacingSide )
	PlayerBoardBack.Paint = function() end
	
	local PlayerEntryHeader = vgui.Create( "DPanel", PlayerBoardBack )
	PlayerEntryHeader:Dock( TOP )
	PlayerEntryHeader:DockMargin( 0, 0, 0, 5 )
	PlayerEntryHeader:SetTall( 20 )
	PlayerEntryHeader.Paint = function( self2, w, h ) 
		draw.RoundedBox( 5, 0, 0, w, h, Color( 255, 255, 255, 175 ) )
		
		draw.SimpleText( [lvlNpcName], "DarkRPFoundation_FontPur22", w/6, h/2-1, Color( 0, 0, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( [lvlNpcExperience], "DarkRPFoundation_FontPur22", w-(w/6), h/2-1, Color( 0, 0, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( [lvlNpcLevel], "DarkRPFoundation_FontPur22", w/2+2, h/2-1, Color( 0, 0, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	
	for k, v in pairs( player.GetAll() ) do
		local PlayerEntry = vgui.Create( "DPanel", PlayerBoardBack )
		PlayerEntry:Dock( TOP )
		PlayerEntry:DockMargin( 0, 0, 0, 5 )
		PlayerEntry:SetTall( 30 )
		PlayerEntry.Paint = function( self2, w, h ) 
			draw.RoundedBox( 5, 0, 0, w, h, Color( 255, 255, 255, 175 ) )
			
			draw.SimpleText( v:Nick(), "DarkRPFoundation_FontPur22", w/12, h/2-1, Color( 0, 0, 0, 200 ), 0, TEXT_ALIGN_CENTER )
			draw.SimpleText( string.Comma( math.Round( tonumber( v.i_experience or 0 ) ) ), "DarkRPFoundation_FontPur22", w-(w/6), h/2-1, Color( 0, 0, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( string.Comma( v.i_level or 0 ), "DarkRPFoundation_FontPur22", w/2, h/2-1, Color( 0, 0, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		
		local Avatar = vgui.Create( "AvatarImage", PlayerEntry )
		Avatar:SetSize( 20, 20 )
		Avatar:SetPos( (PlayerEntry:GetTall()-Avatar:GetTall())/2, (PlayerEntry:GetTall()-Avatar:GetTall())/2 )
		Avatar:SetPlayer( v, 32 )
	end*/
end

function PANEL:Paint( w, h )

end

vgui.Register( "drpf_npc_leveling_leaderboard", PANEL, "DPanel" )