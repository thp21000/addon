local PANEL = {}
	
function PANEL:Init()
	DRPF_MENU_ARMORY_W, DRPF_MENU_ARMORY_H = ScrW()*0.65, ScrH()*0.65

	self:SetSize( ScrW(), ScrH() )
	self:Center()
	self:MakePopup()
	self:SetTitle( "" )
	self:SetDraggable( false )
	self:ShowCloseButton( false )
	
	local BackPanel = vgui.Create( "DPanel", self )
	BackPanel:SetSize( DRPF_MENU_ARMORY_W, DRPF_MENU_ARMORY_H )
	BackPanel:Center()
	BackPanel.Paint = function( self2, w, h )
		surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
		surface.DrawRect( 0, 0, w, h )	
	end
	
	local ColSheet = vgui.Create( "drpf_element_dcolumnsheet", BackPanel )
	ColSheet:Dock( FILL )
	
	local ArmoryPages = {}
	ArmoryPages[1] = {
		Enabled = true,
		Title = DRPF_Functions.L( "menuWeapons" ),
		Element = "drpf_armory_weapons",
		Icon = "materials/darkrpfoundation/bank_and_armory/crate.png",
	}
	ArmoryPages[2] = {
		Enabled = true,
		Title = DRPF_Functions.L( "menuAmmo" ),
		Element = "drpf_armory_ammo",
		Icon = "materials/darkrpfoundation/bank_and_armory/ammo.png",
	}
	ArmoryPages[3] = {
		Enabled = true,
		Title = DRPF_Functions.L( "menuGear" ),
		Element = "drpf_armory_gear",
		Icon = "materials/darkrpfoundation/bank_and_armory/gear.png",
	}
	
	for k, v in pairs( ArmoryPages ) do
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
				if( IsValid( DRPF_MENU_ARMORY ) ) then
					DRPF_MENU_ARMORY:Remove()
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

vgui.Register( "drpf_armory_menu", PANEL, "DFrame" )