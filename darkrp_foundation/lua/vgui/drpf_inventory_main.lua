local PANEL = {}

local SlotPaddingX = 10
local SlotPaddingY = 10
local InvBorder = 10
local PageButtonHeight = 70
local PageChangePadd = 3
local TopSecH = 135
local TypeCol = Color( 0, 0, 0, 0 )
local SidePadd = 0

function PANEL:DrawSlotEntry( Parent, SlotNum )
	if( DRPFINVENTORY_Table[SlotNum].Model ) then
		local InvSlotEntryBack = vgui.Create( "DPanel", Parent )
		InvSlotEntryBack:SetSize( self.SlotSize, self.SlotSize )
		InvSlotEntryBack:Droppable( 'invslot' )
		local function ClickEntry()
			local menu = DermaMenu()
			local btnWithIcon = menu:AddOption( DRPF_Functions.L( "drop" ), function() 
				net.Start( "DarkRPFoundationNet_InventoryDropItem" )
					net.WriteInt( SlotNum, 32 )
				net.SendToServer()
			end )
			btnWithIcon:SetIcon( "icon16/arrow_down.png" )
			menu:Open()
		end
		
		InvSlotEntryBack.DoRightClick, InvSlotEntryBack.DoClick = ClickEntry, ClickEntry
		
		local InvSlotEntry = vgui.Create( "DModelPanel", InvSlotEntryBack )
		InvSlotEntry:SetSize( self.SlotSize, self.SlotSize )
		InvSlotEntry:SetModel( DRPFINVENTORY_Table[SlotNum].Model )
		if( DRPF_Functions.GetInvTypeCFG( DRPFINVENTORY_Table[SlotNum].Class ).GetDetails ) then
			InvSlotEntry:SetTooltip( DRPF_Functions.GetInvTypeCFG( DRPFINVENTORY_Table[SlotNum].Class ).GetDetails( DRPFINVENTORY_Table[SlotNum] ) )
		else
			InvSlotEntry:SetTooltip(DarkRPFoundation.INVENTORY_FUNCS.DefaultEntFuncs.GetDetails( DRPFINVENTORY_Table[SlotNum] ) )
		end
		function InvSlotEntry:DrawModel()
			local curparent = self
			local leftx, topy = self:LocalToScreen( 0, 0 )
			local rightx, bottomy = self:LocalToScreen( self:GetWide(), self:GetTall() )
			while ( curparent:GetParent() != nil ) do
				curparent = curparent:GetParent()
				local x1, y1 = curparent:LocalToScreen( 0, 0 )
				local x2, y2 = curparent:LocalToScreen( curparent:GetWide(), curparent:GetTall() )
				leftx = math.max( leftx, x1 )
				topy = math.max( topy, y1 )
				rightx = math.min( rightx, x2 )
				bottomy = math.min( bottomy, y2 )
				previous = curparent
			end
			render.SetScissorRect( leftx, topy, rightx, bottomy, true )
			local ret = self:PreDrawModel( self.Entity )
			if ( ret != false ) then
				self.Entity:DrawModel()
				self:PostDrawModel( self.Entity )
			end
			render.SetScissorRect( 0, 0, 0, 0, false )
		end
		if( DRPF_Functions.GetInvTypeCFG( DRPFINVENTORY_Table[SlotNum].Class ).ModelDisplay ) then
			DRPF_Functions.GetInvTypeCFG( DRPFINVENTORY_Table[SlotNum].Class ).ModelDisplay( InvSlotEntry, DRPFINVENTORY_Table[SlotNum] )
		else
			DarkRPFoundation.INVENTORY_FUNCS.DefaultEntFuncs.ModelDisplay( InvSlotEntry, DRPFINVENTORY_Table[SlotNum] )
		end
		
		for k, v in pairs( InvSlotEntryBack:GetChildren() ) do
			if( not v.NoDrag ) then
				v.DoRightClick, v.DoClick = InvSlotEntryBack.DoRightClick, InvSlotEntryBack.DoClick
				v:SetDragParent( InvSlotEntryBack )
			end
		end
		
		InvSlotEntryBack.Paint = function( self2, w, h ) 
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
			surface.DrawRect( 0, 0, w, h )
		
			if( IsValid( InvSlotEntry ) ) then
				if( InvSlotEntry:IsHovered() ) then
					surface.SetDrawColor( 0, 0, 0, 50 )
					surface.DrawRect( 0, 0, w, h )
				end
			end
			
			if( DRPFINVENTORY_Table[SlotNum] ) then
				if( DRPFINVENTORY_Table[SlotNum].Class == "spawned_weapon" or DRPFINVENTORY_Table[SlotNum].Class == "spawned_shipment" ) then
					if( DarkRPFoundation.CONFIG.INVENTORY.RareityTypes.SWEPS[DRPFINVENTORY_Table[SlotNum].WClass] ) then
						TypeCol = DarkRPFoundation.CONFIG.INVENTORY.Conditions[DarkRPFoundation.CONFIG.INVENTORY.RareityTypes.SWEPS[DRPFINVENTORY_Table[SlotNum].WClass]]
					else
						TypeCol = DarkRPFoundation.CONFIG.INVENTORY.Conditions[DarkRPFoundation.CONFIG.INVENTORY.RareityTypes.DefaultSWEP]
					end
				else
					if( DarkRPFoundation.CONFIG.INVENTORY.RareityTypes.ENTS[DRPFINVENTORY_Table[SlotNum].Class] ) then
						TypeCol = DarkRPFoundation.CONFIG.INVENTORY.Conditions[DarkRPFoundation.CONFIG.INVENTORY.RareityTypes.ENTS[DRPFINVENTORY_Table[SlotNum].Class]]
					else
						TypeCol = DarkRPFoundation.CONFIG.INVENTORY.Conditions[DarkRPFoundation.CONFIG.INVENTORY.RareityTypes.DefaultENT]
					end
				end

				surface.SetDrawColor( TypeCol )
				local RareityH = 4
				surface.DrawRect( SidePadd, h-RareityH-SidePadd, w-(2*SidePadd), RareityH )
			end
		end
	else
		local InvSlotEntry = vgui.Create( "DButton", Parent )
		InvSlotEntry:SetSize( self.SlotSize, self.SlotSize )
		InvSlotEntry:SetText( "" )
		InvSlotEntry:Droppable( 'invslot' )
		InvSlotEntry.Paint = function( self2, w, h )
			if( DRPFINVENTORY_Table[SlotNum].BackCol ) then
				surface.SetAlphaMultiplier( 0.25 )
				surface.SetDrawColor( DRPFINVENTORY_Table[SlotNum].BackCol )
				surface.DrawRect( 0, 0, w, h )
				surface.SetAlphaMultiplier( 1 )
			end
		end
	end
end

function PANEL:Init()
	self.SlotSize = ((ScrW()*0.5-(SlotPaddingX*(6+1)))/6)

	self:SetSize( (DarkRPFoundation.CONFIG.INVENTORY.InvWidth*self.SlotSize)+(2*InvBorder)+(SlotPaddingX*(DarkRPFoundation.CONFIG.INVENTORY.InvWidth-1)), (self.SlotSize*DarkRPFoundation.CONFIG.INVENTORY.InvHeight)+TopSecH+(SlotPaddingY*(DarkRPFoundation.CONFIG.INVENTORY.InvHeight+1))+PageChangePadd+PageButtonHeight+(2*InvBorder) )
	self:Center()
	self.ActivePage = 1
	
	if( self:GetTall() > ScrH() ) then
		notification.AddLegacy( DRPF_Functions.L( "errorMsg_fullInv" ), NOTIFY_ERROR, 5 )
		DRPF_InventoryMenu:Remove()	
	elseif( self:GetWide() > ScrW() ) then
		notification.AddLegacy( DRPF_Functions.L( "errorMsg_wideInv" ), NOTIFY_ERROR, 5 )
		DRPF_InventoryMenu:Remove()
	end
	
	local InvCloseBut = vgui.Create( "DButton", self )
	local ButSize = 25
	InvCloseBut:SetSize( ButSize, ButSize )
	InvCloseBut:SetPos( self:GetWide()-10-InvCloseBut:GetWide(), 10 )
	InvCloseBut:SetText( "" )
	InvCloseBut.Paint = function( self2, w, h )
		if( self2:IsHovered() and !self2:IsDown() ) then
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "Highlight", 200 ) )	
		elseif( self2:IsDown() ) then
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "Highlight" ) )
		else
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
		end
		
		surface.SetMaterial( DarkRPFoundation.MATERIALS.CloseMat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	
	local InvPagePrev = vgui.Create( "DButton", self )
	InvPagePrev:SetSize( (self:GetWide()-PageChangePadd)/2, PageButtonHeight )
	InvPagePrev:SetPos( 0, self:GetTall()-InvPagePrev:GetTall() )
	InvPagePrev:SetText( "" )	
	InvPagePrev:Receiver( 'invslot', function( self2, panels, bDoDrop, Command, x, y )
		if ( bDoDrop ) then
			for k, v in pairs( panels ) do
				if( table.Count( self2:GetChildren() ) <= 0 ) then
					if( self.ActivePage-1 >= 1 ) then
						local AvailableNum = nil
						for i = ((self.ActivePage-2)*(DarkRPFoundation.CONFIG.INVENTORY.InvWidth*DarkRPFoundation.CONFIG.INVENTORY.InvHeight))+1, ((self.ActivePage-2)*(DarkRPFoundation.CONFIG.INVENTORY.InvWidth*DarkRPFoundation.CONFIG.INVENTORY.InvHeight))+(DarkRPFoundation.CONFIG.INVENTORY.InvWidth*DarkRPFoundation.CONFIG.INVENTORY.InvHeight) do
							if( not DRPFINVENTORY_Table[i] ) then
								AvailableNum = i
								break
							end
						end
						
						if( AvailableNum ) then
							net.Start( "DarkRPFoundationNet_InventoryMoveItem" )
								net.WriteInt( v:GetParent().SlotNumber, 32 )
								net.WriteInt( AvailableNum, 32 )
							net.SendToServer()
						end
					end
				end
			end
		end
	end )
	InvPagePrev.Paint = function( self2, w, h ) 
		surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
		surface.DrawRect( 0, 0, w, h )
		
		if( self2:IsDown() ) then
			surface.SetDrawColor( 0, 0, 0, 75 )
		elseif( self2:IsHovered() ) then
			surface.SetDrawColor( 0, 0, 0, 50 )
		else
			surface.SetDrawColor( 0, 0, 0, 0 )
		end
		surface.DrawRect( 0, 0, w, h )
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( DarkRPFoundation.MATERIALS.ArrowLeft )
		local H = h/2
		surface.DrawTexturedRect( (w/2)-((H*1.53)/2), (h/2)-(H/2), H*1.53, H )
	end
	InvCloseBut.DoClick = function()
		if( IsValid( DRPF_InventoryMenu ) ) then
			DRPF_InventoryMenu:Remove()
		end
	end
	
	local InvPageNext = vgui.Create( "DButton", self )
	InvPageNext:SetSize( (self:GetWide()-PageChangePadd)/2, PageButtonHeight )
	InvPageNext:SetPos( self:GetWide()-InvPageNext:GetWide(), self:GetTall()-InvPageNext:GetTall() )
	InvPageNext:SetText( "" )
	InvPageNext:Receiver( 'invslot', function( self2, panels, bDoDrop, Command, x, y )
		if ( bDoDrop ) then
			for k, v in pairs( panels ) do
				if( table.Count( self2:GetChildren() ) <= 0 ) then
					if( DarkRPFoundation.CONFIG.INVENTORY.InvPages >= self.ActivePage+1 ) then
						local AvailableNum = nil
						for i = (self.ActivePage*(DarkRPFoundation.CONFIG.INVENTORY.InvWidth*DarkRPFoundation.CONFIG.INVENTORY.InvHeight))+1, (self.ActivePage*(DarkRPFoundation.CONFIG.INVENTORY.InvWidth*DarkRPFoundation.CONFIG.INVENTORY.InvHeight))+(DarkRPFoundation.CONFIG.INVENTORY.InvWidth*DarkRPFoundation.CONFIG.INVENTORY.InvHeight) do
							if( not DRPFINVENTORY_Table[i] ) then
								AvailableNum = i
								break
							end
						end
						
						if( AvailableNum ) then
							net.Start( "DarkRPFoundationNet_InventoryMoveItem" )
								net.WriteInt( v:GetParent().SlotNumber, 32 )
								net.WriteInt( AvailableNum, 32 )
							net.SendToServer()
						end
					end
				end
			end
		end
	end )
	InvPageNext.Paint = function( self2, w, h ) 
		surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
		surface.DrawRect( 0, 0, w, h )
		
		if( self2:IsDown() ) then
			surface.SetDrawColor( 0, 0, 0, 75 )
		elseif( self2:IsHovered() ) then
			surface.SetDrawColor( 0, 0, 0, 50 )
		else
			surface.SetDrawColor( 0, 0, 0, 0 )
		end
		surface.DrawRect( 0, 0, w, h )
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( DarkRPFoundation.MATERIALS.ArrowRight )
		local H = h/2
		surface.DrawTexturedRect( (w/2)-((H*1.53)/2), (h/2)-(H/2), H*1.53, H )
	end
	
	local InvPageBack = vgui.Create( "DPanel", self )
	local PageHeaderH = 25
	InvPageBack:SetSize( self:GetWide()-(2*InvBorder), (self.SlotSize*DarkRPFoundation.CONFIG.INVENTORY.InvHeight)+(DarkRPFoundation.CONFIG.INVENTORY.InvHeight-1)*SlotPaddingY+PageHeaderH+SlotPaddingY )
	InvPageBack:SetPos( InvBorder, self:GetTall()-PageButtonHeight-PageChangePadd-InvPageBack:GetTall()-InvBorder )
	InvPageBack.Paint = function( self2, w, h ) 
		surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
		surface.DrawRect( 0, 0, w, PageHeaderH )
		
		draw.SimpleText( DRPF_Functions.L( "page" ) .. " " .. self.ActivePage, "DarkRPFoundation_Font_Inv_PageNum", w/2, PageHeaderH/2, Color( 245, 245, 245 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	
	function self:FillInventory( PageNum )
		InvPageBack:Clear()
		
		for row = 0, DarkRPFoundation.CONFIG.INVENTORY.InvHeight-1 do
			for col = 0, DarkRPFoundation.CONFIG.INVENTORY.InvWidth-1 do
				local SlotNum = ((row*DarkRPFoundation.CONFIG.INVENTORY.InvWidth)+(col+1))+((PageNum-1)*(DarkRPFoundation.CONFIG.INVENTORY.InvWidth*DarkRPFoundation.CONFIG.INVENTORY.InvHeight))
				local SlotX, SlotY = (col*self.SlotSize)+((col)*SlotPaddingX), PageHeaderH+SlotPaddingY+(row*self.SlotSize)+((row)*SlotPaddingY)
				
				local InvSlot = vgui.Create( "DPanel", InvPageBack )
				InvSlot:SetSize( self.SlotSize, self.SlotSize )
				InvSlot:SetPos( SlotX, SlotY )
				InvSlot:Receiver( 'invslot', function( self, panels, bDoDrop, Command, x, y )
					if ( bDoDrop ) then
						for k, v in pairs( panels ) do
							if( table.Count( self:GetChildren() ) <= 0 ) then
								net.Start( "DarkRPFoundationNet_InventoryMoveItem" )
									net.WriteInt( v:GetParent().SlotNumber, 32 )
									net.WriteInt( self.SlotNumber, 32 )
								net.SendToServer()
							end
						end
					end
				end )
				InvSlot.SlotNumber = SlotNum
				InvSlot.Paint = function( self2, w, h )
					surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
					surface.DrawRect( 0, 0, w, h )
				end
				
				if( DRPFINVENTORY_Table[SlotNum] ) then
					self:DrawSlotEntry( InvSlot, SlotNum )
				end
			end
		end
		
		if( IsValid( DRPF_InventoryMenu_Overflow ) ) then
			DRPF_InventoryMenu_Overflow:Remove()
		end

		local InvLimit = DarkRPFoundation.CONFIG.INVENTORY.InvPages*(DarkRPFoundation.CONFIG.INVENTORY.InvWidth*DarkRPFoundation.CONFIG.INVENTORY.InvHeight)
		if( #DRPFINVENTORY_Table > InvLimit ) then
			DRPF_InventoryMenu_Overflow = vgui.Create( "DPanel", DRPF_InventoryMenu )
			DRPF_InventoryMenu_Overflow:SetSize( self.SlotSize+(2*SlotPaddingX), self:GetTall() )
			local SelfX, SelfY = self:GetPos()
			DRPF_InventoryMenu_Overflow:SetPos( SelfX+self:GetWide()+SlotPaddingX, SelfY )
			DRPF_InventoryMenu_Overflow.Paint = function( self2, w, h ) 
				surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
				surface.DrawRect( 0, 0, w, h )
			end
			
			for k, v in pairs( DRPFINVENTORY_Table ) do
				if( k > InvLimit ) then
					local InvOverflowSlot = vgui.Create( "DPanel", DRPF_InventoryMenu_Overflow )
					InvOverflowSlot:SetSize( self.SlotSize, self.SlotSize )
					InvOverflowSlot:Dock( TOP )
					InvOverflowSlot:DockMargin( SlotPaddingX, SlotPaddingX, SlotPaddingX, 0 )
					InvOverflowSlot.SlotNumber = k
					InvOverflowSlot.Paint = function( self2, w, h )
						surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
						surface.DrawRect( 0, 0, w, h )
					end
					
					self:DrawSlotEntry( InvOverflowSlot, k )
				end
			end
		end
	end
	
	self:FillInventory( 1 )
	
	InvPagePrev.DoClick = function()
		local NewPage = math.Clamp( self.ActivePage-1, 1, DarkRPFoundation.CONFIG.INVENTORY.InvPages )
		self:FillInventory( tonumber( NewPage ) )
		self.ActivePage = tonumber( NewPage )
	end	
	
	InvPageNext.DoClick = function()
		local NewPage = math.Clamp( self.ActivePage+1, 1, DarkRPFoundation.CONFIG.INVENTORY.InvPages )
		self:FillInventory( tonumber( NewPage ) )
		self.ActivePage = tonumber( NewPage )
	end
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
	surface.DrawRect( 0, 0, w, h )		
	
	surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
	surface.DrawRect( 0, 0, w, h-PageChangePadd-PageButtonHeight )	
	
	draw.SimpleText( DRPF_Functions.L( "inventory" ), "DarkRPFoundation_Font_Inv_Header", w/2, 25, Color( 245, 245, 245 ), TEXT_ALIGN_CENTER, 0 )
	surface.SetFont( "DarkRPFoundation_Font_Inv_Header" )
	local HeaderX, HeaderY = surface.GetTextSize( "INVENTORY" )
	draw.SimpleText( DRPF_Functions.L( "byScript" ), "DarkRPFoundation_Font_Inv_SubHeader", w/2, 25+HeaderY-10, Color( 155, 155, 155 ), TEXT_ALIGN_CENTER, 0 )
end

vgui.Register( "drpf_inventory_main", PANEL, "DPanel" )