--[[--------------------------------------------------------------------
	Bibliophile
	Stores the contents of in-game books so you can read them later.
	Copyright (c) 2013-2015 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info-Bibliophile.html
	http://www.curse.com/addons/wow/bibliophile
	https://github.com/Phanx/Bibliophile
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

	self:RegisterEvent("ITEM_TEXT_READY")
end

function Collect:ITEM_TEXT_READY()
	--print("ITEM_TEXT_READY")
	if ItemTextGetCreator() then
		-- Ignore saved mail and other player-created items
		return
	end

	local title = ItemTextGetItem()
	local page = ItemTextGetPage()
	--print("Scanning page", page, "of book", title)

	local t = self.db[title] or {}
	t.material = ItemTextGetMaterial()

	t.pages = t.pages or {}
	t.pages[page] = ItemTextGetText()

	if not ItemTextHasNextPage() then
		--print("Last page")
		t.complete = true
		for i = 1, page do
			if not t.pages[i] then
				--print("Missing text for page", i)
				t.complete = nil
				break
			end
		end
	end

	if GetItemCount(title) == 0 then
		-- Coordinate storage format borrowed from LibMapData-1.0 by Kagaro
		local zone = GetCurrentMapAreaID()
		local level = GetCurrentMapDungeonLevel() or 0
		local x, y = GetPlayerMapPosition("player")
		t.locations = t.locations or {}
		t.locations[zone] = floor(x * 10000 + 0.5) * 1000000 + floor(y * 10000 + 0.5) * 100 + level
		--print("Saved location", t.locations[zone], "in", zone)
	end

	self.db[title] = t
end
