local PANEL = {}
	
function PANEL:Init()
	DRPF_NPCMENU_LEVELING_W, DRPF_NPCMENU_LEVELING_H = ScrW()*0.65, ScrH()*0.65

	self:SetSize( ScrW(), ScrH() )
	self:Center()
	self:MakePopup()
	self:SetTitle( "" )
	self:SetDraggable( false )
	self:ShowCloseButton( false )
	
	local BackPanel = vgui.Create( "DPanel", self )
	BackPanel:SetSize( DRPF_NPCMENU_LEVELING_W, DRPF_NPCMENU_LEVELING_H )
	BackPanel:Center()
	BackPanel.Paint = function( self2, w, h )
		surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
		surface.DrawRect( 0, 0, w, h )	
	end
	
	local ColSheet = vgui.Create( "drpf_element_dcolumnsheet", BackPanel )
	ColSheet:Dock( FILL )
	
	local LevelingPages = {}
	LevelingPages[1] = {
		Enabled = true, -- Disables page in the NPC menu
		Title = DRPF_Functions.L( "lvlNpcDashboard" ), -- The title of the page
		Element = "drpf_npc_leveling_dasboard", -- The page VGUI element (IGNORE)
		Icon = "materials/darkrpfoundation/leveling/dashboard.png" -- The page icon (IGNORE)
	}
	LevelingPages[2] = {
		Enabled = true,
		Title = DRPF_Functions.L( "lvlNpcRewards" ),
		Element = "drpf_npc_leveling_rewards",
		Icon = "materials/darkrpfoundation/leveling/rewards.png"
	}
	LevelingPages[3] = {
		Enabled = true,
		Title = DRPF_Functions.L( "lvlNpcLeaderboard" ),
		Element = "drpf_npc_leveling_leaderboard",
		Icon = "materials/darkrpfoundation/leveling/leaderboard.png"
	}

	for k, v in pairs( LevelingPages ) do
		if( v.Enabled ) then
			local HeaderHeight = BackPanel:GetTall()*0.3
			
			local PanelEntry = vgui.Create( "DPanel", ColSheet )
			PanelEntry:Dock( FILL )
			PanelEntry.Paint = function( self2, w, h ) 
				surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
				surface.DrawRect( 0, 0, w, HeaderHeight )
				
				draw.SimpleText( v.Title, "DarkRPFoundation_Font_Lvl_Header", 50, HeaderHeight/2, Color( 245, 245, 245 ), 0, TEXT_ALIGN_CENTER )
				surface.SetFont( "DarkRPFoundation_Font_Lvl_Header" )
				local HeaderX, HeaderY = surface.GetTextSize( v.Title )
				draw.SimpleText( DRPF_Functions.L( "byScript" ), "DarkRPFoundation_Font_Lvl_SubHeader", 53, (HeaderHeight/2)+(HeaderY/2)-10, Color( 155, 155, 155 ), 0, 0 )
			end
			
			local MenuCloseButton = vgui.Create( "DButton", PanelEntry )
			local ButSize = 25
			MenuCloseButton:SetSize( ButSize, ButSize )
			MenuCloseButton:SetPos( (BackPanel:GetWide()-ColSheet.Navigation:GetWide())-10-MenuCloseButton:GetWide(), 10 )
			MenuCloseButton:SetText( "" )
			MenuCloseButton.Paint = function( self2, w, h )
				if( self2:IsHovered() and !self2:IsDown() ) then
					surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "Highlight", 200 ) )	
				elseif( self2:IsDown() ) then
					surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "Highlight" ) )
				else
					surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
				end
				
				surface.SetMaterial( DarkRPFoundation.MATERIALS.CloseMat )
				surface.DrawTexturedRect( 0, 0, w, h )
			end
			MenuCloseButton.DoClick = function()
				if( IsValid( DRPF_NPCMENU_LEVELING ) ) then
					DRPF_NPCMENU_LEVELING:Remove()
				end	
			end
			
			local PanelEntryElement = vgui.Create( v.Element, PanelEntry )
			PanelEntryElement:Dock( FILL )
			PanelEntryElement:DockMargin( 0, HeaderHeight, 0, 0 )
		
			ColSheet:AddSheet( PanelEntry, v.Icon )
		end
	end
end

function PANEL:Paint( w, h )

end

vgui.Register( "drpf_npc_leveling_menu", PANEL, "DFrame" )