AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_pages.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/darkrpfoundation/atm/atm_front.mdl")

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self:GetPhysicsObject():EnableMotion( false )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

util.AddNetworkString( "DarkRPFoundationNet_UseATM" )
function ENT:Use( ply )
	if( IsValid( ply ) ) then
		net.Start( "DarkRPFoundationNet_UseATM" )
			net.WriteEntity( self )
		net.Send( ply )
	end
end

function ENT:Think()
	if( IsValid( self:GetPhysicsObject() ) ) then
		if( self:GetPhysicsObject():IsMotionEnabled() ) then
			self:GetPhysicsObject():EnableMotion( false )
		end
	end
end

function ENT:OnTakeDamage( dmgInfo )

end

function ENT:DoMyAnimationThing( SequenceName, PlaybackRate )
	PlaybackRate = PlaybackRate or 1
	local sequenceID, sequenceDuration = self:LookupSequence( SequenceName )
	if (sequenceID != -1) then
		
		self:ResetSequence(sequenceID)
		self:SetPlaybackRate(PlaybackRate)
		self:ResetSequenceInfo()
		self:SetCycle(0)
		return CurTime() + sequenceDuration * (1 / PlaybackRate) 
	else
		MsgN(DRPF_Functions.L( "atmEntErrorSequence" ) .. " ", SequenceName)
		return CurTime()
	end
end

function ENT:OnRemove()

end

--[[ BANKING FUNCTIONS ]]--
local plyMeta = FindMetaTable( "Player" )

util.AddNetworkString( "DarkRPFoundationNet_SendBanking" )
function plyMeta:DRPF_BankingUpdate()
	net.Start( "DarkRPFoundationNet_SendBanking" )
		net.WriteTable( self:DRPF_BankingGet() )
	net.Send( self )
end

function plyMeta:DRPF_BankingSaveData()
	local BankingData = self:DRPF_BankingGet()
	
	if( BankingData != nil ) then
		local BankingDataJSON = util.TableToJSON( BankingData )
	
		if( DarkRPFoundation.CONFIG.GENERAL.UseMySQL != true ) then
			if( not file.Exists( "darkrpfoundation/banking_data", "DATA" ) ) then
				file.CreateDir( "darkrpfoundation/banking_data" )
			end
		
			file.Write( "darkrpfoundation/banking_data/" .. self:SteamID64() .. ".txt", BankingDataJSON )
		else
			self:DRPF_UpdateDBValue( "banking_data", BankingDataJSON )
		end
	end
end	

function plyMeta:DRPF_BankingSet( BankingData, DontSave )
	self.DRPFBanking = BankingData
	
	self:DRPF_BankingUpdate()
	
	if( not DontSave ) then
		self:DRPF_BankingSaveData()
	end
end	

function plyMeta:DRPF_BankingGet()
	return self.DRPFBanking
end

function plyMeta:DRPF_BankingAddTransactionLog( Title, Amount )
	local BankingData = {}
	if( self:DRPF_BankingGet() ) then
		BankingData = self:DRPF_BankingGet()
	end
	
	local TransactionLogs = BankingData.TransactionLogs or {}
	local NewLog = {
		Date = os.time(),
		Title = Title,
		Amount = Amount
	}
	
	table.insert( TransactionLogs, NewLog )
	table.SortByMember( TransactionLogs, "Date" )
	
	if( #TransactionLogs > DarkRPFoundation.CONFIG.ATM.TransactionBackLog ) then
		for i = DarkRPFoundation.CONFIG.ATM.TransactionBackLog+1, #TransactionLogs do
			if( TransactionLogs[i] ) then
				TransactionLogs[i] = nil
			end
		end
	end
	
	BankingData.TransactionLogs = TransactionLogs
	
	self:DRPF_BankingSet( BankingData )
end

function plyMeta:DRPF_BankingAddBalance( Amount, Reason )
	local BankingData = {}
	if( self:DRPF_BankingGet() ) then
		BankingData = self:DRPF_BankingGet()
		
		BankingData.AccountBalance = ( BankingData.AccountBalance or 0 )+Amount
	else
		BankingData.AccountBalance = Amount
	end
	
	self:DRPF_BankingSet( BankingData )
	
	self:DRPF_BankingAddTransactionLog( Reason, Amount )
end

--[[ LOAD BANKING ]]--
hook.Add( "PlayerInitialSpawn", "DarkRPFoundationHooks_PlayerInitialSpawn_LoadBanking", function( ply )
	local BankingData = {}

	if( DarkRPFoundation.CONFIG.GENERAL.UseMySQL != true ) then
		if( not file.Exists( "darkrpfoundation/banking_data", "DATA" ) ) then
			file.CreateDir( "darkrpfoundation/banking_data" )
		end
		
		if( file.Exists( "darkrpfoundation/banking_data/" .. ply:SteamID64() .. ".txt", "DATA" ) ) then
			local FileTable = file.Read( "darkrpfoundation/banking_data/" .. ply:SteamID64() .. ".txt", "DATA" )
			FileTable = util.JSONToTable( FileTable )

			if( FileTable != nil ) then
				if( istable( FileTable ) ) then
					BankingData = FileTable
				end
			end
		end
		
		ply:DRPF_BankingSet( BankingData, true )
	else
		ply:DRPF_FetchDBValue( "banking_data", function( banking_data )
			local BankingDataTable = util.JSONToTable( banking_data or "" )

			if( BankingDataTable != nil ) then
				if( istable( BankingDataTable ) ) then
					BankingData = BankingDataTable
				end
			end
			
			ply:DRPF_BankingSet( BankingData, true )
		end )
	end
	
	local PlySteamID64 = ply:SteamID64()
	timer.Create( PlySteamID64 .. "_drpf_timer_bankinginterest", DarkRPFoundation.CONFIG.ATM.InterestTime, 0, function()
		if( IsValid( ply ) ) then
			local PlyAccountKey = ply:DRPF_BankingGet().AccountType or 1
			local InterestRate = DarkRPFoundation.CONFIG.ATM.AccountTypes[PlyAccountKey].InterestRate/100
			local Interest = math.Round((ply:DRPF_BankingGet().AccountBalance or 0)*InterestRate)
			if( Interest > 0 ) then
				ply:DRPF_BankingAddBalance( Interest, "Interest" )
				DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyGiveMoney" ) .. " " .. DarkRP.formatMoney( Interest ) .. " " .. DRPF_Functions.L( "atmEntNotifyFromProcent" ) )
			end
		else
			timer.Remove( PlySteamID64 .. "_drpf_timer_bankinginterest" )
		end
	end )
	
	--[[ GROUP ACCOUNTS ]]--
	ply:DRPF_GroupAccountUpdateAll()
end )

--[[ DEPOSITING ]]--
util.AddNetworkString( "DarkRPFoundationNet_ATMDepositMoney" )
net.Receive( "DarkRPFoundationNet_ATMDepositMoney", function( len, ply )
	local DepositAmount = net.ReadInt( 32 )
	
	if( not DepositAmount ) then return end
	if( not isnumber( DepositAmount ) ) then return end
	
	if( DepositAmount < DarkRPFoundation.CONFIG.ATM.MinimumDeposit ) then
		DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyMinDeposit" ) .. " " .. DarkRP.formatMoney( DarkRPFoundation.CONFIG.ATM.MinimumDeposit ) .. "." )
		return
	end
	
	if( ply:getDarkRPVar( "money" ) >= DepositAmount ) then
		ply:addMoney( -DepositAmount )
	
		ply:DRPF_BankingAddBalance( DepositAmount, "Deposit" )
		
		DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyHaveDeposit1" ) .. " " .. DarkRP.formatMoney( DepositAmount ) .. " " .. DRPF_Functions.L( "atmEntNotifyHaveDeposit2" ) )
	else
		DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyDontMoney" ) )
	end
end )

--[[ WITHDRAWING ]]--
util.AddNetworkString( "DarkRPFoundationNet_ATMWithdrawMoney" )
net.Receive( "DarkRPFoundationNet_ATMWithdrawMoney", function( len, ply )
	local WithdrawAmount = net.ReadInt( 32 )
	
	if( not WithdrawAmount ) then return end
	if( not isnumber( WithdrawAmount ) ) then return end
	
	if( WithdrawAmount < DarkRPFoundation.CONFIG.ATM.MinimumWithdrawl ) then
		DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyMinWithdraw" ) .. " " .. DarkRP.formatMoney( DarkRPFoundation.CONFIG.ATM.MinimumWithdrawl ) .. "." )
		return
	end
	
	local BankingData = ply:DRPF_BankingGet()
	if( BankingData and BankingData.AccountBalance and BankingData.AccountBalance >= WithdrawAmount ) then
		ply:DRPF_BankingAddBalance( -WithdrawAmount, "Withdrawl" )
		
		ply:addMoney( WithdrawAmount )
		
		DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyHaveWithdraw1" ) .. " " .. DarkRP.formatMoney( WithdrawAmount ) .. " " .. DRPF_Functions.L( "atmEntNotifyHaveWithdraw2" ) )
	else
		DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyWidthdrawDontMoney" ) )
	end
end )

--[[ UPGRADE ACCOUNT ]]--
util.AddNetworkString( "DarkRPFoundationNet_ATMUpgradeAccount" )
net.Receive( "DarkRPFoundationNet_ATMUpgradeAccount", function( len, ply )
	local BankingData = ply:DRPF_BankingGet()
	local PlayerAccountKey = BankingData.AccountType or 1
	local AccountTypesTable = DarkRPFoundation.CONFIG.ATM.AccountTypes
	
	if( AccountTypesTable[PlayerAccountKey+1] ) then
		if( (BankingData.AccountBalance or 0) >= AccountTypesTable[PlayerAccountKey+1].Requirement ) then
			BankingData.AccountType = PlayerAccountKey+1
			
			ply:DRPF_BankingSet( BankingData )
		
			DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyUpgradeFrom" ) .. AccountTypesTable[PlayerAccountKey].Title .. "' " .. DRPF_Functions.L( "atmEntNotifyUpgradeTo" ) .. " '" .. AccountTypesTable[PlayerAccountKey+1].Title .. "."  )
		else
			DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyUpgradeYouNeed" ) .. " " .. DarkRP.formatMoney( AccountTypesTable[PlayerAccountKey+1].Requirement ) .. " " .. DRPF_Functions.L( "atmEntNotifyUpgradeToBank" ) .."." )
		end
	else
		DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyUpgradeHeghestAccount" ) )
	end
end )

--[[ GROUP ACCOUNTS ]]--
function DRPF_Functions.LoadGroupAccounts()
	DRPF_GroupAccounts = {}
	
	if( DarkRPFoundation.CONFIG.GENERAL.UseMySQL != true ) then
		if( not file.Exists( "darkrpfoundation/banking_data/group_accounts", "DATA" ) ) then
			file.CreateDir( "darkrpfoundation/banking_data/group_accounts" )
		end
		
		for k, v in pairs( file.Find( "darkrpfoundation/banking_data/group_accounts/*.txt", "DATA" ) ) do
			local GroupID = string.Replace( v, ".txt", "" )
			local GroupData = file.Read( "darkrpfoundation/banking_data/group_accounts/" .. v, "DATA" )
			DRPF_GroupAccounts[GroupID] = util.JSONToTable( GroupData )
		end
	else
		DRPF_FetchGroupAccountDB( function( GroupData )
			for k, v in pairs( GroupData ) do
				DRPF_GroupAccounts[v.groupid] = {}
				DRPF_GroupAccounts[v.groupid].PrintName = (v.printname or "Unknown")
				DRPF_GroupAccounts[v.groupid].AccountBalance = (v.accountbalance or 0)
				DRPF_GroupAccounts[v.groupid].AccountMembers = (util.JSONToTable(v.accountmembers or "") or {})
			end
		end )
	end
end

hook.Add( "Initialize", "DarkRPFoundationHooks_Initialize_GroupAccounts", function( ply )
	DRPF_Functions.LoadGroupAccounts()
end )

local KeyToTabKey = {}
KeyToTabKey["printname"] = "PrintName"
KeyToTabKey["accountbalance"] = "AccountBalance"
KeyToTabKey["accountmembers"] = "AccountMembers"

function DRPF_Functions.SaveGroupAccountToFile( GroupID, key )
	if( DRPF_GroupAccounts[GroupID] ) then
		if( DarkRPFoundation.CONFIG.GENERAL.UseMySQL != true ) then
			if( not file.Exists( "darkrpfoundation/banking_data/group_accounts", "DATA" ) ) then
				file.CreateDir( "darkrpfoundation/banking_data/group_accounts" )
			end
			
			if( DRPF_GroupAccounts[GroupID] != nil and istable( DRPF_GroupAccounts[GroupID] ) ) then
				file.Write( "darkrpfoundation/banking_data/group_accounts/" .. GroupID .. ".txt", util.TableToJSON( DRPF_GroupAccounts[GroupID] ) )
			end
		else
			if( key ) then
				local TableKey = KeyToTabKey[key] or key
				DRPF_UpdateGroupAccountDB( GroupID, key, DRPF_GroupAccounts[GroupID][TableKey] )
			else
				DRPF_UpdateGroupAccountDB( GroupID, "printname", DRPF_GroupAccounts[GroupID].PrintName )
				DRPF_UpdateGroupAccountDB( GroupID, "accountbalance", DRPF_GroupAccounts[GroupID].AccountBalance )
				DRPF_UpdateGroupAccountDB( GroupID, "accountmembers", util.TableToJSON( DRPF_GroupAccounts[GroupID].AccountMembers ) )
			end
		end
	end
end

function DRPF_Functions.GetGroupAccountData( GroupID ) -- GroupID is owner's SteamID64
	if( DRPF_GroupAccounts[GroupID] ) then
		return DRPF_GroupAccounts[GroupID]
	else
		return nil
	end
end

function DRPF_Functions.SetGroupAccountData( GroupID, Data, Key ) -- GroupID is owner's SteamID64
	DRPF_GroupAccounts[GroupID] = Data

	if( Key ) then
		DRPF_Functions.SaveGroupAccountToFile( GroupID, Key  )
	else
		DRPF_Functions.SaveGroupAccountToFile( GroupID )
	end
	
	local Owner = player.GetBySteamID64( GroupID )
	if( IsValid( Owner ) ) then
		Owner:DRPF_GroupAccountUpdate( GroupID )
	end
		
	for k, v in pairs( DRPF_GroupAccounts[GroupID].AccountMembers ) do
		local ply = player.GetBySteamID64( k )
		if( IsValid( ply ) ) then
			ply:DRPF_GroupAccountUpdate( GroupID )
		end
	end
end

util.AddNetworkString( "DarkRPFoundationNet_SendGroupAccountData" )
function plyMeta:DRPF_GroupAccountUpdate( GroupID )
	if( DRPF_GroupAccounts[GroupID] ) then
		net.Start( "DarkRPFoundationNet_SendGroupAccountData" )
			net.WriteString( GroupID )
			net.WriteTable( DRPF_GroupAccounts[GroupID] )
		net.Send( self )
	end
end

util.AddNetworkString( "DarkRPFoundationNet_SendGroupAccountDataFull" )
function plyMeta:DRPF_GroupAccountUpdateAll()
	net.Start( "DarkRPFoundationNet_SendGroupAccountDataFull" )
		net.WriteTable( DRPF_GroupAccounts )
	net.Send( self )
end

--[[ CREATE GROUP ACCOUNT ]]--
util.AddNetworkString( "DarkRPFoundationNet_ATMCreateGroupAccount" )
net.Receive( "DarkRPFoundationNet_ATMCreateGroupAccount", function( len, ply )
	if( not DRPF_Functions.GetGroupAccountData( ply:SteamID64() ) ) then
		local NewGroupAccount = {}
		NewGroupAccount.PrintName = ply:Nick() .. DRPF_Functions.L( "atmEntNotifyGroupAccount" )
		NewGroupAccount.AccountBalance = 0
		NewGroupAccount.AccountMembers = {}
		
		DRPF_Functions.SetGroupAccountData( ply:SteamID64(), NewGroupAccount )
		
		DarkRP.notify( ply, 1, 3, DRPF_Functions.L( "atmEntNotifyGroupAccountCreate" ) .. "." )
	else
		DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyAlreadyGroupAccount" ) )
	end
end )

--[[ GROUP ACCOUNT DEPOSIT ]]--
util.AddNetworkString( "DarkRPFoundationNet_ATMGroupDepositMoney" )
net.Receive( "DarkRPFoundationNet_ATMGroupDepositMoney", function( len, ply )
	local GroupID = net.ReadString()
	local DepositAmount = net.ReadInt( 32 )
	
	if( not DepositAmount or not GroupID ) then return end
	if( not isnumber( DepositAmount ) ) then return end
	
	local GroupAccountData = DRPF_GroupAccounts[GroupID]
	
	if( GroupAccountData ) then	
		if( GroupAccountData.AccountMembers[ply:SteamID64()] or GroupID == ply:SteamID64() ) then
			if( ply:getDarkRPVar( "money" ) >= DepositAmount ) then
				ply:addMoney( -DepositAmount )
			
				GroupAccountData.AccountBalance = (GroupAccountData.AccountBalance or 0)+DepositAmount
				
				DRPF_Functions.SetGroupAccountData( GroupID, GroupAccountData, "accountbalance" )
				DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyHaveDepositGroupAccount1" ) .. " " .. DarkRP.formatMoney( DepositAmount ) .. " " .. DRPF_Functions.L( "atmEntNotifyHaveDepositGroupAccount2" ) .. " '" .. GroupAccountData.PrintName .. "'." )
			else
				DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyDontMoneyGroupAccount" ) )
			end
		else
			DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyDontMembersGroupAccount" ) )
		end
	else
		DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyDontGroupAccountExist" ) )
	end
end )

--[[ GROUP ACCOUNT WITHDRAWL ]]--
util.AddNetworkString( "DarkRPFoundationNet_ATMGroupWithdrawMoney" )
net.Receive( "DarkRPFoundationNet_ATMGroupWithdrawMoney", function( len, ply )
	local GroupID = net.ReadString()
	local WithdrawAmount = net.ReadInt( 32 )
	
	if( not WithdrawAmount or not GroupID ) then return end
	if( not isnumber( WithdrawAmount ) ) then return end

	local GroupAccountData = DRPF_GroupAccounts[GroupID]
	
	if( GroupAccountData ) then	
		if( GroupAccountData.AccountMembers[ply:SteamID64()] or GroupID == ply:SteamID64() ) then
			if( (GroupAccountData.AccountBalance or 0) >= WithdrawAmount ) then
				GroupAccountData.AccountBalance = (GroupAccountData.AccountBalance or 0)-WithdrawAmount
				
				DRPF_Functions.SetGroupAccountData( GroupID, GroupAccountData, "accountbalance" )
				
				ply:addMoney( WithdrawAmount )
				
				DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyHaveWithdrawGroupAccount1" ) .. " " .. DarkRP.formatMoney( WithdrawAmount ) .. " " .. DRPF_Functions.L( "atmEntNotifyHaveWithdrawGroupAccount2" ) .. "'" .. GroupAccountData.PrintName .. "'." )
			else
				DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyHaveNotMoneyGroupAccount" ) .. " '" .. GroupAccountData.PrintName .. "'." )
			end
		else
			DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyDontMembersGroupAccount" ) )
		end
	else
		DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyDontGroupAccountExist" ) )
	end
end )

--[[ GROUP ACCOUNT CHANGE NAME ]]--
util.AddNetworkString( "DarkRPFoundationNet_ATMGroupChangeName" )
net.Receive( "DarkRPFoundationNet_ATMGroupChangeName", function( len, ply )
	local NewName = net.ReadString()
	
	if( not NewName ) then return end

	local GroupAccountData = DRPF_GroupAccounts[ply:SteamID64()]
	
	if( GroupAccountData ) then		
		if( string.len( NewName ) <= 25 ) then
			GroupAccountData.PrintName = NewName
			
			DRPF_Functions.SetGroupAccountData( ply:SteamID64(), GroupAccountData, "printname" )
			
			DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyHaveChangedNameGroupAccount" ) )
		else
			DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyNameLimetedCharGroupAccount" ) )
		end
	else
		DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyDontOwnGroupAccount" ) )
	end
end )

--[[ GROUP ACCOUNT INVITE PLAYER ]]--
util.AddNetworkString( "DarkRPFoundationNet_RefreshATMMembers" )
function plyMeta:DRPF_BankingRefreshMembers()
	net.Start( "DarkRPFoundationNet_RefreshATMMembers" )
	net.Send( self )
end

util.AddNetworkString( "DarkRPFoundationNet_ATMGroupInvitePlayer" )
net.Receive( "DarkRPFoundationNet_ATMGroupInvitePlayer", function( len, ply )
	local InvitedPly = net.ReadEntity()
	
	if( not InvitedPly ) then return end

	if( not IsValid( InvitedPly ) ) then 
		DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyPlayerIsInvalid" ) )
		return 
	end

	local GroupAccountData = DRPF_GroupAccounts[ply:SteamID64()]
	
	if( GroupAccountData ) then		
		if( not GroupAccountData.AccountMembers[InvitedPly:SteamID64()] ) then
			GroupAccountData.AccountMembers[InvitedPly:SteamID64()] = InvitedPly:Nick()
			
			DRPF_Functions.SetGroupAccountData( ply:SteamID64(), GroupAccountData, "accountmembers" )
			
			DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyHaveInvited1" ) .. " '" .. InvitedPly:Nick() .. "' " .. DRPF_Functions.L( "atmEntNotifyHaveInvited2" ) )
			
			ply:DRPF_BankingRefreshMembers()
		else
			DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyUserAlready" ) )
		end
	else
		DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyDontOwnGroupAccount" ) )
	end
end )

--[[ GROUP ACCOUNT KICK USER ]]--
util.AddNetworkString( "DarkRPFoundationNet_ATMGroupKickUser" )
net.Receive( "DarkRPFoundationNet_ATMGroupKickUser", function( len, ply )
	local Victim = net.ReadString()
	
	if( not Victim ) then return end

	local GroupAccountData = DRPF_GroupAccounts[ply:SteamID64()]
	
	if( GroupAccountData ) then		
		if( GroupAccountData.AccountMembers[Victim] ) then
			GroupAccountData.AccountMembers[Victim] = nil
			
			DRPF_Functions.SetGroupAccountData( ply:SteamID64(), GroupAccountData, "accountmembers" )
			
			DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntRemovedThisUser" ) )
			
			ply:DRPF_BankingRefreshMembers()
		else
			DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntThisUserNotGroupAcc" ) )
		end
	else
		DarkRP.notify( ply, 0, 3, DRPF_Functions.L( "atmEntNotifyDontOwnGroupAccount" ) )
	end
end )