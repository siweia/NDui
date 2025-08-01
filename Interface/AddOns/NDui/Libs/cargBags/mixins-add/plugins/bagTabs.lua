--[[
	Create tabs for blizzard AccountBankPanel.
	By siweia.
]]
local addon, ns = ...
local B, C, L, DB = unpack(ns)
local cargBags = ns.cargBags
local Implementation = cargBags.classes.Implementation

local AccountBankPanel = AccountBankPanel
local BANK_TAB1 = Enum.BagIndex.AccountBankTab_1 or 13
local ACCOUNT_BANK_TYPE = Enum.BankType.Account or 2

function Implementation:GetBagTabClass()
	return self:GetClass("BagTab", true, "BagTab")
end

local BagTab = cargBags:NewClass("BagTab", nil, "Button")

-- Default attributes
BagTab.bgTex = QUESTION_MARK_ICON

local function AddBankTabSettingsToTooltip(tooltip, depositFlags)
	if not tooltip or not depositFlags then return end

	if FlagsUtil.IsSet(depositFlags, Enum.BagSlotFlags.ExpansionCurrent) then
		GameTooltip_AddNormalLine(tooltip, BANK_TAB_EXPANSION_ASSIGNMENT:format(BANK_TAB_EXPANSION_FILTER_CURRENT))
	elseif FlagsUtil.IsSet(depositFlags, Enum.BagSlotFlags.ExpansionLegacy) then
		GameTooltip_AddNormalLine(tooltip, BANK_TAB_EXPANSION_ASSIGNMENT:format(BANK_TAB_EXPANSION_FILTER_LEGACY))
	end
	
	local filterList = ContainerFrameUtil_ConvertFilterFlagsToList(depositFlags)
	if filterList then
		GameTooltip_AddNormalLine(tooltip, BANK_TAB_DEPOSIT_ASSIGNMENTS:format(filterList), true)
	end
end

local function UpdateTooltip(self, id)
	if not AccountBankPanel.purchasedBankTabData then return end
	local data = AccountBankPanel.purchasedBankTabData[id]
	if not data then return end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip_SetTitle(GameTooltip, data.name, NORMAL_FONT_COLOR)
	AddBankTabSettingsToTooltip(GameTooltip, data.depositFlags)
	GameTooltip_AddInstructionLine(GameTooltip, BANK_TAB_TOOLTIP_CLICK_INSTRUCTION)
	GameTooltip:Show()
end

local buttonNum = 0
function BagTab:Create(bagID)
	buttonNum = buttonNum + 1
	local name = addon.."BagTab"..buttonNum
	local button = setmetatable(CreateFrame("Button", name, nil, "BackdropTemplate"), self.__index)
	button:SetID(buttonNum)
	button.bagId = buttonNum + BANK_TAB1 - 1

	B.PixelIcon(button, BagTab.bgTex, true)
	button:RegisterForDrag("LeftButton", "RightButton")
	button:RegisterForClicks("AnyUp")
	button:SetSize(37, 37)

	cargBags.SetScriptHandlers(button, "OnClick", "OnEnter", "OnLeave")

	if(button.OnCreate) then button:OnCreate(bagID) end

	return button
end

local function highlight(button, func, bagID)
	func(button, not bagID or button.bagId == bagID)
end

function BagTab:OnEnter()
	local hlFunction = self.bar.highlightFunction

	if(hlFunction) then
		if(self.bar.isGlobal) then
			for _, container in pairs(self.implementation.contByID) do
				container:ApplyToButtons(highlight, hlFunction, self.bagId)
			end
		else
			self.bar.container:ApplyToButtons(highlight, hlFunction, self.bagId)
		end
	end

	UpdateTooltip(self, self:GetID())
end

function BagTab:OnLeave()
	local hlFunction = self.bar.highlightFunction

	if(hlFunction) then
		if(self.bar.isGlobal) then
			for _, container in pairs(self.implementation.contByID) do
				container:ApplyToButtons(highlight, hlFunction)
			end
		else
			self.bar.container:ApplyToButtons(highlight, hlFunction)
		end
	end

	GameTooltip:Hide()
end

function BagTab:UpdateButton()
	local container = self.bar.container
	if(container and container.SetFilter) then
		if(not self.filter) then
			local bagID = self.bagId
			self.filter = function(i) return i.bagId ~= bagID end
		end
		self.hidden = not self.hidden

		if(self.bar.isGlobal) then
			for _, container in pairs(container.implementation.contByID) do
				container:SetFilter(self.filter, self.hidden)
				container.implementation:OnEvent("BAG_UPDATE", self.bagId)
			end
		else
			container:SetFilter(self.filter, self.hidden)
			container.implementation:OnEvent("BAG_UPDATE", self.bagId)
		end
	end

	if self.hidden then
		self.bg:SetBackdropBorderColor(0, 0, 0)
	else
		self.bg:SetBackdropBorderColor(1, .8, 0)
	end
end

function BagTab:OnClick(btn)
	if not AccountBankPanel.purchasedBankTabData then return end

	local currentTabID = self:GetID()
	local data = AccountBankPanel.purchasedBankTabData[currentTabID]
	if not data then return end

	if btn == "LeftButton" then
		self.bar.buttons[currentTabID]:UpdateButton()
	else -- right button
		local menu = AccountBankPanel.TabSettingsMenu
		if menu then
			if menu:IsShown() then menu:Hide() end
			menu:SetParent(UIParent)
			menu:ClearAllPoints()
			menu:SetPoint("CENTER", 0, 100)
			menu:EnableMouse(true)
			menu:TriggerEvent(BankPanelTabSettingsMenuMixin.Event.OpenTabSettingsRequested, self.bagId)
		end
	end
end

local function updater(self)
	for _, button in pairs(self.buttons) do
		button:UpdateButton()
	end
end

-- Register the plugin
cargBags:RegisterPlugin("BagTab", function(self, bags)
	if DB.isNewPatch then return end
	if(cargBags.ParseBags) then
		bags = cargBags:ParseBags(bags)
	end

	local bar = CreateFrame("Frame", nil, self)
	bar.container = self

	bar.layouts = cargBags.classes.Container.layouts
	bar.LayoutButtons = cargBags.classes.Container.LayoutButtons

	local buttonClass = self.implementation:GetBagTabClass()
	bar.buttons = {}
	for i = 1, #bags do
		local button = buttonClass:Create(bags[i])
		button:SetParent(bar)
		button.hidden = true
		button.bar = bar
		table.insert(bar.buttons, button)
	end

	hooksecurefunc(AccountBankPanel, "RefreshBankTabs", function(self)
		if not AccountBankPanel.purchasedBankTabData then return end
		for index, data in pairs(self.purchasedBankTabData) do
			bar.buttons[index].Icon:SetTexture(data.icon)
		end
	end)

	updater(bar)

	return bar
end)