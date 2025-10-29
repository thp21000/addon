local ScreenPos = ScrH()*0.75

local IconImage = {}
IconImage[ NOTIFY_GENERIC ] = DarkRPFoundation.MATERIALS.NotifyMat_Generic
IconImage[ NOTIFY_ERROR ] = DarkRPFoundation.MATERIALS.NotifyMat_Error
IconImage[ NOTIFY_UNDO ] = DarkRPFoundation.MATERIALS.NotifyMat_Undo
IconImage[ NOTIFY_HINT ] = DarkRPFoundation.MATERIALS.NotifyMat_Hint
IconImage[ NOTIFY_CLEANUP ] = DarkRPFoundation.MATERIALS.NotifyMat_Cleanup

local Notifications = {}

local function DrawNotification( k, x, y, w, h, text, icon, progress, length )
	-- BACK BAR --
	DarkRPFoundation.DRAW.ThemedBox( x, y - 35, w, h, 5 )
	
	if( DarkRPFoundation.CONFIG.HUD.TimeleftNotifications == true ) then
		if( Notifications[k] ) then
			local TimePercent = math.Clamp( 1-((Notifications[k].time-CurTime())/length), 0, 1 )
			surface.SetDrawColor( 157, 157, 157, 255 )
			surface.DrawRect( x+31, y - 35+1, (w-(31)-1)*TimePercent, 4 )
		end
	end
	
	-- ICON --
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawRect( x+31, y - 35, 1, h )
	
	surface.SetDrawColor( 167, 167, 167, 150 )
	surface.DrawRect( x+1, (y - 35)+1, 30, 30 )	

	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.SetMaterial( icon )

	if progress then
		surface.DrawTexturedRectRotated( x + 16, (y - 35) + h / 2, 16, 16, -CurTime() * 360 % 360 )
	else
		surface.DrawTexturedRect( x + 8, (y - 35) + 8, 16, 16 )
	end
	
	-- TEXT --
	draw.SimpleText( string.upper(text), "TargetID", x + 35 + 5, (y - 34) + h / 2, Color( 255, 255, 255, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
end

--[[ NOTIFICATION FUNCTIONS ]]--
function notification.AddLegacy( text, type, time )
	surface.SetFont( "TargetID" )

	local w = 0
	w = (surface.GetTextSize( string.upper(text) ) + 5 + 45)
	
	local h = 32
	local x = ScrW()
	local y = ScreenPos

	table.insert( Notifications, 1, {
		x = x,
		y = y,
		w = w,
		h = h,

		text = string.upper(text),
		icon = IconImage[ type ],
		time = CurTime() + time,
		length = time,

		progress = false,
	} )
	
	local NotLimit = 5
	if( #Notifications > NotLimit ) then
		for i = NotLimit+1, #Notifications do
			if( Notifications[i] ) then
				Notifications[i] = nil
			end
		end
	end
end

function notification.AddProgress( id, text )
	surface.SetFont( "TargetID" )

	local w = 0
	w = (surface.GetTextSize( string.upper(text) ) + 5 + 45)
	
	local h = 32
	local x = ScrW()
	local y = ScreenPos
	table.insert( Notifications, 1, {
		x = x,
		y = y,
		w = w,
		h = h,

		id = id,
		text = string.upper(text),
		icon = DarkRPFoundation.MATERIALS.NotifyMat_Loading,
		time = math.huge,

		progress = true,
	} )	
end

function notification.Kill( id )
	for k, v in ipairs( Notifications ) do
		if v.id == id then v.time = 0 end
	end
end

hook.Add( "HUDPaint", "DarkRPFoundationHooks_HUDPaint_Notifications", function()
	for k, v in ipairs( Notifications ) do
		DrawNotification( k, math.floor( v.x ), math.floor( v.y ), v.w, v.h, v.text, v.icon, v.progress, v.length )

		v.x = Lerp( FrameTime() * 10, v.x, v.time > CurTime() and ScrW() - v.w - 10 or ScrW() + 1 )
		v.y = Lerp( FrameTime() * 10, v.y, ScreenPos - ( k - 1 ) * ( v.h + 5 ) )
	end

	for k, v in ipairs( Notifications ) do
		if v.x >= ScrW() and v.time < CurTime() then
			table.remove( Notifications, k )
		end
	end
end )