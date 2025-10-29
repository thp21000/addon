include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	local Distance = LocalPlayer():GetPos():DistToSqr( self:GetPos() )

	if( Distance >= DarkRPFoundation.CONFIG.GENERAL.DisplayDist3D2D ) then return end
	
	local AlphaMulti = 1-(Distance/DarkRPFoundation.CONFIG.GENERAL.DisplayDist3D2D)

	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	//TOP PANEL
	Ang:RotateAroundAxis(Ang:Up(), 90)
	Ang:RotateAroundAxis(Ang:Up(), 270)
	Ang:RotateAroundAxis(Ang:Forward(), 90)
	Ang:RotateAroundAxis(Ang:Right(), 270)
	Ang:RotateAroundAxis(Ang:Right(), -20)
	
	local PoliceCount = 0
	for k, v in pairs( player.GetAll() ) do
		if( table.HasValue( DarkRPFoundation.CONFIG.GENERAL.PoliceJobs, v:Team() ) ) then
			PoliceCount = PoliceCount+1
		end
	end
	
	local PoliceText = DRPF_Functions.L( "armoryPolice" ) .. " " .. PoliceCount .. "/" .. DarkRPFoundation.CONFIG.ARMORY.PoliceRequirement
	if( PoliceCount >= DarkRPFoundation.CONFIG.ARMORY.PoliceRequirement ) then
		PoliceText = DRPF_Functions.L( "armoryPolice" ) .. " " .. DRPF_Functions.L( "armoryPoliceEnough" )
	end	
	
	local LockedText = DRPF_Functions.L( "armoryLocked" ) .. " " .. DRPF_Functions.L( "armoryLockedYes" ) 
	if( self:GetLocked() == false ) then
		LockedText = DRPF_Functions.L( "armoryLocked" ) .. " " .. DRPF_Functions.L( "armoryLockedNo" )
	end

	local VaultInfo = {}
	VaultInfo[1] = {
		Icon = DarkRPFoundation.MATERIALS.PoliceBadge,
		Text = PoliceText
	}
	VaultInfo[2] = {
		Icon = DarkRPFoundation.MATERIALS.Lock,
		Text = LockedText
	}	
	VaultInfo[3] = {
		Icon = DarkRPFoundation.MATERIALS.Crate,
		Text = (self:GetShipmentValue() or 0) .. " +" .. DarkRP.formatMoney( (self:GetMoneyValue() or 0) ) .. ""
	}
	
	local IconSize = 32
	local Spacing = 18
	local Padding = 6
	local HeaderSpace = 58
	
	local x, y, w, h = -310, -725, 305, HeaderSpace+(#VaultInfo*(IconSize+Spacing))
	x = x-w
	cam.Start3D2D(Pos + Ang:Up() * 2, Ang, 0.1)
		surface.SetAlphaMultiplier( AlphaMulti )
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
			surface.DrawRect( x, y, w, h )			
			
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
			surface.DrawOutlinedRect( x, y, w, h )
			
			draw.SimpleText( DRPF_Functions.L( "entitiesArmory" ), "DarkRPFoundation_Font_Inv_Button", x+(w/2), y+5, Color( 235, 235, 235, AlphaMulti*255 ), TEXT_ALIGN_CENTER, 0 )
			
			for k, v in pairs( VaultInfo ) do
				surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
				surface.DrawRect( x+1, y+HeaderSpace+((k-1)*(IconSize+Spacing))-Padding, w-2, IconSize+(2*Padding) )	
			
				surface.SetMaterial( v.Icon )
				surface.SetDrawColor( 255, 255, 255 )
				surface.DrawTexturedRect( x+10, y+HeaderSpace+((k-1)*(IconSize+Spacing)), IconSize, IconSize )
				
				draw.SimpleText( v.Text, "DarkRPFoundation_Font_Lvl_PlyNameM", x+10+IconSize+10, y+HeaderSpace+((k-1)*(IconSize+Spacing))+(IconSize/2), Color( 255, 255, 255, AlphaMulti*255 ), 0, TEXT_ALIGN_CENTER )
			end

			local function DrawAlert( Text, Percent )
				local SubH = 65
				surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
				surface.DrawRect( x, y+h+10, w, SubH, 0 )			
				
				surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
				surface.DrawOutlinedRect( x, y+h+10, w, SubH, 0 )
				
				surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor", 150 ) )
				surface.DrawRect( x+1, y+h+10+1, math.Clamp( (w-2)*(Percent or 0), 0, w-2 ), SubH-2 )	
				
				draw.SimpleText( Text, "DarkRPFoundation_Font_Lvl_PlyNameS", x+(w/2), y+h+10+(SubH/2), Color( 235, 235, 235, AlphaMulti*255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
			
			if( not table.HasValue( DarkRPFoundation.CONFIG.GENERAL.PoliceJobs, LocalPlayer():Team() ) ) then
				if( self:GetRobberyCooldown() > CurTime() ) then
					DrawAlert( DRPF_Functions.L( "armoryRefill" ) .. ": " .. math.Round(self:GetRobberyCooldown() - CurTime()), (self:GetRobberyCooldown() - CurTime())/DarkRPFoundation.CONFIG.ARMORY.RobberyCooldown )
				elseif( self:GetFailCooldown() > CurTime() ) then
					DrawAlert( DRPF_Functions.L( "armoryCooldown" ) .. " " .. math.Round(self:GetFailCooldown() - CurTime()), (self:GetFailCooldown() - CurTime())/DarkRPFoundation.CONFIG.ARMORY.FailCooldown )			
				elseif( self:GetUnlockTimer() > CurTime() ) then
					DrawAlert( DRPF_Functions.L( "armoryUnlock" ) .. " " .. math.Round(self:GetUnlockTimer() - CurTime()), (self:GetUnlockTimer() - CurTime())/DarkRPFoundation.CONFIG.ARMORY.OpenTime )
				end
			else
				DrawAlert( DRPF_Functions.L( "press" ) .. " '" .. string.upper(input.LookupBinding( "+use", true )) .. "' " .. DRPF_Functions.L( "toUse" ), 1 )
			end
		surface.SetAlphaMultiplier( 1 )
	cam.End3D2D()
end

net.Receive( "DarkRPFoundationNet_ArmoryUse", function()
	if( not IsValid( DRPF_MENU_ARMORY ) ) then
		DRPF_MENU_ARMORY = vgui.Create( "drpf_armory_menu" )
	else
		DRPF_MENU_ARMORY:SetVisible( true )
	end
end )