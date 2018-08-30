-- [[ Core ]]
local addonName, ns = ...

ns[1] = {} -- F, functions
ns[2] = {} -- C, constants/config
_G[addonName] = ns

AuroraConfig = {}

local F, C = unpack(ns)

-- [[ Constants and settings ]]

local mediaPath = "Interface\\AddOns\\AuroraClassic\\media\\"

C.media = {
	["arrowUp"] = mediaPath.."arrow-up-active",
	["arrowDown"] = mediaPath.."arrow-down-active",
	["arrowLeft"] = mediaPath.."arrow-left-active",
	["arrowRight"] = mediaPath.."arrow-right-active",
	["backdrop"] = "Interface\\ChatFrame\\ChatFrameBackground",
	["checked"] = mediaPath.."CheckButtonHilight",
	["font"] = STANDARD_TEXT_FONT,
	["gradient"] = mediaPath.."gradient",
	["roleIcons"] = mediaPath.."UI-LFG-ICON-ROLES",
	["bgTex"] = mediaPath.."bgTex",
	["glowTex"] = mediaPath.."glowTex",
}

C.defaults = {
	["alpha"] = 0.5,
	["bags"] = false,
	["buttonGradientColour"] = {.3, .3, .3, .3},
	["buttonSolidColour"] = {.2, .2, .2, .6},
	["useButtonGradientColour"] = true,
	["chatBubbles"] = true,
	["bubbleColor"] = false,
	["reskinFont"] = true,
	["loot"] = true,
	["useCustomColour"] = false,
	["customColour"] = {r = 1, g = 1, b = 1},
	["tooltips"] = false,
	["shadow"] = true,
	["fontScale"] = 1,
}

C.frames = {}

-- [[ Functions ]]

local useButtonGradientColour
local _, class = UnitClass("player")
C.classcolours = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
local r, g, b = C.classcolours[class].r, C.classcolours[class].g, C.classcolours[class].b

function F:dummy()
end

local function CreateTex(f)
	if f.Tex then return end
	f.Tex = f:CreateTexture(nil, "BACKGROUND", nil, 1)
	f.Tex:SetAllPoints()
	f.Tex:SetTexture(C.media.bgTex, true, true)
	f.Tex:SetHorizTile(true)
	f.Tex:SetVertTile(true)
	f.Tex:SetBlendMode("ADD")
end

function F:CreateSD()
	if not AuroraConfig.shadow then return end
	if self.Shadow then return end
	self.Shadow = CreateFrame("Frame", nil, self)
	self.Shadow:SetPoint("TOPLEFT", -2, 2)
	self.Shadow:SetPoint("BOTTOMRIGHT", 2, -2)
	self.Shadow:SetBackdrop({edgeFile = C.media.glowTex, edgeSize = 3})
	self.Shadow:SetBackdropBorderColor(0, 0, 0)
	CreateTex(self)
	return self.Shadow
end

function F:CreateBD(a)
	self:SetBackdrop({
		bgFile = C.media.backdrop,
		edgeFile = C.media.backdrop,
		edgeSize = 1.2,
	})
	self:SetBackdropColor(0, 0, 0, a or AuroraConfig.alpha)
	self:SetBackdropBorderColor(0, 0, 0)
	if not a then tinsert(C.frames, self) end
end

function F:CreateBG()
	local f = self
	if self:GetObjectType() == "Texture" then f = self:GetParent() end

	local bg = f:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", self, -1.2, 1.2)
	bg:SetPoint("BOTTOMRIGHT", self, 1.2, -1.2)
	bg:SetTexture(C.media.backdrop)
	bg:SetVertexColor(0, 0, 0)

	return bg
end

-- we assign these after loading variables for caching
-- otherwise we call an extra unpack() every time
local buttonR, buttonG, buttonB, buttonA

function F:CreateGradient()
	local tex = self:CreateTexture(nil, "BORDER")
	tex:SetPoint("TOPLEFT", 1, -1)
	tex:SetPoint("BOTTOMRIGHT", -1, 1)
	tex:SetTexture(useButtonGradientColour and C.media.gradient or C.media.backdrop)
	tex:SetVertexColor(buttonR, buttonG, buttonB, buttonA)

	return tex
end

local function colourButton(self)
	if not self:IsEnabled() then return end

	if useButtonGradientColour then
		self:SetBackdropColor(r, g, b, .25)
	else
		self.bgTex:SetVertexColor(r / 4, g / 4, b / 4)
	end

	self:SetBackdropBorderColor(r, g, b)
end

local function clearButton(self)
	if useButtonGradientColour then
		self:SetBackdropColor(0, 0, 0, 0)
	else
		self.bgTex:SetVertexColor(buttonR, buttonG, buttonB, buttonA)
	end

	self:SetBackdropBorderColor(0, 0, 0)
end

function F:Reskin(noHighlight)
	if self.SetNormalTexture then self:SetNormalTexture("") end
	if self.SetHighlightTexture then self:SetHighlightTexture("") end
	if self.SetPushedTexture then self:SetPushedTexture("") end
	if self.SetDisabledTexture then self:SetDisabledTexture("") end

	if self.Left then self.Left:SetAlpha(0) end
	if self.Middle then self.Middle:SetAlpha(0) end
	if self.Right then self.Right:SetAlpha(0) end
	if self.LeftSeparator then self.LeftSeparator:SetAlpha(0) end
	if self.RightSeparator then self.RightSeparator:SetAlpha(0) end
	if self.TopLeft then self.TopLeft:SetAlpha(0) end
	if self.TopMiddle then self.TopMiddle:SetAlpha(0) end
	if self.TopRight then self.TopRight:SetAlpha(0) end
	if self.MiddleLeft then self.MiddleLeft:SetAlpha(0) end
	if self.MiddleMiddle then self.MiddleMiddle:SetAlpha(0) end
	if self.MiddleRight then self.MiddleRight:SetAlpha(0) end
	if self.BottomLeft then self.BottomLeft:SetAlpha(0) end
	if self.BottomMiddle then self.BottomMiddle:SetAlpha(0) end
	if self.BottomRight then self.BottomRight:SetAlpha(0) end

	F.CreateBD(self, .0)

	self.bgTex = F.CreateGradient(self)

	if not noHighlight then
		self:HookScript("OnEnter", colourButton)
 		self:HookScript("OnLeave", clearButton)
	end
end

function F:ReskinTab()
	self:DisableDrawLayer("BACKGROUND")

	local bg = CreateFrame("Frame", nil, self)
	bg:SetPoint("TOPLEFT", 8, -3)
	bg:SetPoint("BOTTOMRIGHT", -8, 0)
	bg:SetFrameLevel(self:GetFrameLevel()-1)
	F.CreateBD(bg)

	self:SetHighlightTexture(C.media.backdrop)
	local hl = self:GetHighlightTexture()
	hl:SetPoint("TOPLEFT", 9, -4)
	hl:SetPoint("BOTTOMRIGHT", -9, 1)
	hl:SetVertexColor(r, g, b, .25)
end

local function textureOnEnter(self)
	if self:IsEnabled() then
		if self.pixels then
			for _, pixel in pairs(self.pixels) do
				pixel:SetVertexColor(r, g, b)
			end
		else
			self.bgTex:SetVertexColor(r, g, b)
		end
	end
end
F.colourArrow = textureOnEnter

local function textureOnLeave(self)
	if self.pixels then
		for _, pixel in pairs(self.pixels) do
			pixel:SetVertexColor(1, 1, 1)
		end
	else
		self.bgTex:SetVertexColor(1, 1, 1)
	end
end
F.clearArrow = textureOnLeave

local function scrollOnEnter(self)
	local bu = (self.ThumbTexture or self.thumbTexture) or _G[self:GetName().."ThumbTexture"]
	if not bu then return end
	bu.bg:SetBackdropColor(r, g, b, .25)
	bu.bg:SetBackdropBorderColor(r, g, b)
end

local function scrollOnLeave(self)
	local bu = (self.ThumbTexture or self.thumbTexture) or _G[self:GetName().."ThumbTexture"]
	if not bu then return end
	bu.bg:SetBackdropColor(0, 0, 0, 0)
	bu.bg:SetBackdropBorderColor(0, 0, 0)
end

function F:ReskinScroll()
	local frame = self:GetName()

	local track = (self.trackBG or self.Background or self.Track) or (_G[frame.."Track"] or _G[frame.."BG"])
	if track then track:Hide() end
	local top = (self.ScrollBarTop or self.Top or self.ScrollUpBorder) or _G[frame.."Top"]
	if top then top:Hide() end
	local middle = (self.ScrollBarMiddle or self.Middle or self.Border) or _G[frame.."Middle"]
	if middle then middle:Hide() end
	local bottom = (self.ScrollBarBottom or self.Bottom or self.ScrollDownBorder) or _G[frame.."Bottom"]
	if bottom then bottom:Hide() end

	local bu = (self.ThumbTexture or self.thumbTexture) or _G[frame.."ThumbTexture"]
	bu:SetAlpha(0)
	bu:SetWidth(17)

	bu.bg = CreateFrame("Frame", nil, self)
	bu.bg:SetPoint("TOPLEFT", bu, 0, -2)
	bu.bg:SetPoint("BOTTOMRIGHT", bu, 0, 4)
	F.CreateBD(bu.bg, 0)

	local tex = F.CreateGradient(self)
	tex:SetPoint("TOPLEFT", bu.bg, 1, -1)
	tex:SetPoint("BOTTOMRIGHT", bu.bg, -1, 1)

	local up, down = self:GetChildren()
	up:SetWidth(17)
	down:SetWidth(17)

	F.Reskin(up, true)
	F.Reskin(down, true)

	up:SetDisabledTexture(C.media.backdrop)
	local dis1 = up:GetDisabledTexture()
	dis1:SetVertexColor(0, 0, 0, .4)
	dis1:SetDrawLayer("OVERLAY")

	down:SetDisabledTexture(C.media.backdrop)
	local dis2 = down:GetDisabledTexture()
	dis2:SetVertexColor(0, 0, 0, .4)
	dis2:SetDrawLayer("OVERLAY")

	local uptex = up:CreateTexture(nil, "ARTWORK")
	uptex:SetTexture(C.media.arrowUp)
	uptex:SetSize(8, 8)
	uptex:SetPoint("CENTER")
	uptex:SetVertexColor(1, 1, 1)
	up.bgTex = uptex

	local downtex = down:CreateTexture(nil, "ARTWORK")
	downtex:SetTexture(C.media.arrowDown)
	downtex:SetSize(8, 8)
	downtex:SetPoint("CENTER")
	downtex:SetVertexColor(1, 1, 1)
	down.bgTex = downtex

	up:HookScript("OnEnter", textureOnEnter)
	up:HookScript("OnLeave", textureOnLeave)
	down:HookScript("OnEnter", textureOnEnter)
	down:HookScript("OnLeave", textureOnLeave)
	self:HookScript("OnEnter", scrollOnEnter)
	self:HookScript("OnLeave", scrollOnLeave)
end

function F:ReskinDropDown()
	local frame = self:GetName()

	local left = self.Left or _G[frame.."Left"]
	local middle = self.Middle or _G[frame.."Middle"]
	local right = self.Right or _G[frame.."Right"]

	if left then left:SetAlpha(0) end
	if middle then middle:SetAlpha(0) end
	if right then right:SetAlpha(0) end

	local down = self.Button or _G[frame.."Button"]

	down:SetSize(20, 20)
	down:ClearAllPoints()
	down:SetPoint("RIGHT", -18, 2)

	F.Reskin(down, true)

	down:SetDisabledTexture(C.media.backdrop)
	local dis = down:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .4)
	dis:SetDrawLayer("OVERLAY")
	dis:SetAllPoints()

	local tex = down:CreateTexture(nil, "ARTWORK")
	tex:SetTexture(C.media.arrowDown)
	tex:SetSize(8, 8)
	tex:SetPoint("CENTER")
	tex:SetVertexColor(1, 1, 1)
	down.bgTex = tex

	down:HookScript("OnEnter", textureOnEnter)
	down:HookScript("OnLeave", textureOnLeave)

	local bg = CreateFrame("Frame", nil, self)
	bg:SetPoint("TOPLEFT", 16, -4)
	bg:SetPoint("BOTTOMRIGHT", -18, 8)
	bg:SetFrameLevel(self:GetFrameLevel() - 1)
	F.CreateBD(bg, 0)

	local gradient = F.CreateGradient(self)
	gradient:SetPoint("TOPLEFT", bg, 1, -1)
	gradient:SetPoint("BOTTOMRIGHT", bg, -1, 1)
end

function F:ReskinClose(a1, p, a2, x, y)
	self:SetSize(17, 17)

	if not a1 then
		self:SetPoint("TOPRIGHT", -6, -6)
	else
		self:ClearAllPoints()
		self:SetPoint(a1, p, a2, x, y)
	end

	self:SetNormalTexture("")
	self:SetHighlightTexture("")
	self:SetPushedTexture("")
	self:SetDisabledTexture("")
	F.CreateBD(self, 0)
	F.CreateGradient(self)

	self:SetDisabledTexture(C.media.backdrop)
	local dis = self:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .4)
	dis:SetDrawLayer("OVERLAY")
	dis:SetAllPoints()

	self.pixels = {}
	for i = 1, 2 do
		local tex = self:CreateTexture()
		tex:SetColorTexture(1, 1, 1)
		tex:SetSize(11, 2)
		tex:SetPoint("CENTER")
		tex:SetRotation(math.rad((i-1/2)*90))
		tinsert(self.pixels, tex)
	end

	self:HookScript("OnEnter", textureOnEnter)
 	self:HookScript("OnLeave", textureOnLeave)
end

function F:ReskinInput(height, width)
	local frame = self:GetName()

	local left = self.Left or _G[frame.."Left"]
	local middle = self.Middle or _G[frame.."Middle"] or _G[frame.."Mid"]
	local right = self.Right or _G[frame.."Right"]

	left:Hide()
	middle:Hide()
	right:Hide()

	local bd = CreateFrame("Frame", nil, self)
	bd:SetPoint("TOPLEFT", -2, 0)
	bd:SetPoint("BOTTOMRIGHT")
	bd:SetFrameLevel(self:GetFrameLevel() - 1)
	F.CreateBD(bd, 0)

	local gradient = F.CreateGradient(self)
	gradient:SetPoint("TOPLEFT", bd, 1, -1)
	gradient:SetPoint("BOTTOMRIGHT", bd, -1, 1)

	if height then self:SetHeight(height) end
	if width then self:SetWidth(width) end
end

function F:ReskinArrow(direction)
	self:SetSize(18, 18)
	F.Reskin(self, true)

	self:SetDisabledTexture(C.media.backdrop)
	local dis = self:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .3)
	dis:SetDrawLayer("OVERLAY")

	local tex = self:CreateTexture(nil, "ARTWORK")
	tex:SetTexture(mediaPath.."arrow-"..direction.."-active")
	tex:SetSize(8, 8)
	tex:SetPoint("CENTER")
	self.bgTex = tex

	self:HookScript("OnEnter", textureOnEnter)
	self:HookScript("OnLeave", textureOnLeave)
end

function F:ReskinCheck()
	self:SetNormalTexture("")
	self:SetPushedTexture("")
	self:SetHighlightTexture(C.media.backdrop)
	local hl = self:GetHighlightTexture()
	hl:SetPoint("TOPLEFT", 5, -5)
	hl:SetPoint("BOTTOMRIGHT", -5, 5)
	hl:SetVertexColor(r, g, b, .25)

	local bd = CreateFrame("Frame", nil, self)
	bd:SetPoint("TOPLEFT", 4, -4)
	bd:SetPoint("BOTTOMRIGHT", -4, 4)
	bd:SetFrameLevel(self:GetFrameLevel() - 1)
	F.CreateBD(bd, 0)

	local tex = F.CreateGradient(self)
	tex:SetPoint("TOPLEFT", 5, -5)
	tex:SetPoint("BOTTOMRIGHT", -5, 5)

	local ch = self:GetCheckedTexture()
	ch:SetDesaturated(true)
	ch:SetVertexColor(r, g, b)
end

local function colourRadio(self)
	self.bd:SetBackdropBorderColor(r, g, b)
end

local function clearRadio(self)
	self.bd:SetBackdropBorderColor(0, 0, 0)
end

function F:ReskinRadio()
	self:SetNormalTexture("")
	self:SetHighlightTexture("")
	self:SetCheckedTexture(C.media.backdrop)

	local ch = self:GetCheckedTexture()
	ch:SetPoint("TOPLEFT", 4, -4)
	ch:SetPoint("BOTTOMRIGHT", -4, 4)
	ch:SetVertexColor(r, g, b, .6)

	local bd = CreateFrame("Frame", nil, self)
	bd:SetPoint("TOPLEFT", 3, -3)
	bd:SetPoint("BOTTOMRIGHT", -3, 3)
	bd:SetFrameLevel(self:GetFrameLevel() - 1)
	F.CreateBD(bd, 0)
	self.bd = bd

	local tex = F.CreateGradient(self)
	tex:SetPoint("TOPLEFT", 4, -4)
	tex:SetPoint("BOTTOMRIGHT", -4, 4)

	self:HookScript("OnEnter", colourRadio)
	self:HookScript("OnLeave", clearRadio)
end

function F:ReskinSlider(verticle)
	self:SetBackdrop(nil)
	self.SetBackdrop = F.dummy

	local bd = CreateFrame("Frame", nil, self)
	bd:SetPoint("TOPLEFT", 14, -2)
	bd:SetPoint("BOTTOMRIGHT", -15, 3)
	bd:SetFrameStrata("BACKGROUND")
	bd:SetFrameLevel(self:GetFrameLevel() - 1)
	F.CreateBD(bd, 0)

	F.CreateGradient(bd)

	for i = 1, self:GetNumRegions() do
		local region = select(i, self:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
			region:SetBlendMode("ADD")
			if verticle then region:SetRotation(math.rad(90)) end
			return
		end
	end
end

local function expandOnEnter(self)
	if self:IsEnabled() then
		self.bg:SetBackdropColor(r, g, b, .25)
	end
end

local function expandOnLeave(self)
	self.bg:SetBackdropColor(0, 0, 0, .25)
end

local function SetupTexture(self, texture)
	if self.settingTexture then return end
	self.settingTexture = true
	self:SetNormalTexture("")

	if texture and texture ~= "" then
		if texture:find("Plus") then
			self.expTex:SetTexCoord(0, 0.4375, 0, 0.4375)
		elseif texture:find("Minus") then
			self.expTex:SetTexCoord(0.5625, 1, 0, 0.4375)
		end
		self.bg:Show()
	else
		self.bg:Hide()
	end
	self.settingTexture = nil
end

function F:ReskinExpandOrCollapse()
	self:SetHighlightTexture("")
	self:SetPushedTexture("")

	local bg = F.CreateBDFrame(self, .25)
	bg:ClearAllPoints()
	bg:SetSize(13, 13)
	bg:SetPoint("TOPLEFT", self:GetNormalTexture())
	F.CreateGradient(bg)
	self.bg = bg

	self.expTex = bg:CreateTexture(nil, "OVERLAY")
	self.expTex:SetSize(7, 7)
	self.expTex:SetPoint("CENTER")
	self.expTex:SetTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")

	self:HookScript("OnEnter", expandOnEnter)
	self:HookScript("OnLeave", expandOnLeave)
	hooksecurefunc(self, "SetNormalTexture", SetupTexture)
end

function F:SetBD(x, y, x2, y2)
	local bg = CreateFrame("Frame", nil, self)
	if not x then
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("BOTTOMRIGHT")
	else
		bg:SetPoint("TOPLEFT", x, y)
		bg:SetPoint("BOTTOMRIGHT", x2, y2)
	end
	bg:SetFrameLevel(self:GetFrameLevel() - 1)
	F.CreateBD(bg)
	F.CreateSD(bg)
end

function F:StripTextures()
	for i = 1, self:GetNumRegions() do
		local region = select(i, self:GetRegions())
		if region and region:GetObjectType() == "Texture" then
			region:SetTexture("")
		end
	end
end

function F:ReskinPortraitFrame(isButtonFrame)
	local name = self:GetName()

	_G[name.."Bg"]:Hide()
	_G[name.."TitleBg"]:Hide()
	_G[name.."Portrait"]:Hide()
	_G[name.."PortraitFrame"]:Hide()
	_G[name.."TopRightCorner"]:Hide()
	_G[name.."TopLeftCorner"]:Hide()
	_G[name.."TopBorder"]:Hide()
	_G[name.."TopTileStreaks"]:SetTexture("")
	_G[name.."BotLeftCorner"]:Hide()
	_G[name.."BotRightCorner"]:Hide()
	_G[name.."BottomBorder"]:Hide()
	_G[name.."LeftBorder"]:Hide()
	_G[name.."RightBorder"]:Hide()

	if isButtonFrame then
		_G[name.."BtnCornerLeft"]:SetTexture("")
		_G[name.."BtnCornerRight"]:SetTexture("")
		_G[name.."ButtonBottomBorder"]:SetTexture("")

		self.Inset.Bg:Hide()
		self.Inset:DisableDrawLayer("BORDER")
	end

	F.CreateBD(self)
	F.CreateSD(self)
	F.ReskinClose(_G[name.."CloseButton"])
end

function F:CreateBDFrame(a)
	local frame = self
	if self:GetObjectType() == "Texture" then frame = self:GetParent() end
	local lvl = frame:GetFrameLevel()

	local bg = CreateFrame("Frame", nil, frame)
	bg:SetPoint("TOPLEFT", self, -1.2, 1.2)
	bg:SetPoint("BOTTOMRIGHT", self, 1.2, -1.2)
	bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)
	F.CreateBD(bg, a or .5)

	return bg
end

function F:ReskinColourSwatch()
	local name = self:GetName()

	self:SetNormalTexture(C.media.backdrop)
	local nt = self:GetNormalTexture()
	nt:SetPoint("TOPLEFT", 3, -3)
	nt:SetPoint("BOTTOMRIGHT", -3, 3)

	local bg = _G[name.."SwatchBg"]
	bg:SetColorTexture(0, 0, 0)
	bg:SetPoint("TOPLEFT", 2, -2)
	bg:SetPoint("BOTTOMRIGHT", -2, 2)
end

function F:ReskinFilterButton()
	self.TopLeft:Hide()
	self.TopRight:Hide()
	self.BottomLeft:Hide()
	self.BottomRight:Hide()
	self.TopMiddle:Hide()
	self.MiddleLeft:Hide()
	self.MiddleRight:Hide()
	self.BottomMiddle:Hide()
	self.MiddleMiddle:Hide()

	F.Reskin(self)
	self.Text:SetPoint("CENTER")
	self.Icon:SetTexture(C.media.arrowRight)
	self.Icon:SetPoint("RIGHT", self, "RIGHT", -5, 0)
	self.Icon:SetSize(8, 8)
end

function F:ReskinNavBar()
	if self.navBarStyled then return end

	local homeButton = self.homeButton
	local overflowButton = self.overflowButton

	self:GetRegions():Hide()
	self:DisableDrawLayer("BORDER")
	self.overlay:Hide()
	homeButton:GetRegions():Hide()
	F.Reskin(homeButton)
	F.Reskin(overflowButton, true)

	local tex = overflowButton:CreateTexture(nil, "ARTWORK")
	tex:SetTexture(C.media.arrowLeft)
	tex:SetSize(8, 8)
	tex:SetPoint("CENTER")
	overflowButton.bgTex = tex

	overflowButton:HookScript("OnEnter", textureOnEnter)
	overflowButton:HookScript("OnLeave", textureOnLeave)

	self.navBarStyled = true
end

function F:ReskinGarrisonPortrait()
	self.Portrait:ClearAllPoints()
	self.Portrait:SetPoint("TOPLEFT", 4, -4)
	self.PortraitRing:Hide()
	self.PortraitRingQuality:SetTexture("")
	if self.Highlight then self.Highlight:Hide() end

	self.LevelBorder:SetScale(.0001)
	self.Level:ClearAllPoints()
	self.Level:SetPoint("BOTTOM", self, 0, 12)

	self.squareBG = F.CreateBDFrame(self, 1)
	self.squareBG:SetFrameLevel(self:GetFrameLevel())
	self.squareBG:SetPoint("TOPLEFT", 3, -3)
	self.squareBG:SetPoint("BOTTOMRIGHT", -3, 11)
	
	if self.PortraitRingCover then
		self.PortraitRingCover:SetColorTexture(0, 0, 0)
		self.PortraitRingCover:SetAllPoints(self.squareBG)
	end

	if self.Empty then
		self.Empty:SetColorTexture(0, 0, 0)
		self.Empty:SetAllPoints(self.Portrait)
	end
end

function F:ReskinIcon()
	self:SetTexCoord(.08, .92, .08, .92)
	return F.CreateBG(self)
end

function F:ReskinMinMax()
	for _, name in next, {"MaximizeButton", "MinimizeButton"} do
		local button = self[name]
		if button then
			button:SetSize(17, 17)
			button:ClearAllPoints()
			button:SetPoint("CENTER", -3, 0)
			F.Reskin(button)

			button.pixels = {}

			local tex = button:CreateTexture()
			tex:SetColorTexture(1, 1, 1)
			tex:SetSize(11, 2)
			tex:SetPoint("CENTER")
			tex:SetRotation(math.rad(45))
			tinsert(button.pixels, tex)

			local hline = button:CreateTexture()
			hline:SetColorTexture(1, 1, 1)
			hline:SetSize(7, 2)
			tinsert(button.pixels, hline)
			local vline = button:CreateTexture()
			vline:SetColorTexture(1, 1, 1)
			vline:SetSize(2, 7)
			tinsert(button.pixels, vline)

			if name == "MaximizeButton" then
				hline:SetPoint("TOPRIGHT", -4, -4)
				vline:SetPoint("TOPRIGHT", -4, -4)
			else
				hline:SetPoint("BOTTOMLEFT", 4, 4)
				vline:SetPoint("BOTTOMLEFT", 4, 4)
			end

			button:SetScript("OnEnter", textureOnEnter)
			button:SetScript("OnLeave", textureOnLeave)
		end
	end
end

-- [[ Variable and module handling ]]

C.themes = {}
C.themes["AuroraClassic"] = {}

-- [[ Initialize addon ]]

local Skin = CreateFrame("Frame")
Skin:RegisterEvent("ADDON_LOADED")
Skin:SetScript("OnEvent", function(_, _, addon)
	if addon == "AuroraClassic" then
		-- [[ Load Variables ]]

		-- remove deprecated or corrupt variables
		for key in pairs(AuroraConfig) do
			if C.defaults[key] == nil then
				AuroraConfig[key] = nil
			end
		end

		-- load or init variables
		for key, value in pairs(C.defaults) do
			if AuroraConfig[key] == nil then
				if type(value) == "table" then
					AuroraConfig[key] = {}
					for k in pairs(value) do
						AuroraConfig[key][k] = value[k]
					end
				else
					AuroraConfig[key] = value
				end
			end
		end

		useButtonGradientColour = AuroraConfig.useButtonGradientColour

		if useButtonGradientColour then
			buttonR, buttonG, buttonB, buttonA = unpack(C.defaults.buttonGradientColour)
		else
			buttonR, buttonG, buttonB, buttonA = unpack(C.defaults.buttonSolidColour)
		end

		if AuroraConfig.useCustomColour then
			r, g, b = AuroraConfig.customColour.r, AuroraConfig.customColour.g, AuroraConfig.customColour.b
		end

		-- for modules
		C.r, C.g, C.b = r, g, b
	end

	-- [[ Load modules ]]

	-- check if the addon loaded is supported by Aurora, and if it is, execute its module
	local addonModule = C.themes[addon]
	if addonModule then
		if type(addonModule) == "function" then
			addonModule()
		else
			for _, moduleFunc in pairs(addonModule) do
				moduleFunc()
			end
		end
	end
end)