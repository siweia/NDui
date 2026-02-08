local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local M = B:GetModule("Misc")

local _G = getfenv(0)
local next, strmatch = next, string.match
local InCombatLockdown = InCombatLockdown

local modifier = "shift" -- shift, alt or ctrl
local mouseButton = "1" -- 1 = left, 2 = right, 3 = middle, 4 and 5 = thumb buttons if there are any
local pending = {}

function M:Focuser_Setup()
	if not self or self.focuser then return end
	local name = self.GetName and self:GetName()
	if name and strmatch(name, "oUF_NPs") then return end

	if not InCombatLockdown() then
		self:SetAttribute(modifier.."-type"..mouseButton, "focus")
		self.focuser = true
		pending[self] = nil
	else
		pending[self] = true
	end
end

function M:Focuser_CreateFrameHook(name, _, template)
	if name and template == "SecureUnitButtonTemplate" then
		M.Focuser_Setup(_G[name])
	end
end

function M.Focuser_OnEvent(event)
	if event == "PLAYER_REGEN_ENABLED" then
		if next(pending) then
			for frame in next, pending do
				M.Focuser_Setup(frame)
			end
		end
	else
		for _, object in next, oUF.objects do
			if not object.focuser then
				M.Focuser_Setup(object)
			end
		end
	end
end

function M:Focuser()
	if not C.db["Misc"]["Focuser"] then return end

	-- Keybinding override so that models can be shift/alt/ctrl+clicked
	local f = CreateFrame("CheckButton", "FocuserButton", UIParent, "SecureActionButtonTemplate")
	f:SetAttribute("type1", "macro")
	f:SetAttribute("macrotext", "/focus mouseover")
	SetOverrideBindingClick(FocuserButton, true, modifier.."-BUTTON"..mouseButton, "FocuserButton")

	hooksecurefunc("CreateFrame", M.Focuser_CreateFrameHook)
	M:Focuser_OnEvent()
	B:RegisterEvent("PLAYER_REGEN_ENABLED", M.Focuser_OnEvent)
	B:RegisterEvent("GROUP_ROSTER_UPDATE", M.Focuser_OnEvent)
end
M:RegisterMisc("Focuser", M.Focuser)