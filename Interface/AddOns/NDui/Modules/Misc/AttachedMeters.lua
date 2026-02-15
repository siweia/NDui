local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local menu = {
	{text = DAMAGE_METER_LABEL, isTitle = true, notCheckable = true},
	{text = "", isTitle = true, notCheckable = true, iconOnly = true,
		icon = "Interface\\Common\\UI-TooltipDivider-Transparent",
		iconInfo = {tSizeX = 0, tSizeY = 8, tFitDropDownSizeX = true}
	},
	{text = "依附到窗口", arg1 = 1, hasArrow = true,
		menuList = {
			{text = "上", arg1 = 1, func = nil},
			{text = "下", arg1 = 2, func = nil},
			{text = "左", arg1 = 3, func = nil},
			{text = "右", arg1 = 4, func = nil},
		}
	},
	{text = "依附到窗口", arg1 = 3, hasArrow = true,
		menuList = {
			{text = "上", arg1 = 1, func = nil},
			{text = "下", arg1 = 2, func = nil},
			{text = "左", arg1 = 3, func = nil},
			{text = "右", arg1 = 4, func = nil},
		}
	},
}

function M:AttachedMeters_CallMenu(btn)
	if btn == "RightButton" then
		EasyMenu(menu, B.EasyMenu, self, -80, 100, "MENU", 1)
	end
end

function M:AttachedMeters_Setup(frame)
	if not frame.attached then
		frame:SetClampedToScreen(false)
		if frame.ResizeButton then
			frame.ResizeButton:RegisterForClicks("AnyUp")
			frame.ResizeButton:HookScript("OnClick", M.AttachedMeters_CallMenu)
		end

		frame.attached = true
	end
end

function M:AttachedMeters_Start()
	DamageMeter:SetClampedToScreen(false)

	hooksecurefunc(DamageMeter, "SetupSessionWindow", function(_, windowData)
		M:AttachedMeters_Setup(windowData.sessionWindow)
	end)

	for i = 1, 3 do
		local frame = _G["DamageMeterSessionWindow"..i]
		if frame then
			M:AttachedMeters_Setup(frame)
		end
	end
end

local function JustWait(event, addon)
	if addon == "Blizzard_DamageMeter" then
		M:AttachedMeters_Start()
		B:UnregisterEvent(event, JustWait)
	end
end

function M:AttachedMeters()
	if not C.db["Skins"]["DamageMeter"] then return end

	if C_AddOns.IsAddOnLoaded("Blizzard_DamageMeter") then
		M:AttachedMeters_Start()
	else
		B:RegisterEvent("ADDON_LOADED", JustWait)
	end
end
M:RegisterMisc("AttachedMeters", M.AttachedMeters)