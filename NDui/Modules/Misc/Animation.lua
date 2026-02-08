local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local soundID = SOUNDKIT.UI_IG_STORE_CONFIRM_PURCHASE_BUTTON
local PlaySound = PlaySound

local needAnimation

function M:Logo_PlayAnimation()
	if needAnimation then
		M.logoFrame:Show()
		B:UnregisterEvent(self, M.Logo_PlayAnimation)
		needAnimation = false
	end
end

function M:Logo_CheckStatus(isInitialLogin)
	if isInitialLogin and not (IsInInstance() and InCombatLockdown()) then
		needAnimation = true
		M:Logo_Create()
		B:RegisterEvent("PLAYER_STARTED_MOVING", M.Logo_PlayAnimation)
	end
	B:UnregisterEvent(self, M.Logo_CheckStatus)
end

function M:Logo_Create()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(300, 150)
	frame:SetPoint("CENTER", UIParent, "BOTTOM", -500, GetScreenHeight()*.618)
	frame:SetFrameStrata("HIGH")
	frame:SetAlpha(0)
	frame:Hide()

	local tex = frame:CreateTexture()
	tex:SetAllPoints()
	tex:SetTexture(DB.logoTex)

	local delayTime = 0
	local timer1 = .5
	local timer2 = 2
	local timer3 = .2

	local anim = frame:CreateAnimationGroup()

	anim.move1 = anim:CreateAnimation("Translation")
	anim.move1:SetOffset(480, 0)
	anim.move1:SetDuration(timer1)
	anim.move1:SetStartDelay(delayTime)

	anim.fadeIn = anim:CreateAnimation("Alpha")
	anim.fadeIn:SetFromAlpha(0)
	anim.fadeIn:SetToAlpha(1)
	anim.fadeIn:SetDuration(timer1)
	anim.fadeIn:SetSmoothing("IN")
	anim.fadeIn:SetStartDelay(delayTime)

	delayTime = delayTime + timer1

	anim.move2 = anim:CreateAnimation("Translation")
	anim.move2:SetOffset(80, 0)
	anim.move2:SetDuration(timer2)
	anim.move2:SetStartDelay(delayTime)

	delayTime = delayTime + timer2

	anim.move3 = anim:CreateAnimation("Translation")
	anim.move3:SetOffset(-40, 0)
	anim.move3:SetDuration(timer3)
	anim.move3:SetStartDelay(delayTime)

	delayTime = delayTime + timer3

	anim.move4 = anim:CreateAnimation("Translation")
	anim.move4:SetOffset(480, 0)
	anim.move4:SetDuration(timer1)
	anim.move4:SetStartDelay(delayTime)

	anim.fadeOut = anim:CreateAnimation("Alpha")
	anim.fadeOut:SetFromAlpha(1)
	anim.fadeOut:SetToAlpha(0)
	anim.fadeOut:SetDuration(timer1)
	anim.fadeOut:SetSmoothing("OUT")
	anim.fadeOut:SetStartDelay(delayTime)

	frame:SetScript("OnShow", function()
		anim:Play()
	end)
	anim:SetScript("OnFinished", function()
		frame:Hide()
	end)
	anim.fadeIn:SetScript("OnFinished", function()
		PlaySound(soundID)
	end)

	M.logoFrame = frame
end

function M:LoginAnimation()
	B:RegisterEvent("PLAYER_ENTERING_WORLD", M.Logo_CheckStatus)

	SlashCmdList["NDUI_PLAYLOGO"] = function()
		if not M.logoFrame then
			M:Logo_Create()
		end
		M.logoFrame:Show()
		if DB.isDeveloper then print("Play logo") end
	end
	SLASH_NDUI_PLAYLOGO1 = "/nlogo"
end
M:RegisterMisc("LoginAnimation", M.LoginAnimation)