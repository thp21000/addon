local PANEL = {}

surface.SetFont( "DarkRPFoundation_Font_Inv_Header" )
local HeaderX, HeaderY = surface.GetTextSize( "STORAGE" )

function PANEL:Init()
	local SteamID64 = LocalPlayer():SteamID64()

	self:SetSize( ScrW()*0.35, ScrH()*0.5 )
	self:Center()
	self:MakePopup()
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )
	self:DockPadding( 0, HeaderY, 0, 0 )
	
	local MenuCloseButton = vgui.Create( "DButton", self )
	local ButSize = 25
	MenuCloseButton:SetSize( ButSize, ButSize )
	MenuCloseButton:SetPos( self:GetWide()-10-MenuCloseButton:GetWide(), 10 )
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
		self:Remove()
	end
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
	surface.DrawRect( 0, 0, w, h )		
	
	surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
	surface.DrawRect( 0, 0, w, HeaderY )	
	
	draw.SimpleText( "STORAGE", "DarkRPFoundation_Font_Inv_Header", w/2, HeaderY/2, Color( 245, 245, 245 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

vgui.Register( "drpf_atm_bankstorage", PANEL, "DFrame" )