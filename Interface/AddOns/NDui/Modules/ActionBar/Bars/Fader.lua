local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")
----------------------------
-- rLib: framefader, zork
----------------------------
local SpellFlyout = SpellFlyout

local function FaderOnFinished(self)
	self.__owner:SetAlpha(self.finAlpha)
end

local function FaderOnUpdate(self)
	self.__owner:SetAlpha(self.__animFrame:GetAlpha())
end

local function CreateFaderAnimation(frame)
	if frame.fader then return end
	local animFrame = CreateFrame("Frame", nil, frame)
	animFrame.__owner = frame
	frame.fader = animFrame:CreateAnimationGroup()
	frame.fader.__owner = frame
	frame.fader.__animFrame = animFrame
	frame.fader.direction = nil
	frame.fader.setToFinalAlpha = false --test if this will NOT apply the alpha to all regions
	frame.fader.anim = frame.fader:CreateAnimation("Alpha")
	frame.fader:HookScript("OnFinished", FaderOnFinished)
	frame.fader:HookScript("OnUpdate", FaderOnUpdate)
end

function Bar:StartFadeIn(frame)
	if frame.fader.direction == "in" then return end
	frame.fader:Pause()
	frame.fader.anim:SetFromAlpha(frame.faderConfig.fadeOutAlpha or 0)
	frame.fader.anim:SetToAlpha(frame.faderConfig.fadeInAlpha or 1)
	frame.fader.anim:SetDuration(frame.faderConfig.fadeInDuration or 0.3)
	frame.fader.anim:SetSmoothing(frame.faderConfig.fadeInSmooth or "OUT")
	--start right away
	frame.fader.anim:SetStartDelay(frame.faderConfig.fadeInDelay or 0)
	frame.fader.finAlpha = frame.faderConfig.fadeInAlpha
	frame.fader.direction = "in"
	frame.fader:Play()
end

function Bar:StartFadeOut(frame)
	if frame.fader.direction == "out" then return end
	frame.fader:Pause()
	frame.fader.anim:SetFromAlpha(frame.faderConfig.fadeInAlpha or 1)
	frame.fader.anim:SetToAlpha(frame.faderConfig.fadeOutAlpha or 0)
	frame.fader.anim:SetDuration(frame.faderConfig.fadeOutDuration or 0.3)
	frame.fader.anim:SetSmoothing(frame.faderConfig.fadeOutSmooth or "OUT")
	--wait for some time before starting the fadeout
	frame.fader.anim:SetStartDelay(frame.faderConfig.fadeOutDelay or 0)
	frame.fader.finAlpha = frame.faderConfig.fadeOutAlpha
	frame.fader.direction = "out"
	frame.fader:Play()
end

local function IsMouseOverFrame(frame)
	if MouseIsOver(frame) then return true end
	if not SpellFlyout:IsShown() then return false end
	if not SpellFlyout.__faderParent then return false end
	if SpellFlyout.__faderParent == frame and MouseIsOver(SpellFlyout) then return true end
	return false
end

local function FrameHandler(frame)
	if frame.isDisable then return end

	if IsMouseOverFrame(frame) then
		Bar:StartFadeIn(frame)
	else
		Bar:StartFadeOut(frame)
	end
end

local function OffFrameHandler(self)
	if not self.__faderParent then return end
	FrameHandler(self.__faderParent)
end

local function SpellFlyoutOnShow(self)
	local frame = self:GetParent():GetParent():GetParent()
	if not frame.fader then return end
	--set new frame parent
	self.__faderParent = frame
	if not self.__faderHook then
		SpellFlyout:HookScript("OnEnter", OffFrameHandler)
		SpellFlyout:HookScript("OnLeave", OffFrameHandler)
		self.__faderHook = true
	end
	for i = 1, 13 do
		local button = _G["SpellFlyoutButton"..i]
		if not button then break end
		button.__faderParent = frame
		if not button.__faderHook then
			button:HookScript("OnEnter", OffFrameHandler)
			button:HookScript("OnLeave", OffFrameHandler)
			button.__faderHook = true
		end
	end
end
SpellFlyout:HookScript("OnShow", SpellFlyoutOnShow)

local function CreateFrameFader(frame, faderConfig)
	if frame.faderConfig then return end
	frame.faderConfig = faderConfig
	frame:EnableMouse(true)
	CreateFaderAnimation(frame)
	frame:HookScript("OnEnter", FrameHandler)
	frame:HookScript("OnLeave", FrameHandler)
	FrameHandler(frame)
end

function Bar:CreateButtonFrameFader(buttonList, faderConfig)
	CreateFrameFader(self, faderConfig)
	for _, button in next, buttonList do
		if not button.__faderParent then
			button.__faderParent = self
			button:HookScript("OnEnter", OffFrameHandler)
			button:HookScript("OnLeave", OffFrameHandler)
		end
	end
end