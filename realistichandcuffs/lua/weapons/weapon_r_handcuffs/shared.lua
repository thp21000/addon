if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Handcuffs"
	SWEP.Slot = 2
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "ToBadForYou"
SWEP.Instructions = "Left Click: Restrain/Release. \nRight Click: Force Players out of vehicle. \nReload: Inspect."
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.HoldType = "melee";
SWEP.UseHands = true

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "melee"
SWEP.Category = "ToBadForYou"
SWEP.UID = 76561197989708503

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.PlayBackRate = 1

function SWEP:Initialize()
	self:SetHoldType("melee")
	if RHC_GetConf("CUFFS_StarWarsCuffs") then
		self.ViewModel = "models/casual/handcuffs/c_handcuffs.mdl";
		self.WorldModel = "models/casual/handcuffs/handcuffs.mdl";
		self.PlayBackRate = 1.5
	else
		self.ViewModel = "models/tobadforyou/c_hand_cuffs.mdl";
		self.WorldModel = "models/tobadforyou/handcuffs.mdl";
		self.PlayBackRate = 2
	end
end

function SWEP:CanPrimaryAttack() return true; end

function SWEP:PlayCuffSound(Time)
	timer.Simple(Time, function() if IsValid(self) then self:EmitSound(RHandcuffsConfig.CuffSound) end end)
	timer.Simple(Time+1, function() if IsValid(self) then self:EmitSound(RHandcuffsConfig.CuffSound) end end)
end

function SWEP:Think()
	local PlayerToCuff = self.AttemptToCuff
	if IsValid(PlayerToCuff) then
		local vm = self.Owner:GetViewModel();

		local sequence
		if RHC_GetConf("CUFFS_StarWarsCuffs") then
	  	sequence = "draw"
		else
			sequence = "Reset"
		end

		local ResetSeq, Time1 = vm:LookupSequence(sequence)
		local CancelCuffing
		if self.CuffingRagdoll then
			CancelCuffing = PlayerToCuff:GetPos():Distance(self.Owner:GetPos()) > 350
		else
			local TraceEnt = self.Owner:GetEyeTrace().Entity
			CancelCuffing = !IsValid(TraceEnt) or TraceEnt != PlayerToCuff or TraceEnt:GetPos():Distance(self.Owner:GetPos()) > RHC_GetConf("CUFFS_CuffRange")
		end

		if CancelCuffing then
			if !self.CuffingRagdoll then
				PlayerToCuff.RHC_BeingCuffed = false
			end
			self.AttemptToCuff = nil
			vm:SendViewModelMatchingSequence(ResetSeq)
			vm:SetPlaybackRate(self.PlayBackRate)
			if RHC_GetConf("CUFFS_FreezeCuffed") then
				PlayerToCuff:Freeze(false)
			end
		elseif CurTime() >= self.AttemptCuffFinish then
			if SERVER then
				if self.CuffingRagdoll then
					PlayerToCuff.tazeplayer.LastRHCCuffed = self.Owner
					PlayerToCuff.tazeplayer.TazedRHCRestrained = true
				else
					if RHC_GetConf("CUFFS_HandcuffsJailing") then
						PlayerToCuff:RHC_Arrest(RHC_GetConf("CUFFS_JailTime"), self.Owner, "Arrested by cuffs")
					else
						PlayerToCuff:RHCRestrain(self.Owner)
					end
				end
			end
			if self.CuffingRagdoll then
				PlayerToCuff.RagdollCuffed = true
			end
			PlayerToCuff.RHC_BeingCuffed = false
			self.AttemptToCuff = nil
			vm:SendViewModelMatchingSequence(ResetSeq)
			vm:SetPlaybackRate(self.PlayBackRate)
			if RHC_GetConf("CUFFS_FreezeCuffed") then
				PlayerToCuff:Freeze(false)
			end
		end
	end
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 3)
	if !self.Owner:IsRHCWhitelisted() then
		if SERVER then
			TBFY_Notify(self.Owner, 1, 4, RHC_GetLang("NotAllowedToUseCuffs"))
		end
		return
	end

	self.Weapon:EmitSound("npc/vort/claw_swing" .. math.random(1, 2) .. ".wav")
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	local Trace = self.Owner:GetEyeTrace()
	local TPlayer = Trace.Entity
	if !IsValid(TPlayer) then return false end
	local Distance = self.Owner:EyePos():Distance(TPlayer:GetPos());
	if Distance > RHC_GetConf("CUFFS_CuffRange") then return false; end
	if TPlayer:GetNWBool("rks_restrained", false) then
		if SERVER then
			TBFY_Notify(self.Owner, 1, 4, RHC_GetLang("CantCuffRestrained"))
		end
		return
	end

	local CuffTime = RHC_GetConf("CUFFS_CuffingTime")
	local CuffingPlayer = TPlayer:IsPlayer() and !TPlayer:IsRHCImmune() and !IsValid(self.AttemptToCuff)
	local CuffingRagdoll = !TPlayer.RagdollCuffed and TPlayer:GetNWBool("CanRHCArrest", false) and !IsValid(self.AttemptToCuff)
	if CuffingPlayer or CuffingRagdoll then
		if !CuffingRagdoll and (CuffTime == 0 or TPlayer:GetNWBool("rhc_cuffed", false)) then
			if SERVER then
				TPlayer:RHCRestrain(self.Owner)
			end
		else
			self.CuffingRagdoll = !CuffingPlayer
			self.AttemptToCuff = TPlayer
			self.AttemptCuffFinish = CurTime() + CuffTime
			self.AttemptCuffStart = CurTime()
			TPlayer.RHC_BeingCuffed = true
			local vm = self.Owner:GetViewModel();
			local DeploySeq, Time = vm:LookupSequence("Deploy")

			vm:SendViewModelMatchingSequence(DeploySeq)
			vm:SetPlaybackRate(self.PlayBackRate)
			self:PlayCuffSound(.3)
			if SERVER then
				if !CuffingRagdoll and RHC_GetConf("CUFFS_FreezeCuffed") then
					TPlayer:Freeze(true)
				end
			end
		end
	end
end

function SWEP:Reload()
	if self.NextRPress and self.NextRPress > CurTime() then return end
	self.NextRPress = CurTime() + 1
	if CLIENT then return end
	if !RHC_GetConf("INSPECT_AllowInspection") then TBFY_Notify(self.Owner, 1, 4, RHC_GetLang("InspectionDisabled")) return end

	if !self.Owner:IsRHCWhitelisted() then TBFY_Notify(self.Owner, 1, 4, RHC_GetLang("NotAllowedToUseCuffs")) return end

	local Trace = self.Owner:GetEyeTrace()

	self.Weapon:SetNextPrimaryFire(CurTime() + 3)

	local TPlayer = Trace.Entity
	local Distance = self.Owner:EyePos():Distance(TPlayer:GetPos());
	if Distance > 100 then return false; end

	if TPlayer.Restrained then
		self.Owner:RHCInspect(TPlayer)
	end
end

function SWEP:SecondaryAttack()
	if SERVER then
		self.Weapon:SetNextSecondaryFire(CurTime() + 1)
		local Player = self.Owner
		if !Player:IsRHCWhitelisted() then TBFY_Notify(Player, 1, 4, RHC_GetLang("NotAllowedToUseCuffs")) return end

		local Trace = Player:GetEyeTrace()

		local TVehicle = Trace.Entity
		local Distance = Player:GetPos():Distance(TVehicle:GetPos());
		if Distance > 300 then return false; end

		if IsValid(TVehicle) and (TVehicle:IsVehicle() or TVehicle.LFS) then
			local Seats = {}
			if TVehicle.LFS then
				Seats = TVehicle:GetPassengerSeats()
			elseif TVehicle.IsSimfphyscar then
				if istable(TVehicle.pSeat) then
					Seats = TVehicle.pSeat
				else
					Seats = {}
				end
			elseif vcmod1 then
				Seats = TVehicle:VC_getSeatsAvailable()
			elseif SVMOD then
				Seats = TVehicle:SV_GetPassengerSeats()
			elseif NOVA_Config then
				Seats = TVehicle.CmodSeats
			elseif TVehicle.Seats then
				Seats = TVehicle.Seats
			end

			if Player.Dragging then
				local PlayerDragged = Player.Dragging
				if IsValid(PlayerDragged) then
					if SVMOD and SVMOD:IsVehicle(TVehicle) then
						local result = TVehicle:SV_EnterVehicle(PlayerDragged)
						if result == -3 then
							TBFY_Notify(Player, 1, 4, RHC_GetLang("NoSeats"))
						end
					else
						if table.Count(Seats) < 1 then
							TBFY_Notify(Player, 1, 4, RHC_GetLang("NoSeats"))
							if !IsValid(TVehicle:GetDriver()) then
								PlayerDragged:EnterVehicle(TVehicle)
								TBFY_Notify(Player, 1, 4, RHC_GetLang("PlayerPutInDriver"))
							end
							return
						end
						local foundSeat = false
						for k,v in pairs(Seats) do
							local SeatsDist = Player:GetPos():Distance(v:GetPos())
							if SeatsDist < 100 then
								PlayerDragged:EnterVehicle(v)
								foundSeat = true
								break
							end
						end
						if !foundSeat then
							for k,v in pairs(Seats) do
								PlayerDragged:EnterVehicle(v)
								break
							end
						end
					end
				end
			else
				for k,v in pairs(Seats) do
					local Driver = v:GetDriver()
					if IsValid(Driver) and Driver.Restrained then
						Driver:ExitVehicle()
					end
				end
			end
		end
	end
end

if CLIENT then
	function SWEP:DrawWorldModel()
		if not IsValid(self.Owner) then
			return
		end

		local boneindex = self.Owner:LookupBone("ValveBiped.Bip01_R_Hand")
		if boneindex then
			local HPos, HAng = self.Owner:GetBonePosition(boneindex)

			local offset = HAng:Right() * 0.5 + HAng:Forward() * 3.3 + HAng:Up() * 0

			HAng:RotateAroundAxis(HAng:Right(), 0)
			HAng:RotateAroundAxis(HAng:Forward(),  -90)
			HAng:RotateAroundAxis(HAng:Up(), 0)

			self:SetRenderOrigin(HPos + offset)
			self:SetRenderAngles(HAng)

			self:DrawModel()
		end
	end

	function SWEP:DrawHUD()
		draw.SimpleText("Left Click: Cuff player","default",ScrW()/2,5,Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,2,Color(0,0,0,255))
		draw.SimpleText("Right Click: Put dragged player in vehicle","default",ScrW()/2,15,Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,2,Color(0,0,0,255))
		draw.SimpleText("R: Inspect cuffed player","default",ScrW()/2,25,Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,2,Color(0,0,0,255))
		draw.SimpleText("E: Drag cuffed player (While dragging aim at prop/surface to attatch player)","default",ScrW()/2,35,Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP,2,Color(0,0,0,255))

		local PlayerToCuff = self.AttemptToCuff
		if !IsValid(PlayerToCuff) then return end

		local time = self.AttemptCuffFinish - self.AttemptCuffStart
		local curtime = CurTime() - self.AttemptCuffStart
		local percent = math.Clamp(curtime / time, 0, 1)
		local w = ScrW()
		local h = ScrH()
		local Nick = ""
		if self.CuffingRagdoll then
			Nick = RHC_GetLang("TazedPlayer")
		else
			Nick = PlayerToCuff:Nick()
		end

		local TPercent = math.Round(percent*100)
		local TextToDisplay = string.format(RHC_GetLang("CuffingText"), Nick)
		draw.SimpleText(TextToDisplay .. " (" .. TPercent .. "%)", "RHCHUDTEXT", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end
