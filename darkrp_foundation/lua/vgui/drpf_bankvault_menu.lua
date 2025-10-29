local PANEL = {}

surface.SetFont( "DarkRPFoundation_Font_Inv_Header" )
local HeaderX, HeaderY = surface.GetTextSize( DRPF_Functions.L( "bankVaultName" ) )

function PANEL:Init()
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
		
		if( IsValid( self.VaultEnt ) ) then
			net.Start( "DarkRPFoundationNet_BankFail" ) 
				net.WriteEntity( self.VaultEnt )
			net.SendToServer()
		end
	end
	
	local PuzzleBackground = vgui.Create( "DPanel", self )
	PuzzleBackground:SetSize( self:GetWide(), self:GetTall()-HeaderY )
	PuzzleBackground:SetPos( 0, HeaderY )
	PuzzleBackground.Paint = function( self2, w, h ) end
	
	function self:CreatePuzzle()
		PuzzleBackground:Clear()
	
		local Pins = DarkRPFoundation.CONFIG.BANKVAULT.Pins
		local MinHeight = DarkRPFoundation.CONFIG.BANKVAULT.MinHeight
		local MaxHeight = DarkRPFoundation.CONFIG.BANKVAULT.MaxHeight
		
		local Padding = 25
		local SideDif = 2
		local PinsUnlocked = 0

		local MainAreaW, MainAreaH = PuzzleBackground:GetWide()-(2*Padding), PuzzleBackground:GetTall()-(2*Padding)-55-Padding
		
		local PuzzleAreaBack = vgui.Create( "DPanel", PuzzleBackground )
		PuzzleAreaBack:SetSize( MainAreaW-(MainAreaW*0.2)-Padding, MainAreaH )
		PuzzleAreaBack:SetPos( (MainAreaW*0.2)+Padding+Padding, Padding )
		PuzzleAreaBack.Paint = function( self2, w, h )
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
			surface.DrawRect( 0, 0, w, h )			
			
			local Spacing = 15
			local Size = 35
			local TotalWidth = (Pins*Size)+((Pins-1)*Spacing)
			
			for i = 0, Pins-1 do
				if( PinsUnlocked >= i+1 ) then
					surface.SetDrawColor( 65, 175, 65 )
				else
					surface.SetDrawColor( 175, 65, 65 )
				end
				surface.DrawRect( ((w/2)-(TotalWidth/2))+(i*(Spacing+Size)), (h/2)-(Size/2), Size, Size )
			end
		end	
		
		local PuzzleSliderBack = vgui.Create( "DPanel", PuzzleBackground )
		PuzzleSliderBack:SetSize( MainAreaW*0.2, MainAreaH )
		PuzzleSliderBack:SetPos( Padding, Padding )
		PuzzleSliderBack.Paint = function( self2, w, h )
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
			surface.DrawRect( SideDif, 0, w-(2*SideDif), h )
		end		
		
		local FinalHeight = math.random( MinHeight, MaxHeight )
		
		local PuzzleSliderLandZone = vgui.Create( "DPanel", PuzzleSliderBack )
		PuzzleSliderLandZone:SetSize( PuzzleSliderBack:GetWide(), FinalHeight )
		PuzzleSliderLandZone:SetPos( 0, math.random( 0, PuzzleSliderBack:GetTall()-FinalHeight ) )
		PuzzleSliderLandZone.Paint = function( self2, w, h )
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "TertiaryColor" ) )
			surface.DrawRect( SideDif, 0, w-(2*SideDif), h )
		end
		
		local PuzzleSlider = vgui.Create( "DPanel", PuzzleSliderBack )
		PuzzleSlider:SetSize( PuzzleSliderBack:GetWide(), 5 )
		PuzzleSlider:SetPos( 0, 0 )
		PuzzleSlider.Paint = function( self2, w, h )
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "Highlight" ) )
			surface.DrawRect( 0, 0, w, h )
		end
		local FreezeSlider = false
		local TravelDown = true
		PuzzleSlider.Think = function( self2 )
			if( FreezeSlider == true ) then return end
		
			local self2X, self2Y = self2:GetPos()
			local MaxYPos = PuzzleSliderBack:GetTall()-self2:GetTall()
			if( TravelDown == true ) then
				self2:SetPos( 0, math.Clamp( self2Y+DarkRPFoundation.CONFIG.BANKVAULT.SliderSpeed, 0, MaxYPos ) )
				if( self2Y >= MaxYPos ) then
					TravelDown = false
				end
			else
				self2:SetPos( 0, math.Clamp( self2Y-DarkRPFoundation.CONFIG.BANKVAULT.SliderSpeed, 0, MaxYPos ) )
				if( self2Y <= 0 ) then
					TravelDown = true
				end
			end
		end
		
		local function ResetSliderPuzzle()
			FinalHeight = math.random( MinHeight, MaxHeight )
			PuzzleSliderLandZone:SetSize( PuzzleSliderBack:GetWide(), FinalHeight )
			PuzzleSliderLandZone:SetPos( 0, math.random( 0, PuzzleSliderBack:GetTall()-FinalHeight ) )
			
			FreezeSlider = false
		end
		
		local UnlockButton = vgui.Create( "DButton", PuzzleBackground )
		UnlockButton:SetTall( 55 )
		UnlockButton:Dock( BOTTOM )
		UnlockButton:DockMargin( 25, 25, 25, 25 )
		UnlockButton:SetText( "" )
		UnlockButton.Paint = function( self2, w, h )
			if( self2:IsHovered() and !self2:IsDown() ) then
				surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "Highlight", 200 ) )	
			elseif( self2:IsDown() ) then
				surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "Highlight" ) )
			else
				surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
			end
			
			surface.DrawRect( 0, 0, w, h )
			
			draw.SimpleText( DRPF_Functions.L( "bankVaultUnlockPin" ), "DarkRPFoundation_Font_Lvl_RewardHeader", w/2, h/2, Color( 245, 245, 245 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		UnlockButton.DoClick = function()
			FreezeSlider = true
			local PuzzleSliderX, PuzzleSliderY = PuzzleSlider:GetPos()
			local PuzzleSliderLandZoneX, PuzzleSliderLandZoneY = PuzzleSliderLandZone:GetPos()
			if( PuzzleSliderY >= PuzzleSliderLandZoneY and PuzzleSliderY < PuzzleSliderLandZoneY+PuzzleSliderLandZone:GetTall()-PuzzleSlider:GetTall() ) then
				PinsUnlocked = PinsUnlocked+1
				surface.PlaySound( "HL1/fvox/bell.wav" )
				timer.Simple( 0.5, function() 
					if( IsValid( self ) ) then
						ResetSliderPuzzle() 
					end
				end )
			else
				surface.PlaySound( "HL1/fvox/beep.wav" )
				self:Remove()
				if( IsValid( self.VaultEnt ) ) then
					net.Start( "DarkRPFoundationNet_BankFail" ) 
						net.WriteEntity( self.VaultEnt )
					net.SendToServer()
				end
			end
		
			if( PinsUnlocked >= Pins and IsValid( self.VaultEnt ) ) then
				net.Start( "DarkRPFoundationNet_BankUnlock" ) 
					net.WriteEntity( self.VaultEnt )
				net.SendToServer()
				
				self:Remove()
			end
		end
	end
	
	self:CreatePuzzle()
end

function PANEL:Think()
	if( not IsValid( self.VaultEnt ) ) then
		self:Remove()
	end
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
	surface.DrawRect( 0, 0, w, h )		
	
	surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
	surface.DrawRect( 0, 0, w, HeaderY )	
	
	draw.SimpleText( DRPF_Functions.L( "bankVaultName" ), "DarkRPFoundation_Font_Inv_Header", w/2, HeaderY/2, Color( 245, 245, 245 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

vgui.Register( "drpf_bankvault_menu", PANEL, "DFrame" )