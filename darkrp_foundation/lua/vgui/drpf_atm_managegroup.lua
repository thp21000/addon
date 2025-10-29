local PANEL = {}

surface.SetFont( "DarkRPFoundation_Font_Inv_Header" )
local HeaderX, HeaderY = surface.GetTextSize( DRPF_Functions.L( "atmGroupMembers" ) )

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
	
	local InviteMembersBack = vgui.Create( "DPanel", self )
	InviteMembersBack:Dock( TOP )
	InviteMembersBack:DockMargin( 10, 10, 10, 0 )
	InviteMembersBack:SetTall( 60 )
	InviteMembersBack.Paint = function( self2, w, h )
		surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
		surface.DrawRect( 0, 0, w, h )
		
		draw.SimpleText( DRPF_Functions.L( "atmGroupInvite" ), "DarkRPFoundation_Font_Inv_SubHeader", w/2, 10, Color( 245, 245, 245 ), TEXT_ALIGN_CENTER, 0 )
	end
	
	local InviteMembersChoice = vgui.Create( "DComboBox", InviteMembersBack )
	InviteMembersChoice:SetSize( 100, 20 )
	InviteMembersChoice:SetPos( ((self:GetWide()-20)/2)-(InviteMembersChoice:GetWide()/2), 30 )
	InviteMembersChoice:SetValue( "Player Name" )
	for k, v in pairs( player.GetAll() ) do
		if( v != LocalPlayer() ) then
			if( not DRPF_GroupAccounts[SteamID64].AccountMembers[v:SteamID64()] ) then
				InviteMembersChoice:AddChoice( v:Nick(), v )
			end
		end
	end
	InviteMembersChoice.OnSelect = function( self2, index, value )
		local Name, Ply = self2:GetSelected()
		local CanInvite = false
		
		if( IsValid( Ply ) ) then
			if( not DRPF_GroupAccounts[SteamID64].AccountMembers ) then
				CanInvite = true
			elseif( not DRPF_GroupAccounts[SteamID64].AccountMembers[Ply:SteamID64()] ) then
				CanInvite = true
			end
			
			if( CanInvite == true ) then
				net.Start( "DarkRPFoundationNet_ATMGroupInvitePlayer" )
					net.WriteEntity( Ply )
				net.SendToServer()
			else
				notification.AddLegacy( DRPF_Functions.L( "atmAlreadyGroup" ), 0, 3 )
			end
		else
		
		end
	end
	
	self.PageEntryBack = vgui.Create( "drpf_element_dscrollpanel", self )
	self.PageEntryBack:Dock( FILL )
	self.PageEntryBack:DockMargin( 10, 10, 10, 10 )
	self.PageEntryBack.Paint = function( self2, w, h ) end
	
	local PanelSelf = self
	function self:RefreshMembers()
		self.PageEntryBack:Clear()
	
		if( DRPF_GroupAccounts[SteamID64] ) then
			if( DRPF_GroupAccounts[SteamID64].AccountMembers ) then
				for k, v in pairs( DRPF_GroupAccounts[SteamID64].AccountMembers ) do
					local ply = player.GetBySteamID64( k )
					
					local MemberEntryBackPanel = vgui.Create( "DPanel", PanelSelf.PageEntryBack )
					MemberEntryBackPanel:Dock( TOP )
					MemberEntryBackPanel:DockMargin( 0, 0, 0, 10 )
					MemberEntryBackPanel:SetTall( 50 )
					MemberEntryBackPanel.Paint = function( self2, w, h )
						surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
						surface.DrawRect( 0, 0, w, h )
						
						if( IsValid( ply ) ) then
							draw.SimpleText( ply:Nick(), "DarkRPFoundation_Font_Inv_PageNum", h, h/2, Color( 245, 245, 245 ), 0, TEXT_ALIGN_CENTER )
						else
							surface.SetMaterial( DarkRPFoundation.MATERIALS.Disconnected )
							surface.SetDrawColor( 255, 255, 255 )
							local IconSize = h*0.56
							surface.DrawTexturedRect( (h-IconSize)/2, (h-IconSize)/2, IconSize, IconSize )
							
							draw.SimpleText( v, "DarkRPFoundation_Font_Inv_PageNum", h, h/2, Color( 245, 245, 245 ), 0, TEXT_ALIGN_CENTER )
						end
					end
					
					if( IsValid( ply ) ) then
						local AvatarSize = MemberEntryBackPanel:GetTall()*0.56
					
						local Avatar = vgui.Create( "AvatarImage", MemberEntryBackPanel )
						Avatar:SetSize( AvatarSize, AvatarSize )
						Avatar:SetPos( AvatarSize/2, AvatarSize/2 )
						Avatar:SetPlayer( ply, 64 )
					end
					
					local IconSize = MemberEntryBackPanel:GetTall()*0.56
					local Spacing = (MemberEntryBackPanel:GetTall()-IconSize)/2
					local KickMember = vgui.Create( "DButton", MemberEntryBackPanel )
					KickMember:Dock( RIGHT )
					KickMember:DockMargin( 0, Spacing, Spacing, Spacing )
					KickMember:SetWide( IconSize )
					KickMember:SetText( "" )
					KickMember.Paint = function( self2, w, h )
						surface.SetMaterial( DarkRPFoundation.MATERIALS.KickUser )
						surface.SetDrawColor( 255, 255, 255 )
						surface.DrawTexturedRect( 0, 0, w, h )
						
						surface.SetMaterial( DarkRPFoundation.MATERIALS.KickUser )
						if( self2:IsHovered() and !self2:IsDown() ) then
							surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "Highlight", 200 ) )	
						elseif( self2:IsDown() ) then
							surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "Highlight" ) )
						end
						surface.DrawTexturedRect( 0, 0, w, h )
					end
					KickMember.DoClick = function()
						net.Start( "DarkRPFoundationNet_ATMGroupKickUser" )
							net.WriteString( k )
						net.SendToServer()
					end
				end
			end
		end
	end
	
	self:RefreshMembers()
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
	surface.DrawRect( 0, 0, w, h )		
	
	surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
	surface.DrawRect( 0, 0, w, HeaderY )	
	
	draw.SimpleText( DRPF_Functions.L( "atmGroupMembers" ), "DarkRPFoundation_Font_Inv_Header", w/2, HeaderY/2, Color( 245, 245, 245 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

vgui.Register( "drpf_atm_managegroup", PANEL, "DFrame" )