DarkRPFoundation.INVENTORY_FUNCS = {}

DarkRPFoundation.INVENTORY_FUNCS.DefaultEntFuncs = {
	OnPickup = function( ply, ent )
		local ItemTable = {}
		ItemTable.Class = ent:GetClass()
		ItemTable.Model = ent:GetModel()
		
		ItemTable.Name = ent.PrintName or ent:GetClass()
		ItemTable.Description = "A " .. ItemTable.Name .. "."
		
		ply:DRPF_InventoryInsertItem( ItemTable )
	end,
	
	OnSpawn = function( ply, pos, itemtable )
		local ent = ents.Create( itemtable.Class )
		ent:SetPos( pos )
		ent:SetModel( itemtable.Model )
		ent:Spawn()
	end,
	
	ModelDisplay = function( Panel, itemtable )
		Panel:SetCamPos( Panel:GetCamPos()+Vector( 40, 0, 0 ) )
	end,
	
	GetDetails = function( itemtable )
		local Name = itemtable.Name or "Unknown"
		local Description = itemtable.Description or "Some description."
		return string.format( "Name: %s\nDescription: %s", Name, Description )
	end
}

DarkRPFoundation.INVENTORY_FUNCS.EntTypes = {}
DarkRPFoundation.INVENTORY_FUNCS.EntTypes["spawned_weapon"] = {
	OnPickup = function( ply, ent )
		local ItemTable = {}
		ItemTable.Class = "spawned_weapon"
		ItemTable.Model = ent:GetModel()
		
		ItemTable.WClass = ent:GetWeaponClass()
		ItemTable.IAmount = ent:Getamount()
		
		local weaponName = "Weapon"
		if( weapons.GetStored( ent:GetWeaponClass() ) ) then
			weaponName = weapons.GetStored( ent:GetWeaponClass() ).PrintName
		end
		
		ItemTable.Name = weaponName
		
		ItemTable.Description = "A shooty stick!"
		
		ply:DRPF_InventoryInsertItem( ItemTable )
	end,
	OnSpawn = function( ply, pos, itemtable )
		local ent = ents.Create( "spawned_weapon" )
		ent:SetPos( pos )
		ent:SetWeaponClass( itemtable.WClass )
		ent:Setamount( itemtable.IAmount )
		ent:SetModel( itemtable.Model )
		ent:Spawn()
	end,
	ModelDisplay = function( Panel, itemtable )
		Panel:SetCamPos( Vector( 0, 50, 5 ) )
		Panel:SetLookAng( Angle( 180, 90, 180 ) )
		function Panel:LayoutEntity( Entity ) return end
	end,
	GetDetails = function( itemtable )
		local Name = itemtable.Name or "Unknown"
		local Description = itemtable.Description or "Some description."
		local Amount = itemtable.IAmount or 1
		return string.format( "Name: %s\nDescription: %s\nAmount: %d", Name, Description, Amount )
	end
}

DarkRPFoundation.INVENTORY_FUNCS.EntTypes["spawned_shipment"] = {
	OnPickup = function( ply, ent )
		local ItemTable = {}
		ItemTable.Class = "spawned_shipment"
		ItemTable.Model = ent:GetModel()
		
		ItemTable.WClass = CustomShipments[ent:Getcontents()].entity
		ItemTable.SContents = ent:Getcontents()
		ItemTable.IAmount = ent:Getcount()
		
		local weaponName = "Weapon Shipment"
		if( CustomShipments[ent:Getcontents()] ) then
			weaponName = CustomShipments[ent:Getcontents()].name
		end
		
		ItemTable.Name = weaponName
		
		ItemTable.Description = "A shipment of '" .. weaponName .. "'."
		
		ply:DRPF_InventoryInsertItem( ItemTable )
	end,
	OnSpawn = function( ply, pos, itemtable )
		local ent = ents.Create( "spawned_shipment" )
		ent:SetPos( pos )
		ent:SetContents( itemtable.SContents, itemtable.IAmount )
		ent:SetModel( itemtable.Model )
		ent:Spawn()
	end,
	GetDetails = function( itemtable )
		local Name = itemtable.Name or "Unknown"
		local Description = itemtable.Description or "Some description."
		local Amount = itemtable.IAmount or 1
		return string.format( "Name: %s\nDescription: %s\nAmount: %d", Name, Description, Amount )
	end
}

DarkRPFoundation.INVENTORY_FUNCS.EntTypes["drpf_printer_*"] = {
	OnPickup = function( ply, ent )
		local ItemTable = {}
		ItemTable.Class = ent:GetClass()
		ItemTable.Model = ent:GetModel()
		
		ItemTable.PHolding = ent:GetHolding()
		ItemTable.PColor = ent:GetColor()
		ItemTable.PInk = ent:GetInk()
		ItemTable.PUpSpeed = ent:GetUpgradeSpeed()
		ItemTable.PUpAmount = ent:GetUpgradeAmount()
		ItemTable.PUpStorage = ent:GetUpgradeStorage()
		
		ItemTable.Name = ent.PrintName
		ItemTable.Description = "A " .. ent.PrintName .. "."
		
		ply:DRPF_InventoryInsertItem( ItemTable )
	end,
	OnSpawn = function( ply, pos, itemtable )
		local ent = ents.Create( itemtable.Class )
		ent:SetPos( pos )
		ent:SetModel( itemtable.Model )
		ent:Spawn()
		
		ent:SetHolding( itemtable.PHolding or 0 )
		ent:SetInk( itemtable.PInk or 0 )
		ent:InstallItem( "Upgrade Speed", itemtable.PUpSpeed or false )
		ent:InstallItem( "Upgrade Amount", itemtable.PUpAmount or false )
		ent:InstallItem( "Upgrade Storage", itemtable.PUpStorage or false )
	end,
	ModelDisplay = function( Panel, itemtable )
		Panel:SetCamPos( Panel:GetCamPos()+Vector( 40, 0, 0 ) )
		Panel:SetColor( itemtable.PColor or Color( 255, 255, 255 ) )
	end,
	GetDetails = function( itemtable )
		local Name = itemtable.Name or "Unknown"
		local Description = itemtable.Description or "Unknown"
		local Holding = DarkRP.formatMoney( itemtable.PHolding or 1 )
		local Upgrades = ""
		if( itemtable.PUpSpeed ) then
			Upgrades = Upgrades .. " Speed"
		end
		if( itemtable.PUpAmount ) then
			Upgrades = Upgrades .. " Amount"
		end
		if( itemtable.PUpStorage ) then
			Upgrades = Upgrades .. " Storage"
		end
		if( Upgrades == "" ) then
			Upgrades = " None"
		end
		
		return string.format( "Name: %s\nDescription: %s\nHolding: %s\nUpgrades:%s", Name, Description, Holding, Upgrades )
	end,
}

DarkRPFoundation.INVENTORY_FUNCS.EntTypes["drpf_printeritem_ink"] = {
	ModelDisplay = function( Panel, itemtable )
		Panel:SetCamPos( Vector( -20, 0, 0 ) )
		Panel:SetLookAng( Angle( 180, 180, 180 ) )
		function Panel:LayoutEntity( Entity ) return end
	end,
}

DarkRPFoundation.INVENTORY_FUNCS.EntTypes["drpf_printeritem_*"] = {
	ModelDisplay = function( Panel, itemtable )
		Panel:SetCamPos( Vector( 0, 0, 10 ) )
		Panel:SetLookAng( Angle( 90, 180, 0 ) )
		function Panel:LayoutEntity( Entity ) return end
	end,
}