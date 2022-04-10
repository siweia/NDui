local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert = tinsert
local InCombatLockdown = InCombatLockdown
local cfg = C.Bars.bar4

function Bar:ToggleBarFader(name)
	local frame = _G["NDui_Action"..name]
	if not frame then return end

	frame.isDisable = not C.db["Actionbar"][name.."Fader"]
	if frame.isDisable then
		Bar:StartFadeIn(frame)
	else
		Bar:StartFadeOut(frame)
	end
end

function Bar:UpdateFrameClickThru()
	local showBar4, showBar5

	local function updateClickThru()
		_G.NDui_ActionBar4:EnableMouse(showBar4)
		_G.NDui_ActionBar5:EnableMouse((not showBar4 and showBar4) or (showBar4 and showBar5))
	end

	hooksecurefunc("SetActionBarToggles", function(_, _, bar3, bar4)
		showBar4 = not not bar3
		showBar5 = not not bar4
		if InCombatLockdown() then
			B:RegisterEvent("PLAYER_REGEN_ENABLED", updateClickThru)
		else
			updateClickThru()
		end
	end)
end

function Bar:CreateBar4()
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}

	local frame = CreateFrame("Frame", "NDui_ActionBar4", UIParent, "SecureHandlerStateTemplate")
	frame.mover = B.Mover(frame, L["Actionbar"].."4", "Bar4", {"RIGHT", UIParent, "RIGHT", -1, 0})
	Bar.movers[5] = frame.mover

	MultiBarRight:SetParent(frame)
	MultiBarRight:EnableMouse(false)
	hooksecurefunc(MultiBarRight, "SetScale", function(self, scale, force)
		if not force and scale ~= 1 then
			self:SetScale(1, true)
		end
	end)

	for i = 1, num do
		local button = _G["MultiBarRightButton"..i]
		tinsert(buttonList, button)
		tinsert(Bar.buttons, button)
	end
	frame.buttons = buttonList

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if cfg.fader then
		frame.isDisable = not C.db["Actionbar"]["Bar4Fader"]
		Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end

	Bar:UpdateFrameClickThru()
end