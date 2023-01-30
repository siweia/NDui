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
	MainMenuBar, OverrideActionBar, MultiBarLeft, MultiBarRight
}

local framesToDisable = {
	MainMenuBar,
	MicroButtonAndBagsBar, MainMenuBarArtFrame, StatusTrackingBarManager,
	ActionBarDownButton, ActionBarUpButton,
	OverrideActionBar,
	OverrideActionBarExpBar, OverrideActionBarHealthBar, OverrideActionBarPowerBar, OverrideActionBarPitchFrame,
	VerticalMultiBarsContainer,
}

local function DisableAllScripts(frame)
	for _, script in next, scripts do
		if frame:HasScript(script) then
			frame:SetScript(script, nil)
		end
	end
end

local function updateTokenVisibility()
	TokenFrame_LoadUI()
	TokenFrame_Update()
	BackpackTokenFrame_Update()
end

local function DisableDefaultBarEvents() -- credit: Simpy
	-- Spellbook open in combat taint, only happens sometimes
	_G.MultiActionBar_HideAllGrids = B.Dummy
	_G.MultiActionBar_ShowAllGrids = B.Dummy
	-- shut down some events for things we dont use
	_G.ActionBarController:UnregisterAllEvents()
	_G.ActionBarActionEventsFrame:UnregisterAllEvents()
	-- used for ExtraActionButton and TotemBar (on wrath)
	_G.ActionBarButtonEventsFrame:UnregisterAllEvents()
	_G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED") -- needed to let the ExtraActionButton show and Totems to swap
	_G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN") -- needed for cooldowns of them both
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

	DisableDefaultBarEvents()
	-- Hide blizz options
	B.HideOption(InterfaceOptionsActionBarsPanelBottomLeft)
	B.HideOption(InterfaceOptionsActionBarsPanelBottomRight)
	B.HideOption(InterfaceOptionsActionBarsPanelRight)
	B.HideOption(InterfaceOptionsActionBarsPanelRightTwo)
	B.HideOption(InterfaceOptionsActionBarsPanelAlwaysShowActionBars)
	SetCVar("multiBarRightVerticalLayout", 0)
	InterfaceOptionsActionBarsPanelStackRightBars:EnableMouse(false)
	InterfaceOptionsActionBarsPanelStackRightBars:SetAlpha(0)
	-- Update token panel
	B:RegisterEvent("CURRENCY_DISPLAY_UPDATE", updateTokenVisibility)
end