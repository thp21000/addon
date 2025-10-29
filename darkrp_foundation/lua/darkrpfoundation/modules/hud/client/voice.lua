local AlphaFade = 0
local TxtAlphaFade = 0

local W, H = ScrW()*0.1, 30
local X, Y = (ScrW()/2)-(W/2), 40
hook.Add( "HUDPaint", "DarkRPFoundationHooks_HUDPaint_VoiceChat", function()
	if( LocalPlayer():IsSpeaking() == true ) then
		AlphaFade = math.min( AlphaFade + 6, 255 )
	else
		AlphaFade = math.max( AlphaFade - 6, 0 )
	end
	

	DarkRPFoundation.DRAW.ThemedBox( X, Y, W, H, 5, AlphaFade )		
	
	-- ICON --
	DarkRPFoundation.DRAW.IconBox( X+1, Y+1, H-2, H-2, DarkRPFoundation.MATERIALS.VoiceMat, 4, AlphaFade )
	
	-- TEXT --
	draw.SimpleText( DRPF_Functions.L( "hudTalking" ), "DarkRPFoundation_Font21", (X+1+H-2)+((W-H-2)/2), Y+(H/2), Color( 255, 255, 255, AlphaFade ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end )