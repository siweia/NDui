local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:RegisterModule("Skins")

function S:OnLogin()
	-- Add Skins
	self:MicroMenu()
	self:CreateRM()
	self:QuestTracker()
	self:PetBattleUI()

	self:DBMSkin()
	self:SkadaSkin()
	self:BigWigsSkin()
	self:PGFSkin()
	self:ReskinRematch()
	self:PostalSkin()

	-- Register skin
	local media = LibStub and LibStub("LibSharedMedia-3.0", true)
	if media then
		media:Register("statusbar", "normTex", DB.normTex)
	end
end

function S:CreateToggle(frame)
	local close = B.CreateButton(frame, 20, 80, ">", 18)
	close:SetPoint("RIGHT", frame.bg, "LEFT", -2, 0)
	B.CreateSD(close)
	B.CreateTex(close)

	local open = B.CreateButton(UIParent, 20, 80, "<", 18)
	open:SetPoint("RIGHT", frame.bg, "RIGHT", 2, 0)
	B.CreateSD(open)
	B.CreateTex(open)
	open:Hide()

	open:SetScript("OnClick", function()
		open:Hide()
	end)
	close:SetScript("OnClick", function()
		open:Show()
	end)

	return open, close
end

function S:LoadWithAddOn(addonName, value, func)
	local function loadFunc(event, addon)
		if not NDuiDB["Skins"][value] then return end

		if event == "PLAYER_ENTERING_WORLD" then
			B:UnregisterEvent(event, loadFunc)
			if IsAddOnLoaded(addonName) then
				func()
				B:UnregisterEvent("ADDON_LOADED", loadFunc)
			end
		elseif event == "ADDON_LOADED" and addon == addonName then
			func()
			B:UnregisterEvent(event, loadFunc)
		end
	end

	B:RegisterEvent("PLAYER_ENTERING_WORLD", loadFunc)
	B:RegisterEvent("ADDON_LOADED", loadFunc)
end