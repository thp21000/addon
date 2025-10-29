include('shared.lua')

local gradient = Material( 'vgui/gradient-l' )
local x, y, w, h = -257, 26, 374, 179
local Flash = false
timer.Create( tostring( ENT ) .. "FlashOverStorageLimitTimer", 0.5, 0, function()
	if( Flash == false ) then
		Flash = true
	else
		Flash = false
	end
end )
local InkStored = ENT.ConfigTable.MaxInk
function ENT:Draw()
	self:DrawModel()

	local Distance = LocalPlayer():GetPos():DistToSqr( self:GetPos() )

	if( Distance >= DarkRPFoundation.CONFIG.GENERAL.DisplayDist3D2D ) then return end
	
	local AlphaMulti = 1-(Distance/DarkRPFoundation.CONFIG.GENERAL.DisplayDist3D2D)
	surface.SetAlphaMultiplier( AlphaMulti )

	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	//TOP PANEL
	Ang:RotateAroundAxis(Ang:Up(), 90)
	Ang:RotateAroundAxis(Ang:Up(), 270)
	Ang:RotateAroundAxis(Ang:Forward(), 90)
	Ang:RotateAroundAxis(Ang:Right(), 270)
	Ang:RotateAroundAxis(Ang:Forward(), -58)
	
	cam.Start3D2D(Pos + Ang:Up() * 37.1, Ang, 0.06)
		-- Background
		surface.SetDrawColor( self.ConfigTable.ScreenColor )
		surface.DrawRect( x, y, w, h )
		
		surface.SetMaterial( gradient )
		surface.SetDrawColor( 0, 0, 0, 75 )
		surface.DrawTexturedRect( x, y, w, h )
		
		-- Logo
		surface.SetMaterial( DarkRPFoundation.MATERIALS.ServerLogo )
		surface.SetDrawColor( 255, 255, 255 )
		surface.DrawTexturedRect( x+5, y+5, 50, 50 )
		
		draw.SimpleText( DarkRPFoundation.CONFIG.GENERAL.ServerName, "DarkRPFoundation_Font45", x+5+50+5-1, y+5+(50/2)+1, Color( 0, 0, 0 ), 0, TEXT_ALIGN_CENTER )
		draw.SimpleText( DarkRPFoundation.CONFIG.GENERAL.ServerName, "DarkRPFoundation_Font45", x+5+50+5, y+5+(50/2), Color( 255, 255, 255 ), 0, TEXT_ALIGN_CENTER )
		
		-- Progress Bars
		local ProgressBars = {}
		local function AddProgressBar( Title, Percentage )
			table.insert( ProgressBars, { Title, Percentage } )
		end
		
		AddProgressBar( DRPF_Functions.L( "basePrinterEntPrinterHp" ), (self:Health()/self.ConfigTable.PrinterHealth) )
		AddProgressBar( DRPF_Functions.L( "basePrinterEntPrinterInk" ), (self:GetInk()/self.ConfigTable.MaxInk) )
		
		local Spacing = 10
		local Width = (w-(#ProgressBars+1)*Spacing)/#ProgressBars
		for k, v in pairs( ProgressBars ) do
			draw.SimpleText( v[1], "DarkRPFoundation_Font40", x+Spacing+((k-1)*(Spacing+Width)), y+75, Color( 255, 255, 255 ), 0, TEXT_ALIGN_CENTER )
			
			surface.SetDrawColor( 0, 0, 0, 125 )
			surface.DrawRect( x+Spacing+((k-1)*(Spacing+Width)), y+95, Width, 25 )		
			surface.DrawOutlinedRect( x+Spacing+((k-1)*(Spacing+Width)), y+95, Width, 25 )		
			
			surface.SetDrawColor( 255, 255, 255, 200 )
			surface.DrawRect( x+Spacing+((k-1)*(Spacing+Width))+1, y+95+1, (Width-2)*v[2], 25-2 )
			
			draw.SimpleText( math.Round(v[2]*100) .. "%", "DarkRPFoundation_Font30", x+Spacing+((k-1)*(Spacing+Width))+(Width/2)-1, y+95+(25/2)+1, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( math.Round(v[2]*100) .. "%", "DarkRPFoundation_Font30", x+Spacing+((k-1)*(Spacing+Width))+(Width/2)+1, y+95+(25/2)-1, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( math.Round(v[2]*100) .. "%", "DarkRPFoundation_Font30", x+Spacing+((k-1)*(Spacing+Width))+(Width/2), y+95+(25/2), Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		
		-- Money
		local StorageAmount = self.ConfigTable.MoneyStorage
		if( self:GetUpgradeStorage() == true ) then
			StorageAmount = self.ConfigTable.UpgradedMoneyStorage
		end
		
		local MoneyCol = HSVToColor( 140-(140*(self:GetHolding()/(StorageAmount))), 1, 1 )
		draw.SimpleText( DarkRP.formatMoney( self:GetHolding() ), "DarkRPFoundation_Font45", x+w-5-1, y+h+1, Color( 0, 0, 0 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
		if( Flash == false or self:GetHolding() < StorageAmount ) then
			draw.SimpleText( DarkRP.formatMoney( self:GetHolding() ), "DarkRPFoundation_Font45", x+w-5, y+h, MoneyCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
		else
			draw.SimpleText( DarkRP.formatMoney( self:GetHolding() ), "DarkRPFoundation_Font45", x+w-5, y+h, Color( 200, 0, 0 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
		end
		
		-- PrinterTier
		draw.SimpleText( string.upper( self.ConfigTable.PrinterTier ), "DarkRPFoundation_Font35", x+5-1, y+h+1, Color( 0, 0, 0 ), 0, TEXT_ALIGN_BOTTOM )
		draw.SimpleText( string.upper( self.ConfigTable.PrinterTier ), "DarkRPFoundation_Font35", x+5, y+h, self.ConfigTable.PrinterColor, 0, TEXT_ALIGN_BOTTOM )
	cam.End3D2D()
	
	
	//MaxInk PANEL
	Ang:RotateAroundAxis(Ang:Forward(), -5)
	local x, y, w, h = 162, -24, 86, 20
	InkStored = Lerp( FrameTime()*2, InkStored, self:GetInk() )
	cam.Start3D2D(Pos + Ang:Up() * 36.1, Ang, 0.06)
		surface.SetDrawColor( Color( 175, 175, 175, 125 ) )
		surface.DrawRect( x, y, w, h )		
		surface.SetDrawColor( Color( 75, 75, 75 ) )
		surface.DrawRect( x, y, w*(InkStored/self.ConfigTable.MaxInk), h )
	cam.End3D2D()
	
	surface.SetAlphaMultiplier( 1 )
end
