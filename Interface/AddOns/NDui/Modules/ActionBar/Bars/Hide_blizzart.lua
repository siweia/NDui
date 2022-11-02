local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local next, tonumber = next, tonumber
local ACTION_BUTTON_SHOW_GRID_REASON_CVAR = ACTION_BUTTON_SHOW_GRID_REASON_CVAR

local scripts = {
	"OnShow", "OnHide", "OnEvent", "OnEnter", "OnLeave", "OnUpdate", "OnValueChanged", "OnClick", "OnMouseDown", "OnMouseUp",
}

local framesToHide = {
	MainMenuBar, OverrideActionBar,
}

local framesToDisable = {
	MainMenuBar,
	MicroButtonAndBagsBar, MainMenuBarArtFrame, StatusTrackingBarManager,
	ActionBarDownButton, ActionBarUpButton, MainMenuBarVehicleLeaveButton,
	OverrideActionBar,
	OverrideActionBarExpBar, OverrideActionBarHealthBar, OverrideActionBarPowerBar, OverrideActionBarPitchFrame,
}

local function DisableAllScripts(frame)
	for _, script in next, scripts do
		if frame:HasScript(script) then
			frame:SetScript(script, nil)
		end
	end
end

local function buttonShowGrid(name, showgrid)
	for i = 1, 12 do
		local button = _G[name..i]
		if button then
			button:SetAttribute("showgrid", showgrid)
			button:ShowGrid(ACTION_BUTTON_SHOW_GRID_REASON_CVAR)
		end
	end
end

local function updateTokenVisibility()
	TokenFrame_LoadUI()
	TokenFrame_Update()
end

local function ReplaceSpellbookButtons()
	if not DB.isBeta then return end

	local function replaceOnEnter(self)
		local slot = SpellBook_GetSpellBookSlot(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

		if InClickBindingMode() and not self.canClickBind then
			GameTooltip:AddLine(CLICK_BINDING_NOT_AVAILABLE, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
			GameTooltip:Show()
			return
		end

		GameTooltip:SetSpellBookItem(slot, SpellBookFrame.bookType)
		self.UpdateTooltip = nil

		if self.SpellHighlightTexture and self.SpellHighlightTexture:IsShown() then
			GameTooltip:AddLine(SPELLBOOK_SPELL_NOT_ON_ACTION_BAR, LIGHTBLUE_FONT_COLOR.r, LIGHTBLUE_FONT_COLOR.g, LIGHTBLUE_FONT_COLOR.b)
		end
		GameTooltip:Show()
	end

	local function handleSpellButton(button)
		button.OnEnter = replaceOnEnter
		button:SetScript("OnEnter", replaceOnEnter)
		button.OnLeave = B.HideTooltip
		button:SetScript("OnLeave", B.HideTooltip)
	end

	for i = 1, SPELLS_PER_PAGE do
		handleSpellButton(_G["SpellButton"..i])
	end

	local professions = {"PrimaryProfession1", "PrimaryProfession2", "SecondaryProfession1", "SecondaryProfession2", "SecondaryProfession3"}
	for _, button in pairs(professions) do
		local bu = _G[button]
		handleSpellButton(bu.SpellButton1)
		handleSpellButton(bu.SpellButton2)
	end
end

function Bar:HideBlizz()
	MainMenuBar:SetMovable(true)
	MainMenuBar:SetUserPlaced(true)
	MainMenuBar.ignoreFramePositionManager = true
	MainMenuBar:SetAttribute("ignoreFramePositionManager", true)

	for _, frame in next, framesToHide do
		frame:SetParent(B.HiddenFrame)
	end

	for _, frame in next, framesToDisable do
		frame:UnregisterAllEvents()
		DisableAllScripts(frame)
	end

	-- Fix spellbook button taint with Editmode
	ReplaceSpellbookButtons()
	-- Hide blizz options
	SetCVar("multiBarRightVerticalLayout", 0)
	-- Fix maw block anchor
	MainMenuBarVehicleLeaveButton:RegisterEvent("PLAYER_ENTERING_WORLD")
	-- Update token panel
	B:RegisterEvent("CURRENCY_DISPLAY_UPDATE", updateTokenVisibility)
end