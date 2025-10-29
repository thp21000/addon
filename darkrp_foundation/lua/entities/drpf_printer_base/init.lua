AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:StartPrinting()
	if( self:GetUpgradeSpeed() != true ) then
		self:DoMyAnimationThing( "active", 1 )
	else
		self:DoMyAnimationThing( "activex2", 1 )
	end

	local Speed = self.ConfigTable.PrintSpeed
	if( self:GetUpgradeSpeed() == true ) then
		Speed = self.ConfigTable.UpgradedPrintSpeed
	end
	timer.Create( tostring( self ) .. "_PrinterTimer", Speed, 0, function()
		if( IsValid( self ) ) then
			local StorageAmount = self.ConfigTable.MoneyStorage
			if( self:GetUpgradeStorage() == true ) then
				StorageAmount = self.ConfigTable.UpgradedMoneyStorage
			end

			if( self:GetUpgradeAmount() != true ) then
				self:SetHolding( math.Clamp( self:GetHolding()+self.ConfigTable.PrintAmount, 0, StorageAmount ) )
			else
				self:SetHolding( math.Clamp( self:GetHolding()+self.ConfigTable.UpgradedPrintAmount, 0, StorageAmount ) )
			end
			
			self:SetInk( math.Clamp( self:GetInk()-DarkRPFoundation.CONFIG.PRINTERS.InkLostPerPrint, 0, self.ConfigTable.MaxInk ) )
		else
			timer.Remove( tostring( self ) .. "_PrinterTimer" )
		end
	end )
end

function ENT:Initialize()
	self:SetModel("models/darkrpfoundation/money_printer.mdl")

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self:SetHolding( 0 )
	self:SetHealth( self.ConfigTable.PrinterHealth )
	self:SetInk( self.ConfigTable.MaxInk )
	
	self:SetUpgradeSpeed( false )
	self:SetUpgradeAmount( false )
	self:SetUpgradeStorage( false )
	self:SetOverheated( false )
	self:SetStatus( true )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	self:SetColor( self.ConfigTable.PrinterColor )
	
	self:StartPrinting()
	
    self.sound = CreateSound(self, Sound("ambient/levels/labs/equipment_printer_loop1.wav"))
    self.sound:SetSoundLevel(52)
    self.sound:PlayEx(1, 100)
end

function ENT:Use( ply )
	if( IsValid( ply ) ) then
		if( self:GetHolding() > 0 ) then
			ply:addMoney( self:GetHolding() )
			DarkRP.notify( ply, 1, 4, DRPF_Functions.L( "basePrinterEntWithdraw" ) .. " " .. DarkRP.formatMoney( self:GetHolding() ) .. " " .. DRPF_Functions.L( "basePrinterEntThisPrinter" ) )
			self:SetHolding( 0 )
		end
	end
end

function ENT:Think()
	local StorageAmount = self.ConfigTable.MoneyStorage
	if( self:GetUpgradeStorage() == true ) then
		StorageAmount = self.ConfigTable.UpgradedMoneyStorage
	end

	if( timer.Exists( tostring( self ) .. "_PrinterTimer" ) ) then
		if( self:GetInk() <= 0 or self:GetHolding() >= StorageAmount ) then
			if( self:GetStatus() == true ) then
				timer.Pause( tostring( self ) .. "_PrinterTimer" )
				self:DoMyAnimationThing( "idle", 1 )
				self:SetBodygroup( 7, 1 )
				self:SetStatus( false )
			end
		else
			if( self:GetStatus() != true ) then
				timer.UnPause( tostring( self ) .. "_PrinterTimer" )
				if( self:GetUpgradeSpeed() != true ) then
					self:DoMyAnimationThing( "active", 1 )
				else
					self:DoMyAnimationThing( "activex2", 1 )
				end
				self:SetBodygroup( 7, 0 )
				self:SetStatus( true )
			end
		end
	else
		self:StartPrinting()
		self:SetStatus( true )
	end
	
	if( self:GetInk() <= 0 or self:GetHolding() >= StorageAmount ) then
		if( self.sound ) then
			self.sound:Stop()
			self.sound = nil
		end
	else
		if( not self.sound ) then
			self.sound = CreateSound(self, Sound("ambient/levels/labs/equipment_printer_loop1.wav"))
			self.sound:SetSoundLevel(52)
			self.sound:PlayEx(1, 100)
		end
	end

	self:NextThink( CurTime() )
	return true
end

function ENT:OnTakeDamage( dmgInfo )
	self:SetHealth( math.Clamp( self:Health()-dmgInfo:GetDamage(), 0, self.ConfigTable.PrinterHealth ) )
	if( self:Health() <= 0 ) then
		self:Overheat()
	end
end

function ENT:Overheat()
	if( self:GetOverheated() != true ) then
		self:SetOverheated( true )
		self:Ignite()
		timer.Simple( 1, function()
			if( IsValid( self ) ) then
				self:Ignite()
			end
		end )	
		timer.Simple( 2, function()
			if( IsValid( self ) ) then
				local vPoint = self:GetPos()
				local effectdata = EffectData()
				effectdata:SetStart(vPoint)
				effectdata:SetOrigin(vPoint)
				effectdata:SetScale(1)
				util.Effect("Explosion", effectdata)
				DarkRP.notify(self:Getowning_ent(), 1, 4, DarkRP.getPhrase("money_printer_exploded"))
				self:Remove()
			end
		end )
	end
end

function ENT:DoMyAnimationThing( SequenceName, PlaybackRate )
	--print( SequenceName .. "  	" .. tostring(self:GetCooling()) )
	PlaybackRate = PlaybackRate or 1
	local sequenceID, sequenceDuration = self:LookupSequence( SequenceName )
	if (sequenceID != -1) then
		
		self:ResetSequence(sequenceID)
		self:SetPlaybackRate(PlaybackRate)
		self:ResetSequenceInfo()
		self:SetCycle(0)
		return CurTime() + sequenceDuration * (1 / PlaybackRate) 
	else
		MsgN("ERROR: Didn't find a sequence by the name of ", SequenceName)
		return CurTime()
	end
end

function ENT:OnRemove()
	if( self.sound ) then
		self.sound:Stop()
	end
end

function ENT:InstallItem( Item, Bool )
	if( Bool == false ) then return end

	if( Item == "Ink" ) then
		self:SetInk( self.ConfigTable.MaxInk )
	elseif( Item == "Upgrade Amount" ) then
		self:SetUpgradeAmount( true )
		self:SetBodygroup( 1, 1 )
		self:SetBodygroup( 6, 1 )
		
		if( self:GetUpgradeSpeed() != true ) then
			self:SetSkin( 1 )
		else
			self:SetSkin( 3 )
		end
	elseif( Item == "Upgrade Speed" ) then
		self:SetUpgradeSpeed( true )
		self:SetBodygroup( 2, 1 )
		self:SetBodygroup( 5, 1 )
	
		if( self:GetUpgradeAmount() != true ) then
			self:SetSkin( 2 )
		else
			self:SetSkin( 3 )
		end
		
		self:DoMyAnimationThing( "activex2", 1 )
	elseif( Item == "Upgrade Storage" ) then
		self:SetUpgradeStorage( true )
		self:SetBodygroup( 3, 1 )
		self:SetBodygroup( 4, 1 )
	end
end

function ENT:StartTouch( Toucher )
	if( not IsValid( Toucher ) ) then return end
	
	if( Toucher:GetClass() == "drpf_printeritem_repair" ) then
		if( self:Health() < self.ConfigTable.PrinterHealth ) then
			Toucher:Remove()
			self:SetHealth( self.ConfigTable.PrinterHealth )
		end	
	elseif( Toucher:GetClass() == "drpf_printeritem_ink" ) then
		if( self:GetInk() < self.ConfigTable.MaxInk ) then
			Toucher:Remove()
			self:InstallItem( "Ink" )
		end
	elseif( Toucher:GetClass() == "drpf_printeritem_upgrade_amount" ) then
		if( self:GetUpgradeAmount() != true ) then
			Toucher:Remove()
			self:InstallItem( "Upgrade Amount" )
		end
	elseif( Toucher:GetClass() == "drpf_printeritem_upgrade_speed" ) then
		if( self:GetUpgradeSpeed() != true ) then
			Toucher:Remove()
			self:InstallItem( "Upgrade Speed" )
		end
	elseif( Toucher:GetClass() == "drpf_printeritem_upgrade_storage" ) then
		if( self:GetUpgradeStorage() != true ) then
			Toucher:Remove()
			self:InstallItem( "Upgrade Storage" )
		end
	end
end

function ENT:AcceptInput(ply, caller)

end