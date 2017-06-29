local B, C, L, DB = unpack(select(2, ...))
local Bar = NDui:GetModule("Actionbar")

local hiddenFrame = CreateFrame("Frame")
hiddenFrame:Hide()

local scripts = {
	"OnShow", "OnHide", "OnEvent", "OnEnter", "OnLeave", "OnUpdate", "OnValueChanged", "OnClick", "OnMouseDown", "OnMouseUp",
}

local framesToHide = {
	MainMenuBar, OverrideActionBar,
}

local framesToDisable = {
	MainMenuBar,
	ActionBarDownButton, ActionBarUpButton, MainMenuBarVehicleLeaveButton, ExhaustionTick,
	ReputationWatchBar, ArtifactWatchBar, HonorWatchBar, MainMenuExpBar, MainMenuBarMaxLevelBar,
	OverrideActionBar,
	OverrideActionBarExpBar, OverrideActionBarHealthBar, OverrideActionBarPowerBar, OverrideActionBarPitchFrame,
}

local function DisableAllScripts(frame)
	for i, script in next, scripts do
		if frame:HasScript(script) then
			frame:SetScript(script,nil)
		end
	end
end

function Bar:HideBlizz()
	for i, frame in next, framesToHide do
		frame:SetParent(hiddenFrame)
	end

	for i, frame in next, framesToDisable do
		frame:UnregisterAllEvents()
		DisableAllScripts(frame)
	end
end