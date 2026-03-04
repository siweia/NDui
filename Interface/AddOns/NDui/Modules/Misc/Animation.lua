local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local soundID = SOUNDKIT.UI_LEGENDARY_LOOT_TOAST
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

-- 战斗状态提示
function M:CombatAnimation()
	if not C.db["Misc"]["CombatAnimation"] then return end

	local ENTERING_COMBAT = _G.ENTERING_COMBAT
	local LEAVING_COMBAT = _G.LEAVING_COMBAT

	local cfg = {         -- 预留选项
		dropDist = -80,   -- 下落距离
		bounce1 = 30,     -- 第一次回弹高度
		bounce2 = 12,     -- 第二次回弹高度
		targetY = 150,    -- 目标中心点 Y 坐标
		fontSize = 32,
	}
	local initialOffset = cfg.targetY - cfg.dropDist

	local alertFrame = CreateFrame("Frame", "NDui_CombatStateAlertFrame", UIParent)
	alertFrame:SetSize(1, 1)
	alertFrame:SetPoint("CENTER", 0, cfg.targetY)
	alertFrame:Hide()

	local text = B.CreateFS(alertFrame, cfg.fontSize, "")
	text:ClearAllPoints()
	text:SetPoint("CENTER")

	local anim = alertFrame:CreateAnimationGroup()
	-- 阶段一：加速下落
	local drop = anim:CreateAnimation("Translation")
	drop:SetOffset(0, cfg.dropDist)
	drop:SetDuration(0.2)
	drop:SetOrder(1)
	-- 阶段二：第一次回弹
	local b1_up = anim:CreateAnimation("Translation")
	b1_up:SetOffset(0, cfg.bounce1)
	b1_up:SetDuration(0.12)
	b1_up:SetOrder(2)
	-- 阶段三：第一次回落
	local b1_down = anim:CreateAnimation("Translation")
	b1_down:SetOffset(0, -cfg.bounce1)
	b1_down:SetDuration(0.1)
	b1_down:SetOrder(3)
	-- 阶段四：第二次回弹
	local b2_up = anim:CreateAnimation("Translation")
	b2_up:SetOffset(0, cfg.bounce2)
	b2_up:SetDuration(0.08)
	b2_up:SetOrder(4)
	-- 阶段五：第二次回落归位
	local b2_down = anim:CreateAnimation("Translation")
	b2_down:SetOffset(0, -cfg.bounce2)
	b2_down:SetDuration(0.06)
	b2_down:SetOrder(5)
	-- 阶段六：停留后上滑淡出
	local fadeOut = anim:CreateAnimation("Alpha")
	fadeOut:SetFromAlpha(1)
	fadeOut:SetToAlpha(0)
	fadeOut:SetDuration(0.8)
	fadeOut:SetStartDelay(0.6)
	fadeOut:SetOrder(6)
	local slide = anim:CreateAnimation("Translation")
	slide:SetOffset(0, 50)
	slide:SetDuration(0.8)
	slide:SetStartDelay(0.6)
	slide:SetOrder(6)
	-- 动画结束：重置
	anim:SetScript("OnFinished", function()
		alertFrame:Hide()
		alertFrame:SetAlpha(1)
		alertFrame:ClearAllPoints()
		alertFrame:SetPoint("CENTER", 0, cfg.targetY)
	end)

	local function updateCombatState(event)
		if event == "PLAYER_REGEN_DISABLED" then
			text:SetText(ENTERING_COMBAT)
			text:SetTextColor(1, 0.1, 0.1)
		else
			text:SetText(LEAVING_COMBAT)
			text:SetTextColor(0.1, 1, 0.1)
		end

		anim:Stop()
		alertFrame:SetAlpha(1)
		alertFrame:ClearAllPoints()
		alertFrame:SetPoint("CENTER", 0, initialOffset)
		alertFrame:Show()
		anim:Play()
	end
	B:RegisterEvent("PLAYER_REGEN_ENABLED", updateCombatState)
	B:RegisterEvent("PLAYER_REGEN_DISABLED", updateCombatState)
end
M:RegisterMisc("CombatAnimation", M.CombatAnimation)