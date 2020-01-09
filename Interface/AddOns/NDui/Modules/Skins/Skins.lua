local _, ns = ...
local B, C, L, DB, F = unpack(ns)
local S = B:RegisterModule("Skins")

C.themes = {}
C.themes["AuroraClassic"] = {}

function S:OnLogin()
	if not F then
		-- Reskin Blizzard UIs
		for _, func in pairs(C.themes["AuroraClassic"]) do
			func()
		end
		B:RegisterEvent("ADDON_LOADED", function(_, addon)
			local func = C.themes[addon]
			if func then func() end
		end)
	end

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

function S:GetToggleDirection()
	local direc = NDuiDB["Skins"]["ToggleDirection"]
	if direc == 1 then
		return ">", "<", "RIGHT", "LEFT", -2, 0, 20, 80
	elseif direc == 2 then
		return "<", ">", "LEFT", "RIGHT", 2, 0, 20, 80
	elseif direc == 3 then
		return "∨", "∧", "BOTTOM", "TOP", 0, 2, 80, 20
	else
		return "∧", "∨", "TOP", "BOTTOM", 0, -2, 80, 20
	end
end

local toggleFrames = {}

function S:CreateToggle(frame)
	local close = B.CreateButton(frame, 20, 80, ">", 18)
	B.CreateSD(close)
	B.CreateTex(close)
	frame.closeButton = close

	local open = B.CreateButton(UIParent, 20, 80, "<", 18)
	B.CreateSD(open)
	B.CreateTex(open)
	open:Hide()
	frame.openButton = open

	open:SetScript("OnClick", function()
		open:Hide()
	end)
	close:SetScript("OnClick", function()
		open:Show()
	end)

	S:SetToggleDirection(frame)
	tinsert(toggleFrames, frame)

	return open, close
end

function S:SetToggleDirection(frame)
	local str1, str2, rel1, rel2, x, y, width, height = S:GetToggleDirection()
	local parent = frame.bg
	local close = frame.closeButton
	local open = frame.openButton
	close:ClearAllPoints()
	close:SetPoint(rel1, parent, rel2, x, y)
	close:SetSize(width, height)
	close.text:SetText(str1)
	open:ClearAllPoints()
	open:SetPoint(rel1, parent, rel1, -x, -y)
	open:SetSize(width, height)
	open.text:SetText(str2)
end

function S:RefreshToggleDirection()
	for _, frame in pairs(toggleFrames) do
		S:SetToggleDirection(frame)
	end
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