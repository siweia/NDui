local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")
--[[
	职业大厅图标，取代自带的信息条
]]
local ipairs, format = ipairs, format
local GetCurrencyInfo, IsShiftKeyDown = GetCurrencyInfo, IsShiftKeyDown
local C_Garrison_GetCurrencyTypes = C_Garrison.GetCurrencyTypes
local C_Garrison_GetClassSpecCategoryInfo = C_Garrison.GetClassSpecCategoryInfo
local C_Garrison_RequestClassSpecCategoryInfo = C_Garrison.RequestClassSpecCategoryInfo
local LE_GARRISON_TYPE_7_0, LE_FOLLOWER_TYPE_GARRISON_7_0 = LE_GARRISON_TYPE_7_0, LE_FOLLOWER_TYPE_GARRISON_7_0

function M:OrderHall_CreateIcon()
	local hall = CreateFrame("Frame", "NDuiOrderHallIcon", UIParent)
	hall:SetSize(50, 50)
	hall:SetPoint("TOP", 0, -30)
	hall:SetFrameStrata("HIGH")
	hall:Hide()
	B.CreateMF(hall, true)
	B.RestoreMF(hall)
	M.OrderHallIcon = hall

	hall.Icon = hall:CreateTexture(nil, "ARTWORK")
	hall.Icon:SetAllPoints()
	hall.Icon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
	hall.Icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[DB.MyClass]))
	hall.Category = {}

	hall:SetScript("OnEnter", M.OrderHall_OnEnter)
	hall:SetScript("OnLeave", M.OrderHall_OnLeave)
	hooksecurefunc(OrderHallCommandBar, "SetShown", function(_, state)
		hall:SetShown(state)
	end)

	-- Default objects
	B.HideOption(OrderHallCommandBar)
	GarrisonLandingPageTutorialBox:SetClampedToScreen(true)
end

function M:OrderHall_Refresh()
	C_Garrison_RequestClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
	local currency = C_Garrison_GetCurrencyTypes(LE_GARRISON_TYPE_7_0)
	self.name, self.amount, self.texture = GetCurrencyInfo(currency)

	local categoryInfo = C_Garrison_GetClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
	for index, info in ipairs(categoryInfo) do
		local category = self.Category[index]
		if not category then category = {} end
		category.name = info.name
		category.count = info.count
		category.limit = info.limit
		category.description = info.description
	end
	self.numCategory = #categoryInfo
end

function M:OrderHall_OnShiftDown(btn)
	if btn == "LSHIFT" then
		M.OrderHall_OnEnter(M.OrderHallIcon)
	end
end

local function GetAmountString(self)
	return self.amount..format(" |T%s:12:12:0:0:64:64:5:59:5:59|t ", self.texture)
end

function M:OrderHall_OnEnter()
	M.OrderHall_Refresh(self)

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 5, -5)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(DB.MyColor.._G["ORDER_HALL_"..DB.MyClass])
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(self.name, GetAmountString(self), 1,1,1, 1,1,1)

	local blank
	for i = 1, self.numCategory do
		if not blank then
			GameTooltip:AddLine(" ")
			blank = true
		end
		local category = self.Category[i]
		GameTooltip:AddDoubleLine(category.name, category.count.."/"..category.limit, 1,1,1, 1,1,1)
		if IsShiftKeyDown() then
			GameTooltip:AddLine(category.description, .6,.8,1, 1)
		end
	end

	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", L["Details by Shift"], 1,1,1, .6,.8,1)
	GameTooltip:Show()

	B:RegisterEvent("MODIFIER_STATE_CHANGED", M.OrderHall_OnShiftDown)
end

function M:OrderHall_OnLeave()
	GameTooltip:Hide()
	B:UnregisterEvent("MODIFIER_STATE_CHANGED", M.OrderHall_OnShiftDown)
end

function M:OrderHall_OnLoad(addon)
	if addon == "Blizzard_OrderHallUI" then
		M:OrderHall_CreateIcon()
		B:UnregisterEvent(self, M.OrderHall_OnLoad)
	end
end

function M:OrderHall_OnInit()
	if IsAddOnLoaded("Blizzard_OrderHallUI") then
		M:OrderHall_CreateIcon()
	else
		B:RegisterEvent("ADDON_LOADED", M.OrderHall_OnLoad)
	end
end
B:RegisterMisc("OrderHallIcon", M.OrderHall_OnInit)