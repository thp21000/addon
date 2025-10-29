--[[ ATM PAGES ]]--
local ATMPAGES = {}
ATMPAGES[1] = {
	Name = DRPF_Functions.L( "myAccount" ),
	Page = "myaccount",
	Controls = {
		[1] = {
			Name = DRPF_Functions.L( "deposit" ),
			OnClick = function()
				DarkRPFoundation.DERMA.StringRequest( DRPF_Functions.L( "atmDeposit" ), DRPF_Functions.L( "amountMoneyDeposit" ), DarkRPFoundation.CONFIG.ATM.MinimumDeposit, function( text ) 
					text = tonumber( text )
					if( isnumber( text ) ) then
						net.Start( "DarkRPFoundationNet_ATMDepositMoney" )
							net.WriteInt( text, 32 )
						net.SendToServer()
					end
				end, function() end, DRPF_Functions.L( "deposit" ), DRPF_Functions.L( "cancelOperation" ) )
			end
		},
		[2] = {
			Name = DRPF_Functions.L( "withdraw" ),
			OnClick = function()
				DarkRPFoundation.DERMA.StringRequest( DRPF_Functions.L( "atmWithdraw" ), DRPF_Functions.L( "amountMoneyWithdraw" ), DarkRPFoundation.CONFIG.ATM.MinimumWithdrawl, function( text ) 
					text = tonumber( text )
					if( isnumber( text ) ) then
						net.Start( "DarkRPFoundationNet_ATMWithdrawMoney" )
							net.WriteInt( text, 32 )
						net.SendToServer()
					end
				end, function() end, DRPF_Functions.L( "withdraw" ), DRPF_Functions.L( "cancelOperation" ) )
			end
		},
		[3] = {
			Name = DRPF_Functions.L( "historyOperations" ),
			OnClick = function( ATM )
				if( IsValid( ATM.ATMInUse ) ) then
					ATM.ATMInUse:SetActivePage( "transactionlogs" )
				end
			end,	
			PageDesign = function( ATM, Parent )

			end
		},		
		[4] = {
			Name = DRPF_Functions.L( "upgradeAccount" ),
			OnClick = function( ATM )
				if( DarkRPFoundation.CONFIG.ATM.AccountTypes[(DRPFBANKING_Table.AccountType or 1)+1] ) then
					net.Start( "DarkRPFoundationNet_ATMUpgradeAccount" )
					net.SendToServer()
				else
					notification.AddLegacy( DRPF_Functions.L( "infoMaxUpgradeAccount" ), 0, 3 )
				end
			end,
		}
	}
}

ATMPAGES[2] = {
	Name = DRPF_Functions.L( "groupAccount" ),
	Page = "groupaccounts",
	Controls = {}
}

--[[ VGUI ]]--
local PANEL = {}

surface.SetFont( "DarkRPFoundation_Font_Inv_Header" )
local HeaderX, HeaderY = surface.GetTextSize( "ATM" )

function PANEL:Init()
	if( not DRPF_GroupAccounts ) then
		DRPF_GroupAccounts = {}
	end

	local SteamID64 = LocalPlayer():SteamID64()
	
	local PANELSELF = self

	-- Tables --
	function self.MyGroupAccountFunc()
		ATMPAGES[2].Controls[1] = {
			Name = DRPF_Functions.L( "groupAccountMyName" ),
			OnClick = function( ATM )
				if( IsValid( ATM.ATMInUse ) ) then
					ATM.ATMInUse:SetActivePage( "groupaccount", SteamID64 )
				end
			end,
			PageDesign = function( ATM, Parent )
				PANELSELF:CreateButton( PANELSELF.PageEntryBack, DRPF_Functions.L( "deposit" ), function()
					DarkRPFoundation.DERMA.StringRequest( DRPF_Functions.L( "atmGroupDeposit" ), DRPF_Functions.L( "amountMoneyDeposit" ), DarkRPFoundation.CONFIG.ATM.MinimumDeposit, function( text ) 
						text = tonumber( text )
						if( isnumber( text ) ) then
							net.Start( "DarkRPFoundationNet_ATMGroupDepositMoney" )
								net.WriteString( SteamID64 )
								net.WriteInt( text, 32 )
							net.SendToServer()
						end
					end, function() end, DRPF_Functions.L( "deposit" ), DRPF_Functions.L( "cancelOperation" ) )
				end )				
				
				PANELSELF:CreateButton( PANELSELF.PageEntryBack, DRPF_Functions.L( "withdraw" ), function()
					DarkRPFoundation.DERMA.StringRequest( DRPF_Functions.L( "atmGroupWithdraw" ), DRPF_Functions.L( "amountMoneyWithdraw" ), DarkRPFoundation.CONFIG.ATM.MinimumWithdrawl, function( text ) 
						text = tonumber( text )
						if( isnumber( text ) ) then
							net.Start( "DarkRPFoundationNet_ATMGroupWithdrawMoney" )
								net.WriteString( SteamID64 )
								net.WriteInt( text, 32 )
							net.SendToServer()
						end
					end, function() end, DRPF_Functions.L( "withdraw" ), DRPF_Functions.L( "cancelOperation" ) )
				end )				
				
				PANELSELF:CreateButton( PANELSELF.PageEntryBack, DRPF_Functions.L( "changeName" ), function()
					DarkRPFoundation.DERMA.StringRequest( DRPF_Functions.L( "atmGroupEdit" ), DRPF_Functions.L( "atmGroupChengeName" ), DRPF_GroupAccounts[SteamID64].PrintName or "Unknown", function( text ) 
						if( string.len( text ) <= 25 ) then
							net.Start( "DarkRPFoundationNet_ATMGroupChangeName" )
								net.WriteString( text )
							net.SendToServer()
						else
							notification.AddLegacy( DRPF_Functions.L( "atmLimitedChar" ), 0, 3 )
						end
					end, function() end, DRPF_Functions.L( "changeName" ), DRPF_Functions.L( "cancelOperation" ) )
				end )				
				
				PANELSELF:CreateButton( PANELSELF.PageEntryBack, DRPF_Functions.L( "manageMembers" ), function()
					if( not IsValid( PANELSELF.DRPF_ManageMembers ) ) then
						PANELSELF.DRPF_ManageMembers = vgui.Create( "drpf_atm_managegroup" )
					else
						PANELSELF.DRPF_ManageMembers:SetVisible( true )
					end
				end )
			end
		}
	end
	
	if( DRPF_GroupAccounts[SteamID64] ) then
		self.MyGroupAccountFunc()
	else
		ATMPAGES[2].Controls[1] = {
			Name = DRPF_Functions.L( "createGroupAccount" ),
			OnClick = function()
				if( not DRPFBANKING_Table.GroupAccount ) then
					net.Start( "DarkRPFoundationNet_ATMCreateGroupAccount" )
					net.SendToServer()
					timer.Simple( 1, function() 
						if( IsValid( self ) ) then
							self.MyGroupAccountFunc()
							self:SetPage( 2 ) 
						end
					end )
				else
					notification.AddLegacy( DRPF_Functions.L( "atmAlreadyOwnGroup" ), 0, 3 )
				end
			end
		}
	end
	
	local GroupAccountsTable = {}
	for k, v in pairs( DRPF_GroupAccounts ) do
		if( v.AccountMembers[SteamID64] ) then
			v.GroupID = k
			table.insert( GroupAccountsTable, v )
		end
	end
	
	for k, v in pairs( GroupAccountsTable ) do
		ATMPAGES[2].Controls[1+k] = {
			Name = v.PrintName,
			OnClick = function( ATM )
				if( IsValid( ATM.ATMInUse ) ) then
					ATM.ATMInUse:SetActivePage( "groupaccount", v.GroupID )
				end
			end,
			PageDesign = function( ATM, Parent )
				self:CreateButton( self.PageEntryBack, DRPF_Functions.L( "deposit" ), function()
					DarkRPFoundation.DERMA.StringRequest( DRPF_Functions.L( "atmGroupDeposit" ), DRPF_Functions.L( "amountMoneyDeposit" ), DarkRPFoundation.CONFIG.ATM.MinimumDeposit, function( text ) 
						text = tonumber( text )
						if( isnumber( text ) ) then
							net.Start( "DarkRPFoundationNet_ATMGroupDepositMoney" )
								net.WriteString( v.GroupID )
								net.WriteInt( text, 32 )
							net.SendToServer()
						end
					end, function() end, DRPF_Functions.L( "deposit" ), DRPF_Functions.L( "cancelOperation" ) )
				end )				
				
				self:CreateButton( self.PageEntryBack, DRPF_Functions.L( "withdraw" ), function()
					DarkRPFoundation.DERMA.StringRequest( DRPF_Functions.L( "atmGroupWithdraw" ), DRPF_Functions.L( "amountMoneyWithdraw" ), DarkRPFoundation.CONFIG.ATM.MinimumWithdrawl, function( text ) 
						text = tonumber( text )
						if( isnumber( text ) ) then
							net.Start( "DarkRPFoundationNet_ATMGroupWithdrawMoney" )
								net.WriteString( v.GroupID )
								net.WriteInt( text, 32 )
							net.SendToServer()
						end
					end, function() end, DRPF_Functions.L( "withdraw" ), DRPF_Functions.L( "cancelOperation" ) )
				end )				
			end
		}
	end
	
	/*if( DarkRPFoundation.CONFIG.INVENTORY.Enable == true ) then
		ATMPAGES[3] = {
			Name = "Bank Storage",
			Page = "bankstorage",
			NoPage = true,
			OnClick = function()
				if( not IsValid( self.DRPF_BankStorage ) ) then
					self.DRPF_BankStorage = vgui.Create( "drpf_atm_bankstorage" )
				else
					self.DRPF_BankStorage:SetVisible( true )
				end
			end
		}
	end*/
	
	-- Panel --
	self:SetSize( ScrW()*0.2, ScrH()*0.5 )
	self:SetPos( 0, (ScrH()/2)-(self:GetTall()/2) )
	self:MakePopup()
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )
	self:DockPadding( 0, HeaderY, 0, 0 )
	
	local MenuCloseButton = vgui.Create( "DButton", self )
	local ButSize = 25
	MenuCloseButton:SetSize( ButSize, ButSize )
	MenuCloseButton:SetPos( self:GetWide()-10-MenuCloseButton:GetWide(), 10 )
	MenuCloseButton:SetText( "" )
	MenuCloseButton.Paint = function( self2, w, h )
		if( self2:IsHovered() and !self2:IsDown() ) then
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "Highlight", 200 ) )	
		elseif( self2:IsDown() ) then
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "Highlight" ) )
		else
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
		end
		
		surface.SetMaterial( DarkRPFoundation.MATERIALS.CloseMat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	MenuCloseButton.DoClick = function()
		self:Remove()
	end
	
	self.PageEntryBack = vgui.Create( "drpf_element_dscrollpanel", self )
	self.PageEntryBack:Dock( FILL )
	self.PageEntryBack:DockMargin( 10, 10, 10, 10 )
	self.PageEntryBack.Paint = function( self2, w, h ) end
	
	function self:CreateButton( Parent, Text, OnClick, BackBut )
		local PageButton = vgui.Create( "DButton", Parent )
		PageButton:SetTall( 55 )
		PageButton:Dock( TOP )
		PageButton:DockMargin( 0, 0, 0, 10 )
		PageButton:SetText( "" )
		PageButton.Paint = function( self2, w, h )
			if( self2:IsHovered() and !self2:IsDown() ) then
				surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "Highlight", 200 ) )	
			elseif( self2:IsDown() ) then
				surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "Highlight" ) )
			else
				surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
			end
			
			surface.DrawRect( 0, 0, w, h )
			
			draw.SimpleText( Text, "DarkRPFoundation_Font_Lvl_RewardHeader", w/2, h/2, Color( 245, 245, 245 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			
			if( BackBut ) then
				surface.SetMaterial( DarkRPFoundation.MATERIALS.ArrowLeft )
				surface.SetDrawColor( 255, 255, 255 )
				local MatSize = h*0.5
				surface.DrawTexturedRect( (w/2)-((MatSize*1.52631579)/2), (h/2)-(MatSize/2), MatSize*1.52631579, MatSize )
			end
		end
		PageButton.DoClick = function()
			OnClick()
		end
	end
	
	local PanelSelf = self
	
	function self:SetPage( PageKey )
		PanelSelf.PageEntryBack:Clear()
		
		PanelSelf:CreateButton( PanelSelf.PageEntryBack, "", function()
			PanelSelf:FillPages()
			if( IsValid( PanelSelf.ATMInUse ) ) then
				PanelSelf.ATMInUse:SetActivePage( "home" )
			end
		end, true )

		for i = 1, #ATMPAGES[PageKey].Controls do
			PanelSelf:CreateButton( PanelSelf.PageEntryBack, ATMPAGES[PageKey].Controls[i].Name, function()
				ATMPAGES[PageKey].Controls[i].OnClick( PanelSelf )
				if( ATMPAGES[PageKey].Controls[i].PageDesign ) then
					PanelSelf.PageEntryBack:Clear()
					
					PanelSelf:CreateButton( PanelSelf.PageEntryBack, "", function()
						PanelSelf:SetPage( PageKey )
						if( IsValid( PanelSelf.ATMInUse ) ) then
							if( ATMPAGES[PageKey].Page ) then
								PanelSelf.ATMInUse:SetActivePage( ATMPAGES[PageKey].Page )
							end
						end
					end, true )
					ATMPAGES[PageKey].Controls[i].PageDesign( PanelSelf, PanelSelf.PageEntryBack )
				end
			end )
		end
	end
	
	function self:FillPages()
		PanelSelf.PageEntryBack:Clear()
		
		for k, v in pairs( ATMPAGES ) do
			PanelSelf:CreateButton( PanelSelf.PageEntryBack, v.Name, function()
				if( v.Page ) then
					PanelSelf.ATMInUse:SetActivePage( v.Page )
				end
				
				if( v.OnClick ) then
					v.OnClick( PanelSelf )
				end
				
				if( not v.NoPage ) then
					PanelSelf:SetPage( k )
				end
			end )
		end
	end
	
	self:FillPages()
end

function PANEL:SetATMInUse( ReceivedEnt )
	self.ATMInUse = ReceivedEnt
end

function PANEL:Think()
	if( not IsValid( self.ATMInUse ) ) then
		self:Remove()
	end
end

function PANEL:OnRemove()
	LocalPlayer():RemoveEffects( EF_NODRAW )
	if( IsValid( self.ATMInUse ) ) then
		self.ATMInUse:SetActivePage( "home" )
	end
	
	if( IsValid( self.DRPF_ManageMembers ) ) then
		self.DRPF_ManageMembers:Remove()
	end
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
	surface.DrawRect( 0, 0, w, h )		
	
	surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
	surface.DrawRect( 0, 0, w, HeaderY )	
	
	draw.SimpleText( DRPF_Functions.L( "atm" ), "DarkRPFoundation_Font_Inv_Header", w/2, HeaderY/2, Color( 245, 245, 245 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

vgui.Register( "drpf_atm_main", PANEL, "DFrame" )