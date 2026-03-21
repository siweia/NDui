local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local soundID = SOUNDKIT.UI_LEGENDARY_LOOT_TOAST
local PlaySound = PlaySound

-- Shared animation functions
local function createTranslation(anim, order, offsetX, offsetY, duration, smoothing, delay)
    local obj = anim:CreateAnimation("Translation")
    obj:SetOffset(offsetX, offsetY)
    obj:SetDuration(duration)
    obj:SetOrder(order)
    if smoothing then obj:SetSmoothing(smoothing) end
    if delay then obj:SetStartDelay(delay) end
    return obj
end

local function createAlpha(anim, order, fromAlpha, toAlpha, duration, delay)
    local obj = anim:CreateAnimation("Alpha")
    obj:SetFromAlpha(fromAlpha)
    obj:SetToAlpha(toAlpha)
    obj:SetDuration(duration)
    obj:SetOrder(order)
    if delay then obj:SetStartDelay(delay) end
    return obj
end

local function createScale(anim, order, fromX, fromY, toX, toY, duration, smoothing, delay)
    local obj = anim:CreateAnimation("Scale")
    obj:SetScaleFrom(fromX, fromY)
    obj:SetScaleTo(toX, toY)
    obj:SetDuration(duration)
    obj:SetOrder(order)
    obj:SetOrigin("CENTER", 0, 0)
    if smoothing then obj:SetSmoothing(smoothing) end
    if delay then obj:SetStartDelay(delay) end
    return obj
end

-- Logo Animation
local needAnimation

function M:Logo_PlayAnimation()
	if needAnimation and M.logoFrame then
		M.logoFrame:Show()
		B:UnregisterEvent("PLAYER_STARTED_MOVING", M.Logo_PlayAnimation)
		needAnimation = false
	end
end

function M:Logo_CheckStatus(isInitialLogin)
	if isInitialLogin and not (IsInInstance() and InCombatLockdown()) then
		needAnimation = true
		M:Logo_Create()
		B:RegisterEvent("PLAYER_STARTED_MOVING", M.Logo_PlayAnimation)
	end
	B:UnregisterEvent("PLAYER_ENTERING_WORLD", M.Logo_CheckStatus)
end

function M:Logo_Create()
	if M.logoFrame then return end

	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(300, 150)
	frame:SetPoint("CENTER", UIParent, "BOTTOM", -500, GetScreenHeight() * .618)
	frame:SetFrameStrata("HIGH")
	frame:SetAlpha(0)
	frame:Hide()

	local tex = frame:CreateTexture()
	tex:SetAllPoints()
	tex:SetTexture(DB.logoTex)

	local anim = frame:CreateAnimationGroup()
	local timer1, timer2, timer3 = 0.5, 2.0, 0.2

	-- Order 1: 右移 + 淡入
	createTranslation(anim, 1, 480, 0, timer1, "IN")
	local fadeIn = createAlpha(anim, 1, 0, 1, timer1)
	-- Order 2: 慢速右移
	createTranslation(anim, 2, 80, 0, timer2)
	-- Order 3: 轻微左回撤
	createTranslation(anim, 3, -40, 0, timer3)
	-- Order 4: 快速右移 + 淡出
	createTranslation(anim, 4, 480, 0, timer1)
	createAlpha(anim, 4, 1, 0, timer1)

	frame:SetScript("OnShow", function() anim:Play() end)
	anim:SetScript("OnFinished", function() frame:Hide() end)
	fadeIn:SetScript("OnFinished", function() PlaySound(soundID) end)

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

-- Combat Animation
function M:CombatAnimation()
	if not C.db["Misc"]["CombatAnimation"] then return end

	local ENTERING_COMBAT = _G.ENTERING_COMBAT
	local LEAVING_COMBAT = _G.LEAVING_COMBAT

	local cfg = {
		slideInDist    = 350,
		nudgeDist      = -40,
		slideOutDist   = 480,
		targetY        = 150,
		minScale       = .1,
		maxScale       = 1.5,
		inDuration     = .3,
		bounceDuration = .15,
		holdDuration   = .8,
		nudgeDuration  = .2,
		outDuration    = .5,
	}

	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(1, 1)
	frame:SetPoint("CENTER", -cfg.slideInDist, cfg.targetY)
	frame:Hide()

	local text = B.CreateFS(frame, 32, "")
	text:ClearAllPoints()
	text:SetPoint("CENTER")

	local bg = frame:CreateTexture(nil, "ARTWORK")
	bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	bg:SetTexCoord(0, .66, 0, .31)
	bg:SetPoint("BOTTOM", 0, -20)
	bg:SetSize(150, 30)

	local anim = frame:CreateAnimationGroup()

	-- 阶段 1：入场（左滑 + 淡入 + 放大）
	createTranslation(anim, 1, cfg.slideInDist, 0, cfg.inDuration, "IN")
	createAlpha(anim, 1, 0, 1, cfg.inDuration)
	createScale(anim, 1, cfg.minScale, cfg.minScale, cfg.maxScale, cfg.maxScale, cfg.inDuration, "IN")
	-- 阶段 2：回弹（缩小至正常）
	createScale(anim, 2, cfg.maxScale, cfg.maxScale, 1.0, 1.0, cfg.bounceDuration, "OUT")
	-- 阶段 3：蓄力（向左微移，带停留延迟）
	createTranslation(anim, 3, cfg.nudgeDist, 0, cfg.nudgeDuration, nil, cfg.holdDuration)
	-- 阶段 4：退场（右滑 + 淡出 + 缩小）
	local totalMoveOut = -cfg.nudgeDist + cfg.slideOutDist
	createTranslation(anim, 4, totalMoveOut, 0, cfg.outDuration)
	createAlpha(anim, 4, 1, 0, cfg.outDuration)
	createScale(anim, 4, 1.0, 1.0, cfg.minScale, cfg.minScale, cfg.outDuration)

	anim:SetScript("OnFinished", function() frame:Hide() end)

	local function updateCombatState(event)
		if event == "PLAYER_REGEN_DISABLED" then
			text:SetText(ENTERING_COMBAT)
			text:SetTextColor(1, .1, .1)
			bg:SetVertexColor(1, .1, .1, .8)
		else
			text:SetText(LEAVING_COMBAT)
			text:SetTextColor(.1, 1, .1)
			bg:SetVertexColor(.1, 1, .1, .8)
		end

		anim:Stop()
		frame:Show()
		anim:Play()
	end
	B:RegisterEvent("PLAYER_REGEN_ENABLED", updateCombatState)
	B:RegisterEvent("PLAYER_REGEN_DISABLED", updateCombatState)
end
M:RegisterMisc("CombatAnimation", M.CombatAnimation)