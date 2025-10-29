
local PANEL = {}

AccessorFunc( PANEL, "ActiveButton", "ActiveButton" )

function PANEL:Init()

	self.Navigation = vgui.Create( "DScrollPanel", self )
	self.Navigation:Dock( LEFT )
	self.Navigation:SetWidth( 75 )
	self.Navigation:DockMargin( 0, 0, 0, 0 )
	self.Navigation.Paint = function( self2, w, h )
		surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "TertiaryColor" ) )
		surface.DrawRect( 0, 0, w, h )
	end

	self.Content = vgui.Create( "Panel", self )
	self.Content:Dock( FILL )

	self.Items = {}

end

function PANEL:UseButtonOnlyStyle()
	self.ButtonOnly = true
end

function PANEL:AddSheet( panel, material )

	if ( !IsValid( panel ) ) then return end

	local Sheet = {}

	Sheet.Button = vgui.Create( "DButton", self.Navigation )
	Sheet.Button.Target = panel
	Sheet.Button:Dock( TOP )
	local padding = 20
	Sheet.Button:SetTall( self.Navigation:GetWide()-padding-padding )
	Sheet.Button:SetText( "" )
	Sheet.Button:DockMargin( padding, padding, padding, 0 )
	local ButMat = Material( material, "noclamp smooth" )
	Sheet.Button.Paint = function( self2, w, h )	
		surface.SetDrawColor( 255, 255, 255 )
		surface.SetMaterial( ButMat )
		surface.DrawTexturedRect( 0, 0, w, h )
		
		if( self2:IsHovered() and !self2:IsDown() and !self2.m_bSelected ) then
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "Highlight", 200 ) )	
		elseif( self2:IsDown() || self2.m_bSelected ) then
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "Highlight" ) )
		end
		
		surface.SetMaterial( ButMat )
		surface.DrawTexturedRect( 0, 0, w, h )	
	end

	Sheet.Button.DoClick = function()
		self:SetActiveButton( Sheet.Button )
	end

	Sheet.Panel = panel
	Sheet.Panel:SetParent( self.Content )
	Sheet.Panel:SetAlpha( 0 )
	Sheet.Panel:SetVisible( false )

	if ( self.ButtonOnly ) then
		Sheet.Button:SizeToContents()
	end

	table.insert( self.Items, Sheet )

	if ( !IsValid( self.ActiveButton ) ) then
		self:SetActiveButton( Sheet.Button )
	end
	
	return Sheet
end

function PANEL:SetActiveButton( active )

	if ( self.ActiveButton == active ) then return end

	if ( self.ActiveButton && self.ActiveButton.Target ) then
		self.ActiveButton.Target:SetAlpha( 0 )
		self.ActiveButton.Target:SetVisible( false )
		self.ActiveButton:SetSelected( false )
		self.ActiveButton:SetToggle( false )
	end

	self.ActiveButton = active
	active.Target:SetVisible( true )
	active.Target:AlphaTo( 255, 0.5, 0, function() end )
	active:SetSelected( true )
	active:SetToggle( true )

	self.Content:InvalidateLayout()

end

derma.DefineControl( "drpf_element_dcolumnsheet", "", PANEL, "Panel" )
