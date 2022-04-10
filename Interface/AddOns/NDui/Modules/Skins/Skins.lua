local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:RegisterModule("Skins")

local pairs, wipe = pairs, wipe
local IsAddOnLoaded = IsAddOnLoaded
local LE_ITEM_QUALITY_COMMON, BAG_ITEM_QUALITY_COLORS = LE_ITEM_QUALITY_COMMON, BAG_ITEM_QUALITY_COLORS

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
	if not C.db["Skins"]["BlizzardSkins"] then
		wipe(C.defaultThemes)
		wipe(C.themes)
	end

	if next(C.defaultThemes) then
		for _, func in pairs(C.defaultThemes) do
			func()
		end
		wipe(C.defaultThemes)
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

	hooksecurefunc("SetItemButtonQuality", function(button, quality)
		if quality then
			if quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality] then
				button.IconBorder:Show()
				button.IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b)
			else
				button.IconBorder:Hide()
			end
		else
			button.IconBorder:Hide()
		end
	end)
end

function S:OnLogin()
	self:LoadAddOnSkins()

	-- Add Skins
	self:QuestTracker()
	self:TradeSkillSkin()
	self:DBMSkin()
	self:SkadaSkin()
	self:LoadOtherSkins()

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
	open:ClearAllPoints()
	open:SetPoint(rel1, parent, rel1, -x, -y)
	open:SetSize(width, height)

	if C.db["Skins"]["ToggleDirection"] == 5 then
		close:SetScale(.001)
		close:SetAlpha(0)
		open:SetScale(.001)
		open:SetAlpha(0)
		close.text:SetText("")
		open.text:SetText("")
	else
		close:SetScale(1)
		close:SetAlpha(1)
		open:SetScale(1)
		open:SetAlpha(1)
		close.text:SetText(str1)
		open.text:SetText(str2)
	end
end

function S:RefreshToggleDirection()
	for _, frame in pairs(toggleFrames) do
		S:SetToggleDirection(frame)
	end
end

S.SharedWindowData = {
	area = "override",
	xoffset = -16,
	yoffset = 12,
	bottomClampOverride = 152,
	width = 714,
	height = 487,
	whileDead = 1,
}

function S:EnlargeDefaultUIPanel(name, pushed)
	local frame = _G[name]
	if not frame then return end

	UIPanelWindows[name] = S.SharedWindowData
	UIPanelWindows[name].pushable = pushed

	frame:SetSize(S.SharedWindowData.width, S.SharedWindowData.height)
	frame.TitleText:ClearAllPoints()
	frame.TitleText:SetPoint("TOP", frame, 0, -18)

	frame.scrollFrame:ClearAllPoints()
	frame.scrollFrame:SetPoint("TOPRIGHT", frame, -65, -70)
	frame.scrollFrame:SetPoint("BOTTOMRIGHT", frame, -65, 80)
	frame.listScrollFrame:ClearAllPoints()
	frame.listScrollFrame:SetPoint("TOPLEFT", frame, 19, -70)
	frame.listScrollFrame:SetPoint("BOTTOMLEFT", frame, 19, 80)

	if not C.db["Skins"]["BlizzardSkins"] then
		local leftTex = frame:CreateTexture(nil, "BACKGROUND")
		leftTex:SetTexture(309665)
		leftTex:SetSize(512, 512)
		leftTex:SetPoint("TOPLEFT")
		local rightTex = frame:CreateTexture(nil, "BACKGROUND")
		rightTex:SetTexture(309666)
		rightTex:SetSize(256, 512)
		rightTex:SetPoint("TOPLEFT", leftTex, "TOPRIGHT")
	end
end