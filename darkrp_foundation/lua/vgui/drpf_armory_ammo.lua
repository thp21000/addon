local PANEL = {}
	
function PANEL:Init()
	local W, H = DRPF_MENU_ARMORY_W-75, DRPF_MENU_ARMORY_H-(DRPF_MENU_ARMORY_H*0.3)

	local BackPanel = vgui.Create( "DPanel", self )
	BackPanel:SetSize( W, H )
	BackPanel:SetPos( 0, 0 )
	BackPanel.Paint = function( self2, w, h ) end
	
	local ListSpacing = 10
	local ListWide = 5
	
	local ScrollPanel = vgui.Create( "drpf_element_dscrollpanel", BackPanel )
	ScrollPanel:Dock( FILL )
	ScrollPanel:DockMargin( (ListSpacing/2), (ListSpacing/2), (ListSpacing/2), (ListSpacing/2) )
	
	local List = vgui.Create( "DIconLayout", ScrollPanel )
	List:Dock( FILL )
	
	local AmmoTable = {}
	for k, v in pairs( DarkRPFoundation.CONFIG.ARMORY.Ammo ) do
		AmmoTable[k] = v
		AmmoTable[k].key = k
	end
	
	table.sort( AmmoTable, function(a, b) return (a.Level or 0) < (b.Level or 0) end)
	
	local ItemCount = #AmmoTable
	for k, v in pairs( AmmoTable ) do
		local ListItem = List:Add( "DPanel" )
		if( ItemCount > 5  ) then
			ListItem:SetSize( (W-ListSpacing-10)/ListWide, 300 )
		else
			ListItem:SetSize( (W-ListSpacing)/ListWide, 300 )
		end
		ListItem.Paint = function( self2, w, h ) 
			if( v.Restrictions and not table.HasValue( v.Restrictions, LocalPlayer():Team() ) ) then
				surface.SetAlphaMultiplier( 0.1 )
			end
			
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
			surface.DrawRect( (ListSpacing/2), (ListSpacing/2), w-ListSpacing, h-ListSpacing )
			
			if( string.len( v.Name ) < 13 ) then
				draw.SimpleText( v.Name, "DarkRPFoundation_Font_Armory_ItemHeader", w/2, 130, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, 0 )
			else
				draw.SimpleText( string.sub( v.Name, 1, 13 ) .. "...", "DarkRPFoundation_Font_Armory_ItemHeader", w/2, 130, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, 0 )
			end
			draw.SimpleText( DRPF_Functions.L( "level" ) .. ": " .. (v.Level or 0), "DarkRPFoundation_Font_Armory_ItemInfo", w/2, 160, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, 0 )
			
			surface.SetAlphaMultiplier( 1 )
		end
		
		local ItemModel = vgui.Create( "DModelPanel", ListItem )
		ItemModel:Dock( TOP )
		ItemModel:DockMargin( 5, ListSpacing/2, 5, 5 )
		ItemModel:SetTall( 130 )
		ItemModel:SetModel( v.Model )
		ItemModel:SetCamPos( Vector( 0, 50, 5 ) )
		ItemModel:SetLookAng( Angle( 180, 90, 180 ) )
		function ItemModel:LayoutEntity( Entity ) return end
		
		local ItemEquip = vgui.Create( "DButton", ListItem )
		ItemEquip:SetTall( 55 )
		ItemEquip:Dock( BOTTOM )
		ItemEquip:DockMargin( (ListSpacing/2)+5, (ListSpacing/2)+5, (ListSpacing/2)+5, (ListSpacing/2)+5 )
		ItemEquip:SetText( "" )
		ItemEquip.Paint = function( self2, w, h )
			if( self2:IsHovered() and !self2:IsDown() ) then
				surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "Highlight", 200 ) )	
			elseif( self2:IsDown() ) then
				surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "Highlight" ) )
			else
				surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "TertiaryColor" ) )
			end
			
			surface.DrawRect( 0, 0, w, h )
			
			draw.SimpleText( DRPF_Functions.L( "equip" ), "DarkRPFoundation_Font_Lvl_RewardHeader", w/2, h/2, Color( 245, 245, 245 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		ItemEquip.DoClick = function()
			if( DarkRPFoundation.CONFIG.ARMORY.Ammo[v.key] ) then
				net.Start( "DarkRPFoundationNet_ArmoryEquipAmmo" )
					net.WriteInt( v.key, 32 )
				net.SendToServer()
			end
		end
		
		if( v.Restrictions ) then
			if( not table.HasValue( v.Restrictions, LocalPlayer():Team() ) ) then
				local RestrictionCover = vgui.Create( "DPanel", ListItem )
				RestrictionCover:SetPos( (ListSpacing/2), (ListSpacing/2) )
				RestrictionCover:SetSize( ListItem:GetWide()-ListSpacing, ListItem:GetTall()-ListSpacing )
				RestrictionCover.Paint = function( self2, w, h ) 
					surface.SetDrawColor( 0, 0, 0, 200 )
					surface.DrawRect( 0, 0, w, h )
					
					draw.SimpleText( DRPF_Functions.L( "restricted" ), "DarkRPFoundation_Font_Armory_ItemHeader", w/2, h/4, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

					for i = 1, 5 do
						if( v.Restrictions[i] ) then
							draw.SimpleText( team.GetName( v.Restrictions[i] ) or "", "DarkRPFoundation_Font_Armory_ItemInfo", w/2, (h/4)+15+((i-1)*20), Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, 0 )
						end
					end
				end
			end
		end
	end
end

function PANEL:Paint( w, h )

end

vgui.Register( "drpf_armory_ammo", PANEL, "DPanel" )