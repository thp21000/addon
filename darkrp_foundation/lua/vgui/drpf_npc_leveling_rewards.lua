local PANEL = {}
	
function PANEL:Init()
	local W, H = DRPF_NPCMENU_LEVELING_W-75, DRPF_NPCMENU_LEVELING_H-(DRPF_NPCMENU_LEVELING_H*0.3)
	
	local EntriesOnPage = 7
	
	local ActivePage = 1
	for i = 1, math.ceil( DarkRPFoundation.CONFIG.LEVELING.MaxLevel/EntriesOnPage ) do
		if( i_level >= ((i-1)*EntriesOnPage)+1 and i_level <= ((i-1)*EntriesOnPage)+EntriesOnPage ) then
			ActivePage = i
			break
		end
	end
	
	local BackPanel = vgui.Create( "DPanel", self )
	local Margin = 35
	BackPanel:SetSize( W-(2*Margin), H-(2*Margin) )
	BackPanel:SetPos( Margin, Margin )
	local InfoH = 45
	BackPanel.Paint = function( self2, w, h )
		local InfoBarWidth = w*0.2
		local InfoBarHeight = InfoH*0.35
		
		draw.SimpleText( DRPF_Functions.L( "lvlNpcCurrentLvl" ), "DarkRPFoundation_Font_Lvl_LevelInfo", 0, 0, Color( 245, 245, 245 ), 0, 0 )
		
		draw.SimpleText( i_level, "DarkRPFoundation_Font_Lvl_LevelInfo", InfoBarWidth+30, 0, Color( 245, 245, 245 ), 0, 0 )
		
		-- Level progess --
		local percent = i_experience/(DarkRPFoundation.CONFIG.LEVELING.OrignalEXPRequired*(DarkRPFoundation.CONFIG.LEVELING.EXPRequiredIncrease^(i_level) ))
		percent = math.Clamp( percent, 0, (DarkRPFoundation.CONFIG.LEVELING.OrignalEXPRequired*(DarkRPFoundation.CONFIG.LEVELING.EXPRequiredIncrease^(i_level) )) )
		
		surface.SetDrawColor( 245, 245, 245, 50 )
		surface.DrawRect( 0, InfoH-InfoBarHeight, InfoBarWidth, InfoBarHeight )		
		
		surface.SetDrawColor( 245, 245, 245, 255 )
		surface.DrawRect( 0, InfoH-InfoBarHeight, InfoBarWidth*percent, InfoBarHeight )
		
		draw.SimpleText( math.Clamp( i_level+1, 0, DarkRPFoundation.CONFIG.LEVELING.MaxLevel ), "DarkRPFoundation_Font_Lvl_LevelInfo", InfoBarWidth+30, InfoH-(InfoBarHeight/2)-2, Color( 245, 245, 245 ), 0, TEXT_ALIGN_CENTER )
		draw.SimpleText( "⮞", "DarkRPFoundation_Font_Lvl_LevelInfo", InfoBarWidth+30-10, InfoH-(InfoBarHeight/2)-3, Color( 245, 245, 245 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
	end
	
	-- Rewards --
	local Spacing = 5
	
	local RewardsBackPanel = vgui.Create( "DPanel", BackPanel )
	local HeaderInfoH = 60
	RewardsBackPanel:SetSize( BackPanel:GetWide(), BackPanel:GetTall()-HeaderInfoH )
	RewardsBackPanel:SetPos( 0, HeaderInfoH )
	RewardsBackPanel.Paint = function( self2, w, h ) end	
	
	local SectionW = (RewardsBackPanel:GetWide()-((EntriesOnPage-1)*Spacing))/EntriesOnPage
	
	local NormalRewardsHeader = vgui.Create( "DPanel", RewardsBackPanel )
	surface.SetFont( "DarkRPFoundation_Font_Lvl_RewardHeader" )
	local HeaderX, HeaderY = surface.GetTextSize( "1" )
	NormalRewardsHeader:SetSize( RewardsBackPanel:GetWide(), HeaderY+15 )
	NormalRewardsHeader:SetPos( 0, 0 )
	NormalRewardsHeader.Paint = function( self2, w, h )
		for i = 0, EntriesOnPage-1 do
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
			surface.DrawRect( i*(SectionW+Spacing), 0, SectionW, h )
			
			if( ((ActivePage-1)*EntriesOnPage)+i <= DarkRPFoundation.CONFIG.LEVELING.MaxLevel ) then
				draw.SimpleText( ((ActivePage-1)*EntriesOnPage)+i, "DarkRPFoundation_Font_Lvl_RewardHeader", i*(SectionW+Spacing)+(SectionW/2), h/2, Color( 245, 245, 245 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
		end
	end	
	
	local HeaderToRewardSpacing = 10
	local LeftOverH = RewardsBackPanel:GetTall()-NormalRewardsHeader:GetTall()-HeaderToRewardSpacing-4
	local RewardTierH = (LeftOverH-Spacing)/2

	local NormalRewardsBack = vgui.Create( "DPanel", RewardsBackPanel )
	NormalRewardsBack:SetSize( RewardsBackPanel:GetWide(), RewardTierH )
	NormalRewardsBack:SetPos( 0, NormalRewardsHeader:GetTall()+HeaderToRewardSpacing )
	NormalRewardsBack.Paint = function( self2, w, h )
		for i = 0, EntriesOnPage-1 do
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
			surface.DrawRect( i*(SectionW+Spacing), 0, SectionW, h )
		end
	end
	
	local VIPRewardsBack = vgui.Create( "DPanel", RewardsBackPanel )
	VIPRewardsBack:SetSize( RewardsBackPanel:GetWide(), RewardTierH+4 )
	VIPRewardsBack:SetPos( 0, NormalRewardsHeader:GetTall()+HeaderToRewardSpacing+NormalRewardsBack:GetTall()+Spacing )
	VIPRewardsBack.Paint = function( self2, w, h )
		for i = 0, EntriesOnPage-1 do
			surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "SecondaryColor" ) )
			surface.DrawRect( i*(SectionW+Spacing), 0, SectionW, h )			
			
			surface.SetDrawColor( 201, 176, 55 )
			surface.DrawRect( i*(SectionW+Spacing), h-4, SectionW, 4 )
		end
	end
	
	function self:RefreshRewards()
		NormalRewardsBack:Clear()
		VIPRewardsBack:Clear()
		
		for i = 0, EntriesOnPage-1 do
			local SlotNum = ((ActivePage-1)*EntriesOnPage)+i

			if( DarkRPFoundation.CONFIG.LEVELING.Rewards[SlotNum] ) then
				local NormalRewardsEntryBack = vgui.Create( "DPanel", NormalRewardsBack )
				NormalRewardsEntryBack:SetSize( SectionW, NormalRewardsBack:GetTall() )
				NormalRewardsEntryBack:SetPos( i*(SectionW+Spacing), 0 )
				NormalRewardsEntryBack:DockPadding( 5, 0, 5, 0 )
				NormalRewardsEntryBack.Paint = function( self2, w, h )
					surface.SetDrawColor( 255, 0, 0, 0 )
					surface.DrawRect( 0, 0, w, h )
				end
				
				local RewardsAmount = 0
				for k, v in pairs( DarkRPFoundation.CONFIG.LEVELING.Rewards[SlotNum] ) do
					if( DarkRPFoundation.DEVCONFIG.LevelRewards[k] ) then
						RewardsAmount = RewardsAmount+1
					end
				end
				
				for k, v in pairs( DarkRPFoundation.CONFIG.LEVELING.Rewards[SlotNum] ) do
					if( DarkRPFoundation.DEVCONFIG.LevelRewards[k] ) then
						local NormalRewardsEntryReward = vgui.Create( "DButton", NormalRewardsEntryBack )
						NormalRewardsEntryReward:Dock( TOP )
						NormalRewardsEntryReward:DockMargin( 0, 5, 0, 0 )
						NormalRewardsEntryReward:SetText( "" )
						NormalRewardsEntryReward:SetToolTip( DarkRPFoundation.DEVCONFIG.LevelRewards[k].FormatVal( v ) )
						NormalRewardsEntryReward:SetTall( (NormalRewardsEntryBack:GetTall()-(RewardsAmount+1)*5)/RewardsAmount )
						local ButAlpha = 0
						local ButAlphaTxt = 0
						NormalRewardsEntryReward.Paint = function( self2, w, h )
							local BorderW = 2
							DarkRPFoundation.DRAW.OutlinedBox( 0, 0, w, h, BorderW, DarkRPFoundation.DRAW.GetTheme( "TertiaryColor" ) )
							surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
							surface.DrawRect( BorderW, BorderW, w-(2*BorderW), h-(2*BorderW) )
							
							local IconPadding = 5+BorderW
						
							if( DarkRPFoundation.DEVCONFIG.LevelRewards[k].Icon ) then
								if( DarkRPFoundation.MATERIALS[DarkRPFoundation.DEVCONFIG.LevelRewards[k].Icon[1]] ) then
									surface.SetMaterial( DarkRPFoundation.MATERIALS[DarkRPFoundation.DEVCONFIG.LevelRewards[k].Icon[1]] )
									surface.SetDrawColor( 255, 255, 255, 255 )
									if( w >= h*DarkRPFoundation.DEVCONFIG.LevelRewards[k].Icon[2] ) then
										local IconW, IconH = h*DarkRPFoundation.DEVCONFIG.LevelRewards[k].Icon[2]-(2*IconPadding), h-(2*IconPadding)
										surface.DrawTexturedRect( (w/2)-(IconW/2), (h/2)-(IconH/2), IconW, IconH )
									else
										local IconW, IconH = w-(2*IconPadding), w/DarkRPFoundation.DEVCONFIG.LevelRewards[k].Icon[2]-(2*IconPadding)
										surface.DrawTexturedRect( (w/2)-(IconW/2), (h/2)-(IconH/2), IconW, IconH )
									end
								end
							end
							
							if( self2:IsDown() ) then
								ButAlpha = math.Clamp( ButAlpha+3, 0, 200 )
								ButAlphaTxt = math.Clamp( ButAlphaTxt+3, 0, 255 )
							elseif( self2:IsHovered() and ButAlpha <= 170 ) then
								ButAlpha = math.Clamp( ButAlpha+3, 0, 170 )
								ButAlphaTxt = math.Clamp( ButAlphaTxt+3, 0, 255 )
							else
								ButAlpha = math.Clamp( ButAlpha-3, 0, 200 )
								ButAlphaTxt = math.Clamp( ButAlphaTxt-3, 0, 255 )
							end
							
							surface.SetDrawColor( 0, 0, 0, ButAlpha )
							surface.DrawRect( BorderW, BorderW, w-(2*BorderW), h-(2*BorderW) )
							
							draw.SimpleText( k, "DarkRPFoundation_Font_Lvl_PlyNameXXS", w/2, h/2, Color( 255, 255, 255, ButAlphaTxt ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
						end
					end
				end
				
				if( i_level >= SlotNum ) then
					for i = 0, RewardsAmount-1 do
						local NormalRewardsEntryRewardTick = vgui.Create( "DPanel", NormalRewardsEntryBack )
						NormalRewardsEntryRewardTick:SetSize( 16, 16 )
						local Spacing = 2
						NormalRewardsEntryRewardTick:SetPos( NormalRewardsEntryBack:GetWide()-NormalRewardsEntryRewardTick:GetWide()-Spacing, Spacing+(i*(NormalRewardsEntryBack:GetTall()-(RewardsAmount+1)*5)/RewardsAmount)+(i*5) )
						NormalRewardsEntryRewardTick.Paint = function( self2, w, h )
							surface.SetMaterial( DarkRPFoundation.MATERIALS["Checked"] )
							surface.SetDrawColor( 255, 255, 255, 255 )
							surface.DrawTexturedRect( 0, 0, w, h )
						end
					end
				end
			end
			
			if( DarkRPFoundation.CONFIG.LEVELING.VIPRewards[SlotNum] ) then
				local VIPRewardsEntryBack = vgui.Create( "DPanel", VIPRewardsBack )
				VIPRewardsEntryBack:SetSize( SectionW, VIPRewardsBack:GetTall()-4 )
				VIPRewardsEntryBack:SetPos( i*(SectionW+Spacing), 0 )
				VIPRewardsEntryBack:DockPadding( 5, 0, 5, 0 )
				VIPRewardsEntryBack.Paint = function( self2, w, h )
					surface.SetDrawColor( 255, 0, 0, 0 )
					surface.DrawRect( 0, 0, w, h )
				end
				
				local RewardsAmount = 0
				for k, v in pairs( DarkRPFoundation.CONFIG.LEVELING.VIPRewards[SlotNum] ) do
					if( DarkRPFoundation.DEVCONFIG.LevelRewards[k] ) then
						RewardsAmount = RewardsAmount+1
					end
				end
				
				for k, v in pairs( DarkRPFoundation.CONFIG.LEVELING.VIPRewards[SlotNum] ) do
					if( DarkRPFoundation.DEVCONFIG.LevelRewards[k] ) then
						local NormalRewardsEntryReward = vgui.Create( "DButton", VIPRewardsEntryBack )
						NormalRewardsEntryReward:Dock( TOP )
						NormalRewardsEntryReward:DockMargin( 0, 5, 0, 0 )
						NormalRewardsEntryReward:SetText( "" )
						NormalRewardsEntryReward:SetToolTip( DarkRPFoundation.DEVCONFIG.LevelRewards[k].FormatVal( v ) )
						NormalRewardsEntryReward:SetTall( (VIPRewardsEntryBack:GetTall()-(RewardsAmount+1)*5)/RewardsAmount )
						local ButAlpha = 0
						local ButAlphaTxt = 0
						NormalRewardsEntryReward.Paint = function( self2, w, h )
							local BorderW = 2
							DarkRPFoundation.DRAW.OutlinedBox( 0, 0, w, h, BorderW, DarkRPFoundation.DRAW.GetTheme( "TertiaryColor" ) )
							surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
							surface.DrawRect( BorderW, BorderW, w-(2*BorderW), h-(2*BorderW) )
							
							local IconPadding = 5+BorderW
						
							if( DarkRPFoundation.DEVCONFIG.LevelRewards[k].Icon ) then
								if( DarkRPFoundation.MATERIALS[DarkRPFoundation.DEVCONFIG.LevelRewards[k].Icon[1]] ) then
									surface.SetMaterial( DarkRPFoundation.MATERIALS[DarkRPFoundation.DEVCONFIG.LevelRewards[k].Icon[1]] )
									surface.SetDrawColor( 255, 255, 255, 255 )
									if( w >= h*DarkRPFoundation.DEVCONFIG.LevelRewards[k].Icon[2] ) then
										local IconW, IconH = h*DarkRPFoundation.DEVCONFIG.LevelRewards[k].Icon[2]-(2*IconPadding), h-(2*IconPadding)
										surface.DrawTexturedRect( (w/2)-(IconW/2), (h/2)-(IconH/2), IconW, IconH )
									else
										local IconW, IconH = w-(2*IconPadding), w/DarkRPFoundation.DEVCONFIG.LevelRewards[k].Icon[2]-(2*IconPadding)
										surface.DrawTexturedRect( (w/2)-(IconW/2), (h/2)-(IconH/2), IconW, IconH )
									end
								end
							end
							
							if( self2:IsDown() ) then
								ButAlpha = math.Clamp( ButAlpha+3, 0, 200 )
								ButAlphaTxt = math.Clamp( ButAlphaTxt+3, 0, 255 )
							elseif( self2:IsHovered() and ButAlpha <= 170 ) then
								ButAlpha = math.Clamp( ButAlpha+3, 0, 170 )
								ButAlphaTxt = math.Clamp( ButAlphaTxt+3, 0, 255 )
							else
								ButAlpha = math.Clamp( ButAlpha-3, 0, 200 )
								ButAlphaTxt = math.Clamp( ButAlphaTxt-3, 0, 255 )
							end
							
							surface.SetDrawColor( 0, 0, 0, ButAlpha )
							surface.DrawRect( BorderW, BorderW, w-(2*BorderW), h-(2*BorderW) )
							
							draw.SimpleText( k, "DarkRPFoundation_Font_Lvl_PlyNameXXS", w/2, h/2, Color( 255, 255, 255, ButAlphaTxt ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
						end
					end
				end
				
				if( table.HasValue( DarkRPFoundation.CONFIG.LEVELING.VIPRanks, DRPF_Functions.GetAdminGroup( LocalPlayer() ) ) ) then
					if( i_level >= SlotNum ) then
						for i = 0, RewardsAmount-1 do
							local NormalRewardsEntryRewardTick = vgui.Create( "DPanel", VIPRewardsEntryBack )
							NormalRewardsEntryRewardTick:SetSize( 16, 16 )
							local Spacing = 2
							NormalRewardsEntryRewardTick:SetPos( VIPRewardsEntryBack:GetWide()-NormalRewardsEntryRewardTick:GetWide()-Spacing, Spacing+(i*(VIPRewardsEntryBack:GetTall()-(RewardsAmount+1)*5)/RewardsAmount)+(i*5) )
							NormalRewardsEntryRewardTick.Paint = function( self2, w, h )
								surface.SetMaterial( DarkRPFoundation.MATERIALS["Checked"] )
								surface.SetDrawColor( 255, 255, 255, 255 )
								surface.DrawTexturedRect( 0, 0, w, h )
							end
						end
					end
				else
					for i = 0, RewardsAmount-1 do
						local p = vgui.Create( "Panel" )
						p:SetSize( 290, 25 )
						p:SetVisible( false )
						p.Paint = function( s, w, h ) draw.SimpleText( DRPF_Functions.L( "lvlNpcVipRewards" ), "DarkRPFoundation_Font_Lvl_PlyNameXXXS", w/2, h/2, Color( 0, 0, 0, ButAlphaTxt ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) end

						local NormalRewardsEntryRewardTick = vgui.Create( "DPanel", VIPRewardsEntryBack )
						NormalRewardsEntryRewardTick:SetSize( 16, 16 )
						local Spacing = 2
						NormalRewardsEntryRewardTick:SetPos( VIPRewardsEntryBack:GetWide()-NormalRewardsEntryRewardTick:GetWide()-Spacing, Spacing+(i*(VIPRewardsEntryBack:GetTall()-(RewardsAmount+1)*5)/RewardsAmount)+(i*5) )
						--NormalRewardsEntryRewardTick:SetToolTip( "You need VIP for these rewards!" )
						NormalRewardsEntryRewardTick:SetTooltipPanel( p )
						NormalRewardsEntryRewardTick.Paint = function( self2, w, h )
							surface.SetMaterial( DarkRPFoundation.MATERIALS["Cross"] )
							surface.SetDrawColor( 255, 255, 255, 255 )
							surface.DrawTexturedRect( 0, 0, w, h )
						end
					end
				end
			end
		end
	end
	self:RefreshRewards()
	
	-- Page Controls --
	local NormalRewardsNxtPageLeft = vgui.Create( "DButton", RewardsBackPanel )
	NormalRewardsNxtPageLeft:SetSize( NormalRewardsHeader:GetTall(), NormalRewardsHeader:GetTall() )
	NormalRewardsNxtPageLeft:SetPos( 0, 0 )
	NormalRewardsNxtPageLeft:SetText( "" )
	NormalRewardsNxtPageLeft.Paint = function( self2, w, h )
		local ButAlpha = 0
		if( self2:IsHovered() and !self2:IsDown() ) then
			ButAlpha = 100
		elseif( self2:IsDown() ) then
			ButAlpha = 175
		else
			ButAlpha = 0
		end
		
		surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "Highlight", ButAlpha ) )
		surface.DrawRect( 0, 0, w, h )
		
		draw.SimpleText( "⮜", "DarkRPFoundation_Font30", w/2-1, h/2-3, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end	
	NormalRewardsNxtPageLeft.DoClick = function()
		ActivePage = math.Clamp( ActivePage-1, 1, math.ceil( DarkRPFoundation.CONFIG.LEVELING.MaxLevel/EntriesOnPage ) )
		self:RefreshRewards()
	end
	
	local NormalRewardsNxtPageRight = vgui.Create( "DButton", RewardsBackPanel )
	NormalRewardsNxtPageRight:SetSize( NormalRewardsHeader:GetTall(), NormalRewardsHeader:GetTall() )
	NormalRewardsNxtPageRight:SetPos( RewardsBackPanel:GetWide()-NormalRewardsNxtPageRight:GetWide(), 0 )
	NormalRewardsNxtPageRight:SetText( "" )
	NormalRewardsNxtPageRight.Paint = function( self2, w, h )
		local ButAlpha = 0
		if( self2:IsHovered() and !self2:IsDown() ) then
			ButAlpha = 100
		elseif( self2:IsDown() ) then
			ButAlpha = 175
		else
			ButAlpha = 0
		end
		
		surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "Highlight", ButAlpha ) )
		surface.DrawRect( 0, 0, w, h )
		
		draw.SimpleText( "⮞", "DarkRPFoundation_Font30", w/2+1, h/2-3, Color( 255, 255, 255, 175 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	NormalRewardsNxtPageRight.DoClick = function()
		ActivePage = math.Clamp( ActivePage+1, 1, math.ceil( DarkRPFoundation.CONFIG.LEVELING.MaxLevel/EntriesOnPage ) )
		self:RefreshRewards()
	end
	
	-- Collect Rewards --
	local CollectRewardsButton = vgui.Create( "DButton", BackPanel )
	CollectRewardsButton:SetSize( 100, 40 )
	CollectRewardsButton:SetPos( BackPanel:GetWide()-CollectRewardsButton:GetWide(), 0 )
	CollectRewardsButton:SetText( "" )
	CollectRewardsButton.Paint = function( self2, w, h )
		local ButAlpha = 75
		if( self2:IsHovered() and !self2:IsDown() ) then
			ButAlpha = 100
		elseif( self2:IsDown() ) then
			ButAlpha = 175
		else
			ButAlpha = 75
		end
	
		local BorderW = 2
		DarkRPFoundation.DRAW.OutlinedBox( 0, 0, w, h, BorderW, DarkRPFoundation.DRAW.GetTheme( "TertiaryColor" ) )
		surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "PrimaryColor" ) )
		surface.DrawRect( BorderW, BorderW, w-(2*BorderW), h-(2*BorderW) )		
		
		surface.SetDrawColor( DarkRPFoundation.DRAW.GetTheme( "TertiaryColor", ButAlpha ) )
		surface.DrawRect( BorderW, BorderW, w-(2*BorderW), h-(2*BorderW) )
		
		draw.SimpleText( DRPF_Functions.L( "lvlNpcCollect" ), "DarkRPFoundation_Font_Lvl_PlyNameXXXS", w/2, h/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	CollectRewardsButton.DoClick = function()
		net.Start( "DarkRPFoundationNet_NPCLevelingCollectRewards" )
		net.SendToServer()
	end
end

function PANEL:Paint( w, h )

end

vgui.Register( "drpf_npc_leveling_rewards", PANEL, "DPanel" )