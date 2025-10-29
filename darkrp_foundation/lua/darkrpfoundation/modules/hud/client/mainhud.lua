--[[ Default HUD Hider ]]--
local ToHide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudVoiceSelfStatus"] = true,
	["DarkRP_HUD"] = true,
	["DarkRP_EntityDisplay"] = true,
	["DarkRP_LocalPlayerHUD"] = true,
	["DarkRP_Hungermod"] = true,
	["DarkRP_Agenda"] = false,
	["DarkRP_LockdownHUD"] = true,
	["DarkRP_ArrestedHUD"] = true,
}

hook.Add( "HUDShouldDraw", "DarkRPFoundationHooks_HUDShouldDraw_HideHUD", function( name )
	if ( ToHide[ name ] ) then return false end
end )

--[[ Main HUD ]]--
local FinalPercent = 0
hook.Add( "HUDPaint", "DarkRPFoundationHooks_HUDPaint_MainHUD", function() 
	-- HUD VARIABLES --
	local x, y = ScrW(), ScrH()
	local ply = LocalPlayer()
	local BarWidths = x/7
	local EXPBarHeight = 8

	-- LEVELLING HUD --
	if( DarkRPFoundation.CONFIG.LEVELING.Enable == true ) then
		-- EXP variables
		local percent = i_experience/(DarkRPFoundation.CONFIG.LEVELING.OrignalEXPRequired*(DarkRPFoundation.CONFIG.LEVELING.EXPRequiredIncrease^(i_level) ))
		percent = math.Clamp( percent, 0, (DarkRPFoundation.CONFIG.LEVELING.OrignalEXPRequired*(DarkRPFoundation.CONFIG.LEVELING.EXPRequiredIncrease^(i_level) )) )
		
		FinalPercent = Lerp( 2 * FrameTime() , FinalPercent , percent )
		
		-- Background bar
		surface.SetDrawColor( 113, 113, 113, 255 )
		surface.DrawRect( 0, 0, x, EXPBarHeight )	
		
		surface.SetDrawColor( 123, 123, 123, 255 )
		surface.DrawRect( 0, 0, x, EXPBarHeight*0.35 )
		
		-- Black line bottom
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect( 0, EXPBarHeight, x, 1 )
		
		-- EXP percent bar
		surface.SetDrawColor( 99, 255, 165, 255 )
		surface.DrawRect( 0, 0, FinalPercent*x, EXPBarHeight )	
		surface.SetDrawColor( 0, 255, 110, 255 )
		surface.DrawRect( 0, 0, FinalPercent*x, EXPBarHeight*0.35 )
	
		-- Greyish overlay
		surface.SetDrawColor( 113, 113, 113, 75 )
		surface.DrawRect( 0, 0, x, EXPBarHeight )	
		
		-- Vertical black bars
		local vertbaramount = 20
		for i=1,vertbaramount do 
			local position = ScrW()/vertbaramount
			surface.SetDrawColor( 0, 0, 0, 150 )
			surface.DrawRect( i*position, 0, 1, EXPBarHeight )
		end 
	else
		--Background Bar
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect( 0, 0, x, EXPBarHeight )	
	end
	
	-- HEALTH BAR --
	DarkRPFoundation.DRAW.ThemedBox( 0, EXPBarHeight, BarWidths, 20, 5 )
	
	-- Filled bar
	surface.SetDrawColor( 252, 70, 70, 255 )
	surface.DrawRect( 1, EXPBarHeight+1, math.Clamp((ply:Health()/ply:GetMaxHealth())*BarWidths, 0, BarWidths)-2, 20-2 )			
	
	surface.SetDrawColor( 255, 96, 96, 255 )
	surface.DrawRect( 1, EXPBarHeight+1, math.Clamp((ply:Health()/ply:GetMaxHealth())*BarWidths, 0, BarWidths)-2, 5 )	
	
	-- Icon
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( DarkRPFoundation.MATERIALS.HealthMat	)
	surface.DrawTexturedRect( 3, EXPBarHeight+3, 14, 14 )
	
	-- Bar text
	surface.SetFont( "DarkRPFoundation_Font18" )
	local HealthX, HealthY = surface.GetTextSize(ply:Health())

	draw.SimpleText( ply:Health(), "DarkRPFoundation_Font18", BarWidths-HealthX-5, EXPBarHeight+10, Color( 255, 255, 255, 255 ), 0, TEXT_ALIGN_CENTER )
	
	-- ARMOR BAR --
	DarkRPFoundation.DRAW.ThemedBox( BarWidths-1, EXPBarHeight, BarWidths, 20, 5 )
	
	-- Filled bar
	surface.SetDrawColor( 70, 70, 252, 255 )
	surface.DrawRect( BarWidths-1+1, EXPBarHeight+1, math.Clamp((ply:Armor()/255)*BarWidths, 0, BarWidths)-2, 20-2 )		
	
	surface.SetDrawColor( 96, 96, 255, 255 )
	surface.DrawRect( BarWidths-1+1, EXPBarHeight+1, math.Clamp((ply:Armor()/255)*BarWidths, 0, BarWidths)-2, 5 )	
	
	-- Icon
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( DarkRPFoundation.MATERIALS.ArmorMat	)
	surface.DrawTexturedRect( BarWidths-1+3, EXPBarHeight+3, 14, 14 )
	
	-- Bar text
	surface.SetFont( "DarkRPFoundation_Font18" )
	local ArmorX, ArmorY = surface.GetTextSize(ply:Armor())
	
	draw.SimpleText( ply:Armor(), "DarkRPFoundation_Font18", BarWidths-1+BarWidths-ArmorX-5, EXPBarHeight+10, Color( 255, 255, 255, 255 ), 0, TEXT_ALIGN_CENTER )
	
	-- HUNGER BAR --
	if( DarkRP.disabledDefaults["modules"]["hungermod"] != true ) then
		DarkRPFoundation.DRAW.ThemedBox( BarWidths+BarWidths-3, EXPBarHeight, BarWidths, 20, 5 )
		
		-- Filled bar
		surface.SetDrawColor( 207, 160, 16, 255 )
		surface.DrawRect( BarWidths+BarWidths-3+1, EXPBarHeight+1, math.Clamp((ply:getDarkRPVar('Energy')/100)*BarWidths, 0, BarWidths)-2, 20-2 )		
		
		surface.SetDrawColor( 211, 169, 78, 255 )
		surface.DrawRect( BarWidths+BarWidths-3+1, EXPBarHeight+1, math.Clamp((ply:getDarkRPVar('Energy')/100)*BarWidths, 0, BarWidths)-2, 5 )	

		-- Bar text
		surface.SetFont( "DarkRPFoundation_Font18" )
		local HungerX, HungerY = surface.GetTextSize(ply:getDarkRPVar('Energy').."%")
		
		-- Icon
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( DarkRPFoundation.MATERIALS.HungerMat	)
		surface.DrawTexturedRect( BarWidths-1+BarWidths-1+3, EXPBarHeight+3, 14, 14 )
		
		draw.SimpleText( ply:getDarkRPVar('Energy').."%", "DarkRPFoundation_Font18", BarWidths+BarWidths-3+BarWidths-HungerX-5, EXPBarHeight+10, Color( 255, 255, 255, 255 ), 0, TEXT_ALIGN_CENTER )
	end
	
	-- DATE/TIME BAR --
	local TimeBarSize = BarWidths/1.25
	DarkRPFoundation.DRAW.ThemedBox( x-TimeBarSize+1, EXPBarHeight, TimeBarSize, 20, 5 )
	
	-- Icon
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( DarkRPFoundation.MATERIALS.TimeMat	)
	surface.DrawTexturedRect( x-TimeBarSize+1+5, EXPBarHeight+3, 14, 14 )
	
	-- Bar text
	surface.SetFont( "DarkRPFoundation_Font18" )
	local DateX, DateY = surface.GetTextSize(os.date( "%d/%m/%Y" , os.time() ))
	
	draw.SimpleText( os.date( "%H:%M" , os.time() ), "DarkRPFoundation_Font18", x-TimeBarSize+1+5+16, EXPBarHeight+10, Color( 255, 255, 255, 255 ), 0, TEXT_ALIGN_CENTER )
	draw.SimpleText( os.date( "%d/%m/%Y" , os.time() ), "DarkRPFoundation_Font18", x-DateX-5, EXPBarHeight+10, Color( 255, 255, 255, 255 ), 0, TEXT_ALIGN_CENTER )
	
	-- LEVEL INFO BAR --
	local LeveInfoBarSize = 0
	if( DarkRPFoundation.CONFIG.LEVELING.Enable == true ) then
		LeveInfoBarSize = TimeBarSize/1.25
		DarkRPFoundation.DRAW.ThemedBox( x-LeveInfoBarSize+1-TimeBarSize+2, EXPBarHeight, LeveInfoBarSize, 20, 5 )
		
		-- Bar text
		local percent = i_experience/(DarkRPFoundation.CONFIG.LEVELING.OrignalEXPRequired*(DarkRPFoundation.CONFIG.LEVELING.EXPRequiredIncrease^(i_level) ))
		percent = math.Clamp( percent, 0, (DarkRPFoundation.CONFIG.LEVELING.OrignalEXPRequired*(DarkRPFoundation.CONFIG.LEVELING.EXPRequiredIncrease^(i_level) )) )
		percent = math.Round( percent*100, 1 )
		
		surface.SetFont( "DarkRPFoundation_Font18" )
		local LvlPercentageX, LvlPercentageY = surface.GetTextSize( percent.." %" )
		
		draw.SimpleText( DRPF_Functions.L( "lvlNpcLevel" ) .. " " .. i_level , "DarkRPFoundation_Font18", x-LeveInfoBarSize+1-TimeBarSize+2+5, EXPBarHeight+10, Color( 255, 255, 255, 255 ), 0, TEXT_ALIGN_CENTER )
		draw.SimpleText( percent.." %" , "DarkRPFoundation_Font18", x+1-TimeBarSize+2-LvlPercentageX-5-1, EXPBarHeight+10, Color( 255, 255, 255, 255 ), 0, TEXT_ALIGN_CENTER )
	end
	
	-- SALARY/WALLET BAR --
	surface.SetFont( "DarkRPFoundation_Font18" )
	local SalaryX, SalaryY = surface.GetTextSize( DarkRP.formatMoney(ply:getDarkRPVar('salary')) )
	local WalletX, WalletY = surface.GetTextSize( DarkRP.formatMoney(ply:getDarkRPVar('money')) )
	
	local MoneyBarSize = 14+SalaryX+WalletX+50
	DarkRPFoundation.DRAW.ThemedBox( x-TimeBarSize-LeveInfoBarSize-MoneyBarSize+4, EXPBarHeight, MoneyBarSize, 20, 5 )
	
	-- Icon
	DarkRPFoundation.DRAW.IconBox( x-TimeBarSize-LeveInfoBarSize-MoneyBarSize+4+1, EXPBarHeight+1, 18, 18, DarkRPFoundation.MATERIALS.SalaryMat )
	
	-- Bar text
	draw.SimpleText( DarkRP.formatMoney(ply:getDarkRPVar('salary')).."/hr", "DarkRPFoundation_Font18", x-MoneyBarSize-LeveInfoBarSize+1-TimeBarSize+2+5+16, EXPBarHeight+10, Color( 255, 255, 255, 255 ), 0, TEXT_ALIGN_CENTER )
	draw.SimpleText( DarkRP.formatMoney(ply:getDarkRPVar('money')), "DarkRPFoundation_Font18", x-LeveInfoBarSize+1-TimeBarSize+2-WalletX-5, EXPBarHeight+10, Color( 255, 255, 255, 255 ), 0, TEXT_ALIGN_CENTER )

	-- JOB NAME BAR --
	surface.SetFont( "DarkRPFoundation_Font18" )
	local JobX, JobY = surface.GetTextSize( ply:getDarkRPVar('job') or "" )

	local JobBarSize = JobX+10
	DarkRPFoundation.DRAW.ThemedBox( x-JobBarSize-TimeBarSize-LeveInfoBarSize-MoneyBarSize+5, EXPBarHeight, JobBarSize, 20, 5 )
	
	draw.SimpleText( ply:getDarkRPVar('job'), "DarkRPFoundation_Font18", x-JobBarSize-MoneyBarSize-LeveInfoBarSize+1-TimeBarSize+2+5, EXPBarHeight+10, Color( 255, 255, 255, 255 ), 0, TEXT_ALIGN_CENTER )
	
end )