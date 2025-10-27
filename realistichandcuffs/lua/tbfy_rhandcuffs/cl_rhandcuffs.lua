
local PLAYER = FindMetaTable("Player")

local RHC_BoneManipulations = {
	["Cuffed"] = {
		["ValveBiped.Bip01_R_UpperArm"] = Angle(-28,18,-21),
		["ValveBiped.Bip01_L_Hand"] = Angle(0,0,119),
		["ValveBiped.Bip01_L_Forearm"] = Angle(15,20,40),
		["ValveBiped.Bip01_L_UpperArm"] = Angle(15, 26, 0),
		["ValveBiped.Bip01_R_Forearm"] = Angle(0,50,0),
		["ValveBiped.Bip01_R_Hand"] = Angle(45,34,-15),
		["ValveBiped.Bip01_L_Finger01"] = Angle(0,50,0),
		["ValveBiped.Bip01_R_Finger0"] = Angle(10,2,0),
		["ValveBiped.Bip01_R_Finger1"] = Angle(-10,0,0),
		["ValveBiped.Bip01_R_Finger11"] = Angle(0,-40,0),
		["ValveBiped.Bip01_R_Finger12"] = Angle(0,-30,0)
	},
	["Cuffed_StarWars"] = {
		["ValveBiped.Bip01_L_Hand"] = Angle(0,0,119),
		["ValveBiped.Bip01_L_Forearm"] = Angle(0,25,40),
		["ValveBiped.Bip01_L_UpperArm"] = Angle(30, 26, 0),
		["ValveBiped.Bip01_R_UpperArm"] = Angle(-40,20, 0),
		["ValveBiped.Bip01_R_Forearm"] = Angle(5,50,0),
		["ValveBiped.Bip01_R_Hand"] = Angle(45,34,-15),
		["ValveBiped.Bip01_L_Finger01"] = Angle(0,50,0),
		["ValveBiped.Bip01_R_Finger0"] = Angle(10,2,0),
		["ValveBiped.Bip01_R_Finger1"] = Angle(-10,0,0),
		["ValveBiped.Bip01_R_Finger11"] = Angle(0,-40,0),
		["ValveBiped.Bip01_R_Finger12"] = Angle(0,-30,0)
	},
	["HandsUp"] = {
		["ValveBiped.Bip01_R_UpperArm"] = Angle(73,35,128),
		["ValveBiped.Bip01_L_Hand"] = Angle(-12,12,90),
		["ValveBiped.Bip01_L_Forearm"] = Angle(-28,-29,44),
		["ValveBiped.Bip01_R_Forearm"] = Angle(-22,1,15),
		["ValveBiped.Bip01_L_UpperArm"] = Angle(-77,-46,4),
		["ValveBiped.Bip01_R_Hand"] = Angle(33,39,-21),
		["ValveBiped.Bip01_L_Finger01"] = Angle(0,30,0),
		["ValveBiped.Bip01_L_Finger1"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger11"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger2"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger21"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger3"] = Angle(0,45,0),
		["ValveBiped.Bip01_L_Finger31"] = Angle(0,45,0),
		["ValveBiped.Bip01_R_Finger0"] = Angle(-10,0,0),
		["ValveBiped.Bip01_R_Finger11"] = Angle(0,30,0),
		["ValveBiped.Bip01_R_Finger2"] = Angle(20,25,0),
		["ValveBiped.Bip01_R_Finger21"] = Angle(0,45,0),
		["ValveBiped.Bip01_R_Finger3"] = Angle(20,35,0),
		["ValveBiped.Bip01_R_Finger31"] = Angle(0,45,0)
	}
}


net.Receive("rhc_jailed", function()
	LocalPlayer().RHC_Arrested = CurTime()
end)

net.Receive("rhc_update_jailtime", function()
	local Bool, Time, SteamID, Nick = net.ReadBool(), net.ReadFloat(), net.ReadString(), net.ReadString()

	if Bool then
		RHC_ArrestedPlayers[SteamID] = {ATime = Time, ANick = Nick}
	else
		RHC_ArrestedPlayers[SteamID] = false
	end
end)

net.Receive("rhc_bonemanipulate", function()
	local Player, Type, Reset = net.ReadEntity(), net.ReadString(), net.ReadBool()

	if IsValid(Player) then
		for k,v in pairs(RHC_BoneManipulations[Type]) do
			local Bone = Player:LookupBone(k)
			if Bone then
				if Reset then
					Player:ManipulateBoneAngles(Bone, Angle(0,0,0))
				else
					Player:ManipulateBoneAngles(Bone, v)
				end
			end
		end
		if RHandcuffsConfig.DisablePlayerShadow then
			Player:DrawShadow(false)
		end
	end
end)

surface.CreateFont("RHCHUDTEXT", {
	size = 23,
	weight = 400,
	antialias = true,
	shadow = false,
	font = "Coolvetica"
})

net.Receive("tbfy_surr", function(Player, len)
	local SurrTime = net.ReadFloat()
	if SurrTime == 0 then
		LocalPlayer().Surrendering = false
	else
		LocalPlayer().Surrendering = SurrTime
	end
end)

hook.Add("HUDPaint", "TBFY_Surr", function()
	local ST = LocalPlayer().Surrendering
	if ST then
		local W,H = ScrW(), ScrH()
		local TimeLeft = math.Round(ST - CurTime(),1)
		draw.SimpleTextOutlined("Surrendering - " .. TimeLeft,"RHCHUDTEXT",ScrW()/2,ScrH()/2,Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,2,Color(0,0,0,255))
	end
end)

hook.Add("HUDPaint", "rhc_arrested", function()
	local Player = LocalPlayer()
	local W, H = ScrW(), ScrH()
	if Player:RHC_IsArrested() then
		local STime = Player.RHC_Arrested or 0
		local ATime = Player:RHC_GetATime()
		local TimeLeft = math.Round(STime+ATime-CurTime())
		draw.SimpleTextOutlined(string.format(RHC_GetLang("ArrestedText"), TimeLeft), "RHCHUDTEXT", W/2, H/12, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0,0,0,255))
	end
end)

//Whacky way to add text without overriding the function completely
hook.Add("loadCustomDarkRPItems", "rhc_set_drawPINFO", function()
	local OldDrawPlayerInfo = PLAYER.drawPlayerInfo
	function RHC_AddInCuffs(self)
		if RHandcuffsConfig.DisplayOverheadCuffed and self:GetNWBool("rhc_cuffed", false) then
			local pos = self:EyePos()

			pos.z = pos.z + 10
			pos = pos:ToScreen()
			if not self:getDarkRPVar("wanted") then
				pos.y = pos.y - 50
			end

			draw.DrawText("Handcuffed", "RHCHUDTEXT", pos.x + 1, pos.y - 19, Color(0,0,0,255), 1)
			draw.DrawText("Handcuffed", "RHCHUDTEXT", pos.x, pos.y - 20, Color(255,255,255,255) , 1)
		end
		OldDrawPlayerInfo(self)
	end
	PLAYER.drawPlayerInfo = RHC_AddInCuffs
end)

net.Receive("rhc_send_inspect_information", function()
	local Player, WepAmount = net.ReadEntity(), net.ReadFloat()

	local WepTbl = {}
	for i = 1, WepAmount do
		local TID = net.ReadFloat()
		local WepC = net.ReadString()

		if WepC and WepC != "" then
			WepTbl[TID] = WepC
		end
	end

	local InsMenu = vgui.Create("rhc_inspect_menu")
	InsMenu:SetupInfo(Player, WepTbl)
	if (itemstore or BRICKS_SERVER) and RHandcuffsConfig.InventoryIllegalItemsEnabled then
		local ItemAmount = net.ReadFloat()
		local iItems = {}
		for i = 1, ItemAmount do
			local ID, N, M = net.ReadFloat(), net.ReadString(), net.ReadString()
			iItems[ID] = {Name = N, Model = M}
		end
		InsMenu:SetupItems(iItems)
	end

	LocalPlayer().LastInspect = Player
end)

surface.CreateFont( "rhc_inspect_headline", {
	font = "Arial",
	size = 20,
	weight = 1000,
	antialias = true,
})

surface.CreateFont( "rhc_inspect_information", {
	font = "Arial",
	size = 20,
	weight = 100,
	antialias = true,
})

surface.CreateFont( "rhc_inspect_confiscate_weapon", {
	font = "Arial",
	size = 11,
	weight = 1000,
	antialias = true,
})

surface.CreateFont( "rhc_inspect_stealmoney", {
	font = "Arial",
	size = 14,
	weight = 1000,
	antialias = true,
})

surface.CreateFont( "rhc_inspect_weaponname", {
	font = "Arial",
	size = 14,
	weight = 100,
	antialias = true,
})

local MainPanelColor = Color(255,255,255,200)
local HeaderColor = Color(50,50,50,255)
local SecondPanelColor = Color(215,215,220,255)
local ButtonColor = Color(50,50,50,255)
local ButtonColorHovering = Color(75,75,75,200)
local ButtonColorPressed = Color(150,150,150,200)
local ButtonOutline = Color(0,0,0,200)

local PANEL = {}

function PANEL:Init()
	self.Name = ""
	self.SlotID = 0
	self.WID = 0

	self.WModel = vgui.Create("ModelImage", self)
end

function PANEL:Paint(W,H)
	draw.SimpleText(self.Name, "rhc_inspect_weaponname", W/2, 0, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
end

function PANEL:PerformLayout(W,H)
	self.ConfisItem:SetPos(2.5,H-20)
	self.ConfisItem:SetSize(W-5,15)

	self.WModel:SetPos(7.5,10)
	self.WModel:SetSize(W-15,W-15)
end

function PANEL:SetItemInfo(ID, Name, model)
	if self.StarWars then
		self.ConfisItem = vgui.Create("tbfy_button_starwars", self)
		self.ConfisItem:SetBoxColor(Color(0,0,0,100), Color(25,25,25,220), Color(100,100,100,255))
	else
		self.ConfisItem = vgui.Create("tbfy_button", self)
	end
	self.ConfisItem:SetBText(RHC_GetLang("Confiscate"))
	self.ConfisItem:SetBFont("rhc_inspect_confiscate_weapon")

	if model then
		self.WModel:SetModel(model)
	end
	self.Name = Name
	self.SlotID = ID

	self.ConfisItem.DoClick = function()
		if RHC_GetConf("INSPECT_AllowConfiscating") then
			net.Start("rhc_confiscate_item")
				net.WriteEntity(LocalPlayer().LastInspect)
				net.WriteFloat(self.SlotID)
			net.SendToServer()

			self:Remove()
		else
			LocalPlayer():ChatPrint(RHC_GetLang("ConfiscationDisabled"))
		end
	end
end

function PANEL:SetInfo(Wep, ID)
	if self.StarWars then
		self.ConfisItem = vgui.Create("tbfy_button_starwars", self)
		self.ConfisItem:SetBoxColor(Color(0,0,0,100), Color(25,25,25,220), Color(100,100,100,255))
	else
		self.ConfisItem = vgui.Create("tbfy_button", self)
	end
	self.ConfisItem:SetBText(RHC_GetLang("Confiscate"))
	self.ConfisItem:SetBFont("rhc_inspect_confiscate_weapon")

	local SWEPTable = weapons.GetStored(Wep)
	if SWEPTable then
		if SWEPTable.WorldModel then
			self.WModel:SetModel(SWEPTable.WorldModel)
		else
			LocalPlayer():ChatPrint("Invalid SWEP Model for: " .. Wep)
		end
		if SWEPTable.PrintName then
			self.Name = SWEPTable.PrintName
		else
			LocalPlayer():ChatPrint("Invalid SWEP Name for: " .. Wep)
		end
	else
		LocalPlayer():ChatPrint("Invalid SWEP Table for: " .. Wep)
	end
	self.WID = ID

	self.ConfisItem.DoClick = function()
		if !RHandcuffsConfig.DisableConfiscations then
			net.Start("rhc_confiscate_weapon")
				net.WriteEntity(LocalPlayer().LastInspect)
				net.WriteFloat(self.WID)
			net.SendToServer()

			self:Remove()
		else
			LocalPlayer():ChatPrint(RHC_GetLang("ConfiscationDisabled"))
		end
	end
end
vgui.Register("rhc_inspect_item", PANEL)

local PANEL = {}

function PANEL:Init()
	self:ShowCloseButton(false)
	self:SetTitle("")
	self:MakePopup()

	self.StarWars = RHC_GetConf("CUFFS_StarWarsCuffs")

	self.Name = "INVALID"
	self.Job = "INVALID"
	self.SteamID = "INVALID"
	self.Wallet = 0
	self.WepItems = {}
	self.iItems = {}

	self.TopDPanel = vgui.Create("DPanel", self)
	self.TopDPanel.Paint = function(selfp, W,H)
		if self.StarWars then
			draw.RoundedBox(4, 5, 4, W-10, H-8, Color(21, 34, 56,255))
		else
			draw.RoundedBoxEx(8, 0, 0, W, H, HeaderColor, true, true, false, false)
		end
		draw.SimpleText("Inspecting: " .. self.Name, "rhc_inspect_headline", W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	self.InfoDPanel = vgui.Create("DPanel", self)
	self.InfoDPanel.Paint = function(selfp, W,H)
		if !self.StarWars then
			draw.RoundedBoxEx(8, 0, 0, W, H, SecondPanelColor, false, false, true, true)
		end
		local TW, TH = surface.GetTextSize("Name: ")
		draw.SimpleText("Name:", "rhc_inspect_headline", 5, 10, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText(self.Name, "rhc_inspect_information", 5+TW, 10, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		TW, TH = surface.GetTextSize("SteamID: ")
		draw.SimpleText("SteamID:", "rhc_inspect_headline", 5, 25, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText(self.SteamID, "rhc_inspect_information", 5 + TW, 25, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		TW, TH = surface.GetTextSize("Job: ")
		draw.SimpleText("Job:", "rhc_inspect_headline", 5, 40, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText(self.Job, "rhc_inspect_information", 5 + TW, 40, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		TW, TH = surface.GetTextSize("Wallet: ")
		draw.SimpleText("Wallet:", "rhc_inspect_headline", 5, 55, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText(self.Wallet, "rhc_inspect_information", 5 + TW, 55, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end

	self.WeaponHeader = vgui.Create("DPanel", self)
	self.WeaponHeader.Paint = function(selfp, W,H)
		if self.StarWars then
			draw.RoundedBox(4, 0, 0, W, H, Color(21, 34, 56,255))
		else
			draw.RoundedBoxEx(8, 0, 0, W, H, HeaderColor, true, true, false, false)
		end
		draw.SimpleText("illegal Weapons", "rhc_inspect_headline", W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	self.WeaponList = vgui.Create("DScrollPanel", self)
	self.WeaponList.Paint = function(selfp, W, H)
		if !self.StarWars then
			draw.RoundedBoxEx(4, 0, 0, W-15, H, SecondPanelColor, false, false, true, true)
		end
	end

	self.WeaponList.VBar.Paint = function() end
	self.WeaponList.VBar.btnUp.Paint = function() end
	self.WeaponList.VBar.btnDown.Paint = function() end
	self.WeaponList.VBar.btnGrip.Paint = function() end

	if (itemstore or BRICKS_SERVER) and RHandcuffsConfig.InventoryIllegalItemsEnabled then
		self.ItemHeader = vgui.Create("DPanel", self)
		self.ItemHeader.Paint = function(selfp, W,H)
			if self.StarWars then
				draw.RoundedBox(4, 0, 0, W, H, Color(21, 34, 56,255))
			else
				draw.RoundedBoxEx(8, 0, 0, W, H, HeaderColor, true, true, false, false)
			end
			draw.SimpleText("illegal Items", "rhc_inspect_headline", W/2, H/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

		self.ItemList = vgui.Create("DScrollPanel", self)
		self.ItemList.Paint = function(selfp, W, H)
			if !self.StarWars then
				draw.RoundedBoxEx(4, 0, 0, W-15, H, SecondPanelColor, false, false, true, true)
			end
		end

		self.ItemList.VBar.Paint = function() end
		self.ItemList.VBar.btnUp.Paint = function() end
		self.ItemList.VBar.btnDown.Paint = function() end
		self.ItemList.VBar.btnGrip.Paint = function() end
	end

	self.CloseButton = vgui.Create("tbfy_button", self)
	self.CloseButton:SetBText("X")
	if self.StarWars then
		self.CloseButton:SetBoxColor(Color(0,0,0,0), Color(0,0,0,0), Color(0,0,0,0))
	end
	self.CloseButton.DoClick = function() self:Remove() end
end

function PANEL:SetupItems(Items)
	for k,v in pairs(Items) do
		local Item = vgui.Create("rhc_inspect_item", self.ItemList)
		Item.StarWars = self.StarWars
		Item:SetItemInfo(k, v.Name, v.Model)
		self.iItems[k] = Item
	end
end

function PANEL:SetupInfo(Player, WepTbl)
	self.Name = Player:Nick()
	self.Job = Player:getDarkRPVar("job")
	self.SteamID = Player:SteamID()
	self.Wallet = DarkRP.formatMoney(Player:getDarkRPVar("money"))
	local jobTable = {}
	if DarkRP then
		jobTable = Player:getJobTable()
	end

	for k,v in pairs(WepTbl) do
		if !RHandcuffsConfig.BlackListedWeapons[v] then
			if RHC_GetConf("INSPECT_AllowConfiscatingJobWeapons") or (jobTable.weapons and !table.HasValue(jobTable.weapons, v)) then
				local Wep = vgui.Create("rhc_inspect_item", self.WeaponList)
				Wep.StarWars = self.StarWars
				Wep:SetInfo(v, k)
				self.WepItems[k] = Wep
			end
		end
	end
end

local TopH = 25
local InfoH =75
local WeaponListH = 180
local ItemListH = 180
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
		draw.RoundedBoxEx(8, 0, TopH, W, H-TopH, MainPanelColor,false,false,true,true)
	end
end

local WepsPerLine = 4
local Width, Height, Padding = 300, 330, 5
function PANEL:PerformLayout()
	local Height = TopH*2+InfoH+WeaponListH

	if (itemstore or BRICKS_SERVER) and RHandcuffsConfig.InventoryIllegalItemsEnabled then
		Height = Height+ItemListH+TopH
	end

	self:SetPos(ScrW()/2-Width/2, ScrH()/2-Height/2)
	self:SetSize(Width, Height)

	self.TopDPanel:SetPos(0,0)
	self.TopDPanel:SetSize(Width,TopH)

	self.InfoDPanel:SetPos(Padding,TopH+Padding)
	self.InfoDPanel:SetSize(Width-Padding*2,InfoH-Padding*2)

	self.WeaponHeader:SetPos(Padding,TopH+InfoH)
	self.WeaponHeader:SetSize(Width-Padding*2,TopH)

	self.WeaponList:SetPos(Padding,TopH*2+InfoH)
	self.WeaponList:SetSize(Width+Padding, WeaponListH-Padding)

	local WAvailable = self.WeaponList:GetWide()-15
	local WepWSize = WAvailable/WepsPerLine

	local NumSlots = 0
	local CRow = 0
	for k,v in pairs(self.WepItems) do
		if IsValid(v) then
			if NumSlots >= WepsPerLine then
				NumSlots = 0
				CRow = CRow + 1
			end
			v:SetPos(WepWSize*(NumSlots),CRow*(WepWSize+15))
			v:SetSize(WepWSize,WepWSize+15)
			NumSlots = NumSlots + 1
		end
	end

	if (itemstore or BRICKS_SERVER) and RHandcuffsConfig.InventoryIllegalItemsEnabled then
		self.ItemHeader:SetPos(Padding,TopH*2+InfoH+WeaponListH)
		self.ItemHeader:SetSize(Width-Padding*2,TopH)

		self.ItemList:SetPos(Padding,TopH*3+InfoH+ItemListH)
		self.ItemList:SetSize(Width+Padding, ItemListH-Padding)

		local NumSlots = 0
		local CRow = 0
		for k,v in pairs(self.iItems) do
			if IsValid(v) then
				if NumSlots >= WepsPerLine then
					NumSlots = 0
					CRow = CRow + 1
				end
				v:SetPos(WepWSize*(NumSlots),CRow*(WepWSize+15))
				v:SetSize(WepWSize,WepWSize+15)
				NumSlots = NumSlots + 1
			end
		end
	end

	self.CloseButton:SetPos(Width-TopH,TopH/2-9)
	self.CloseButton:SetSize(20, 20)
end
vgui.Register("rhc_inspect_menu", PANEL, "DFrame")
