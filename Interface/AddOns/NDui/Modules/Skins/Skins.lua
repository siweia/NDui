local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:RegisterModule("Skins")

local pairs, wipe = pairs, wipe
local IsAddOnLoaded = IsAddOnLoaded

C.defaultThemes = {}
C.themes = {}
C.otherSkins = {}

function S:RegisterSkin(addonName, func)
	C.otherSkins[addonName] = func
end

function S:LoadSkins(list)
	if not next(list) then return end

	for addonName, func in pairs(list) do
		local isLoaded, isFinished = IsAddOnLoaded(addonName)
		if isLoaded and isFinished then
			func()
			list[addonName] = nil
		end
	end
end

function S:LoadAddOnSkins()
	if IsAddOnLoaded("AuroraClassic") or IsAddOnLoaded("Aurora") then return end

	-- Reskin Blizzard UIs
	for _, func in pairs(C.defaultThemes) do
		func()
	end
	wipe(C.defaultThemes)

	if not C.db["Skins"]["BlizzardSkins"] then
		wipe(C.themes)
	end

	S:LoadSkins(C.themes) -- blizzard ui
	S:LoadSkins(C.otherSkins) -- other addons

	B:RegisterEvent("ADDON_LOADED", function(_, addonName)
		local func = C.themes[addonName]
		if func then
			func()
			C.themes[addonName] = nil
		end

		local func = C.otherSkins[addonName]
		if func then
			func()
			C.otherSkins[addonName] = nil
		end
	end)
end

function S:OnLogin()
	self:LoadAddOnSkins()

	-- Add Skins
	self:DBMSkin()
	self:SkadaSkin()
	self:PGFSkin()
	self:ReskinRematch()
	self:OtherSkins()

	-- Register skin
	local media = LibStub and LibStub("LibSharedMedia-3.0", true)
	if media then
		media:Register("statusbar", "normTex", DB.normTex)
	end
end

function S:GetToggleDirection()
	local direc = C.db["Skins"]["ToggleDirection"]
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

	if C.db["Skins"]["ToggleDirection"] == 5 then
		close:SetScale(.001)
		close:SetAlpha(0)
		open:SetScale(.001)
		open:SetAlpha(0)
	else
		close:SetScale(1)
		close:SetAlpha(1)
		open:SetScale(1)
		open:SetAlpha(1)
	end
end

function S:RefreshToggleDirection()
	for _, frame in pairs(toggleFrames) do
		S:SetToggleDirection(frame)
	end
end