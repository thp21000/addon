local agendaText
local W, H = ScrW()*0.3, ScrH()*0.1
local X, Y = ScrW()-W-5, 28-1+5+1
local LockdownYPos = 28+5

hook.Add( "HUDPaint", "DarkRPFoundationHooks_HUDPaint_DarkRP_Agenda", function()
    local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_Agenda")
    if shouldDraw == false then return end

    local agenda = LocalPlayer():getAgendaTable()
    if( not agenda ) then
		LockdownYPos = 28+5
		return 
	else
		LockdownYPos = 28-1+5+1+(ScrH()*0.1)+5
	end
    agendaText = agendaText or DarkRP.textWrap((LocalPlayer():getDarkRPVar("agenda") or ""):gsub("//", "\n"):gsub("\\n", "\n"), "DarkRPFoundation_Font16", W)
	
	surface.SetDrawColor( 113, 113, 113, 255 )
	surface.DrawRect( X, Y, W, H )
	
	surface.SetDrawColor( 123, 123, 123, 255 )
	surface.DrawRect( X, Y, W, H*0.1 )
	
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawOutlinedRect( X, Y, W, H )

    draw.DrawNonParsedText(agenda.Title, "DarkRPFoundation_Font20", X+3, Y-2, Color(255,255,255,255), 0)
    draw.DrawNonParsedText(agendaText, "DarkRPFoundation_Font16", X+3, Y+15, Color(255,255,255,255), 0)
end )

hook.Add("DarkRPVarChanged", "DarkRPFoundationHooks_DarkRPVarChanged_agendaHUD", function(ply, var, _, new)
    if ply ~= LocalPlayer() then return end
    if var == "agenda" and new then
        agendaText = DarkRP.textWrap(new:gsub("//", "\n"):gsub("\\n", "\n"), "DarkRPFoundation_Font16", W)
    else
        agendaText = nil
    end
end)

surface.SetFont( "DarkRPFoundation_Font20" )
local LockDownX, LockDownY = surface.GetTextSize( "LOCKDOWN" )
local W, H = LockDownX+20+LockDownY+3, LockDownY+5
local X = ScrW()-W-5
local WantedY = 0

local FlashAlpha = 0
local FlashNew = 0
local function FlashChange()
	timer.Simple( 0.5, function() 
		if( FlashNew > 125 ) then
			FlashNew = 0
		else
			FlashNew = 255
		end
		FlashChange()
	end )
end
FlashChange()

hook.Add( "HUDPaint", "DarkRPFoundationHooks_HUDPaint_LockDownAndWanted", function()
    if( GetGlobalBool("DarkRP_LockDown") ) then
		DarkRPFoundation.DRAW.ThemedBox( X, LockdownYPos, W, H, H*0.1 )
		
		FlashAlpha = Lerp( FrameTime()*4, FlashAlpha, FlashNew )
		surface.SetDrawColor( 255, 113, 113, FlashAlpha )
		surface.DrawRect( X+1, LockdownYPos+1, W-2, H-2 )
		
		-- ICON --
		DarkRPFoundation.DRAW.IconBox( X+1, LockdownYPos+1, H-2, H-2, DarkRPFoundation.MATERIALS.JailMat )
		
		-- TEXT --
        draw.SimpleText( DRPF_Functions.L( "hudLockdown" ), "DarkRPFoundation_Font20", (X+1+H-2)+((W-H-2)/2), LockdownYPos+(H/2)-1, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		
		WantedY = LockdownYPos+H+5
	else
		WantedY = LockdownYPos
    end
	
	if( LocalPlayer():isWanted() ) then
		DarkRPFoundation.DRAW.ThemedBox( X, WantedY, W, H, H*0.1 )
		
		FlashAlpha = Lerp( FrameTime()*4, FlashAlpha, FlashNew )
		surface.SetDrawColor( 255, 113, 113, FlashAlpha )
		surface.DrawRect( X+1, WantedY+1, W-2, H-2 )
		
		-- ICON --
		DarkRPFoundation.DRAW.IconBox( X+1, WantedY+1, H-2, H-2, DarkRPFoundation.MATERIALS.WantedMat )
		
		-- TEXT --
        draw.SimpleText( DRPF_Functions.L( "hudWanted" ), "DarkRPFoundation_Font20", (X+1+H-2)+((W-H-2)/2), WantedY+(H/2)-1, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
end )

usermessage.Hook("_Notify", function( msg )
    local txt = msg:ReadString()
    GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())
    surface.PlaySound("buttons/lightswitch2.wav")

    -- Log to client console
    MsgC(Color(255, 20, 20, 255), "[DarkRP] ", Color(200, 200, 200, 255), txt, "\n")
end )