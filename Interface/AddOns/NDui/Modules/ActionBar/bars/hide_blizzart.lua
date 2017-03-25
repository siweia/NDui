local B, C, L, DB = unpack(select(2, ...))
local Bar = NDui:GetModule("Actionbar")

function Bar:HideBlizzard()
	--hide blizzard
	local pastebin = CreateFrame("Frame")
	pastebin:Hide()

	--hide main menu bar frames
	MainMenuBar:SetParent(pastebin)
	MainMenuBarPageNumber:SetParent(pastebin)
	ActionBarDownButton:SetParent(pastebin)
	ActionBarUpButton:SetParent(pastebin)

	--hide override actionbar frames
	OverrideActionBar:SetParent(pastebin)
	OverrideActionBar:EnableMouse(false)
	local scripts = {
		"OnShow", "OnHide", "OnEvent", "OnEnter", "OnLeave", "OnUpdate", "OnValueChanged", "OnClick", "OnMouseDown", "OnMouseUp"
	}
	local framesToDisable = {
		OverrideActionBar, OverrideActionBarExpBar, OverrideActionBarHealthBar, OverrideActionBarPowerBar, OverrideActionBarPitchFrame, ArtifactWatchBar
	}

	for _, frame in next, framesToDisable do
		frame:UnregisterAllEvents()
		for _, script in next, scripts do
			if frame:HasScript(script) then
				frame:SetScript(script, nil)
			end
		end
	end

	--hide bag buttons
	local buttonList = {
		MainMenuBarBackpackButton, CharacterBag0Slot, CharacterBag1Slot, CharacterBag2Slot, CharacterBag3Slot,
	}
	for _, button in pairs(buttonList) do
		button:SetParent(pastebin)
	end

	--hide micro buttons
	for _, buttonName in pairs(MICRO_BUTTONS) do
		local button = _G[buttonName]
		button:SetParent(pastebin)
	end

	--remove some the default background textures
	StanceBarLeft:SetTexture(nil)
	StanceBarMiddle:SetTexture(nil)
	StanceBarRight:SetTexture(nil)
	SlidingActionBarTexture0:SetTexture(nil)
	SlidingActionBarTexture1:SetTexture(nil)
	PossessBackground1:SetTexture(nil)
	PossessBackground2:SetTexture(nil)
	MainMenuBarTexture0:SetTexture(nil)
	MainMenuBarTexture1:SetTexture(nil)
	MainMenuBarTexture2:SetTexture(nil)
	MainMenuBarTexture3:SetTexture(nil)
	MainMenuBarLeftEndCap:SetTexture(nil)
	MainMenuBarRightEndCap:SetTexture(nil)
end