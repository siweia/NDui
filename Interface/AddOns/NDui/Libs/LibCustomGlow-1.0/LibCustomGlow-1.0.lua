--[[
	This library contains work of Hendrick "nevcairiel" Leppkes
	https://www.wowace.com/projects/libbuttonglow-1-0
]]

-- luacheck:globals CreateFromMixins ObjectPoolMixin CreateTexturePool CreateFramePool
local MAJOR_VERSION = "LibCustomGlow-1.0-NDui"
local MINOR_VERSION = 30
if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end

local lib, oldversion = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local Masque = LibStub("Masque", true)
local fallbackLevel = 0 -- NDui:decreased from 8
local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local textureList = {
	empty = [[Interface\AdventureMap\BrokenIsles\AM_29]],
	white = [[Interface\BUTTONS\WHITE8X8]],
	shine = [[Interface\ItemSocketingFrame\UI-ItemSockets]],
}

local shineCoords = {0.3984375, 0.4453125, 0.40234375, 0.44921875}
if isRetail then
	textureList.shine = [[Interface\Artifacts\Artifacts]]
	shineCoords = {0.8115234375, 0.9169921875, 0.8798828125, 0.9853515625}
end

lib.glowList, lib.startList, lib.stopList = {}, {}, {}

local function ApplyDefaults(opts, defaults)
	return setmetatable(opts or {}, { __index = defaults })
end

local function RegisterGlow(name, startFunc, stopFunc)
	table.insert(lib.glowList, name)
	lib.startList[name] = startFunc
	lib.stopList[name] = stopFunc
end

local PixelGlowDefaults = {
	num = 8,
	border = true,
	color = {1, 1, 0, 1},
	frameLevel = fallbackLevel,
	frequency = nil,
	key = "",
	length = nil,
	th = 1,
	xOffset = 0,
	yOffset = 0,
}

local AutoCastGlowDefaults = {
	num = 4,
	color = {1, 1, 0, 1},
	frameLevel = fallbackLevel,
	frequency = nil,
	key = "",
	scale = 1,
	xOffset = 0,
	yOffset = 0,
}

local ButtonGlowDefaults = {
	color = nil,
	frameLevel = fallbackLevel,
	frequency = nil,
}

local ProcGlowDefaults = {
	color = nil,
	duration = 1,
	frameLevel = fallbackLevel,
	key = "",
	startAnim = true,
	xOffset = 0,
	yOffset = 0,
}

local GlowParent = UIParent
local GlowMaskPool = {
	createFunc = function(self)
		return self.parent:CreateMaskTexture()
	end,
	resetFunc = function(self, mask)
		mask:Hide()
		mask:ClearAllPoints()
	end,
	AddObject = function(self, object)
		local dummy = true
		self.activeObjects[object] = dummy
		self.activeObjectCount = self.activeObjectCount + 1
	end,
	ReclaimObject = function(self, object)
		table.insert(self.inactiveObjects, object)
		self.activeObjects[object] = nil
		self.activeObjectCount = self.activeObjectCount - 1
	end,
	Release = function(self, object)
		local active = self.activeObjects[object] ~= nil
		if active then
			self:resetFunc(object)
			self:ReclaimObject(object)
		end
		return active
	end,
	Acquire = function(self)
		local object = table.remove(self.inactiveObjects)
		local new = object == nil
		if new then
			object = self:createFunc()
			self:resetFunc(object, new)
		end
		self:AddObject(object)
		return object, new
	end,
	Init = function(self, parent)
		self.activeObjects = {}
		self.inactiveObjects = {}
		self.activeObjectCount = 0
		self.parent = parent
	end
}
GlowMaskPool:Init(GlowParent)

local function TexPoolResetter(pool, tex)
	local maskNum = tex:GetNumMaskTextures()
	for i = maskNum, 1, -1 do
		tex:RemoveMaskTexture(tex:GetMaskTexture(i))
	end
	tex:Hide()
	tex:ClearAllPoints()
end

local GlowTexPool = CreateTexturePool(GlowParent, "OVERLAY", 7, nil, TexPoolResetter)
lib.GlowTexPool = GlowTexPool

local function FramePoolResetter(framePool, frame)
	frame:SetScript("OnUpdate", nil)

	local parent = frame:GetParent()
	if parent[frame.name] then
		parent[frame.name] = nil
	end
	if frame.textures then
		for _, texture in pairs(frame.textures) do
			GlowTexPool:Release(texture)
		end
	end
	if frame.bg then
		GlowTexPool:Release(frame.bg)
		frame.bg = nil
	end
	if frame.masks then
		for _, mask in pairs(frame.masks) do
			GlowMaskPool:Release(mask)
		end
		frame.masks = nil
	end

	frame.textures = {}
	frame.info = {}
	frame.name = nil
	frame.timer = nil
	frame:Hide()
	frame:ClearAllPoints()
end

local GlowFramePool = CreateFramePool("Frame", GlowParent, nil, FramePoolResetter)
lib.GlowFramePool = GlowFramePool

local function addFrameAndTex(r, color, name, key, num, xOffset, yOffset, texture, texCoord, desaturated, frameLevel)
	key = key or ""
	frameLevel = frameLevel or fallbackLevel

	if not r[name..key] then
		r[name..key] = GlowFramePool:Acquire()
		r[name..key]:SetParent(r)
		r[name..key].name = name..key
	end

	local f = r[name..key]
	f:SetFrameLevel(r:GetFrameLevel() + frameLevel)
	f:ClearAllPoints()
	f:SetPoint("TOPLEFT", r, "TOPLEFT", -xOffset + 0.05, yOffset + 0.05)
	f:SetPoint("BOTTOMRIGHT", r, "BOTTOMRIGHT", xOffset, -yOffset + 0.05)
	f:Show()

	if not f.textures then
		f.textures = {}
	end

	for i = 1, num do
		if not f.textures[i] then
			f.textures[i] = GlowTexPool:Acquire()
			f.textures[i]:SetTexture(texture)
			f.textures[i]:SetTexCoord(texCoord[1], texCoord[2], texCoord[3], texCoord[4])
			f.textures[i]:SetDesaturated(desaturated)
			f.textures[i]:SetParent(f)
			f.textures[i]:SetDrawLayer("OVERLAY")
			if not isRetail and name == "_AutoCastGlow" then
				f.textures[i]:SetBlendMode("ADD")
			end
		end

		f.textures[i]:SetVertexColor(color[1], color[2], color[3], color[4])
		f.textures[i]:Show()
	end

	while #f.textures > num do
		GlowTexPool:Release(f.textures[#f.textures])
		table.remove(f.textures)
	end
end

-- Pixel Glow Functions
local function pCalc1(progress, s, th, p)
	local c
	if progress > p[3] or progress < p[0] then
		c = 0
	elseif progress > p[2] then
		c = s - th - (progress - p[2]) / (p[3] - p[2]) * (s - th)
	elseif progress > p[1] then
		c = s - th
	else
		c = (progress - p[0]) / (p[1] - p[0]) * (s - th)
	end

	return math.floor(c + 0.5)
end

local function pCalc2(progress, s, th, p)
	local c
	if progress > p[3] then
		c = s - th - (progress - p[3]) / (p[0] + 1 - p[3]) * (s - th)
	elseif progress > p[2] then
		c = s - th
	elseif progress > p[1] then
		c = (progress - p[1]) / (p[2] - p[1]) * (s - th)
	elseif progress > p[0] then
		c = 0
	else
		c = s - th - (progress + 1 - p[3]) / (p[0] + 1 - p[3]) * (s - th)
	end

	return math.floor(c + 0.5)
end

local function pUpdate(self, elapsed)
	self.timer = self.timer + elapsed / self.info.period
	if self.timer > 1 or self.timer < -1 then
		self.timer = self.timer % 1
	end

	local progress = self.timer
	local width, height = self:GetSize()
	if width ~= self.info.width or height ~= self.info.height then
		local perimeter = 2 * (width + height)
		if not (perimeter > 0) then return end

		self.info.width = width
		self.info.height = height
		self.info.pTLx = {
			[0] = (height + self.info.length / 2) / perimeter,
			[1] = (height + width + self.info.length / 2) / perimeter,
			[2] = (2 * height + width - self.info.length / 2) / perimeter,
			[3] = 1 - self.info.length / 2 / perimeter
		}
		self.info.pTLy = {
			[0] = (height - self.info.length / 2) / perimeter,
			[1] = (height + width + self.info.length / 2) / perimeter,
			[2] = (height * 2 + width + self.info.length / 2) / perimeter,
			[3] = 1 - self.info.length / 2 / perimeter
		}
		self.info.pBRx = {
			[0] = self.info.length / 2 / perimeter,
			[1] = (height - self.info.length / 2) / perimeter,
			[2] = (height + width - self.info.length / 2) / perimeter,
			[3] = (height * 2 + width + self.info.length / 2) / perimeter
		}
		self.info.pBRy = {
			[0] = self.info.length / 2 / perimeter,
			[1] = (height + self.info.length / 2) / perimeter,
			[2] = (height + width - self.info.length / 2) / perimeter,
			[3] = (height * 2 + width - self.info.length / 2) / perimeter
		}
	end

	if self:IsShown() then
		if not (self.masks[1]:IsShown()) then
			self.masks[1]:Show()
			self.masks[1]:ClearAllPoints()
			self.masks[1]:SetPoint("TOPLEFT", self, "TOPLEFT", self.info.th, -self.info.th)
			self.masks[1]:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -self.info.th, self.info.th)
		end
		if self.masks[2] and not self.masks[2]:IsShown() then
			self.masks[2]:Show()
			self.masks[2]:ClearAllPoints()
			self.masks[2]:SetPoint("TOPLEFT", self, "TOPLEFT", self.info.th + 1, -self.info.th - 1)
			self.masks[2]:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -self.info.th - 1, self.info.th + 1)
		end
		if self.bg and not self.bg:IsShown() then
			self.bg:Show()
		end
		for k, line in pairs(self.textures) do
			line:ClearAllPoints()
			line:SetPoint("TOPLEFT", self, "TOPLEFT", pCalc1((progress + self.info.step * (k - 1)) % 1, width, self.info.th, self.info.pTLx), -pCalc2((progress + self.info.step * (k - 1)) % 1, height, self.info.th, self.info.pTLy))
			line:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", self.info.th + pCalc2((progress + self.info.step * (k - 1)) % 1, width, self.info.th, self.info.pBRx), -height + pCalc1((progress + self.info.step * (k - 1)) % 1, height, self.info.th, self.info.pBRy))
		end
	end
end

function lib.PixelGlow_Start(r, options)
	if not r then return end

	options = ApplyDefaults(options, PixelGlowDefaults)

	local period
	if options.frequency then
		if not (options.frequency > 0 or options.frequency < 0) then
			period = 4
		else
			period = 1 / options.frequency
		end
	else
		period = 4
	end

	local width, height = r:GetSize()
	options.length = options.length or math.floor((width + height) * (2 / options.num - 0.1))
	options.length = math.min(options.length, math.min(width, height))

	addFrameAndTex(r, options.color, "_PixelGlow", options.key, options.num, options.xOffset, options.yOffset, textureList.white, {0, 1, 0, 1}, nil, options.frameLevel)
	local f = r["_PixelGlow"..options.key]
	if not f.masks then f.masks = {} end

	if not f.masks[1] then
		f.masks[1] = GlowMaskPool:Acquire()
		f.masks[1]:SetTexture(textureList.empty, "CLAMPTOWHITE", "CLAMPTOWHITE")
		f.masks[1]:Show()
	end
	f.masks[1]:ClearAllPoints()
	f.masks[1]:SetPoint("TOPLEFT", f, "TOPLEFT", options.th, -options.th)
	f.masks[1]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -options.th, options.th)

	if not options.border == false then
		if not f.masks[2] then
			f.masks[2] = GlowMaskPool:Acquire()
			f.masks[2]:SetTexture(textureList.empty, "CLAMPTOWHITE", "CLAMPTOWHITE")
		end
		f.masks[2]:ClearAllPoints()
		f.masks[2]:SetPoint("TOPLEFT", f, "TOPLEFT", options.th + 1, -options.th - 1)
		f.masks[2]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -options.th - 1, options.th + 1)

		if not f.bg then
			f.bg = GlowTexPool:Acquire()
			f.bg:SetColorTexture(0, 0, 0, 0)
			f.bg:SetParent(f)
			f.bg:SetAllPoints(f)
			f.bg:SetDrawLayer("OVERLAY")
			f.bg:AddMaskTexture(f.masks[2])
		end
	else
		if f.bg then
			GlowTexPool:Release(f.bg)
			f.bg = nil
		end
		if f.masks[2] then
			GlowMaskPool:Release(f.masks[2])
			f.masks[2] = nil
		end
	end
	for _, tex in pairs(f.textures) do
		if tex:GetNumMaskTextures() < 1 then
			tex:AddMaskTexture(f.masks[1])
		end
	end

	f.timer = f.timer or 0
	f.info = f.info or {}
	f.info.step = 1 / options.num
	f.info.period = period
	f.info.th = options.th
	if f.info.length ~= options.length then
		f.info.width = nil
		f.info.length = options.length
	end
	pUpdate(f, 0)
	f:SetScript("OnUpdate", pUpdate)
end

function lib.PixelGlow_Stop(r, key)
	if not r then return end

	key = key or ""
	if not r["_PixelGlow"..key] then
		return false
	else
		GlowFramePool:Release(r["_PixelGlow"..key])
	end
end

-- Autocast Glow Functions
local function acUpdate(self, elapsed)
	local width, height = self:GetSize()
	if width ~= self.info.width or height ~= self.info.height then
		if width * height == 0 then return end -- Avoid division by zero
		self.info.width = width
		self.info.height = height
		self.info.perimeter = 2 * (width + height)
		self.info.bottomlim = height * 2 + width
		self.info.rightlim = height + width
		self.info.space = self.info.perimeter / self.info.num
	end

	local texIndex = 0
	for k = 1, 4 do
		self.timer[k] = self.timer[k] + elapsed / (self.info.period * k)
		if self.timer[k] > 1 or self.timer[k] < -1 then
			self.timer[k] = self.timer[k] % 1
		end
		for i = 1, self.info.num do
			texIndex = texIndex + 1
			local position = (self.info.space * i + self.info.perimeter * self.timer[k]) % self.info.perimeter
			if position > self.info.bottomlim then
				self.textures[texIndex]:SetPoint("CENTER", self, "BOTTOMRIGHT", -position + self.info.bottomlim, 0)
			elseif position > self.info.rightlim then
				self.textures[texIndex]:SetPoint("CENTER", self, "TOPRIGHT", 0, -position + self.info.rightlim)
			elseif position > self.info.height then
				self.textures[texIndex]:SetPoint("CENTER", self, "TOPLEFT", position - self.info.height, 0)
			else
				self.textures[texIndex]:SetPoint("CENTER", self, "BOTTOMLEFT", 0, position)
			end
		end
	end
end

function lib.AutoCastGlow_Start(r, options)
	if not r then return end

	options = ApplyDefaults(options, AutoCastGlowDefaults)

	local period
	if options.frequency then
		if not (options.frequency > 0 or options.frequency < 0) then
			period = 8
		else
			period = 1 / options.frequency
		end
	else
		period = 8
	end

	addFrameAndTex(r, options.color, "_AutoCastGlow", options.key, options.num * 4, options.xOffset, options.yOffset, textureList.shine, shineCoords, true, options.frameLevel)
	local f = r["_AutoCastGlow"..options.key]
	local sizes = {7, 6, 5, 4}
	for k, size in pairs(sizes) do
		for i = 1, options.num do
			f.textures[i + options.num * (k - 1)]:SetSize(size * options.scale, size * options.scale)
		end
	end

	f.timer = f.timer or {0, 0, 0, 0}
	f.info = f.info or {}
	f.info.num = options.num
	f.info.period = period
	f:SetScript("OnUpdate", acUpdate)
	acUpdate(f, 0)
end

function lib.AutoCastGlow_Stop(r, key)
	if not r then return end

	key = key or ""
	if not r["_AutoCastGlow"..key] then
		return false
	else
		GlowFramePool:Release(r["_AutoCastGlow"..key])
	end
end

-- Action Button Glow
local function ButtonGlowResetter(framePool, frame)
	frame:SetScript("OnUpdate", nil)

	local parent = frame:GetParent()
	if parent._ButtonGlow then
		parent._ButtonGlow = nil
	end

	frame:Hide()
	frame:ClearAllPoints()
end

local ButtonGlowPool = CreateFramePool("Frame", GlowParent, nil, ButtonGlowResetter)
lib.ButtonGlowPool = ButtonGlowPool

local function CreateScaleAnim(group, target, order, duration, x, y, delay)
	local scale = group:CreateAnimation("Scale")
	scale:SetChildKey(target)
	scale:SetOrder(order)
	scale:SetDuration(duration)
	scale:SetScale(x, y)

	if delay then
		scale:SetStartDelay(delay)
	end
end

local function CreateAlphaAnim(group, target, order, duration, fromAlpha, toAlpha, delay, appear)
	local alpha = group:CreateAnimation("Alpha")
	alpha:SetChildKey(target)
	alpha:SetOrder(order)
	alpha:SetDuration(duration)
	alpha:SetFromAlpha(fromAlpha)
	alpha:SetToAlpha(toAlpha)
	if delay then
		alpha:SetStartDelay(delay)
	end
	if appear then
		table.insert(group.appear, alpha)
	else
		table.insert(group.fade, alpha)
	end
end

local function AnimIn_OnPlay(group)
	local frame = group:GetParent()
	local frameWidth, frameHeight = frame:GetSize()
	frame.spark:SetSize(frameWidth, frameHeight)
	frame.spark:SetAlpha(not frame.color and 1.0 or 0.3 * frame.color[4])
	frame.innerGlow:SetSize(frameWidth / 2, frameHeight / 2)
	frame.innerGlow:SetAlpha(not frame.color and 1.0 or frame.color[4])
	frame.innerGlowOver:SetAlpha(not frame.color and 1.0 or frame.color[4])
	frame.outerGlow:SetSize(frameWidth * 2, frameHeight * 2)
	frame.outerGlow:SetAlpha(not frame.color and 1.0 or frame.color[4])
	frame.outerGlowOver:SetAlpha(not frame.color and 1.0 or frame.color[4])
	frame.ants:SetSize(frameWidth * 0.85, frameHeight * 0.85)
	frame.ants:SetAlpha(0)
	frame:Show()
end

local function AnimIn_OnFinished(group)
	local frame = group:GetParent()
	local frameWidth, frameHeight = frame:GetSize()
	frame.spark:SetAlpha(0)
	frame.innerGlow:SetAlpha(0)
	frame.innerGlow:SetSize(frameWidth, frameHeight)
	frame.innerGlowOver:SetAlpha(0.0)
	frame.outerGlow:SetSize(frameWidth, frameHeight)
	frame.outerGlowOver:SetAlpha(0.0)
	frame.outerGlowOver:SetSize(frameWidth, frameHeight)
	frame.ants:SetAlpha(not frame.color and 1.0 or frame.color[4])
end

local function AnimIn_OnStop(group)
	local frame = group:GetParent()
	local frameWidth, frameHeight = frame:GetSize()
	frame.spark:SetAlpha(0)
	frame.innerGlow:SetAlpha(0)
	frame.innerGlowOver:SetAlpha(0.0)
	frame.outerGlowOver:SetAlpha(0.0)
end

local function bgHide(self)
	if self.animOut:IsPlaying() then
		self.animOut:Stop()
		ButtonGlowPool:Release(self)
	end
end

local function bgUpdate(self, elapsed)
	AnimateTexCoords(self.ants, 256, 256, 48, 48, 22, elapsed, self.throttle)
	local cooldown = self:GetParent().cooldown
	if (cooldown and cooldown:IsShown() and cooldown:GetCooldownDuration() > 3000) then
		self:SetAlpha(0.5)
	else
		self:SetAlpha(1.0)
	end
end

local function configureButtonGlow(f, alpha)
	f.spark = f:CreateTexture(nil, "BACKGROUND")
	f.spark:SetPoint("CENTER")
	f.spark:SetAlpha(0)
	f.spark:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
	f.spark:SetTexCoord(0.00781250, 0.61718750, 0.00390625, 0.26953125)
	-- inner glow
	f.innerGlow = f:CreateTexture(nil, "OVERLAY")
	f.innerGlow:SetPoint("CENTER")
	f.innerGlow:SetAlpha(0)
	f.innerGlow:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
	f.innerGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
	-- inner glow over
	f.innerGlowOver = f:CreateTexture(nil, "OVERLAY")
	f.innerGlowOver:SetPoint("TOPLEFT", f.innerGlow, "TOPLEFT")
	f.innerGlowOver:SetPoint("BOTTOMRIGHT", f.innerGlow, "BOTTOMRIGHT")
	f.innerGlowOver:SetAlpha(0)
	f.innerGlowOver:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
	f.innerGlowOver:SetTexCoord(0.00781250, 0.50781250, 0.53515625, 0.78515625)
	-- outer glow
	f.outerGlow = f:CreateTexture(nil, "OVERLAY")
	f.outerGlow:SetPoint("CENTER")
	f.outerGlow:SetAlpha(0)
	f.outerGlow:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
	f.outerGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
	-- outer glow over
	f.outerGlowOver = f:CreateTexture(nil, "OVERLAY")
	f.outerGlowOver:SetPoint("TOPLEFT", f.outerGlow, "TOPLEFT")
	f.outerGlowOver:SetPoint("BOTTOMRIGHT", f.outerGlow, "BOTTOMRIGHT")
	f.outerGlowOver:SetAlpha(0)
	f.outerGlowOver:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
	f.outerGlowOver:SetTexCoord(0.00781250, 0.50781250, 0.53515625, 0.78515625)
	-- ants
	f.ants = f:CreateTexture(nil, "OVERLAY")
	f.ants:SetPoint("CENTER")
	f.ants:SetAlpha(0)
	f.ants:SetTexture([[Interface\SpellActivationOverlay\IconAlertAnts]])

	f.animIn = f:CreateAnimationGroup()
	f.animIn.appear = {}
	f.animIn.fade = {}
	CreateScaleAnim(f.animIn, "spark", 1, 0.2, 1.5, 1.5)
	CreateAlphaAnim(f.animIn, "spark", 1, 0.2, 0, alpha, nil, true)
	CreateScaleAnim(f.animIn, "innerGlow", 1, 0.3, 2, 2)
	CreateScaleAnim(f.animIn, "innerGlowOver", 1, 0.3, 2, 2)
	CreateAlphaAnim(f.animIn, "innerGlowOver", 1, 0.3, alpha, 0, nil, false)
	CreateScaleAnim(f.animIn, "outerGlow", 1, 0.3, 0.5, 0.5)
	CreateScaleAnim(f.animIn, "outerGlowOver", 1, 0.3, 0.5, 0.5)
	CreateAlphaAnim(f.animIn, "outerGlowOver", 1, 0.3, alpha, 0, nil, false)
	CreateScaleAnim(f.animIn, "spark", 1, 0.2, 2/3, 2/3, 0.2)
	CreateAlphaAnim(f.animIn, "spark", 1, 0.2, alpha, 0, 0.2, false)
	CreateAlphaAnim(f.animIn, "innerGlow", 1, 0.2, alpha, 0, 0.3, false)
	CreateAlphaAnim(f.animIn, "ants", 1, 0.2, 0, alpha, 0.3, true)
	f.animIn:SetScript("OnPlay", AnimIn_OnPlay)
	f.animIn:SetScript("OnStop", AnimIn_OnStop)
	f.animIn:SetScript("OnFinished", AnimIn_OnFinished)

	f.animOut = f:CreateAnimationGroup()
	f.animOut.appear = {}
	f.animOut.fade = {}
	CreateAlphaAnim(f.animOut, "outerGlowOver", 1, 0.2, 0, alpha, nil, true)
	CreateAlphaAnim(f.animOut, "ants", 1, 0.2, alpha, 0, nil, false)
	CreateAlphaAnim(f.animOut, "outerGlowOver", 2, 0.2, alpha, 0, nil, false)
	CreateAlphaAnim(f.animOut, "outerGlow", 2, 0.2, alpha, 0, nil, false)
	f.animOut:SetScript("OnFinished", function(self) ButtonGlowPool:Release(self:GetParent()) end)

	f:SetScript("OnHide", bgHide)
end

local function updateAlphaAnim(f, alpha)
	for _, anim in pairs(f.animIn.appear) do
		anim:SetToAlpha(alpha)
	end
	for _, anim in pairs(f.animIn.fade) do
		anim:SetFromAlpha(alpha)
	end
	for _, anim in pairs(f.animOut.appear) do
		anim:SetToAlpha(alpha)
	end
	for _, anim in pairs(f.animOut.fade) do
		anim:SetFromAlpha(alpha)
	end
end

local ButtonGlowTextures = {["spark"] = true, ["innerGlow"] = true, ["innerGlowOver"] = true, ["outerGlow"] = true, ["outerGlowOver"] = true, ["ants"] = true}

local function noZero(num)
	if num == 0 then
		return 0.001
	else
		return num
	end
end

function lib.ButtonGlow_Start(r, options)
	if not r then return end

	options = ApplyDefaults(options, ButtonGlowDefaults)

	local throttle
	if options.frequency and options.frequency > 0 then
		throttle = 0.25 / options.frequency * 0.01
	else
		throttle = 0.01
	end
	if r._ButtonGlow then
		local f = r._ButtonGlow
		local width, height = r:GetSize()

		f:SetFrameLevel(r:GetFrameLevel() + options.frameLevel)
		if (f._lastW ~= width and f._lastH ~= height) then
			f:ClearAllPoints()
			f:SetPoint("TOPLEFT", r, "TOPLEFT", -width * 0.2, height * 0.2)
			f:SetPoint("BOTTOMRIGHT", r, "BOTTOMRIGHT", width * 0.2, -height * 0.2)
			f.ants:ClearAllPoints()
			f.ants:SetPoint("TOPLEFT", f, "TOPLEFT", width * 0.15, -height * 0.15)
			f.ants:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -width * 0.15, height * 0.15)
			AnimIn_OnFinished(f.animIn)
			f._lastW, f._lastH = width, height
		end

		if f.animOut:IsPlaying() then
			f.animOut:Stop()
			f.animIn:Play()
		end

		if not options.color then
			for texture in pairs(ButtonGlowTextures) do
				f[texture]:SetDesaturated(false)
				f[texture]:SetVertexColor(1, 1, 1)
				local alpha = math.min(f[texture]:GetAlpha() / noZero(f.color and f.color[4] or 1), 1)
				f[texture]:SetAlpha(alpha)
				updateAlphaAnim(f, 1)
			end
			f.color = false
		else
			for texture in pairs(ButtonGlowTextures) do
				f[texture]:SetDesaturated(true)
				f[texture]:SetVertexColor(options.color[1], options.color[2], options.color[3])
				local alpha = math.min(f[texture]:GetAlpha() / noZero(f.color and f.color[4] or 1) * options.color[4], 1)
				f[texture]:SetAlpha(alpha)
				updateAlphaAnim(f, options.color and options.color[4] or 1)
			end
			f.color = options.color
		end
		f.throttle = throttle
	else
		local f, new = ButtonGlowPool:Acquire()
		if new then
			configureButtonGlow(f, options.color and options.color[4] or 1)
		else
			updateAlphaAnim(f, options.color and options.color[4] or 1)
		end
		r._ButtonGlow = f
		local width, height = r:GetSize()
		f._lastW, f._lastH = width, height -- 新增：记录
		f:SetParent(r)
		f:SetFrameLevel(r:GetFrameLevel() + options.frameLevel)
		f:SetSize(width * 1.4, height * 1.4)
		f:ClearAllPoints()
		f:SetPoint("TOPLEFT", r, "TOPLEFT", -width * 0.2, height * 0.2)
		f:SetPoint("BOTTOMRIGHT", r, "BOTTOMRIGHT", width * 0.2, -height * 0.2)
		if not options.color then
			f.color = false
			for texture in pairs(ButtonGlowTextures) do
				f[texture]:SetDesaturated(false)
				f[texture]:SetVertexColor(1, 1, 1)
			end
		else
			f.color = options.color
			for texture in pairs(ButtonGlowTextures) do
				f[texture]:SetDesaturated(true)
				f[texture]:SetVertexColor(options.color[1], options.color[2], options.color[3])
			end
		end
		f.throttle = throttle
		f:SetScript("OnUpdate", bgUpdate)

		f.animIn:Play()

		if Masque and Masque.UpdateSpellAlert and (not r.overlay or not issecurevariable(r, "overlay")) then
			local old_overlay = r.overlay
			r.overlay = f
			Masque:UpdateSpellAlert(r)
			r.overlay = old_overlay
		end
	end
end

function lib.ButtonGlow_Stop(r)
	if r._ButtonGlow then
		if r._ButtonGlow.animOut:IsPlaying() then
			-- Do nothing the animOut finishing will release
		elseif r._ButtonGlow.animIn:IsPlaying() then
			r._ButtonGlow.animIn:Stop()
			ButtonGlowPool:Release(r._ButtonGlow)
		elseif r:IsVisible() then
			r._ButtonGlow.animOut:Play()
		else
			ButtonGlowPool:Release(r._ButtonGlow)
		end
	end
end

-- ProcGlow
local function ProcGlowResetter(framePool, frame)
	-- 停止并隐藏
	if frame.ProcStartAnim and frame.ProcStartAnim:IsPlaying() then frame.ProcStartAnim:Stop() end
	if frame.ProcLoopAnim and frame.ProcLoopAnim:IsPlaying() then frame.ProcLoopAnim:Stop() end
	if frame.ProcStart then frame.ProcStart:Hide() end
	if frame.ProcLoop then frame.ProcLoop:Hide() end

	frame._procState = "idle"

	frame:Hide()
	frame:ClearAllPoints()
	frame:SetScript("OnShow", nil)
	frame:SetScript("OnHide", nil)

	local parent = frame:GetParent()
	if frame.key and parent and parent[frame.key] then
		parent[frame.key] = nil
	end
end

local ProcGlowPool = CreateFramePool("Frame", GlowParent, nil, ProcGlowResetter)
lib.ProcGlowPool = ProcGlowPool

local function InitProcGlow(f)
	-- Start 贴图
	f.ProcStart = f:CreateTexture(nil, "OVERLAY")
	f.ProcStart:SetBlendMode("ADD")
	f.ProcStart:SetAtlas("UI-HUD-ActionBar-Proc-Start-Flipbook")
	f.ProcStart:SetAlpha(1)
	f.ProcStart:SetSize(150, 150)
	f.ProcStart:SetPoint("CENTER")
	-- Loop 贴图：绑定到父 frame 四边，避免 FlipBook 覆盖尺寸
	f.ProcLoop = f:CreateTexture(nil, "OVERLAY")
	f.ProcLoop:SetAtlas("UI-HUD-ActionBar-Proc-Loop-Flipbook")
	f.ProcLoop:SetAlpha(0)
	f.ProcLoop:ClearAllPoints()
	f.ProcLoop:SetPoint("TOPLEFT", f, "TOPLEFT")
	f.ProcLoop:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
	-- Loop 动画
	f.ProcLoopAnim = f:CreateAnimationGroup()
	f.ProcLoopAnim:SetLooping("REPEAT")
	f.ProcLoopAnim:SetToFinalAlpha(true)

	local alphaRepeat = f.ProcLoopAnim:CreateAnimation("Alpha")
	alphaRepeat:SetChildKey("ProcLoop")
	alphaRepeat:SetFromAlpha(1)
	alphaRepeat:SetToAlpha(1)
	alphaRepeat:SetDuration(.001)
	alphaRepeat:SetOrder(0)
	f.ProcLoopAnim.alphaRepeat = alphaRepeat

	local flipbookRepeat = f.ProcLoopAnim:CreateAnimation("FlipBook")
	flipbookRepeat:SetChildKey("ProcLoop")
	flipbookRepeat:SetDuration(1)
	flipbookRepeat:SetOrder(0)
	flipbookRepeat:SetFlipBookRows(6)
	flipbookRepeat:SetFlipBookColumns(5)
	flipbookRepeat:SetFlipBookFrames(30)
	flipbookRepeat:SetFlipBookFrameWidth(0)
	flipbookRepeat:SetFlipBookFrameHeight(0)
	f.ProcLoopAnim.flipbookRepeat = flipbookRepeat
	-- Start 动画
	f.ProcStartAnim = f:CreateAnimationGroup()
	f.ProcStartAnim:SetToFinalAlpha(true)

	local flipbookStartAlphaIn = f.ProcStartAnim:CreateAnimation("Alpha")
	flipbookStartAlphaIn:SetChildKey("ProcStart")
	flipbookStartAlphaIn:SetDuration(.001)
	flipbookStartAlphaIn:SetOrder(0)
	flipbookStartAlphaIn:SetFromAlpha(1)
	flipbookStartAlphaIn:SetToAlpha(1)

	local flipbookStart = f.ProcStartAnim:CreateAnimation("FlipBook")
	flipbookStart:SetChildKey("ProcStart")
	flipbookStart:SetDuration(0.7)
	flipbookStart:SetOrder(1)
	flipbookStart:SetFlipBookRows(6)
	flipbookStart:SetFlipBookColumns(5)
	flipbookStart:SetFlipBookFrames(30)
	flipbookStart:SetFlipBookFrameWidth(0)
	flipbookStart:SetFlipBookFrameHeight(0)
	f.ProcStartAnim.flipbookStart = flipbookStart

	local flipbookStartAlphaOut = f.ProcStartAnim:CreateAnimation("Alpha")
	flipbookStartAlphaOut:SetChildKey("ProcStart")
	flipbookStartAlphaOut:SetDuration(.001)
	flipbookStartAlphaOut:SetOrder(2)
	flipbookStartAlphaOut:SetFromAlpha(1)
	flipbookStartAlphaOut:SetToAlpha(0)

	-- Start 播放完成后进入 Loop
	f.ProcStartAnim:SetScript("OnFinished", function(self)
		local p = self:GetParent()
		p.ProcStart:Hide()
		p.ProcLoop:Show()
		p.ProcLoopAnim:Play()
		p._procState = "loop"
	end)
	-- 状态标记
	f._procState = "idle"
end

local function SetupProcGlow(f, options)
	f.key = "_ProcGlow" .. options.key
	-- 更新颜色
	if not options.color then
		f.ProcStart:SetDesaturated(false)
		f.ProcStart:SetVertexColor(1, 1, 1, 1)
		f.ProcLoop:SetDesaturated(false)
		f.ProcLoop:SetVertexColor(1, 1, 1, 1)
	else
		f.ProcStart:SetDesaturated(true)
		f.ProcStart:SetVertexColor(unpack(options.color))
		f.ProcLoop:SetDesaturated(true)
		f.ProcLoop:SetVertexColor(unpack(options.color))
	end
	-- 更新 Loop 动画时长
	f.ProcLoopAnim.flipbookRepeat:SetDuration(options.duration)
	f.startAnim = options.startAnim
	-- 刷新时不重播，只在 idle 状态下启动
	local isPlaying = (f.ProcStartAnim and f.ProcStartAnim:IsPlaying()) or (f.ProcLoopAnim and f.ProcLoopAnim:IsPlaying())
	if not isPlaying and f._procState == "idle" then
		if options.startAnim then
			local w, h = f:GetSize()
			f.ProcStart:ClearAllPoints()
			f.ProcStart:SetPoint("CENTER", f, "CENTER")
			f.ProcStart:SetPoint("TOPLEFT", f, "CENTER", -(w / 42 * 75) / 1.4, (h / 42 * 75) / 1.4)
			f.ProcStart:SetPoint("BOTTOMRIGHT", f, "CENTER", (w / 42 * 75) / 1.4, -(h / 42 * 75) / 1.4)
			f.ProcStart:Show()
			f.ProcLoop:Hide()
			f.ProcStartAnim:Play()
			f._procState = "start"
		else
			f.ProcStart:Hide()
			f.ProcLoop:Show()
			f.ProcLoopAnim:Play()
			f._procState = "loop"
		end
	end
	-- OnHide：只停止，不重播
	f:SetScript("OnHide", function(self)
		if self.ProcStartAnim and self.ProcStartAnim:IsPlaying() then self.ProcStartAnim:Stop() end
		if self.ProcLoopAnim and self.ProcLoopAnim:IsPlaying() then self.ProcLoopAnim:Stop() end
		if self.ProcStart then self.ProcStart:Hide() end
		if self.ProcLoop then self.ProcLoop:Hide() end
	end)
end

function lib.ProcGlow_Start(r, options)
	if not r then return end

	options = ApplyDefaults(options, ProcGlowDefaults)

	local key = "_ProcGlow" .. options.key
	local f, new
	if r[key] then
		f = r[key]
	else
		f, new = ProcGlowPool:Acquire()
		if new then InitProcGlow(f) end
		r[key] = f
	end

	f:SetParent(r)
	f:SetFrameLevel(r:GetFrameLevel() + options.frameLevel)

	local width, height = r:GetSize()
	local xOffset = options.xOffset + width * 0.2
	local yOffset = options.yOffset + height * 0.2
	f:ClearAllPoints()
	f:SetPoint("TOPLEFT", r, "TOPLEFT", -xOffset, yOffset)
	f:SetPoint("BOTTOMRIGHT", r, "BOTTOMRIGHT", xOffset, -yOffset)

	SetupProcGlow(f, options)
	f:Show()
end

function lib.ProcGlow_Stop(r, key)
	key = key or ""
	local f = r["_ProcGlow" .. key]
	if f then
		if f.ProcStartAnim and f.ProcStartAnim:IsPlaying() then f.ProcStartAnim:Stop() end
		if f.ProcLoopAnim and f.ProcLoopAnim:IsPlaying() then f.ProcLoopAnim:Stop() end
		if f.ProcStart then f.ProcStart:Hide() end
		if f.ProcLoop then f.ProcLoop:Hide() end
		f._procState = "idle"
		ProcGlowPool:Release(f)
	end
end

-- 注册光效
RegisterGlow("Pixel Glow", lib.PixelGlow_Start, lib.PixelGlow_Stop)
RegisterGlow("Autocast Shine", lib.AutoCastGlow_Start, lib.AutoCastGlow_Stop)
RegisterGlow("Action Button Glow", lib.ButtonGlow_Start, lib.ButtonGlow_Stop)
RegisterGlow("Proc Glow", lib.ProcGlow_Start, lib.ProcGlow_Stop)

-- NDui
local LCG_GlowList = {
	[1] = "Pixel Glow",
	[2] = "Autocast Shine",
	[3] = "Action Button Glow",
	[4] = "Proc Glow",
}

local function GetGlowType()
	return LCG_GlowList[NDuiADB and NDuiADB.GlowMode or 3]
end
function lib.ShowOverlayGlow(button)
	lib.startList[GetGlowType()](button)
end
function lib.HideOverlayGlow(button)
	lib.stopList[GetGlowType()](button)
end