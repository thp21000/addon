AddCSLuaFile()

if CLIENT then
    SWEP.PrintName = DRPF_Functions.L( "inventoryWeaponsName" )
    SWEP.Slot = 1
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = true
end

-- Variables that are used on both client and server

SWEP.Author = "BrickWall"
SWEP.Instructions = DRPF_Functions.L( "inventoryWeaponsInfo" )
SWEP.Contact = ""
SWEP.Purpose = "Use inventory"

SWEP.ViewModel = Model( "" ) -- just change the model 
SWEP.WorldModel = ( "" )
SWEP.ViewModelFOV = 85
SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "DarkRP Foundation"

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = -1     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false        -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""

--[[-------------------------------------------------------
Name: SWEP:Initialize()
Desc: Called when the weapon is first loaded
---------------------------------------------------------]]
function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:SetupDataTables()

end

--[[-------------------------------------------------------
Name: SWEP:PrimaryAttack()
Desc: +attack1 has been pressed
---------------------------------------------------------]]
local BlacklistedEnts = {}
BlacklistedEnts["func_door"] = true
BlacklistedEnts["func_door_rotating"] = true
BlacklistedEnts["prop_door_rotating"] = true
BlacklistedEnts["prop_door_rotating"] = true
BlacklistedEnts["func_breakable_surf"] = true
BlacklistedEnts["prop_dynamic"] = true

function SWEP:CanPickupItem()
	local ply = self.Owner
	
	if( not IsValid( ply ) ) then return false end 
	
	local TraceEntity = ply:GetEyeTrace().Entity
	
	if( not IsValid( TraceEntity ) ) then return false end
	if( TraceEntity:IsPlayer() ) then return false end
	
	if( DarkRPFoundation.CONFIG.INVENTORY.ListType == "Blacklist" ) then
		if( table.HasValue( DarkRPFoundation.CONFIG.INVENTORY.ListEntries, TraceEntity:GetClass() ) ) then
			return false
		end
	else
		if( not table.HasValue( DarkRPFoundation.CONFIG.INVENTORY.ListEntries, TraceEntity:GetClass() ) ) then
			return false
		end
	end
	
	local InvTable = {}
	if( CLIENT ) then InvTable = DRPFINVENTORY_Table else InvTable = ply:DRPF_InventoryGet() end
	if( InvTable ) then
		if( table.Count( InvTable ) >= (DarkRPFoundation.CONFIG.INVENTORY.InvWidth*DarkRPFoundation.CONFIG.INVENTORY.InvHeight)*DarkRPFoundation.CONFIG.INVENTORY.InvPages ) then
			return false
		end
	end
	
	return true
end

function SWEP:PrimaryAttack()
	if( SERVER ) then
		local ply = self.Owner
		
		if( not self:CanPickupItem() ) then return end 
		
		local TraceEntity = ply:GetEyeTrace().Entity
		
		if( IsValid( TraceEntity ) ) then
			ply:DRPF_InventoryAddEnt( TraceEntity )
		end
	end
end

function SWEP:Holster()
	return true
end

function SWEP:Think()

end

function SWEP:SecondaryAttack()
	if( CLIENT ) then
		if( not IsValid( DRPF_InventoryMenu ) ) then
			DRPF_InventoryMenu = vgui.Create( "DFrame" )
			DRPF_InventoryMenu:SetSize( ScrW(), ScrH() )
			DRPF_InventoryMenu:Center()
			DRPF_InventoryMenu:MakePopup()
			DRPF_InventoryMenu:SetTitle( "" )
			DRPF_InventoryMenu:ShowCloseButton( false )
			DRPF_InventoryMenu:SetDraggable( false )
			DRPF_InventoryMenu.Paint = function() end
			
			DRPF_InventoryMenu_MainPanel = vgui.Create( "drpf_inventory_main", DRPF_InventoryMenu )
		else
			DRPF_InventoryMenu:SetVisible( true )
		end
	end
end

