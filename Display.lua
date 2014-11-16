--[[--------------------------------------------------------------------
	Bibliophile
	Stores the contents of in-game books so you can read them later.
	Copyright (c) 2013-2014 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info-Bibliophile.html
	http://www.curse.com/addons/wow/bibliophile
	https://github.com/Phanx/Bibliophile
----------------------------------------------------------------------]]

local ADDON, private = ...

------------------------------------------------------------------------

ItemTextPageText:EnableMouseWheel(true)
ItemTextPageText:SetScript("OnMouseWheel", function(self, delta)
	local page = (delta < 0) and ItemTextNextPageButton or (delta > 0) and ItemTextPrevPageButton
	local scroll = (delta < 0) and ItemTextScrollFrameScrollBarScrollDownButton or (delta > 0) and ItemTextScrollFrameScrollBarScrollUpButton

	if scroll:IsVisible() and scroll:IsEnabled() then
		scroll:Click()
	elseif page:IsVisible() then
		page:Click()
	end
end)

------------------------------------------------------------------------

local Display = CreateFrame("Frame", "Bibliophile", UIParent, "ButtonFrameTemplate")
Display:Hide()

function Display:Setup()
	local f, fs, tx

	self:SetSize(667, 496)
	self:SetPoint("TOPLEFT")
	self:EnableMouse(true)

	tx = self:CreateTexture(nil, "OVERLAY")
	tx:SetTexture("Interface\\QuestFrame\\UI-QuestLog-BookIcon")
	tx:SetSize(64, 64)
	tx:SetPoint("TOPLEFT", -9, 9)
	self.BookIcon = tx

	tx = self:CreateTexture(nil, "BACKGROUND")
	tx:SetTexture("Interface\\QuestFrame\\QuestBookBG")
	tx:SetSize(510, 620)
	tx:SetPoint("TOPLEFT", 6, -63)
	self.BookBG = tx

	tx = self:CreateTexture(nil, "BACKGROUND")
	tx:SetTexture("Interface\\QuestFrame\\QuestBG")
	tx:SetSize(510, 620)
	tx:SetPoint("TOPLEFT", 336, -62)
	self.QuestBG = tx

	fs = self:CreateFontString("$parentTitleText", "OVERLAY", "GameFontNormal")
	fs:SetText(GetAddOnMetadata(ADDON, "Title"))
	fs:SetSize(300, 14)
	fs:SetPoint("TOP", 0, -3)
	self.TitleText = fs

	--
	--	Inner border
	--

	tx = self:CreateTexture(nil, "OVERLAY", "UI-Frame-InnerTopLeft")
	tx:SetPoint("TOPLEFT", self, "TOPRIGHT", -334, -60)
	self.InsetBorderTopLeft = tx

	tx = self:CreateTexture(nil, "OVERLAY", "UI-Frame-InnerBotLeftCorner")
	tx:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", -334, 25)
	self.InsetBorderBotLeft = tx

	tx = self:CreateTexture(nil, "OVERLAY", "!UI-Frame-InnerLeftTile")
	tx:SetPoint("TOPLEFT", self.InsetBorderTopLeft, "BOTTOMLEFT")
	tx:SetPoint("BOTTOMLEFT", self.InsetBorderBotLeft, "TOPLEFT")
	self.InsetBorderLeft = tx

	--
	--	Count
	--

	f = CreateFrame("Frame", "$parentCount", self, "InsetFrameTemplate3")
	f:SetSize(120, 20)
	f:SetPoint("TOPLEFT", 70, -33)

	fs = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	fs:SetPoint("CENTER")
	self.Count = fs

	--
	--	"No books" frame
	--

	f = CreateFrame("Frame", "$parentNoBooks", self)
	f:Hide()
	f:SetSize(302, 396)
	f:SetPoint("TOPLEFT", 5, -63)

	tx = f:CreateTexture(nil, "BACKGROUND")
	tx:SetTexture("Interface\\QuestFrame\\UI-QuestLog-Empty-TopLeft")
	tx:SetSize(256, 256)
	tx:SetPoint("TOPLEFT")
	f.BackgroundTopLeft = tx

	tx = f:CreateTexture(nil, "BACKGROUND")
	tx:SetTexture("Interface\\QuestFrame\\UI-QuestLog-Empty-BotLeft")
	tx:SetSize(256, 190)
	tx:SetPoint("TOPRIGHT", f.BackgroundTopLeft, "BOTTOMRIGHT")
	tx:SetTexCoord(0, 1, 0, 0.828125) -- 212/256
	f.BackgroundBotLeft = tx

	tx = f:CreateTexture(nil, "BACKGROUND")
	tx:SetTexture("Interface\\QuestFrame\\UI-QuestLog-Empty-TopRight")
	tx:SetSize(46, 256)
	tx:SetPoint("TOPRIGHT")
	tx:SetPoint("BOTTOMLEFT", f.BackgroundTopLeft, "BOTTOMRIGHT")
	tx:SetTexCoord(0, 0.71875, 0, 1) -- 184/256
	f.BackgroundTopRight = tx

	tx = f:CreateTexture(nil, "BACKGROUND")
	tx:SetTexture("Interface\\QuestFrame\\UI-QuestLog-Empty-BotRight")
	tx:SetSize(256, 190)
	tx:SetPoint("TOPLEFT", f.BackgroundTopLeft, "BOTTOMRIGHT")
	tx:SetTexCoord(0, 0.71875, 0, 0.828125) -- 184/256, 212/256
	f.BackgroundBotRight = tx

	fs = f:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	fs:SetText("You haven't read any books yet!")
	fs:SetWidth(200)
	fs:SetPoint("CENTER", -6, 16)
	f.Text = fs

	--
	--	Scroll frame
	--

	f = CreateFrame("ScrollFrame", "$parentScrollFrame", self, "HybridScrollFrameTemplate")
	f:SetSize(305, 403)
	f:SetPoint("TOPLEFT", 6, -64)
	self.ScrollFrame = f

	tx = f:CreateTexture(nil, "BACKGROUND")
	tx:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
	tx:SetSize(29, 102)
	tx:SetPoint("TOPLEFT", f, "TOPRIGHT", -6, 5)
	tx:SetTexCoord(0, 0.445, 0, 0.4)
	f.Top = tx

	tx = f:CreateTexture(nil, "BACKGROUND")
	tx:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
	tx:SetSize(29, 106)
	tx:SetPoint("BOTTOMLEFT", f, "BOTTOMRIGHT", -6, -2)
	tx:SetTexCoord(0.515625, 0.960625, 0, 0.4140625)
	f.Bottom = tx

	tx = f:CreateTexture(nil, "BACKGROUND")
	tx:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
	tx:SetSize(29, 1)
	tx:SetPoint("TOP", f.Top, "BOTTOM")
	tx:SetPoint("BOTTOM", f.Bottom, "TOP")
	tx:SetTexCoord(0, 0.445, 0.75, 1)
	f.Middle = tx

	f = CreateFrame("Slider", "$parentScrollBar", self.ScrollFrame, "HybridScrollBarTemplate")
	f:SetPoint("TOPLEFT", self.ScrollFrame, "TOPRIGHT", 0, -13)
	f:SetPoint("BOTTOMLEFT", self.scrollFrame, "TOPRIGHT", 0, 14)
	self.ScrollFrame.ScrollBar = f

	do
		local n = f:GetName()
		_G[n.."BG"]:Hide()
		_G[n.."Top"]:Hide()
		_G[n.."Bottom"]:Hide()
		_G[n.."Middle"]:Hide()
		f.doNotHide = true
	end

	--
	--	Title highlight
	--

	f = CreateFrame("Frame", "$parentHighlightFrame", self.ScrollFrame)
	f:Hide()
	f:SetPoint("TOPLEFT")
	f:SetPoint("BOTTOMRIGHT")
	f:SetParent(nil)
	self.HighlightFrame = f

	tx = f:CreateTexture(nil, "ARTWORK")
	tx:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
	tx:SetBlendMode("ADD")

	--
	--	Detail frame
	--

	f = CreateFrame("Frame", "$parentDetailFrame", self, "ButtonFrameTemplate")
	f:SetSize(338, 496)
	f:SetPoint("TOPLEFT", self, "TOPRIGHT")
end