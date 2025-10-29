function DRPF_Functions.GetInvTypeCFG( Class )
	if(DarkRPFoundation.INVENTORY_FUNCS.EntTypes[Class] ) then
		return DarkRPFoundation.INVENTORY_FUNCS.EntTypes[Class]
	else
		for k, v in pairs(DarkRPFoundation.INVENTORY_FUNCS.EntTypes ) do
			if( string.EndsWith( k, "*" ) ) then
				local Starter = string.Replace( k, "*", "" )
				if( string.StartWith( Class, Starter ) ) then
					return DarkRPFoundation.INVENTORY_FUNCS.EntTypes[k]
				end
			end
		end
		return DarkRPFoundation.INVENTORY_FUNCS.DefaultEntFuncs
	end
end

if( SERVER ) then
	local plyMeta = FindMetaTable( "Player" )
	
	util.AddNetworkString( "DarkRPFoundationNet_SendInventory" )
	function plyMeta:DRPF_InventoryUpdate()
		net.Start( "DarkRPFoundationNet_SendInventory" )
			net.WriteTable( self:DRPF_InventoryGet() )
		net.Send( self )
	end
	
	function plyMeta:DRPF_InventorySet( InvTable, nosave )
		self.DRPFInventory = InvTable
		
		self:DRPF_InventoryUpdate()
		
		if( not nosave ) then
			self:DRPF_InventorySaveData()
		end
	end	
	
	function plyMeta:DRPF_InventoryGet()
		return self.DRPFInventory
	end	
	
	function plyMeta:DRPF_InventorySaveData()
		if( timer.Exists( self:SteamID64() .. "_drpf_timer_saveinventory" ) ) then
			timer.Remove( self:SteamID64() .. "_drpf_timer_saveinventory" )
		end
	
		timer.Create( self:SteamID64() .. "_drpf_timer_saveinventory", 5, 1, function()
			if( IsValid( self ) ) then
				local Inventory = self:DRPF_InventoryGet()
				if( Inventory != nil ) then
					if( not istable( Inventory ) ) then
						Inventory = {}
					end
				else
					Inventory = {}
				end
				
				local InventoryJSON = util.TableToJSON( Inventory )
				
				if( DarkRPFoundation.CONFIG.GENERAL.UseMySQL != true ) then
					if( not file.Exists( "darkrpfoundation/inventory", "DATA" ) ) then
						file.CreateDir( "darkrpfoundation/inventory" )
					end
					
					file.Write( "darkrpfoundation/inventory/" .. self:SteamID64() .. ".txt", InventoryJSON )
				else
					self:DRPF_UpdateDBValue( "inventory", InventoryJSON )
				end
			end
		end )
	end
	
	--[[ SAVING/LOADING ]]--
	hook.Add( "PlayerInitialSpawn", "DarkRPFoundationHooks_PlayerInitialSpawn_InventoryLoad", function( ply )
		local InvTable = {}
	
		if( DarkRPFoundation.CONFIG.GENERAL.UseMySQL != true ) then
			if( file.Exists( "darkrpfoundation/inventory/" .. ply:SteamID64() .. ".txt", "DATA" ) ) then
				local FileTable = file.Read( "darkrpfoundation/inventory/" .. ply:SteamID64() .. ".txt", "DATA" )
				FileTable = util.JSONToTable( FileTable )
				
				if( FileTable != nil ) then
					if( istable( FileTable ) ) then
						InvTable = FileTable
					end
				end
			end
			
			ply:DRPF_InventorySet( InvTable, true )
		else
			ply:DRPF_FetchDBValue( "inventory", function( inventory )
				local InventoryTable = util.JSONToTable( inventory or "" )

				if( InventoryTable != nil ) then
					if( istable( InventoryTable ) ) then
						InvTable = InventoryTable
					end
				end
				
				ply:DRPF_InventorySet( InvTable, true )
			end )
		end
	end )
	
	--[[ ADDING/REMOVING ]]--
	local function CanPickupItem( ItemEntity )
		if( DarkRPFoundation.CONFIG.INVENTORY.ListType == "Blacklist" ) then
			if( table.HasValue( DarkRPFoundation.CONFIG.INVENTORY.ListEntries, ItemEntity:GetClass() ) ) then
				return false
			end
		else
			if( not table.HasValue( DarkRPFoundation.CONFIG.INVENTORY.ListEntries, ItemEntity:GetClass() ) ) then
				return false
			end
		end
		
		return true
	end
	
	function plyMeta:DRPF_InventoryAddEnt( ItemEntity )
		if( IsValid( ItemEntity ) ) then
			if( CanPickupItem( ItemEntity ) ) then
				if( DRPF_Functions.GetInvTypeCFG( ItemEntity:GetClass() ).OnPickup ) then
					DRPF_Functions.GetInvTypeCFG( ItemEntity:GetClass() ).OnPickup( self, ItemEntity )
				else
					DarkRPFoundation.INVENTORY_FUNCS.DefaultEntFuncs.OnPickup( self, ItemEntity )
				end
				ItemEntity:Remove()
			end
		end
	end	
	
	function plyMeta:DRPF_InventoryInsertItem( ItemTable )
		local InvTable = self:DRPF_InventoryGet()
		
		for i = 1, #InvTable do
			if( not InvTable[i] ) then
				InvTable[i] = ItemTable
				self:DRPF_InventorySet( InvTable )
				return
			end
		end
		
		table.insert( InvTable, ItemTable )
		self:DRPF_InventorySet( InvTable )
	end
	
	--[[ INVENTORY MANAGEMENT ]]--
	util.AddNetworkString( "DarkRPFoundationNet_InventoryMoveItem" )
	net.Receive( "DarkRPFoundationNet_InventoryMoveItem", function( len, ply )
		local SlotFrom = net.ReadInt( 32 )
		local SlotTo = net.ReadInt( 32 )
		
		if( not SlotFrom or not SlotTo ) then return end
		if( not IsValid( ply ) ) then return end
		
		local InvTable = ply:DRPF_InventoryGet()
		
		if( InvTable[SlotFrom] and not InvTable[SlotTo] ) then
			InvTable[SlotTo] = InvTable[SlotFrom]
			InvTable[SlotFrom] = nil
			
			ply:DRPF_InventorySet( InvTable )
		end
	end )
	
	util.AddNetworkString( "DarkRPFoundationNet_InventoryDropItem" )
	net.Receive( "DarkRPFoundationNet_InventoryDropItem", function( len, ply )
		local ItemSlot = net.ReadInt( 32 )
		
		if( not ItemSlot ) then return end
		if( not IsValid( ply ) ) then return end
		
		local InvTable = ply:DRPF_InventoryGet()
		
		if( InvTable[ItemSlot] ) then
			local PlacePos = ply:GetPos()+(ply:GetForward()*30)
			if( DRPF_Functions.GetInvTypeCFG( InvTable[ItemSlot].Class ).OnSpawn ) then
				DRPF_Functions.GetInvTypeCFG( InvTable[ItemSlot].Class ).OnSpawn( ply, PlacePos, InvTable[ItemSlot] )
			else
				DarkRPFoundation.INVENTORY_FUNCS.DefaultEntFuncs.OnSpawn( ply, PlacePos, InvTable[ItemSlot] )
			end
			InvTable[ItemSlot] = nil
			ply:DRPF_InventorySet( InvTable )
		end
	end )
	
	--[[ INVENTORY SWEP ]]--
	hook.Add( "PlayerLoadout", "DarkRPFoundationHooks_PlayerLoadout_InventorySWEP", function( ply )
		if( IsValid( ply ) ) then
			ply:Give( "drpf_inventorypickup" )
		end
	end )
end

if( CLIENT ) then
	net.Receive( "DarkRPFoundationNet_SendInventory", function()
		local InvTable = net.ReadTable()
		
		DRPFINVENTORY_Table = InvTable
		
		if( IsValid( DRPF_InventoryMenu_MainPanel ) ) then
			DRPF_InventoryMenu_MainPanel:FillInventory( DRPF_InventoryMenu_MainPanel.ActivePage or 1 )
		end
	end )
end