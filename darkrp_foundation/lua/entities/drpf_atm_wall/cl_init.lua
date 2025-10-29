include("shared.lua")
include("cl_pages.lua")
-- code copied from vault code, may be naming errors --
DRPF_ATMS_CSModels = (DRPF_ATMS_CSModels or {})
 
function ENT:Initialize()
	self.ATMPanelMat = CreateMaterial( "drpf_atm_panelmaterial_entid" .. self:EntIndex(), "UnlitGeneric", {} )
	self.ATMRenderTarget = GetRenderTarget( "drpf_atm_panelmaterial_entid" .. self:EntIndex(), 1024, 1024, false )

	self.ATMRear = ClientsideModel( "models/darkrpfoundation/atm/atm_rear.mdl" )
	self.ATMRear:SetPos( self:GetPos() )
	self.ATMRear:SetAngles( self:GetAngles() )
	self.ATMRear:SetNoDraw( true )
	self.ATMRear:SetParent( self )
	
	self.ATMPanelMat:SetTexture( "$basetexture", self.ATMRenderTarget )
	DRPF_ATMS_CSModels[self:EntIndex()] = self
	self:SetActivePage( "home" )
end

function ENT:SetActivePage( page_key, extra_param )
	if( not DRPF_ATMPAGES[page_key] ) then return end

	if( self.ActivePageKey != page_key ) then
		self.PageFadeIn = 0
	end
	
	self.ActivePageKey = page_key
	self.ExtraPageParma = extra_param
end

local ScreenW, ScreenH = 1024, 760
function ENT:Think()
	self.ATMRear:SetPos( self:GetPos() ) -- Keeps the rear of the vault position aligned with the front
	self.ATMRear:SetAngles( self:GetAngles() ) -- Keeps the rear of the vault angles aligned with the front
end

function ENT:RenderScreen()
	local Distance = LocalPlayer():GetPos():DistToSqr( self:GetPos() )

	if( Distance < DarkRPFoundation.CONFIG.GENERAL.DisplayDist3D2D ) then
		render.PushRenderTarget( self.ATMRenderTarget )
			render.Clear(0,0,0,0,true,true) 
			cam.Start2D()
				local X, Y, W, H = 0, 0, ScreenW, ScreenH
				if( DRPF_ATMPAGES[self.ActivePageKey] ) then
					self.PageFadeIn = math.Clamp( self.PageFadeIn+12, 0, 255 )
					local AlphaMulti = 1-(Distance/DarkRPFoundation.CONFIG.GENERAL.DisplayDist3D2D)
					surface.SetAlphaMultiplier( (self.PageFadeIn/255)*AlphaMulti )
						DRPF_ATMPAGES[self.ActivePageKey].DrawPage( self, W, H, self.ExtraPageParma )
					surface.SetAlphaMultiplier( 1 )
				end
			cam.End2D()
		render.PopRenderTarget()
		
		self.ATMRear:SetSubMaterial( 1, "!drpf_atm_panelmaterial_entid" .. self:EntIndex() )
	end
end

--[[ RENDERING REAR ATM ]]--
hook.Add( "PreDrawTranslucentRenderables", "DarkRPFoundationHooks_PreDrawTranslucentRenderables_ATMStencils", function( isDrawingDepth, isDrawSkybox )
	if( isDrawSkybox or isDrawingDepth ) then return end

	for k, v in pairs( DRPF_ATMS_CSModels ) do
		if( not IsValid( v ) ) then continue end
		
		v:RenderScreen()
		
		local screenpos = v:GetPos():ToScreen()
		if screenpos.visible == false then
			continue
		end

		render.ClearStencil()
		render.SetStencilEnable( true )
		render.SetStencilWriteMask( 255 )
		render.SetStencilTestMask( 255 )
		render.SetStencilReferenceValue( 69 )
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
		render.SetStencilPassOperation( STENCILOPERATION_REPLACE )

		local VAngles = v:GetAngles()
		VAngles:RotateAroundAxis( VAngles:Right(), -90 )

		cam.Start3D2D( v:GetPos() - ( v:GetAngles():Up() * -5 ) + ( v:GetAngles():Forward() ), VAngles, 0.5 )
			draw.NoTexture()
			draw.RoundedBox( 0, -64/2, -64/2, 75.5, 65, Color( 255, 255, 255, 1 ) )
		cam.End3D2D()
		
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
		render.SuppressEngineLighting( true )
		render.DepthRange( 0, 0.8 )
		
		v.ATMRear:DrawModel()
		
		render.SuppressEngineLighting( false )

		render.SetStencilEnable( false )
		render.DepthRange( 0, 1 )
	end
end )

net.Receive( "DarkRPFoundationNet_UseATM", function()
	local ReceivedEnt = net.ReadEntity()
	
	if( not IsValid( ReceivedEnt ) ) then return end
	
	if( not IsValid( DRPF_ATMControls ) ) then
		DRPF_ATMControls = vgui.Create( "drpf_atm_main" )
		DRPF_ATMControls:SetATMInUse( ReceivedEnt )
		LocalPlayer():AddEffects( EF_NODRAW )
	else
		DRPF_ATMControls:SetVisible( true )
	end
end )

net.Receive( "DarkRPFoundationNet_RefreshATMMembers", function()
	if( IsValid( DRPF_ATMControls ) ) then
		if( IsValid( DRPF_ATMControls.DRPF_ManageMembers ) ) then
			DRPF_ATMControls.DRPF_ManageMembers:RefreshMembers()
		end
	end
end )

net.Receive( "DarkRPFoundationNet_SendGroupAccountData", function()
	local GroupID = net.ReadString()
	local Data = net.ReadTable()
	
	if( not DRPF_GroupAccounts ) then
		DRPF_GroupAccounts = {}
	end
	
	if( Data != nil ) then
		DRPF_GroupAccounts[GroupID] = Data
	end
end )

net.Receive( "DarkRPFoundationNet_SendGroupAccountDataFull", function()
	local Data = net.ReadTable()
	
	if( not DRPF_GroupAccounts ) then
		DRPF_GroupAccounts = {}
	end
	
	if( Data != nil ) then
		DRPF_GroupAccounts = Data
	end
end )

hook.Add( "CalcView", "DarkRPFoundationHooks_CalcView_ATMView", function(ply, pos, angles, fov)
	if( IsValid( DRPF_ATMControls ) ) then
		local ATM = DRPF_ATMControls.ATMInUse
		
		if( IsValid( ATM ) ) then
			local view = {}
			view.origin = ATM:GetPos()+(ATM:GetForward()*23)+(ATM:GetUp()*2.5)
			local ATMAngles = ATM:GetAngles()
			ATMAngles:RotateAroundAxis( ATMAngles:Up(), 180 )
			view.angles = ATMAngles
			view.fov = fov
			view.drawviewer = true
			
			return view
		end
	end
end )

--[[ BANKING FUNCTIONS ]]--
net.Receive( "DarkRPFoundationNet_SendBanking", function()
	local BankingData = net.ReadTable()
	
	DRPFBANKING_Table = BankingData
end )