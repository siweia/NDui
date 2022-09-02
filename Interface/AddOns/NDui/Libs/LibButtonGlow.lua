--[[
Copyright (c) 2015-2017, Hendrik "nevcairiel" Leppkes <h.leppkes@gmail.com>

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.
    * Neither the name of the developer nor the names of its contributors
      may be used to endorse or promote products derived from this software without
      specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
local _, ns = ...
local B, C, L, DB = unpack(ns)

local unusedOverlayGlows, numOverlays = {}, 0
local tinsert, tremove, tostring = table.insert, table.remove, tostring
local iconAlertTexture = [[Interface\SpellActivationOverlay\IconAlert]]
local iconAlertAntsTexture = [[Interface\SpellActivationOverlay\IconAlertAnts]]

local function overlayGlowAnimOutFinished(animGroup)
	local overlay = animGroup:GetParent()
	local button = overlay:GetParent()
	overlay:Hide()
	tinsert(unusedOverlayGlows, overlay)
	button.__overlay = nil
end

local function overlayGlow_OnHide(self)
	if self.animOut:IsPlaying() then
		self.animOut:Stop()
		overlayGlowAnimOutFinished(self.animOut)
	end
end

local function createScaleAnim(group, target, order, duration, x, y, delay)
	local scale = group:CreateAnimation("Scale")
	scale:SetTarget(target)
	scale:SetOrder(order)
	scale:SetDuration(duration)
	scale:SetScale(x, y)

	if delay then
		scale:SetStartDelay(delay)
	end
end

local function createAlphaAnim(group, target, order, duration, fromAlpha, toAlpha, delay)
	local alpha = group:CreateAnimation("Alpha")
	alpha:SetTarget(target)
	alpha:SetOrder(order)
	alpha:SetDuration(duration)
	alpha:SetFromAlpha(fromAlpha)
	alpha:SetToAlpha(toAlpha)

	if delay then
		alpha:SetStartDelay(delay)
	end
end

local function animIn_OnPlay(group)
	local frame = group:GetParent()
	local frameWidth, frameHeight = frame:GetSize()
	frame.innerGlow:SetSize(frameWidth / 2, frameHeight / 2)
	frame.innerGlow:SetAlpha(1)
	frame.innerGlowOver:SetAlpha(1)
	frame.outerGlow:SetSize(frameWidth * 1.1, frameHeight * 1.1)
	frame.outerGlow:SetAlpha(1)
	frame.outerGlowOver:SetAlpha(1)
	frame.ants:SetSize(frameWidth * .85, frameHeight * .85)
	frame.ants:SetAlpha(0)
	frame:Show()
end

local function animIn_OnFinished(group)
	local frame = group:GetParent()
	local frameWidth, frameHeight = frame:GetSize()
	frame.innerGlow:SetAlpha(0)
	frame.innerGlow:SetSize(frameWidth, frameHeight)
	frame.innerGlowOver:SetAlpha(0)
	frame.outerGlow:SetSize(frameWidth, frameHeight)
	frame.outerGlowOver:SetAlpha(0)
	frame.outerGlowOver:SetSize(frameWidth, frameHeight)
	frame.ants:SetAlpha(1)
end

local function overlayGlow_OnUpdate(self, elapsed)
	AnimateTexCoords(self.ants, 256, 256, 48, 48, 22, elapsed, 0.01)
	local cooldown = self:GetParent().cooldown
	-- we need some threshold to avoid dimming the glow during the gdc
	-- (using 1500 exactly seems risky, what if casting speed is slowed or something?)
	if(cooldown and cooldown:IsShown() and cooldown:GetCooldownDuration() > 3000) then
		self:SetAlpha(.5)
	else
		self:SetAlpha(1)
	end
end

local function createOverlayGlow()
	numOverlays = numOverlays + 1

	-- create frame and textures
	local name = "ButtonGlowOverlay"..tostring(numOverlays)
	local overlay = CreateFrame("Frame", name, UIParent)

	-- inner glow
	overlay.innerGlow = overlay:CreateTexture(name.."InnerGlow", "ARTWORK")
	overlay.innerGlow:SetPoint("CENTER")
	overlay.innerGlow:SetAlpha(0)
	overlay.innerGlow:SetTexture(iconAlertTexture)
	overlay.innerGlow:SetTexCoord(.00781250, .50781250, .27734375, .52734375)

	-- inner glow over
	overlay.innerGlowOver = overlay:CreateTexture(name.."InnerGlowOver", "ARTWORK")
	overlay.innerGlowOver:SetPoint("TOPLEFT", overlay.innerGlow, "TOPLEFT")
	overlay.innerGlowOver:SetPoint("BOTTOMRIGHT", overlay.innerGlow, "BOTTOMRIGHT")
	overlay.innerGlowOver:SetAlpha(0)
	overlay.innerGlowOver:SetTexture(iconAlertTexture)
	overlay.innerGlowOver:SetTexCoord(.00781250, .50781250, .53515625, .78515625)

	-- outer glow
	overlay.outerGlow = overlay:CreateTexture(name.."OuterGlow", "ARTWORK")
	overlay.outerGlow:SetPoint("CENTER")
	overlay.outerGlow:SetAlpha(0)
	overlay.outerGlow:SetTexture(iconAlertTexture)
	overlay.outerGlow:SetTexCoord(.00781250, .50781250, .27734375, .52734375)

	-- outer glow over
	overlay.outerGlowOver = overlay:CreateTexture(name.."OuterGlowOver", "ARTWORK")
	overlay.outerGlowOver:SetPoint("TOPLEFT", overlay.outerGlow, "TOPLEFT")
	overlay.outerGlowOver:SetPoint("BOTTOMRIGHT", overlay.outerGlow, "BOTTOMRIGHT")
	overlay.outerGlowOver:SetAlpha(0)
	overlay.outerGlowOver:SetTexture(iconAlertTexture)
	overlay.outerGlowOver:SetTexCoord(.00781250, .50781250, .53515625, .78515625)

	-- ants
	overlay.ants = overlay:CreateTexture(name.."Ants", "OVERLAY")
	overlay.ants:SetPoint("CENTER")
	overlay.ants:SetAlpha(0)
	overlay.ants:SetTexture(iconAlertAntsTexture)

	-- setup antimations
	overlay.animIn = overlay:CreateAnimationGroup()
	createScaleAnim(overlay.animIn, overlay.innerGlow, 1, .3, 2, 2)
	createScaleAnim(overlay.animIn, overlay.innerGlowOver, 1, .3, 2, 2)
	createAlphaAnim(overlay.animIn, overlay.innerGlowOver, 1, .3, 1, 0)
	createScaleAnim(overlay.animIn, overlay.outerGlowOver, 1, .3, .5, .5)
	createAlphaAnim(overlay.animIn, overlay.outerGlowOver, 1, .3, 1, 0)
	createAlphaAnim(overlay.animIn, overlay.innerGlow, 1, .2, 1, 0, .3)
	createAlphaAnim(overlay.animIn, overlay.ants, 1, .2, 0, 1, .3)
	overlay.animIn:SetScript("OnPlay", animIn_OnPlay)
	overlay.animIn:SetScript("OnFinished", animIn_OnFinished)

	overlay.animOut = overlay:CreateAnimationGroup()
	createAlphaAnim(overlay.animOut, overlay.outerGlowOver, 1, .2, 0, 1)
	createAlphaAnim(overlay.animOut, overlay.ants, 1, .2, 1, 0)
	createAlphaAnim(overlay.animOut, overlay.outerGlowOver, 2, .2, 1, 0)
	createAlphaAnim(overlay.animOut, overlay.outerGlow, 2, .2, 1, 0)
	overlay.animOut:SetScript("OnFinished", overlayGlowAnimOutFinished)

	-- scripts
	overlay:SetScript("OnUpdate", overlayGlow_OnUpdate)
	overlay:SetScript("OnHide", overlayGlow_OnHide)

	return overlay
end

local function getOverlayGlow()
	local overlay = tremove(unusedOverlayGlows)
	if not overlay then
		overlay = createOverlayGlow()
	end
	return overlay
end

function B:ShowOverlayGlow()
	if self.__overlay then
		if self.__overlay.animOut:IsPlaying() then
			self.__overlay.animOut:Stop()
			self.__overlay.animIn:Play()
		end
	else
		local overlay = getOverlayGlow()
		local frameWidth, frameHeight = self:GetSize()
		overlay:SetParent(self)
		overlay:SetFrameLevel(self:GetFrameLevel() + 5)
		overlay:ClearAllPoints()
		--Make the height/width available before the next frame:
		overlay:SetSize(frameWidth * 1.4, frameHeight * 1.4)
		overlay:SetPoint("TOPLEFT", self, "TOPLEFT", -frameWidth * .2, frameHeight * .2)
		overlay:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", frameWidth * .2, -frameHeight * .2)
		overlay.animIn:Play()
		self.__overlay = overlay
	end
end

function B:HideOverlayGlow()
	if self.__overlay then
		if self.__overlay.animIn:IsPlaying() then
			self.__overlay.animIn:Stop()
		end
		if self:IsVisible() then
			self.__overlay.animOut:Play()
		else
			overlayGlowAnimOutFinished(self.__overlay.animOut)
		end
	end
end