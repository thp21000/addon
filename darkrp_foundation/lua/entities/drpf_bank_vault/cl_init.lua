include("shared.lua")

DRPF_VAULTS_CSModels = (DRPF_VAULTS_CSModels or {})
 
function ENT:Initialize()
	self.VaultRear = ClientsideModel( "models/darkrpfoundation/bank/vault_interior.mdl" )
	self.VaultRear:SetPos( self:GetPos() )
	self.VaultRear:SetAngles( self:GetAngles() )
	self.VaultRear:SetNoDraw( true )
	self.VaultRear:SetParent( self )
	
	DRPF_VAULTS_CSModels[self:EntIndex()] = self
	self.RenderGroup = 7
	self.VaultRear.RenderGroup = 7
end

function ENT:Think()
	self.VaultRear:SetPos( self:GetPos() ) -- Keeps the rear of the vault position aligned with the front
	self.VaultRear:SetAngles( self:GetAngles() ) -- Keeps the rear of the vault angles aligned with the front
end

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
	
	local PoliceText = DRPF_Functions.L( "armoryPolice" ) .. " " .. PoliceCount .. "/" .. DarkRPFoundation.CONFIG.BANKVAULT.PoliceRequirement 
	if( PoliceCount >= DarkRPFoundation.CONFIG.BANKVAULT.PoliceRequirement ) then
		PoliceText = DRPF_Functions.L( "armoryPolice" ) .. DRPF_Functions.L( "armoryPoliceEnough" )
	end	
	
	local LockedText = DRPF_Functions.L( "armoryLocked" ) .. DRPF_Functions.L( "armoryLockedYes" )
	if( self:GetLocked() == false ) then
		LockedText = DRPF_Functions.L( "armoryLocked" ) .. DRPF_Functions.L( "armoryLockedNo" )
	end
	
	local AlarmText = DRPF_Functions.L( "bankValueEntAlarm" ) .. DRPF_Functions.L( "armoryLockedYes" )
	if( self:GetAlarm() == true ) then
		AlarmText = DRPF_Functions.L( "bankValueEntAlarm" ) .. DRPF_Functions.L( "armoryLockedYes" )
	end
	
	local VaultInfo = {}
	VaultInfo[1] = {
		Icon = DarkRPFoundation.MATERIALS.MoneyBag,
		Text = DRPF_Functions.L( "bankValueEntMoney" ) .. self:GetMoneyBags() .. "/" .. DarkRPFoundation.CONFIG.BANKVAULT.MoneyBags
	}
	VaultInfo[2] = {
		Icon = DarkRPFoundation.MATERIALS.PoliceBadge,
		Text = PoliceText
	}
	VaultInfo[3] = {
		Icon = DarkRPFoundation.MATERIALS.Lock,
		Text = LockedText
	}
	VaultInfo[4] = {
		Icon = DarkRPFoundation.MATERIALS.Alarm,
		Text = AlarmText
	}
	
	local IconSize = 32
	local Spacing = 18
	local Padding = 6
	local HeaderSpace = 58
	
	local x, y, w, h = -545, -725, 305, HeaderSpace+(#VaultInfo*(IconSize+Spacing))
	x = x-w
	cam.Start3D2D(Pos - Ang:Up() * 17, Ang, 0.1)
		surface.SetAlphaMultiplier( AlphaMulti )
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
			surface.DrawRect( x, y, w, h )			
			
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
			surface.DrawOutlinedRect( x, y, w, h )
	
			draw.SimpleText( DRPF_Functions.L( "bankValueEntName" ), "DarkRPFoundation_Font_Inv_Button", x+(w/2), y+5, Color( 235, 235, 235, AlphaMulti*255 ), TEXT_ALIGN_CENTER, 0 )
			
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
			
			if( self:GetRobberyCooldown() > CurTime() ) then
				DrawAlert( DRPF_Functions.L( "armoryCooldown" ) .. " " .. math.Round(self:GetRobberyCooldown() - CurTime()), (self:GetRobberyCooldown() - CurTime())/DarkRPFoundation.CONFIG.BANKVAULT.RobberyCooldown )
			elseif( self:GetLocked() == false ) then
				DrawAlert( DRPF_Functions.L( "bankValueEntLock" ) .. " " .. math.Round(self:GetUnlockTimer() - CurTime()), (self:GetUnlockTimer() - CurTime())/DarkRPFoundation.CONFIG.BANKVAULT.OpenTime )
			elseif( self:GetAlarm() == true ) then
				DrawAlert( DRPF_Functions.L( "bankValueEntAlarmEnd" ) .. " " .. math.Round(self:GetAlarmCooldown() - CurTime()), (self:GetAlarmCooldown() - CurTime())/DarkRPFoundation.CONFIG.BANKVAULT.AlarmDuration )
			end
		surface.SetAlphaMultiplier( 1 )
	cam.End3D2D()
end

--[[ RENDERING REAR ATM ]]--
hook.Add( "PreDrawTranslucentRenderables", "DarkRPFoundationHooks_PreDrawTranslucentRenderables_VaultStencils", function( isDrawingDepth, isDrawSkybox )
	if( isDrawSkybox or isDrawingDepth ) then return end

	for k, v in pairs( DRPF_VAULTS_CSModels ) do
		if( not IsValid( v ) ) then continue end

		local screenpos = v:GetPos():ToScreen()
		if( screenpos.visible == false and LocalPlayer():GetEyeTrace().Entity != v ) then
			continue
		end

		render.ClearStencil()
		render.SetStencilEnable( true )
		render.SetStencilReferenceValue( 69 )
		render.SetStencilWriteMask( 255 )
		render.SetStencilTestMask( 255 )
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
		render.SetStencilPassOperation( STENCILOPERATION_REPLACE )

		local VAngles = v:GetAngles()
		VAngles:RotateAroundAxis( VAngles:Right(), -90 )

		cam.Start3D2D( v:GetPos() - ( v:GetAngles():Up() * -5 ), VAngles, 0.5 )
			draw.NoTexture()
			draw.RoundedBox( 0, -190, -60, 190, 120, Color( 255, 255, 255, 1 ) )
		cam.End3D2D()
		
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
		render.DepthRange( 0, 0.8 )
		
		v.VaultRear:DrawModel()
		
		render.SetStencilEnable(false)
		render.DepthRange( 0, 1 )
	end
end )

--[[ UNLOCKING UI ]]--
net.Receive( "DarkRPFoundationNet_BankUse", function()
	local ReceivedEnt = net.ReadEntity()
	
	if( not IsValid( ReceivedEnt.VaultMenu ) ) then
		ReceivedEnt.VaultMenu = vgui.Create( "drpf_bankvault_menu" )
		ReceivedEnt.VaultMenu.VaultEnt = ReceivedEnt
	else
		ReceivedEnt.VaultMenu:SetVisible( true )
	end
end )