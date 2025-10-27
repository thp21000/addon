
net.Receive("RHC_Jailer_Menu", function()
	local PlayerToJail = net.ReadEntity()

	local JailerMenu = vgui.Create("rhc_jailernpc_menu")
	JailerMenu:SetAPlayer(PlayerToJail)
end)

net.Receive("RHC_Bailer_Menu", function()
	vgui.Create("rhc_bailernpc_menu")
end)

surface.CreateFont( "rhc_bailer_pheader", {
	font = "trebuchet18",
	size = 18,
	weight = 1000,
	antialias = true,
})

surface.CreateFont( "rhc_npc_text", {
	font = "Verdana",
	size = 50,
	weight = 500,
	antialias = true,
})

local HeaderH = 25
local BailerPlayerColor = Color(45,45,45,255)
local MainPanelColor = Color(255,255,255,200)
local HeaderColor = Color(50,50,50,255)
local SecondPanelColor = Color(215,215,220,255)
local ButtonColor = Color(60,60,75,255)
local ButtonColorHovering = Color(55,55,75,200)
local ButtonColorPressed = Color(150,150,150,200)
local ButtonOutline = Color(0,0,0,200)

local PANEL = {}

function PANEL:Init()
	self:ShowCloseButton(false)
	self:SetTitle("")
	self:MakePopup()
	self.JailNick = RHC_GetLang("ReqDraggingPlayer")
	self.StarWars = RHC_GetConf("CUFFS_StarWarsCuffs")

	self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function(selfp, W,H)
		if !self.StarWars then
			draw.RoundedBoxEx(8, 0, 0, W, H, HeaderColor, true, true, false, false)
		end
		draw.SimpleText(RHandcuffsConfig.NPCData["rhc_jailer"].Text, "Trebuchet18", W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	self.JailSlider = vgui.Create("DNumSlider", self)
	self.JailSlider:SetText(RHC_GetConf("JAIL_AmountType"))
	self.JailSlider.Label:SetTextColor(Color(0,0,0,255))
	self.JailSlider:SetMin(1)
	self.JailSlider:SetMax(RHC_GetConf("JAIL_MaxJailTime"))
	self.JailSlider:SetDecimals(0)
	self.JailSlider:SetValue(1)
	self.JailSlider.Scratch.OnMousePressed = function() end
	self.JailSlider.Scratch.OnMouseReleased = function() end
	self.JailSlider.Scratch:SetCursor("none")

	if self.StarWars then
		self.JailButton = vgui.Create("tbfy_button_starwars", self)
		self.JailButton:SetBoxColor(Color(0,0,0,100), Color(25,25,25,220), Color(100,100,100,255))
	else
		self.JailButton = vgui.Create("tbfy_button", self)
	end
	self.JailButton:SetBText(RHC_GetLang("PutinJail"))
	self.JailButton.DoClick = function() net.Start("RHC_jail_player") net.WriteEntity(self.APlayer) net.WriteFloat(self.JailSlider:GetValue()) net.WriteString(self.JailReason:GetValue()) net.SendToServer() self:Remove() end

	self.JailReason = vgui.Create("DTextEntry", self)

	self.CloseButton = vgui.Create("tbfy_button", self)
	self.CloseButton:SetBText("X")
	if self.StarWars then
		self.CloseButton:SetBoxColor(Color(0,0,0,0), Color(0,0,0,0), Color(0,0,0,0))
	end
	self.CloseButton.DoClick = function() self:Remove() end
end

function PANEL:SetAPlayer(Player)
	if !IsValid(Player) and !Player:IsPlayer() then return end
	self.JailNick = "Player: " .. Player:Nick()
	self.APlayer = Player
end

local Width, Height = 200, 140
function PANEL:Paint(W,H)
	if self.StarWars then
		draw.RoundedBox(8, 0, 0, W, H, Color(21, 34, 56,255))
		surface.SetTexture(surface.GetTextureID("vgui/gradient_down"))
		surface.SetDrawColor(0, 142, 203, 200)
		surface.DrawTexturedRect(0,0,W,H)
		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawOutlinedRect(0,0,W,H,3)
		surface.SetDrawColor(0, 109, 105, 200)
		surface.DrawOutlinedRect(0,0,W,H,2)

		draw.SimpleText(self.JailNick, "Trebuchet18", W/2, HeaderH+5, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("Reason:", "Trebuchet18", 5, HeaderH+55, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	else
		draw.RoundedBoxEx(8, 0, HeaderH, W, H-HeaderH, MainPanelColor,false,false,true,true)

		draw.SimpleText(self.JailNick, "Trebuchet18", W/2, HeaderH+5, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("Reason:", "Trebuchet18", 5, HeaderH+55, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
end

function PANEL:PerformLayout()
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	self.TopDPanel:SetPos(0,0)
	self.TopDPanel:SetSize(Width,HeaderH+2)

	self.JailSlider:SetPos(5,HeaderH+25)
	self.JailSlider:SetSize(Width-10,25)

	self.JailReason:SetPos(50, HeaderH+55)
	self.JailReason:SetSize(Width-60, 20)

	self.JailButton:SetPos(Width/2-37.5,Height-33)
	self.JailButton:SetSize(75,25)

	self.CloseButton:SetPos(Width-HeaderH/2-7.5,HeaderH/2-7.5)
	self.CloseButton:SetSize(15, 15)
end
vgui.Register("rhc_jailernpc_menu", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
	self.BailNick = ""
	self.Time = 0
	self.BailPrice = 0
	self.BailPlayer = nil
	self.ArrestedBy = ""

	self.Avatar = vgui.Create("AvatarImage", self)
end

function PANEL:SetBailPlayer(Player)
	self.BailPlayer = Player
	self.BailNick = Player:Nick()
	local Time = Player:RHC_GetATime()/60
	self.Time = Time
	self.ArrestedBy = Player:RHC_GetANick()
	self.BailPrice = Time*RHC_GetConf("BAIL_PriceForEach")

	self.Avatar:SetPlayer(Player, 128)

	if self.StarWars then
		self.BailPButton = vgui.Create("tbfy_button_starwars", self)
		self.BailPButton:SetBoxColor(Color(0,0,0,100), Color(25,25,25,220), Color(100,100,100,255))
	else
		self.BailPButton = vgui.Create("tbfy_button", self)
	end
	self.BailPButton:SetBText(RHC_GetLang("BailPlayer"))
	self.BailPButton:SetBoxColor(ButtonColor, ButtonColorHovering, ButtonColorPressed)
	self.BailPButton.DoClick = function()
		if !LocalPlayer():canAfford(self.BailPrice) then LocalPlayer():ChatPrint("You can't afford that!") return end
		net.Start("RHC_bail_player")
			net.WriteEntity(self.BailPlayer)
		net.SendToServer()

		local MainP = self.MainPanel
		MainP.BailPlayers[self.TID] = nil
		self:Remove()
		MainP:PerformLayout()
	end
end

function PANEL:Paint(W,H)
	if self.StarWars then
		draw.RoundedBox(8, 0, 0, W, H, Color(21, 34, 56,255))
	else
		draw.RoundedBox(8, 0, 0, W, H, BailerPlayerColor)
	end

	draw.SimpleText(self.BailNick, "rhc_bailer_pheader", W/2, 0, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

	local TextStartW = H

	draw.SimpleText(RHC_GetLang("ArrestedBy") .. ": " .. self.ArrestedBy, "Trebuchet18", TextStartW, 30, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText(RHC_GetLang("JailTime") .. ": " .. self.Time .. " years", "Trebuchet18", TextStartW, 45, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText(RHC_GetLang("BailPrice") .. ": $" .. self.BailPrice, "Trebuchet18", TextStartW, 60, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
end

function PANEL:PerformLayout(W,H)
	self.BailPButton:SetPos(W-105, H-30)
	self.BailPButton:SetSize(100,25)

	local AH = H - 10
	self.Avatar:SetPos(5,5)
	self.Avatar:SetSize(AH,AH)
end

vgui.Register("rhc_bailernpc_player", PANEL)

local PANEL = {}

function PANEL:Init()
	self:ShowCloseButton(false)
	self:SetTitle("")
	self:MakePopup()
	self.StarWars = RHC_GetConf("CUFFS_StarWarsCuffs")

	self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function(selfp, W,H)
		if !self.StarWars then
			draw.RoundedBoxEx(8, 0, 0, W, H, HeaderColor, true, true, false, false)
		end
		draw.SimpleText(RHandcuffsConfig.NPCData["rhc_bailer"].Text, "Trebuchet18", W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	self.BailerList = vgui.Create("DScrollPanel", self)
	self.BailerList.Paint = function(selfp, W, H)
	end

	self.BailerList.VBar.Paint = function() end
	self.BailerList.VBar.btnUp.Paint = function() end
	self.BailerList.VBar.btnDown.Paint = function() end
	self.BailerList.VBar.btnGrip.Paint = function() end

	self.BailPlayers = {}
	for k,v in pairs(player.GetAll()) do
		if v:RHC_IsArrested() then
			local BailP = vgui.Create("rhc_bailernpc_player", self.BailerList)
			BailP.StarWars = self.StarWars
			BailP:SetBailPlayer(v)
			BailP.MainPanel = self
			BailP.TID = k
			self.BailPlayers[k] = BailP
		end
	end

	self.CloseButton = vgui.Create("tbfy_button", self)
	self.CloseButton:SetBText("X")
	if self.StarWars then
		self.CloseButton:SetBoxColor(Color(0,0,0,0), Color(0,0,0,0), Color(0,0,0,0))
	end
	self.CloseButton.DoClick = function() self:Remove() end
end

function PANEL:Paint(W,H)
	if self.StarWars then
		draw.RoundedBox(8, 0, 0, W, H, Color(21, 34, 56,255))
		surface.SetTexture(surface.GetTextureID("vgui/gradient_down"))
		surface.SetDrawColor(0, 142, 203, 200)
		surface.DrawTexturedRect(0,0,W,H)
		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawOutlinedRect(0,0,W,H,3)
		surface.SetDrawColor(0, 109, 105, 200)
		surface.DrawOutlinedRect(0,0,W,H,2)
	else
		draw.RoundedBoxEx(8, 0, HeaderH, W, H-HeaderH, MainPanelColor,false,false,true,true)
	end
end

local Width, Height = 350, 401
function PANEL:PerformLayout()
	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	local HeaderH = 25

	self.TopDPanel:SetPos(0,0)
	self.TopDPanel:SetSize(Width,HeaderH+2)

	self.BailerList:SetPos(5,HeaderH+5)
	self.BailerList:SetSize(Width+5, Height-HeaderH-10)

	local BW = self.BailerList:GetWide()-15
	local SBH = 0
	for k,v in pairs(self.BailPlayers) do
		v:SetPos(0,SBH)
		v:SetSize(BW,90)
		SBH = SBH + 92
	end

	self.CloseButton:SetPos(Width-HeaderH/2-7.5,HeaderH/2-7.5)
	self.CloseButton:SetSize(15, 15)
end

vgui.Register("rhc_bailernpc_menu", PANEL, "DFrame")
