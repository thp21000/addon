local TextColor = Color( 255,255,255,150 )
local BackColor = Color( 0, 0, 0, 100 )

local Notifications = {}

local AlphaFade = 0
local AlphaFadeOuter = 0
local AlphaFadeText = 0
local function DrawNotification( x, y, w, h, text, col, reason )
	AlphaFade = math.min( AlphaFade + 3, 210 )
	AlphaFadeOuter = math.min( AlphaFadeOuter + 3, 255 )
	AlphaFadeText = math.min( AlphaFadeText + 3, 150 )
	
	surface.SetDrawColor( 0, 0, 0, AlphaFade )
	surface.DrawRect((x/2)-(w/2), y, w, h)
	
	surface.SetDrawColor( Color( 0, 0, 0, AlphaFadeOuter ) )
	surface.DrawOutlinedRect( (x/2)-(w/2), y, w, h )			

	draw.SimpleText( string.upper(text), "LevelingHUD_TargetID", (x/2), y+(h/2), Color( 255, 255, 255, AlphaFadeText ),TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	
	surface.SetFont( "LevelingHUD_TargetIDSmall" )
	local reasonX, reasonY = surface.GetTextSize( reason )
	reasonX = reasonX+20
	reasonY = reasonY+3
	
	surface.SetDrawColor( 0, 0, 0, AlphaFade )
	surface.DrawRect((x/2)-(w/2), y+h+1, w, reasonY)
	
	surface.SetDrawColor( Color( 0, 0, 0, AlphaFadeOuter ) )
	surface.DrawOutlinedRect( (x/2)-(w/2), y+h+1, w, reasonY )	
	
	draw.SimpleText( string.upper(reason), "LevelingHUD_TargetIDSmall", (x/2), y+h+1+(reasonY/2), Color( 255, 255, 255, AlphaFadeText ),TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

local function LevelingNotifyRepeat( x, y, w, h, txt, inputtime, reason )
	if( !Notifications[1] ) then
		table.insert( Notifications, 1, {
			x = x,
			y = y,
			w = w,
			h = h,

			text = txt,
			time = CurTime() + inputtime,
			col = Color( 255,255,255,240 ),
			reasontxt = reason
		} )
	else
		timer.Simple( inputtime, function()
			LevelingNotifyRepeat( x, y, w, h, txt, inputtime, reason )
		end )
	end
end

local function LevelingAddNotify( txt, time, reason )

	local w = 0
	surface.SetFont( "LevelingHUD_TargetIDSmall" )
	local reasonX = (surface.GetTextSize( reason ) + 10 )
	surface.SetFont( "LevelingHUD_TargetID" )
	local txtX = (surface.GetTextSize( txt ) + 5 + 25)
	
	if( txtX > reasonX ) then
		w = txtX
	else
		w = reasonX
	end
	
	local h = 25
	local x = ScrW()
	local y = 7

	LevelingNotifyRepeat( x, y, w, h, txt, time, reason )
end

hook.Add( "HUDPaint", "DarkRPFoundationHooks_HUDPaint_LevellingNotifications", function()
	for k, v in ipairs( Notifications ) do
		DrawNotification( math.floor( v.x ), math.floor( v.y ), v.w, v.h, v.text, v.col, v.reasontxt )
	
		--v.x = Lerp( FrameTime() * 5, v.x, v.time > CurTime() and ScrW() - v.w - 10 or ScrW() + 1 )
		v.y = Lerp( FrameTime() * 5, v.y, v.y+2 )
	end

	for k, v in ipairs( Notifications ) do
		if v.x >= ScrW() and v.time < CurTime() then
			AlphaFade = 0
			AlphaFadeOuter = 0
			AlphaFadeText = 0
			table.remove( Notifications, k )
		end
	end
end )

net.Receive( "DarkRPFoundationNet_LevelNotify", function( len, pl )
	local msg = net.ReadString()
	local time = net.ReadInt( 8 )
	local reason = net.ReadString()
	LevelingAddNotify( msg, time, reason )
end )