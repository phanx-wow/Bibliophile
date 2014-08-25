--[[--------------------------------------------------------------------
	Bibliophile
	Stores the contents of in-game books so you can read them later.
	Copyright (c) 2013-2014 Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info-Bibliophile.html
	http://www.curse.com/addons/wow/bibliophile
----------------------------------------------------------------------]]

local ADDON, private = ...

BibliophileDB = {}
--[[
	"enUS" = {
		"Book Title" = {
			complete = true,
			material = "Material",
			pages = {
				[1] = "Page text",
				[2] = "Page text",
			},
			locations = {
				"mapID" = "position",
			},
		}
	}
]]

local Collect = CreateFrame("Frame")
Collect:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)
Collect:RegisterEvent("PLAYER_LOGIN")

function Collect:PLAYER_LOGIN()	
	local lang = GetLocale()
	self.db = BibliophileDB[lang] or {}
	BibliophileDB[lang] = self.db
	
	self:RegisterEvent("ITEM_TEXT_BEGIN")
	self:RegisterEvent("ITEM_TEXT_CLOSED")
	self:RegisterEvent("ITEM_TEXT_READY")
	self:RegisterEvent("ITEM_TEXT_TRANSLATION")
end

function Collect:ITEM_TEXT_BEGIN(...)
	print("ITEM_TEXT_BEGIN", ...)
	local name = ItemTextGetItem()
	local creator = ItemTextGetCreator()
	local material = ItemTextGetMaterial()
	local page = ItemTextGetPage()
	local text = ItemTextGetText()
	local isLastPage = not ItemTextHasNextPage()
	local zone = GetCurrentMapAreaID()
end

function Collect:ITEM_TEXT_READY(...)
	print("ITEM_TEXT_READY", ...)
end

function Collect:ITEM_TEXT_TRANSLATION(...)
	print("ITEM_TEXT_TRANSLATION", ...)
end

function Collect:ITEM_TEXT_CLOSED(...)
	print("ITEM_TEXT_CLOSED", ...)
end

