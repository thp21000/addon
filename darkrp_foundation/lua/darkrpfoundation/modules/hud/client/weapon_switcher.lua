--[[ Config ]]--
local MAX_SLOTS = 6
local CACHE_TIME = 1
local MOVE_SOUND = "Player.WeaponSelectionMoveSlot"
local SELECT_SOUND = "Player.WeaponSelected"

--[[ Instance variables ]]--
local iCurSlot = 0 -- Currently selected slot. 0 = no selection
local iCurPos = 1 -- Current position in that slot
local flNextPrecache = 0 -- Time until next precache
local flSelectTime = 0 -- Time the weapon selection changed slot/visibility states. Can be used to close the weapon selector after a certain amount of idle time
local iWeaponCount = 0 -- Total number of weapons on the player

-- Weapon cache; table of tables. tCache[Slot + 1] contains a table containing that slot's weapons. Table's length is tCacheLength[Slot + 1]
local tCache = {}

-- Weapon cache length. tCacheLength[Slot + 1] will contain the number of weapons that slot has
local tCacheLength = {}

--[[ Weapon switcher ]]--
local MatTable = {}
local function GetWepMat( Mat )
	if( not MatTable[Mat] ) then
		MatTable[Mat] = Material( Mat )
	else
		return MatTable[Mat]
	end
	
	return MatTable[Mat]
end

local function ResizeWepMat( w, h, requiredW, requiredH )
	local newWidth, newHeight = w, h
	if( w <= requiredW ) then
		newWidth = w;
	end

	newHeight = h * newWidth / w

	if( newHeight > requiredH ) then
		newWidth = w * requiredH / h
		newHeight = requiredH
	end

	return newWidth, newHeight
end

local HL2Icons = {}
HL2Icons["weapon_357"] = 'e'
HL2Icons["weapon_annabelle"] = 'b'
HL2Icons["weapon_ar2"] = 'l'
HL2Icons["weapon_bugbait"] = 'j'
HL2Icons["weapon_crossbow"] = 'g'
HL2Icons["weapon_crowbar"] = 'c'
HL2Icons["weapon_frag"] = 'k'
HL2Icons["weapon_physcannon"] = 'm'
HL2Icons["weapon_physgun"] = 'h'
HL2Icons["weapon_pistol"] = 'd'
HL2Icons["weapon_rpg"] = 'i'
HL2Icons["weapon_shotgun"] = 'b'
HL2Icons["weapon_smg1"] = 'a'
HL2Icons["weapon_stunstick"] = 'n'
HL2Icons["weapon_slam"] = 'o'

local stockIcon = Material( "weapons/swep" )
local function DrawWeaponIcon( X, Y, W, H, Wep )
	if( HL2Icons[Wep:GetClass()] ) then
		local letter = HL2Icons[Wep:GetClass()]
		draw.SimpleText( letter, "DarkRPFoundation_FontHL2", X+(W/2), Y+(H/2), Color( 222, 223, 124 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	elseif( IsMounted( "cstrike" ) and Wep.IconLetter != nil and Wep.IconLetter != "" ) then
		draw.SimpleText( Wep.IconLetter, "DarkRPFoundation_FontCStrike", X+(W/2), Y+(H/2)-(H/4), Color( 222, 223, 124 ), TEXT_ALIGN_CENTER, 0 )
	else
		if( Wep.WepSelectIcon or Wep.Icon or Wep.SelectIcon ) then
			local icon = nil
			local iconW, iconH = 0, 0
			if( Wep.SelectIcon ) then
				icon = Wep.SelectIcon
			elseif( Wep.Icon ) then
				icon = Wep.Icon
			else
				icon = Wep.WepSelectIcon
			end
			
			if( type( icon ) == "IMaterial" ) then
				surface.SetMaterial( icon )
				iconW, iconH = icon:Width(), icon:Height()
			elseif( type( icon ) == "number" ) then
				surface.SetTexture( icon )
				iconW, iconH = surface.GetTextureSize( icon )
			elseif( type( icon ) == "string" ) then
				local mat = GetWepMat( icon )
				surface.SetMaterial( mat )
				iconW, iconH = mat:Width(), mat:Height()
			else

			end
			
			iconW, iconH = ResizeWepMat( iconW, iconH, W, H )
			
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawTexturedRect( X, Y, W, H )
		else
			local iconW, iconH = stockIcon:Width(), stockIcon:Height()
			iconW, iconH = ResizeWepMat( iconW, iconH, W, H )
			
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( stockIcon )
			surface.DrawTexturedRect( X, Y, W, H )
		end
	end			
end

local function DrawWeaponHUD()
	local X, Y = 5, 28-1+5+1
	local HeaderW, HeaderH = ScrW()*0.085, 50
	local HeaderExW = ScrW()*0.15
	local HeaderSpacing = 5	
	local SlotW, SlotH = HeaderExW, 50
	local SlotExH = 150
	local SlotSpacing = 5
	
	for i = 1, MAX_SLOTS do
		if( iCurSlot == i ) then
			local SlotX, SlotY = (X + (HeaderW+HeaderSpacing) * i - (HeaderW+HeaderSpacing)), Y
			DarkRPFoundation.DRAW.ThemedBox( SlotX, SlotY, HeaderExW, HeaderH, 5 )
			surface.SetDrawColor( 167, 167, 167, 150 )
			surface.DrawRect( SlotX+1, SlotY+1, HeaderH-2, HeaderH-2 )	
			draw.SimpleText(string.upper(i), "DarkRPFoundation_FontTID26", SlotX+1+((HeaderH-2)/2), SlotY+1+((HeaderH-2)/2), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText( DRPF_Functions.L( "hudWeapons" ), "DarkRPFoundation_Font22", (SlotX+1)+(HeaderH-2)+((HeaderExW-(HeaderH-2))/2), SlotY+(HeaderH/2), Color( 222, 223, 124 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			local SlotX, SlotY = (X + (HeaderW+HeaderSpacing) * i - (HeaderW+HeaderSpacing)), Y
			if( iCurSlot < i ) then
				SlotX = SlotX-HeaderW+HeaderExW
			end
			DarkRPFoundation.DRAW.ThemedBox( SlotX, SlotY, HeaderW, HeaderH, 5 )
			draw.SimpleText( DRPF_Functions.L( "hudWeapons" ), "DarkRPFoundation_Font22", SlotX+HeaderW/2, SlotY+(HeaderH/2), Color( 222, 223, 124 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

	local tWeapons = tCache[iCurSlot]

	for i = 1, tCacheLength[iCurSlot] do
		local wep = tWeapons[i]
		if( IsValid( wep ) ) then
			if( iCurPos == i ) then
				-- CURRENT WEAPON --
				local SlotX, SlotY = (X + (HeaderW+HeaderSpacing) * iCurSlot - (HeaderW+HeaderSpacing)), (Y + HeaderH) + ((SlotH+SlotSpacing)* i)-(SlotH)
				DarkRPFoundation.DRAW.ThemedBox( SlotX, SlotY, SlotW, SlotExH, SlotExH )
				draw.SimpleText( string.upper( wep:GetPrintName() ), "DarkRPFoundation_Font18", SlotX+5, SlotY+SlotExH-3, color_white, 0, TEXT_ALIGN_BOTTOM)
				if( wep:Clip1() > -1 ) then
					draw.SimpleText( wep:Clip1() .. " / " .. LocalPlayer():GetAmmoCount( wep:GetPrimaryAmmoType() ), "DarkRPFoundation_FontTID25", SlotX+5, SlotY+SlotExH-3-15, Color( 222, 223, 124 ), 0, TEXT_ALIGN_BOTTOM)
				end
				
				DrawWeaponIcon( SlotX+10, SlotY+25, SlotW-20, SlotExH-50, wep )
			else
				local SlotX, SlotY = (X + (HeaderW+HeaderSpacing) * iCurSlot - (HeaderW+HeaderSpacing)), (Y + HeaderH) + ((SlotH+SlotSpacing)* i)-(SlotH)
				if( iCurPos < i ) then
					SlotY = SlotY-SlotH+SlotExH
				end
				DarkRPFoundation.DRAW.ThemedBox( SlotX, SlotY, SlotW, SlotH, 5 )
				draw.SimpleText( string.upper( wep:GetPrintName() ), "DarkRPFoundation_Font18", SlotX+5, SlotY+SlotH-3, color_white, 0, TEXT_ALIGN_BOTTOM)
				if( wep:Clip1() > -1 ) then
					draw.SimpleText( wep:Clip1() .. " / " .. LocalPlayer():GetAmmoCount( wep:GetPrimaryAmmoType() ), "DarkRPFoundation_FontTID25", SlotX+5, SlotY+SlotH-3-15, Color( 222, 223, 124 ), 0, TEXT_ALIGN_BOTTOM)
				end
			end
		end
	end
end

--[[ Implementation ]]--

-- Initialize tables with slot number
for i = 1, MAX_SLOTS do
	tCache[i] = {}
	tCacheLength[i] = 0
end

-- Hide the default weapon selection
hook.Add("HUDShouldDraw", "DarkRPFoundationHooks_HUDShouldDraw_WeaponSelection", function(sName)
	if (sName == "CHudWeaponSelection") then
		return false
	end
end)

local function PrecacheWeps()
	-- Reset all table values
	for i = 1, MAX_SLOTS do
		for j = 1, tCacheLength[i] do
			tCache[i][j] = nil
		end

		tCacheLength[i] = 0
	end

	-- Update the cache time
	flNextPrecache = RealTime() + CACHE_TIME
	iWeaponCount = 0

	-- Discontinuous table
	for _, pWeapon in pairs(LocalPlayer():GetWeapons()) do
		iWeaponCount = iWeaponCount + 1

		-- Weapon slots start internally at "0"
		-- Here, we will start at "1" to match the slot binds
		local iSlot = pWeapon:GetSlot() + 1

		if (iSlot <= MAX_SLOTS) then
			-- Cache number of weapons in each slot
			local iLen = tCacheLength[iSlot] + 1
			tCacheLength[iSlot] = iLen
			tCache[iSlot][iLen] = pWeapon
		end
	end

	-- Make sure we're not pointing out of bounds
	if (iCurSlot ~= 0) then
		local iLen = tCacheLength[iCurSlot]

		if (iLen < iCurPos) then
			if (iLen == 0) then
				iCurSlot = 0
			else
				iCurPos = iLen
			end
		end
	end
end

local cl_drawhud = GetConVar("cl_drawhud")

hook.Add("HUDPaint", "DarkRPFoundationHooks_HUDPaint_WeaponSelector", function()
	if (iCurSlot == 0 or not cl_drawhud:GetBool()) then
		return
	end

	local pPlayer = LocalPlayer()

	-- Don't draw in vehicles unless weapons are allowed to be used
	-- Or while dead!
	if (pPlayer:IsValid() and pPlayer:Alive() and pPlayer:KeyDown( IN_ATTACK ) != true and (not pPlayer:InVehicle() or pPlayer:GetAllowWeaponsInVehicle())) then
		if (flNextPrecache <= RealTime()) then
			PrecacheWeps()
		end

		DrawWeaponHUD()
	else
		iCurSlot = 0
	end
end)

hook.Add("PlayerBindPress", "DarkRPFoundationHooks_PlayerBindPress_WeaponSelector", function(pPlayer, sBind, bPressed)
	if (not pPlayer:Alive() or pPlayer:InVehicle() and not pPlayer:GetAllowWeaponsInVehicle()) then
		return
	end

	sBind = string.lower(sBind)

	-- Close the menu
	if (sBind == "cancelselect") then
		if (bPressed) then
			iCurSlot = 0
		end

		return true
	end

	-- Move to the weapon before the current
	if (sBind == "invprev") then
		iWepSelectClose = CurTime()+DarkRPFoundation.CONFIG.HUD.WeaponSelectClose
		
		if (not bPressed) then
			return true
		end

		PrecacheWeps()

		if (iWeaponCount == 0) then
			return true
		end

		local bLoop = iCurSlot == 0

		if (bLoop) then
			local pActiveWeapon = pPlayer:GetActiveWeapon()

			if (pActiveWeapon:IsValid()) then
				local iSlot = pActiveWeapon:GetSlot() + 1
				local tSlotCache = tCache[iSlot]

				if (tSlotCache[1] ~= pActiveWeapon) then
					iCurSlot = iSlot
					iCurPos = 1

					for i = 2, tCacheLength[iSlot] do
						if (tSlotCache[i] == pActiveWeapon) then
							iCurPos = i - 1

							break
						end
					end

					flSelectTime = RealTime()
					pPlayer:EmitSound(MOVE_SOUND)

					return true
				end

				iCurSlot = iSlot
			end
		end

		if (bLoop or iCurPos == 1) then
			repeat
				if (iCurSlot <= 1) then
					iCurSlot = MAX_SLOTS
				else
					iCurSlot = iCurSlot - 1
				end
			until(tCacheLength[iCurSlot] ~= 0)

			iCurPos = tCacheLength[iCurSlot]
		else
			iCurPos = iCurPos - 1
		end

		flSelectTime = RealTime()
		pPlayer:EmitSound(MOVE_SOUND)

		return true
	end

	-- Move to the weapon after the current
	if (sBind == "invnext") then
		iWepSelectClose = CurTime()+DarkRPFoundation.CONFIG.HUD.WeaponSelectClose
		if (not bPressed) then
			return true
		end

		PrecacheWeps()

		-- Block the action if there aren't any weapons available
		if (iWeaponCount == 0) then
			return true
		end

		-- Lua's goto can't jump between child scopes
		local bLoop = iCurSlot == 0

		-- Weapon selection isn't currently open, move based on the active weapon's position
		if (bLoop) then
			local pActiveWeapon = pPlayer:GetActiveWeapon()

			if (pActiveWeapon:IsValid()) then
				local iSlot = pActiveWeapon:GetSlot() + 1
				local iLen = tCacheLength[iSlot]
				local tSlotCache = tCache[iSlot]

				if (tSlotCache[iLen] ~= pActiveWeapon) then
					iCurSlot = iSlot
					iCurPos = 1

					for i = 1, iLen - 1 do
						if (tSlotCache[i] == pActiveWeapon) then
							iCurPos = i + 1

							break
						end
					end

					flSelectTime = RealTime()
					pPlayer:EmitSound(MOVE_SOUND)

					return true
				end

				-- At the end of a slot, move to the next one
				iCurSlot = iSlot
			end
		end

		if (bLoop or iCurPos == tCacheLength[iCurSlot]) then
			-- Loop through the slots until one has weapons
			repeat
				if (iCurSlot == MAX_SLOTS) then
					iCurSlot = 1
				else
					iCurSlot = iCurSlot + 1
				end
			until(tCacheLength[iCurSlot] ~= 0)

			-- Start at the beginning of the new slot
			iCurPos = 1
		else
			-- Bump up the position
			iCurPos = iCurPos + 1
		end

		flSelectTime = RealTime()
		pPlayer:EmitSound(MOVE_SOUND)

		return true
	end

	-- Keys 1-6
	if (sBind:sub(1, 4) == "slot") then
		local iSlot = tonumber(sBind:sub(5))

		-- If the command is slot#, use it for the weapon HUD
		-- Otherwise, let it pass through to prevent false positives
		if (iSlot == nil) then
			return
		end

		if (not bPressed) then
			return true
		end

		PrecacheWeps()

		-- Play a sound even if there aren't any weapons in that slot for "haptic" (really auditory) feedback
		if (iWeaponCount == 0) then
			pPlayer:EmitSound(MOVE_SOUND)

			return true
		end

		-- If the slot number is in the bounds
		if (iSlot <= MAX_SLOTS) then
			-- If the slot is already open
			if (iSlot == iCurSlot) then
				-- Start back at the beginning
				if (iCurPos == tCacheLength[iCurSlot]) then
					iCurPos = 1
				-- Move one up
				else
					iCurPos = iCurPos + 1
				end
			-- If there are weapons in this slot, display them
			elseif (tCacheLength[iSlot] ~= 0) then
				iCurSlot = iSlot
				iCurPos = 1
			end

			flSelectTime = RealTime()
			pPlayer:EmitSound(MOVE_SOUND)
		end

		return true
	end

	-- If the weapon selection is currently open
	if (iCurSlot ~= 0) then
		if (sBind == "+attack") then
			-- Hide the selection
			local pWeapon = tCache[iCurSlot][iCurPos]
			iCurSlot = 0

			-- If the weapon still exists and isn't the player's active weapon
			if (pWeapon:IsValid() and pWeapon ~= pPlayer:GetActiveWeapon()) then
				input.SelectWeapon(pWeapon)
			end

			flSelectTime = RealTime()
			pPlayer:EmitSound(SELECT_SOUND)

			return true
		end

		-- Another shortcut for closing the selection
		if (sBind == "+attack2") then
			flSelectTime = RealTime()
			iCurSlot = 0

			return true
		end
		
	end
end)

hook.Add( "Think", "DarkRPFoundationHooks_Think_WeaponSelector", function()
	if( LocalPlayer():IsValid() and LocalPlayer():Alive() and LocalPlayer():KeyDown( IN_ATTACK ) != true and (not LocalPlayer():InVehicle() or LocalPlayer():GetAllowWeaponsInVehicle())) then
		if( iWepSelectClose ) then
			if( CurTime() >= iWepSelectClose and iWepSelectClose > 0 ) then
				iCurSlot = 0
				iWepSelectClose = 0
			end
		end
	end
end )
