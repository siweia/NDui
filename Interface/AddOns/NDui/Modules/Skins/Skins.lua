local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:RegisterModule("Skins")

C.themes = {}
C.themes["AuroraClassic"] = {}

StaticPopupDialogs["AURORA_CLASSIC_WARNING"] = {
	text = L["AuroraClassic warning"],
	button1 = DISABLE,
	hideOnEscape = false,
	whileDead = 1,
	OnAccept = function()
		DisableAddOn("Aurora")
		DisableAddOn("AuroraClassic")
		ReloadUI()
	end,
}
function S:DetectAurora()
	if DB.isDeveloper then return end

	if IsAddOnLoaded("AuroraClassic") or IsAddOnLoaded("Aurora") then
		StaticPopup_Show("AURORA_CLASSIC_WARNING")
	end
end

function S:LoadDefaultSkins()
	if IsAddOnLoaded("AuroraClassic") or IsAddOnLoaded("Aurora") then return end

	-- Reskin Blizzard UIs
	for _, func in pairs(C.themes["AuroraClassic"]) do
		func()
	end
	if NDuiDB["Skins"]["BlizzardSkins"] then
		B:RegisterEvent("ADDON_LOADED", function(_, addon)
			local func = C.themes[addon]
			if func then func() end
		end)
	end
end

function S:OnLogin()
	self:DetectAurora()
	self:LoadDefaultSkins()

	-- Add Skins
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

local function CreateToggleButton(parent)
	local bu = CreateFrame("Button", nil, parent)
	bu:SetSize(20, 80)
	bu.text = B.CreateFS(bu, 18, nil, true)
	B.ReskinMenuButton(bu)

	return bu
end

function S:CreateToggle(frame)
	local close = CreateToggleButton(frame)
	frame.closeButton = close

	local open = CreateToggleButton(UIParent)
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