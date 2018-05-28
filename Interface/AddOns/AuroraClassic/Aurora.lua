-- [[ Core ]]

-- for custom APIs (see docs online)
local LATEST_API_VERSION = "7.0"

-- see F.AddPlugin
local AURORA_LOADED = false

local addon, core = ...

core[1] = {} -- F, functions
core[2] = {} -- C, constants/config

AuroraClassic = core

AuroraConfig = {}

local F, C = unpack(select(2, ...))

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
	["buttonSolidColour"] = {.2, .2, .2, 1},
	["useButtonGradientColour"] = true,
	["chatBubbles"] = true,
	["enableFont"] = false,
	["loot"] = true,
	["useCustomColour"] = false,
	["customColour"] = {r = 1, g = 1, b = 1},
	["tooltips"] = false,
	["mmb"] = false,
	["shadow"] = true,
}

C.frames = {}

-- [[ Cached variables ]]

local useButtonGradientColour

-- [[ Functions ]]

local _, class = UnitClass("player")

C.classcolours = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS

local r, g, b = C.classcolours[class].r, C.classcolours[class].g, C.classcolours[class].b

F.dummy = function() end

local CreateTex = function(f)
	if f.Tex then return end
	f.Tex = f:CreateTexture(nil, "BACKGROUND", nil, 1)
	f.Tex:SetAllPoints()
	f.Tex:SetTexture(C.media.bgTex, true, true)
	f.Tex:SetHorizTile(true)
	f.Tex:SetVertTile(true)
	f.Tex:SetBlendMode("ADD")
end

F.CreateSD = function(f)
	if not AuroraConfig.shadow then return end
	if f.Shadow then return end
	f.Shadow = CreateFrame("Frame", nil, f)
	f.Shadow:SetPoint("TOPLEFT", f, -2, 2)
	f.Shadow:SetPoint("BOTTOMRIGHT", f, 2, -2)
	f.Shadow:SetBackdrop({edgeFile = C.media.glowTex, edgeSize = 3})
	f.Shadow:SetBackdropBorderColor(0, 0, 0)
	CreateTex(f)
	return f.Shadow
end

F.CreateBD = function(f, a)
	f:SetBackdrop({
		bgFile = C.media.backdrop,
		edgeFile = C.media.backdrop,
		edgeSize = 1.2,
	})
	f:SetBackdropColor(0, 0, 0, a or AuroraConfig.alpha)
	f:SetBackdropBorderColor(0, 0, 0)
	if not a then tinsert(C.frames, f) end
end

F.CreateBG = function(frame)
	local f = frame
	if frame:GetObjectType() == "Texture" then f = frame:GetParent() end

	local bg = f:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", frame, -1.2, 1.2)
	bg:SetPoint("BOTTOMRIGHT", frame, 1.2, -1.2)
	bg:SetTexture(C.media.backdrop)
	bg:SetVertexColor(0, 0, 0)

	return bg
end

-- we assign these after loading variables for caching
-- otherwise we call an extra unpack() every time
local buttonR, buttonG, buttonB, buttonA

F.CreateGradient = function(f)
	local tex = f:CreateTexture(nil, "BORDER")
	tex:SetPoint("TOPLEFT", 1, -1)
	tex:SetPoint("BOTTOMRIGHT", -1, 1)
	tex:SetTexture(useButtonGradientColour and C.media.gradient or C.media.backdrop)
	tex:SetVertexColor(buttonR, buttonG, buttonB, buttonA)

	return tex
end

local function colourButton(f)
	if not f:IsEnabled() then return end

	if useButtonGradientColour then
		f:SetBackdropColor(r, g, b, .3)
	else
		f.bgTex:SetVertexColor(r / 4, g / 4, b / 4)
	end

	f:SetBackdropBorderColor(r, g, b)
end

local function clearButton(f)
	if useButtonGradientColour then
		f:SetBackdropColor(0, 0, 0, 0)
	else
		f.bgTex:SetVertexColor(buttonR, buttonG, buttonB, buttonA)
	end

	f:SetBackdropBorderColor(0, 0, 0)
end

F.Reskin = function(f, noHighlight)
	if f.SetNormalTexture then f:SetNormalTexture("") end
	if f.SetHighlightTexture then f:SetHighlightTexture("") end
	if f.SetPushedTexture then f:SetPushedTexture("") end
	if f.SetDisabledTexture then f:SetDisabledTexture("") end

	if f.Left then f.Left:SetAlpha(0) end
	if f.Middle then f.Middle:SetAlpha(0) end
	if f.Right then f.Right:SetAlpha(0) end
	if f.LeftSeparator then f.LeftSeparator:SetAlpha(0) end
	if f.RightSeparator then f.RightSeparator:SetAlpha(0) end
	if f.TopLeft then f.TopLeft:SetAlpha(0) end
	if f.TopMiddle then f.TopMiddle:SetAlpha(0) end
	if f.TopRight then f.TopRight:SetAlpha(0) end
	if f.MiddleLeft then f.MiddleLeft:SetAlpha(0) end
	if f.MiddleMiddle then f.MiddleMiddle:SetAlpha(0) end
	if f.MiddleRight then f.MiddleRight:SetAlpha(0) end
	if f.BottomLeft then f.BottomLeft:SetAlpha(0) end
	if f.BottomMiddle then f.BottomMiddle:SetAlpha(0) end
	if f.BottomRight then f.BottomRight:SetAlpha(0) end

	F.CreateBD(f, .0)

	f.bgTex = F.CreateGradient(f)

	if not noHighlight then
		f:HookScript("OnEnter", colourButton)
 		f:HookScript("OnLeave", clearButton)
	end
end

F.ReskinTab = function(f)
	f:DisableDrawLayer("BACKGROUND")

	local bg = CreateFrame("Frame", nil, f)
	bg:SetPoint("TOPLEFT", 8, -3)
	bg:SetPoint("BOTTOMRIGHT", -8, 0)
	bg:SetFrameLevel(f:GetFrameLevel()-1)
	F.CreateBD(bg)

	f:SetHighlightTexture(C.media.backdrop)
	local hl = f:GetHighlightTexture()
	hl:SetPoint("TOPLEFT", 9, -4)
	hl:SetPoint("BOTTOMRIGHT", -9, 1)
	hl:SetVertexColor(r, g, b, .25)
end

local function colourScroll(f)
	if f:IsEnabled() then
		f.bgTex:SetVertexColor(r, g, b)
	end
end

local function clearScroll(f)
	f.bgTex:SetVertexColor(1, 1, 1)
end

F.ReskinScroll = function(f)
	local frame = f:GetName()

	local track = (f.trackBG or f.Background or f.Track) or (_G[frame.."Track"] or _G[frame.."BG"])
	if track then track:Hide() end
	local top = (f.ScrollBarTop or f.Top or f.ScrollUpBorder) or _G[frame.."Top"]
	if top then top:Hide() end
	local middle = (f.ScrollBarMiddle or f.Middle or f.Border) or _G[frame.."Middle"]
	if middle then middle:Hide() end
	local bottom = (f.ScrollBarBottom or f.Bottom or f.ScrollDownBorder) or _G[frame.."Bottom"]
	if bottom then bottom:Hide() end

	local bu = (f.ThumbTexture or f.thumbTexture) or _G[frame.."ThumbTexture"]
	bu:SetAlpha(0)
	bu:SetWidth(17)

	bu.bg = CreateFrame("Frame", nil, f)
	bu.bg:SetPoint("TOPLEFT", bu, 0, -2)
	bu.bg:SetPoint("BOTTOMRIGHT", bu, 0, 4)
	F.CreateBD(bu.bg, 0)

	local tex = F.CreateGradient(f)
	tex:SetPoint("TOPLEFT", bu.bg, 1, -1)
	tex:SetPoint("BOTTOMRIGHT", bu.bg, -1, 1)

	local up, down = f:GetChildren()
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

	up:HookScript("OnEnter", colourScroll)
	up:HookScript("OnLeave", clearScroll)
	down:HookScript("OnEnter", colourScroll)
	down:HookScript("OnLeave", clearScroll)
end

local function colourArrow(f)
	if f:IsEnabled() then
		f.bgTex:SetVertexColor(r, g, b)
	end
end

local function clearArrow(f)
	f.bgTex:SetVertexColor(1, 1, 1)
end

F.colourArrow = colourArrow
F.clearArrow = clearArrow

F.ReskinDropDown = function(f)
	local frame = f:GetName()

	local left = f.Left or _G[frame.."Left"]
	local middle = f.Middle or _G[frame.."Middle"]
	local right = f.Right or _G[frame.."Right"]

	if left then left:SetAlpha(0) end
	if middle then middle:SetAlpha(0) end
	if right then right:SetAlpha(0) end

	local down = f.Button or _G[frame.."Button"]

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

	down:HookScript("OnEnter", colourArrow)
	down:HookScript("OnLeave", clearArrow)

	local bg = CreateFrame("Frame", nil, f)
	bg:SetPoint("TOPLEFT", 16, -4)
	bg:SetPoint("BOTTOMRIGHT", -18, 8)
	bg:SetFrameLevel(f:GetFrameLevel()-1)
	F.CreateBD(bg, 0)

	local gradient = F.CreateGradient(f)
	gradient:SetPoint("TOPLEFT", bg, 1, -1)
	gradient:SetPoint("BOTTOMRIGHT", bg, -1, 1)
end

local function colourClose(f)
	if f:IsEnabled() then
		for _, pixel in pairs(f.pixels) do
			pixel:SetVertexColor(r, g, b)
		end
	end
end

local function clearClose(f)
	for _, pixel in pairs(f.pixels) do
		pixel:SetVertexColor(1, 1, 1)
	end
end

F.ReskinClose = function(f, a1, p, a2, x, y)
	f:SetSize(17, 17)

	if not a1 then
		f:SetPoint("TOPRIGHT", -6, -6)
	else
		f:ClearAllPoints()
		f:SetPoint(a1, p, a2, x, y)
	end

	f:SetNormalTexture("")
	f:SetHighlightTexture("")
	f:SetPushedTexture("")
	f:SetDisabledTexture("")

	F.CreateBD(f, 0)

	F.CreateGradient(f)

	f:SetDisabledTexture(C.media.backdrop)
	local dis = f:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .4)
	dis:SetDrawLayer("OVERLAY")
	dis:SetAllPoints()

	f.pixels = {}

	for i = 1, 8 do
		local tex = f:CreateTexture()
		tex:SetColorTexture(1, 1, 1)
		tex:SetSize(2, 2)
		tex:SetPoint("BOTTOMLEFT", 3+i, 3+i)
		tinsert(f.pixels, tex)
	end

	for i = 1, 8 do
		local tex = f:CreateTexture()
		tex:SetColorTexture(1, 1, 1)
		tex:SetSize(2, 2)
		tex:SetPoint("TOPLEFT", 3+i, -3-i)
		tinsert(f.pixels, tex)
	end

	f:HookScript("OnEnter", colourClose)
 	f:HookScript("OnLeave", clearClose)
end

F.ReskinInput = function(f, height, width)
	local frame = f:GetName()

	local left = f.Left or _G[frame.."Left"]
	local middle = f.Middle or _G[frame.."Middle"] or _G[frame.."Mid"]
	local right = f.Right or _G[frame.."Right"]

	left:Hide()
	middle:Hide()
	right:Hide()

	local bd = CreateFrame("Frame", nil, f)
	bd:SetPoint("TOPLEFT", -2, 0)
	bd:SetPoint("BOTTOMRIGHT")
	bd:SetFrameLevel(f:GetFrameLevel()-1)
	F.CreateBD(bd, 0)

	local gradient = F.CreateGradient(f)
	gradient:SetPoint("TOPLEFT", bd, 1, -1)
	gradient:SetPoint("BOTTOMRIGHT", bd, -1, 1)

	if height then f:SetHeight(height) end
	if width then f:SetWidth(width) end
end

F.ReskinArrow = function(f, direction)
	f:SetSize(18, 18)
	F.Reskin(f, true)

	f:SetDisabledTexture(C.media.backdrop)
	local dis = f:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .3)
	dis:SetDrawLayer("OVERLAY")

	local tex = f:CreateTexture(nil, "ARTWORK")
	tex:SetTexture(mediaPath.."arrow-"..direction.."-active")
	tex:SetSize(8, 8)
	tex:SetPoint("CENTER")
	f.bgTex = tex

	f:HookScript("OnEnter", colourArrow)
	f:HookScript("OnLeave", clearArrow)
end

F.ReskinCheck = function(f)
	f:SetNormalTexture("")
	f:SetPushedTexture("")
	f:SetHighlightTexture(C.media.backdrop)
	local hl = f:GetHighlightTexture()
	hl:SetPoint("TOPLEFT", 5, -5)
	hl:SetPoint("BOTTOMRIGHT", -5, 5)
	hl:SetVertexColor(r, g, b, .2)

	local bd = CreateFrame("Frame", nil, f)
	bd:SetPoint("TOPLEFT", 4, -4)
	bd:SetPoint("BOTTOMRIGHT", -4, 4)
	bd:SetFrameLevel(f:GetFrameLevel()-1)
	F.CreateBD(bd, 0)

	local tex = F.CreateGradient(f)
	tex:SetPoint("TOPLEFT", 5, -5)
	tex:SetPoint("BOTTOMRIGHT", -5, 5)

	local ch = f:GetCheckedTexture()
	ch:SetDesaturated(true)
	ch:SetVertexColor(r, g, b)
end

local function colourRadio(f)
	f.bd:SetBackdropBorderColor(r, g, b)
end

local function clearRadio(f)
	f.bd:SetBackdropBorderColor(0, 0, 0)
end

F.ReskinRadio = function(f)
	f:SetNormalTexture("")
	f:SetHighlightTexture("")
	f:SetCheckedTexture(C.media.backdrop)

	local ch = f:GetCheckedTexture()
	ch:SetPoint("TOPLEFT", 4, -4)
	ch:SetPoint("BOTTOMRIGHT", -4, 4)
	ch:SetVertexColor(r, g, b, .6)

	local bd = CreateFrame("Frame", nil, f)
	bd:SetPoint("TOPLEFT", 3, -3)
	bd:SetPoint("BOTTOMRIGHT", -3, 3)
	bd:SetFrameLevel(f:GetFrameLevel()-1)
	F.CreateBD(bd, 0)
	f.bd = bd

	local tex = F.CreateGradient(f)
	tex:SetPoint("TOPLEFT", 4, -4)
	tex:SetPoint("BOTTOMRIGHT", -4, 4)

	f:HookScript("OnEnter", colourRadio)
	f:HookScript("OnLeave", clearRadio)
end

F.ReskinSlider = function(f)
	f:SetBackdrop(nil)
	f.SetBackdrop = F.dummy

	local bd = CreateFrame("Frame", nil, f)
	bd:SetPoint("TOPLEFT", 14, -2)
	bd:SetPoint("BOTTOMRIGHT", -15, 3)
	bd:SetFrameStrata("BACKGROUND")
	bd:SetFrameLevel(f:GetFrameLevel()-1)
	F.CreateBD(bd, 0)

	F.CreateGradient(bd)

	for i = 1, f:GetNumRegions() do
		local region = select(i, f:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
			region:SetBlendMode("ADD")
			return
		end
	end
end

local function colourExpandOrCollapse(f)
	if f:IsEnabled() then
		f.plus:SetVertexColor(r, g, b)
		f.minus:SetVertexColor(r, g, b)
	end
end

local function clearExpandOrCollapse(f)
	f.plus:SetVertexColor(1, 1, 1)
	f.minus:SetVertexColor(1, 1, 1)
end

local function SetupTexture(self, texture)
	if self.settingTexture then return end
	self.settingTexture = true
	self:SetNormalTexture("")

	if texture and texture ~= "" then
		if texture:find("Plus") then
			self.plus:Show()
		elseif texture:find("Minus") then
			self.plus:Hide()
		end
		self.bg:Show()
	else
		self.bg:Hide()
	end
	self.settingTexture = nil
end

F.ReskinExpandOrCollapse = function(f)
	f:SetHighlightTexture("")
	f:SetPushedTexture("")

	local bg = F.CreateBDFrame(f)
	bg:ClearAllPoints()
	bg:SetSize(13, 13)
	bg:SetPoint("TOPLEFT", f:GetNormalTexture())
	f.bg = bg

	f.minus = bg:CreateTexture(nil, "OVERLAY")
	f.minus:SetSize(7, 2)
	f.minus:SetPoint("CENTER")
	f.minus:SetColorTexture(1, 1, 1)

	f.plus = bg:CreateTexture(nil, "OVERLAY")
	f.plus:SetSize(2, 7)
	f.plus:SetPoint("CENTER")
	f.plus:SetColorTexture(1, 1, 1)

	f:HookScript("OnEnter", colourExpandOrCollapse)
	f:HookScript("OnLeave", clearExpandOrCollapse)
	hooksecurefunc(f, "SetNormalTexture", SetupTexture)
end

F.SetBD = function(f, x, y, x2, y2)
	local bg = CreateFrame("Frame", nil, f)
	if not x then
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("BOTTOMRIGHT")
	else
		bg:SetPoint("TOPLEFT", x, y)
		bg:SetPoint("BOTTOMRIGHT", x2, y2)
	end
	bg:SetFrameLevel(f:GetFrameLevel()-1)
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

F.ReskinPortraitFrame = function(f, isButtonFrame)
	local name = f:GetName()

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

		f.Inset.Bg:Hide()
		f.Inset:DisableDrawLayer("BORDER")
	end

	F.CreateBD(f)
	F.CreateSD(f)
	F.ReskinClose(_G[name.."CloseButton"])
end

F.CreateBDFrame = function(f, a)
	local frame
	if f:GetObjectType() == "Texture" then
		frame = f:GetParent()
	else
		frame = f
	end

	local lvl = frame:GetFrameLevel()

	local bg = CreateFrame("Frame", nil, frame)
	bg:SetPoint("TOPLEFT", f, -1.2, 1.2)
	bg:SetPoint("BOTTOMRIGHT", f, 1.2, -1.2)
	bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)

	F.CreateBD(bg, a or .5)

	return bg
end

F.ReskinColourSwatch = function(f)
	local name = f:GetName()

	local bg = _G[name.."SwatchBg"]

	f:SetNormalTexture(C.media.backdrop)
	local nt = f:GetNormalTexture()

	nt:SetPoint("TOPLEFT", 3, -3)
	nt:SetPoint("BOTTOMRIGHT", -3, 3)

	bg:SetColorTexture(0, 0, 0)
	bg:SetPoint("TOPLEFT", 2, -2)
	bg:SetPoint("BOTTOMRIGHT", -2, 2)
end

F.ReskinFilterButton = function(f)
	f.TopLeft:Hide()
	f.TopRight:Hide()
	f.BottomLeft:Hide()
	f.BottomRight:Hide()
	f.TopMiddle:Hide()
	f.MiddleLeft:Hide()
	f.MiddleRight:Hide()
	f.BottomMiddle:Hide()
	f.MiddleMiddle:Hide()

	F.Reskin(f)
	f.Icon:SetTexture(C.media.arrowRight)

	f.Text:SetPoint("CENTER")
	f.Icon:SetPoint("RIGHT", f, "RIGHT", -5, 0)
	f.Icon:SetSize(8, 8)
end

F.ReskinNavBar = function(f)
	local overflowButton = f.overflowButton

	f:GetRegions():Hide()
	f:DisableDrawLayer("BORDER")
	f.overlay:Hide()
	f.homeButton:GetRegions():Hide()

	F.Reskin(f.homeButton)
	F.Reskin(overflowButton, true)

	local tex = overflowButton:CreateTexture(nil, "ARTWORK")
	tex:SetTexture(C.media.arrowLeft)
	tex:SetSize(8, 8)
	tex:SetPoint("CENTER")
	overflowButton.bgTex = tex

	overflowButton:HookScript("OnEnter", colourArrow)
	overflowButton:HookScript("OnLeave", clearArrow)
end

F.ReskinGarrisonPortrait = function(portrait)
	local level = portrait.Level
	local cover = portrait.PortraitRingCover

	portrait.Portrait:ClearAllPoints()
	portrait.Portrait:SetPoint("TOPLEFT", 4, -4)
	portrait.PortraitRing:Hide()
	portrait.PortraitRingQuality:SetTexture("")
	portrait.LevelBorder:Hide()
	portrait.LevelBorder.Show = F.dummy

	level:ClearAllPoints()
	level:SetPoint("BOTTOM", portrait, 0, 12)

	local squareBG = CreateFrame("Frame", nil, portrait)
	squareBG:SetFrameLevel(portrait:GetFrameLevel())
	squareBG:SetPoint("TOPLEFT", 3, -3)
	squareBG:SetPoint("BOTTOMRIGHT", -3, 11)
	F.CreateBD(squareBG, 1)
	portrait.squareBG = squareBG

	if cover then
		cover:SetColorTexture(0, 0, 0)
		cover:SetAllPoints(squareBG)
	end
end

F.ReskinIcon = function(icon)
	icon:SetTexCoord(.08, .92, .08, .92)
	return F.CreateBG(icon)
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

			for i = 1, 8 do
				local tex = button:CreateTexture()
				tex:SetColorTexture(1, 1, 1)
				tex:SetSize(2, 2)
				tex:SetPoint("BOTTOMLEFT", 3+i, 3+i)
				tinsert(button.pixels, tex)
			end
			local hline = button:CreateTexture()
			hline:SetColorTexture(1, 1, 1)
			hline:SetSize(7, 2)
			tinsert(button.pixels, hline)
			local vline = button:CreateTexture()
			vline:SetColorTexture(1, 1, 1)
			vline:SetSize(2, 7)
			tinsert(button.pixels, vline)

			if name == "MaximizeButton" then
				hline:SetPoint("TOP", 1, -4)
				vline:SetPoint("RIGHT", -4, 1)
			else
				hline:SetPoint("BOTTOM", 1, 4)
				vline:SetPoint("LEFT", 4, 1)
			end

			button:SetScript("OnEnter", colourClose)
			button:SetScript("OnLeave", clearClose)
		end
	end
end

-- [[ Variable and module handling ]]

C.themes = {}
C.themes["AuroraClassic"] = {}

-- use of this function ensures that Aurora and custom style (if used) are properly initialised
-- prior to loading third party plugins
F.AddPlugin = function(func)
	if AURORA_LOADED then
		func()
	else
		tinsert(C.themes["AuroraClassic"], func)
	end
end

-- [[ Initialize addon ]]

local Skin = CreateFrame("Frame", nil, UIParent)
Skin:RegisterEvent("ADDON_LOADED")
Skin:SetScript("OnEvent", function(self, event, addon)
	if addon == "AuroraClassic" then
		-- [[ Load Variables ]]

		-- remove deprecated or corrupt variables
		for key, value in pairs(AuroraConfig) do
			if C.defaults[key] == nil then
				AuroraConfig[key] = nil
			end
		end

		-- load or init variables
		for key, value in pairs(C.defaults) do
			if AuroraConfig[key] == nil then
				if type(value) == "table" then
					AuroraConfig[key] = {}
					for k, v in pairs(value) do
						AuroraConfig[key][k] = value[k]
					end
				else
					AuroraConfig[key] = value
				end
			end
		end

		useButtonGradientColour = AuroraConfig.useButtonGradientColour

		if useButtonGradientColour then
			buttonR, buttonG, buttonB, buttonA = unpack(AuroraConfig.buttonGradientColour)
		else
			buttonR, buttonG, buttonB, buttonA = unpack(AuroraConfig.buttonSolidColour)
		end

		if AuroraConfig.useCustomColour then
			r, g, b = AuroraConfig.customColour.r, AuroraConfig.customColour.g, AuroraConfig.customColour.b
		end
		-- for modules
		C.r, C.g, C.b = r, g, b

		-- [[ Custom style support ]]

		local customStyle = AURORA_CUSTOM_STYLE

		if customStyle and customStyle.apiVersion ~= nil and customStyle.apiVersion == LATEST_API_VERSION then
			local protectedFunctions = {
				["AddPlugin"] = true,
			}

			-- replace functions
			if customStyle.functions then
				for funcName, func in pairs(customStyle.functions) do
					if F[funcName] and not protectedFunctions[funcName] then
						F[funcName] = func
					end
				end
			end

			-- replace class colours
			if customStyle.classcolors then
				C.classcolours = customStyle.classcolors

				if not AuroraConfig.useCustomColour then
					r, g, b = C.classcolours[class].r, C.classcolours[class].g, C.classcolours[class].b
					C.r, C.g, C.b = r, g, b
				end
			end

			-- replace colour scheme
			local highlightColour = customStyle.highlightColor
			if highlightColour then
				r, g, b = highlightColour.r, highlightColour.g, highlightColour.b
				C.r, C.g, C.b = r, g, b
			end
		end

		-- [[ Plugin helper ]]

		-- from this point, plugins added with F.AddPlugin are executed directly instead of cached
		AURORA_LOADED = true
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

	-- all this should be moved out of the main file when I have time
	if addon == "AuroraClassic" then

		-- [[ Headers ]]

		local header = {"GameMenuFrame", "AudioOptionsFrame", "ChatConfigFrame", "ColorPickerFrame"}
		for i = 1, #header do
			local title = _G[header[i].."Header"]
			if title then
				title:SetTexture("")
				title:ClearAllPoints()
				if title == _G["GameMenuFrameHeader"] then
					title:SetPoint("TOP", GameMenuFrame, 0, 7)
				else
					title:SetPoint("TOP", header[i], 0, 0)
				end
			end
		end

		-- [[ Simple backdrops ]]

		local bds = {"TicketStatusFrameButton", "RaidInfoFrame", "ScrollOfResurrectionSelectionFrame", "ScrollOfResurrectionFrame", "ReportCheatingDialog"}

		for i = 1, #bds do
			local bd = _G[bds[i]]
			if bd then
				F.CreateBD(bd)
				F.CreateSD(bd)
			else
				print("Aurora: "..bds[i].." was not found.")
			end
		end

		local lightbds = {"SecondaryProfession1", "SecondaryProfession2", "SecondaryProfession3", "FriendsFriendsList", "AddFriendNoteFrame", "ScrollOfResurrectionSelectionFrameList", "ReportCheatingDialogCommentFrame"}
		for i = 1, #lightbds do
			local bd = _G[lightbds[i]]
			if bd then
				F.CreateBD(bd, .25)
			else
				print("Aurora: "..lightbds[i].." was not found.")
			end
		end

		-- [[ Scroll bars ]]

		local scrollbars = {"LFDQueueFrameSpecificListScrollFrameScrollBar", "PaperDollTitlesPaneScrollBar", "PaperDollEquipmentManagerPaneScrollBar", "RaidInfoScrollFrameScrollBar", "FriendsFriendsScrollFrameScrollBar", "WhoListScrollFrameScrollBar", "LFDQueueFrameRandomScrollFrameScrollBar", "ScrollOfResurrectionSelectionFrameListScrollFrameScrollBar"}
		for i = 1, #scrollbars do
			local scrollbar = _G[scrollbars[i]]
			if scrollbar then
				F.ReskinScroll(scrollbar)
			else
				print("Aurora: "..scrollbars[i].." was not found.")
			end
		end

		-- [[ Dropdowns ]]

		for _, dropdown in pairs({"LFDQueueFrameTypeDropDown", "WhoFrameDropDown", "FriendsFriendsFrameDropDown", "RaidFinderQueueFrameSelectionDropDown", "Advanced_GraphicsAPIDropDown"}) do
			F.ReskinDropDown(_G[dropdown])
		end

		-- [[ Input frames ]]

		for _, input in pairs({"AddFriendNameEditBox", "ScrollOfResurrectionSelectionFrameTargetEditBox", "ScrollOfResurrectionFrameNoteFrame", "FriendsFrameBroadcastInput"}) do
			F.ReskinInput(_G[input])
		end

		-- [[ Arrows ]]

		F.ReskinArrow(SpellBookPrevPageButton, "left")
		F.ReskinArrow(SpellBookNextPageButton, "right")
		F.ReskinArrow(InboxPrevPageButton, "left")
		F.ReskinArrow(InboxNextPageButton, "right")
		F.ReskinArrow(TabardCharacterModelRotateLeftButton, "left")
		F.ReskinArrow(TabardCharacterModelRotateRightButton, "right")

		-- [[ Backdrop frames ]]

		F.SetBD(RaidParentFrame)

		local FrameBDs = {"GameMenuFrame", "AudioOptionsFrame", "ChatConfigFrame", "StackSplitFrame", "AddFriendFrame", "FriendsFriendsFrame", "ColorPickerFrame", "ReadyCheckFrame", "GuildInviteFrame"}
		for i = 1, #FrameBDs do
			local FrameBD = _G[FrameBDs[i]]
			F.CreateBD(FrameBD)
			F.CreateSD(FrameBD)
		end

		-- Dropdown lists

		hooksecurefunc("UIDropDownMenu_CreateFrames", function(level, index)
			for i = 1, _G.UIDROPDOWNMENU_MAXLEVELS do
				local menu = _G["DropDownList"..i.."MenuBackdrop"]
				local backdrop = _G["DropDownList"..i.."Backdrop"]
				if not backdrop.reskinned then
					if AuroraConfig.tooltips then
						F.CreateBD(menu)
					end
					F.CreateBD(backdrop)
					F.CreateSD(backdrop)
					backdrop.reskinned = true
				end
			end
		end)

		local createBackdrop = function(parent, texture)
			local bg = parent:CreateTexture(nil, "BACKGROUND")
			bg:SetColorTexture(0, 0, 0, .5)
			bg:SetPoint("CENTER", texture)
			bg:SetSize(12, 12)
			parent.bg = bg

			local left = parent:CreateTexture(nil, "BACKGROUND")
			left:SetWidth(1)
			left:SetColorTexture(0, 0, 0)
			left:SetPoint("TOPLEFT", bg)
			left:SetPoint("BOTTOMLEFT", bg)
			parent.left = left

			local right = parent:CreateTexture(nil, "BACKGROUND")
			right:SetWidth(1)
			right:SetColorTexture(0, 0, 0)
			right:SetPoint("TOPRIGHT", bg)
			right:SetPoint("BOTTOMRIGHT", bg)
			parent.right = right

			local top = parent:CreateTexture(nil, "BACKGROUND")
			top:SetHeight(1)
			top:SetColorTexture(0, 0, 0)
			top:SetPoint("TOPLEFT", bg)
			top:SetPoint("TOPRIGHT", bg)
			parent.top = top

			local bottom = parent:CreateTexture(nil, "BACKGROUND")
			bottom:SetHeight(1)
			bottom:SetColorTexture(0, 0, 0)
			bottom:SetPoint("BOTTOMLEFT", bg)
			bottom:SetPoint("BOTTOMRIGHT", bg)
			parent.bottom = bottom
		end

		local toggleBackdrop = function(bu, show)
			if show then
				bu.bg:Show()
				bu.left:Show()
				bu.right:Show()
				bu.top:Show()
				bu.bottom:Show()
			else
				bu.bg:Hide()
				bu.left:Hide()
				bu.right:Hide()
				bu.top:Hide()
				bu.bottom:Hide()
			end
		end

		hooksecurefunc("ToggleDropDownMenu", function(level, _, dropDownFrame, anchorName)
			if not level then level = 1 end

			local uiScale = UIParent:GetScale()

			local listFrame = _G["DropDownList"..level]

			if level == 1 then
				if not anchorName then
					local xOffset = dropDownFrame.xOffset and dropDownFrame.xOffset or 16
					local yOffset = dropDownFrame.yOffset and dropDownFrame.yOffset or 9
					local point = dropDownFrame.point and dropDownFrame.point or "TOPLEFT"
					local relativeTo = dropDownFrame.relativeTo and dropDownFrame.relativeTo or dropDownFrame
					local relativePoint = dropDownFrame.relativePoint and dropDownFrame.relativePoint or "BOTTOMLEFT"

					listFrame:ClearAllPoints()
					listFrame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)

					-- make sure it doesn't go off the screen
					local offLeft = listFrame:GetLeft()/uiScale
					local offRight = (GetScreenWidth() - listFrame:GetRight())/uiScale
					local offTop = (GetScreenHeight() - listFrame:GetTop())/uiScale
					local offBottom = listFrame:GetBottom()/uiScale

					local xAddOffset, yAddOffset = 0, 0
					if offLeft < 0 then
						xAddOffset = -offLeft
					elseif offRight < 0 then
						xAddOffset = offRight
					end

					if offTop < 0 then
						yAddOffset = offTop
					elseif offBottom < 0 then
						yAddOffset = -offBottom
					end
					listFrame:ClearAllPoints()
					listFrame:SetPoint(point, relativeTo, relativePoint, xOffset + xAddOffset, yOffset + yAddOffset)
				elseif anchorName ~= "cursor" then
					-- this part might be a bit unreliable
					local _, _, relPoint, xOff, yOff = listFrame:GetPoint()
					if relPoint == "BOTTOMLEFT" and xOff == 0 and floor(yOff) == 5 then
						listFrame:SetPoint("TOPLEFT", anchorName, "BOTTOMLEFT", 16, 9)
					end
				end
			else
				local point, anchor, relPoint, _, y = listFrame:GetPoint()
				if point:find("RIGHT") then
					listFrame:SetPoint(point, anchor, relPoint, -14, y)
				else
					listFrame:SetPoint(point, anchor, relPoint, 9, y)
				end
			end

			for j = 1, UIDROPDOWNMENU_MAXBUTTONS do
				local bu = _G["DropDownList"..level.."Button"..j]
				local _, _, _, x = bu:GetPoint()
				if bu:IsShown() and x then
					local hl = _G["DropDownList"..level.."Button"..j.."Highlight"]
					local check = _G["DropDownList"..level.."Button"..j.."Check"]

					hl:SetPoint("TOPLEFT", -x + 1, 0)
					hl:SetPoint("BOTTOMRIGHT", listFrame:GetWidth() - bu:GetWidth() - x - 1, 0)

					if not bu.bg then
						createBackdrop(bu, check)
						hl:SetColorTexture(r, g, b, .2)
						_G["DropDownList"..level.."Button"..j.."UnCheck"]:SetTexture("")

						local arrow = _G["DropDownList"..level.."Button"..j.."ExpandArrow"]
						arrow:SetNormalTexture(C.media.arrowRight)
						arrow:SetSize(8, 8)
					end

					if not bu.notCheckable then
						toggleBackdrop(bu, true)

						-- only reliable way to see if button is radio or or check...
						local _, co = check:GetTexCoord()

						if co == 0 then
							check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
							check:SetVertexColor(r, g, b, 1)
							check:SetSize(20, 20)
							check:SetDesaturated(true)
						else
							check:SetTexture(C.media.backdrop)
							check:SetVertexColor(r, g, b, .6)
							check:SetSize(10, 10)
							check:SetDesaturated(false)
						end

						check:SetTexCoord(0, 1, 0, 1)
					else
						toggleBackdrop(bu, false)
					end
				end
			end
		end)

		hooksecurefunc("UIDropDownMenu_SetIconImage", function(icon, texture)
			if texture:find("Divider") then
				icon:SetColorTexture(1, 1, 1, .2)
				icon:SetHeight(1)
			end
		end)

		-- Tab text position

		hooksecurefunc("PanelTemplates_DeselectTab", function(tab)
			local text = tab.Text or _G[tab:GetName().."Text"]
			text:SetPoint("CENTER", tab, "CENTER")
		end)

		hooksecurefunc("PanelTemplates_SelectTab", function(tab)
			local text = tab.Text or _G[tab:GetName().."Text"]
			text:SetPoint("CENTER", tab, "CENTER")
		end)

		-- [[ Custom skins ]]

		-- Pet stuff

		if class == "HUNTER" or class == "MAGE" or class == "DEATHKNIGHT" or class == "WARLOCK" then
			if class == "HUNTER" then
				PetStableBottomInset:DisableDrawLayer("BACKGROUND")
				PetStableBottomInset:DisableDrawLayer("BORDER")
				PetStableLeftInset:DisableDrawLayer("BACKGROUND")
				PetStableLeftInset:DisableDrawLayer("BORDER")
				PetStableModelShadow:Hide()
				PetStableModelRotateLeftButton:Hide()
				PetStableModelRotateRightButton:Hide()
				PetStableFrameModelBg:Hide()
				PetStablePrevPageButtonIcon:SetTexture("")
				PetStableNextPageButtonIcon:SetTexture("")

				F.ReskinPortraitFrame(PetStableFrame, true)
				F.ReskinArrow(PetStablePrevPageButton, "left")
				F.ReskinArrow(PetStableNextPageButton, "right")

				PetStableSelectedPetIcon:SetTexCoord(.08, .92, .08, .92)
				F.CreateBG(PetStableSelectedPetIcon)

				for i = 1, NUM_PET_ACTIVE_SLOTS do
					local bu = _G["PetStableActivePet"..i]

					bu.Background:Hide()
					bu.Border:Hide()

					bu:SetNormalTexture("")
					bu.Checked:SetTexture(C.media.checked)

					_G["PetStableActivePet"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
					F.CreateBD(bu, .25)
				end

				for i = 1, NUM_PET_STABLE_SLOTS do
					local bu = _G["PetStableStabledPet"..i]
					local bd = CreateFrame("Frame", nil, bu)
					bd:SetPoint("TOPLEFT", -1, 1)
					bd:SetPoint("BOTTOMRIGHT", 1, -1)
					F.CreateBD(bd, .25)
					bu:SetNormalTexture("")
					bu:DisableDrawLayer("BACKGROUND")
					_G["PetStableStabledPet"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
				end
			end
		end

		-- Ghost frame

		GhostFrameContentsFrameIcon:SetTexCoord(.08, .92, .08, .92)

		local GhostBD = CreateFrame("Frame", nil, GhostFrameContentsFrame)
		GhostBD:SetPoint("TOPLEFT", GhostFrameContentsFrameIcon, -1, 1)
		GhostBD:SetPoint("BOTTOMRIGHT", GhostFrameContentsFrameIcon, 1, -1)
		F.CreateBD(GhostBD, 0)

		-- Currency frame

		TokenFramePopupCorner:Hide()
		TokenFramePopup:SetPoint("TOPLEFT", TokenFrame, "TOPRIGHT", 1, -28)
		F.CreateBD(TokenFramePopup)
		F.CreateSD(TokenFramePopup)
		F.ReskinClose(TokenFramePopupCloseButton)
		F.ReskinCheck(TokenFramePopupInactiveCheckBox)
		F.ReskinCheck(TokenFramePopupBackpackCheckBox)

		local function updateButtons()
			local buttons = TokenFrameContainer.buttons

			if not buttons then return end

			for i = 1, #buttons do
				local bu = buttons[i]

				if not bu.styled then
					bu.highlight:SetPoint("TOPLEFT", 1, 0)
					bu.highlight:SetPoint("BOTTOMRIGHT", -1, 0)
					bu.highlight.SetPoint = F.dummy
					bu.highlight:SetColorTexture(r, g, b, .2)
					bu.highlight.SetTexture = F.dummy

					bu.expandIcon:SetTexture("")

					local minus = bu:CreateTexture(nil, "OVERLAY")
					minus:SetSize(7, 1)
					minus:SetPoint("LEFT", 8, 0)
					minus:SetTexture(C.media.backdrop)
					minus:SetVertexColor(1, 1, 1)
					minus:Hide()
					bu.minus = minus

					local plus = bu:CreateTexture(nil, "OVERLAY")
					plus:SetSize(1, 7)
					plus:SetPoint("LEFT", 11, 0)
					plus:SetTexture(C.media.backdrop)
					plus:SetVertexColor(1, 1, 1)
					plus:Hide()
					bu.plus = plus

					bu.categoryMiddle:SetAlpha(0)
					bu.categoryLeft:SetAlpha(0)
					bu.categoryRight:SetAlpha(0)

					bu.icon:SetTexCoord(.08, .92, .08, .92)
					bu.bg = F.CreateBG(bu.icon)

					bu.styled = true
				end

				if bu.isHeader then
					bu.bg:Hide()
					bu.minus:Show()
					bu.plus:SetShown(not bu.isExpanded)
				else
					bu.bg:Show()
					bu.plus:Hide()
					bu.minus:Hide()
				end
			end
		end

		TokenFrame:HookScript("OnShow", updateButtons)
		hooksecurefunc("TokenFrame_Update", updateButtons)
		hooksecurefunc(TokenFrameContainer, "update", updateButtons)

		F.ReskinScroll(TokenFrameContainerScrollBar)

		-- Reputation frame

		ReputationDetailCorner:Hide()
		ReputationDetailDivider:Hide()
		ReputationListScrollFrame:GetRegions():Hide()
		select(2, ReputationListScrollFrame:GetRegions()):Hide()

		ReputationDetailFrame:SetPoint("TOPLEFT", ReputationFrame, "TOPRIGHT", 2, -28)

		local function UpdateFactionSkins()
			for i = 1, GetNumFactions() do
				local statusbar = _G["ReputationBar"..i.."ReputationBar"]

				if statusbar then
					statusbar:SetStatusBarTexture(C.media.backdrop)

					if not statusbar.reskinned then
						F.CreateBD(statusbar, .25)
						statusbar.reskinned = true
					end

					_G["ReputationBar"..i.."Background"]:SetTexture(nil)
					_G["ReputationBar"..i.."ReputationBarHighlight1"]:SetTexture(nil)
					_G["ReputationBar"..i.."ReputationBarHighlight2"]:SetTexture(nil)
					_G["ReputationBar"..i.."ReputationBarAtWarHighlight1"]:SetTexture(nil)
					_G["ReputationBar"..i.."ReputationBarAtWarHighlight2"]:SetTexture(nil)
					_G["ReputationBar"..i.."ReputationBarLeftTexture"]:SetTexture(nil)
					_G["ReputationBar"..i.."ReputationBarRightTexture"]:SetTexture(nil)
				end
			end
		end

		ReputationFrame:HookScript("OnShow", UpdateFactionSkins)
		ReputationFrame:HookScript("OnEvent", UpdateFactionSkins)

		for i = 1, NUM_FACTIONS_DISPLAYED do
			local bu = _G["ReputationBar"..i.."ExpandOrCollapseButton"]
			F.ReskinExpandOrCollapse(bu)
		end

		hooksecurefunc("ReputationFrame_Update", function()
			local numFactions = GetNumFactions()
			local factionIndex, factionButton, isCollapsed
			local factionOffset = FauxScrollFrame_GetOffset(ReputationListScrollFrame)

			for i = 1, NUM_FACTIONS_DISPLAYED do
				factionIndex = factionOffset + i
				factionButton = _G["ReputationBar"..i.."ExpandOrCollapseButton"]

				if factionIndex <= numFactions then
					_, _, _, _, _, _, _, _, _, isCollapsed = GetFactionInfo(factionIndex)
					if isCollapsed then
						factionButton.plus:Show()
					else
						factionButton.plus:Hide()
					end
				end
			end
		end)

		F.CreateBD(ReputationDetailFrame)
		F.CreateSD(ReputationDetailFrame)
		F.ReskinClose(ReputationDetailCloseButton)
		F.ReskinCheck(ReputationDetailAtWarCheckBox)
		F.ReskinCheck(ReputationDetailInactiveCheckBox)
		F.ReskinCheck(ReputationDetailMainScreenCheckBox)
		F.ReskinCheck(ReputationDetailLFGBonusReputationCheckBox)
		F.ReskinScroll(ReputationListScrollFrameScrollBar)

		select(3, ReputationDetailFrame:GetRegions()):Hide()

		-- Raid frame (social frame)

		F.ReskinCheck(RaidFrameAllAssistCheckButton)

		-- Professions

		local professions = {"PrimaryProfession1", "PrimaryProfession2", "SecondaryProfession1", "SecondaryProfession2", "SecondaryProfession3"}

		for _, button in pairs(professions) do
			local bu = _G[button]
			bu.professionName:SetTextColor(1, 1, 1)
			bu.missingHeader:SetTextColor(1, 1, 1)
			bu.missingText:SetTextColor(1, 1, 1)

			bu.statusBar:SetHeight(13)
			bu.statusBar:SetStatusBarTexture(C.media.backdrop)
			bu.statusBar:GetStatusBarTexture():SetGradient("VERTICAL", 0, .6, 0, 0, .8, 0)
			bu.statusBar.rankText:SetPoint("CENTER")

			local _, p = bu.statusBar:GetPoint()
			bu.statusBar:SetPoint("TOPLEFT", p, "BOTTOMLEFT", 1, -3)

			_G[button.."StatusBarLeft"]:Hide()
			bu.statusBar.capRight:SetAlpha(0)
			_G[button.."StatusBarBGLeft"]:Hide()
			_G[button.."StatusBarBGMiddle"]:Hide()
			_G[button.."StatusBarBGRight"]:Hide()

			local bg = CreateFrame("Frame", nil, bu.statusBar)
			bg:SetPoint("TOPLEFT", -1, 1)
			bg:SetPoint("BOTTOMRIGHT", 1, -1)
			bg:SetFrameLevel(bu:GetFrameLevel()-1)
			F.CreateBD(bg, .25)
		end

		local professionbuttons = {"PrimaryProfession1SpellButtonTop", "PrimaryProfession1SpellButtonBottom", "PrimaryProfession2SpellButtonTop", "PrimaryProfession2SpellButtonBottom", "SecondaryProfession1SpellButtonLeft", "SecondaryProfession1SpellButtonRight", "SecondaryProfession2SpellButtonLeft", "SecondaryProfession2SpellButtonRight", "SecondaryProfession3SpellButtonLeft", "SecondaryProfession3SpellButtonRight"}

		for _, button in pairs(professionbuttons) do
			local icon = _G[button.."IconTexture"]
			local bu = _G[button]
			_G[button.."NameFrame"]:SetAlpha(0)

			bu:SetPushedTexture("")
			bu:SetCheckedTexture(C.media.checked)
			bu:GetHighlightTexture():Hide()

			if icon then
				icon:SetTexCoord(.08, .92, .08, .92)
				icon:ClearAllPoints()
				icon:SetPoint("TOPLEFT", 2, -2)
				icon:SetPoint("BOTTOMRIGHT", -2, 2)
				F.CreateBG(icon)
			end
		end

		for i = 1, 2 do
			local bu = _G["PrimaryProfession"..i]

			_G["PrimaryProfession"..i.."IconBorder"]:Hide()

			bu.professionName:ClearAllPoints()
			bu.professionName:SetPoint("TOPLEFT", 100, -4)

			bu.icon:SetAlpha(1)
			bu.icon:SetTexCoord(.08, .92, .08, .92)
			bu.icon:SetDesaturated(false)
			F.CreateBG(bu.icon)

			local bg = CreateFrame("Frame", nil, bu)
			bg:SetPoint("TOPLEFT")
			bg:SetPoint("BOTTOMRIGHT", 0, -4)
			bg:SetFrameLevel(0)
			F.CreateBD(bg, .25)
		end

		hooksecurefunc("FormatProfession", function(frame, index)
			if index then
				local _, texture = GetProfessionInfo(index)

				if frame.icon and texture then
					frame.icon:SetTexture(texture)
				end
			end
		end)

		-- Friends Frame

		for i = 1, 3 do
			select(i, FriendsFrameFriendsScrollFrame:GetRegions()):Hide()
		end
		IgnoreListFrameTop:Hide()
		IgnoreListFrameMiddle:Hide()
		IgnoreListFrameBottom:Hide()

		for i = 1, 3 do
			F.ReskinTab(_G["FriendsFrameTab"..i])
		end

		FriendsFrameIcon:Hide()

		for i = 1, FRIENDS_TO_DISPLAY do
			local bu = _G["FriendsFrameFriendsScrollFrameButton"..i]
			local ic = bu.gameIcon

			bu.background:Hide()
			bu.travelPassButton:SetAlpha(0)
			bu.travelPassButton:EnableMouse(false)

			bu:SetHighlightTexture(C.media.backdrop)
			bu:GetHighlightTexture():SetVertexColor(.24, .56, 1, .2)

			ic:SetSize(22, 22)
			ic:SetTexCoord(.15, .85, .15, .85)

			bu.bg = CreateFrame("Frame", nil, bu)
			bu.bg:SetAllPoints(ic)
			F.CreateBD(bu.bg, 0)
		end

		local function UpdateScroll()
			for i = 1, FRIENDS_TO_DISPLAY do
				local bu = _G["FriendsFrameFriendsScrollFrameButton"..i]

				if bu.gameIcon:IsShown() then
					bu.bg:Show()
					bu.gameIcon:SetPoint("TOPRIGHT", bu, "TOPRIGHT", -2, -2)
				else
					bu.bg:Hide()
				end
			end
		end

		local bu1 = FriendsFrameFriendsScrollFrameButton1
		bu1.bg:SetPoint("BOTTOMRIGHT", bu1.gameIcon, 0, -1)

		hooksecurefunc("FriendsFrame_UpdateFriends", UpdateScroll)
		hooksecurefunc(FriendsFrameFriendsScrollFrame, "update", UpdateScroll)

		FriendsFrameStatusDropDown:ClearAllPoints()
		FriendsFrameStatusDropDown:SetPoint("TOPLEFT", FriendsFrame, "TOPLEFT", 10, -28)

		for _, button in pairs({FriendsTabHeaderSoRButton, FriendsTabHeaderRecruitAFriendButton}) do
			button:SetPushedTexture("")
			button:GetRegions():SetTexCoord(.08, .92, .08, .92)
			F.CreateBDFrame(button)
		end

		F.CreateBD(FriendsFrameBattlenetFrame.UnavailableInfoFrame)
		FriendsFrameBattlenetFrame.UnavailableInfoFrame:SetPoint("TOPLEFT", FriendsFrame, "TOPRIGHT", 1, -18)

		FriendsFrameBattlenetFrame:GetRegions():Hide()
		F.CreateBD(FriendsFrameBattlenetFrame, .25)

		FriendsFrameBattlenetFrame.Tag:SetParent(FriendsListFrame)
		FriendsFrameBattlenetFrame.Tag:SetPoint("TOP", FriendsFrame, "TOP", 0, -8)

		hooksecurefunc("FriendsFrame_CheckBattlenetStatus", function()
			if BNFeaturesEnabled() then
				local frame = FriendsFrameBattlenetFrame

				frame.BroadcastButton:Hide()

				if BNConnected() then
					frame:Hide()
					FriendsFrameBroadcastInput:Show()
					FriendsFrameBroadcastInput_UpdateDisplay()
				end
			end
		end)

		hooksecurefunc("FriendsFrame_Update", function()
			if FriendsFrame.selectedTab == 1 and FriendsTabHeader.selectedTab == 1 and FriendsFrameBattlenetFrame.Tag:IsShown() then
				FriendsFrameTitleText:Hide()
			else
				FriendsFrameTitleText:Show()
			end
		end)

		local whoBg = CreateFrame("Frame", nil, WhoFrameEditBoxInset)
		whoBg:SetPoint("TOPLEFT")
		whoBg:SetPoint("BOTTOMRIGHT", -1, 1)
		whoBg:SetFrameLevel(WhoFrameEditBoxInset:GetFrameLevel()-1)
		F.CreateBD(whoBg, .25)

		F.ReskinPortraitFrame(FriendsFrame, true)
		F.Reskin(FriendsFrameAddFriendButton)
		F.Reskin(FriendsFrameSendMessageButton)
		F.Reskin(FriendsFrameIgnorePlayerButton)
		F.Reskin(FriendsFrameUnsquelchButton)
		F.ReskinScroll(FriendsFrameFriendsScrollFrameScrollBar)
		F.ReskinScroll(FriendsFrameIgnoreScrollFrameScrollBar)
		F.ReskinDropDown(FriendsFrameStatusDropDown)
		F.Reskin(FriendsListFrameContinueButton)

		-- Battlenet toast frame

		F.CreateBD(BNToastFrame)
		F.CreateSD(BNToastFrame)
		F.CreateBD(BNToastFrame.TooltipFrame)
		F.CreateSD(BNToastFrame.TooltipFrame)

		-- Battletag invite frame

		F.CreateBD(BattleTagInviteFrame)
		F.CreateSD(BattleTagInviteFrame)

		local send, cancel = BattleTagInviteFrame:GetChildren()
		F.Reskin(send)
		F.Reskin(cancel)

		-- Gossip Frame

		GossipGreetingScrollFrameTop:Hide()
		GossipGreetingScrollFrameBottom:Hide()
		GossipGreetingScrollFrameMiddle:Hide()
		select(19, GossipFrame:GetRegions()):Hide()

		GossipGreetingText:SetTextColor(1, 1, 1)

		NPCFriendshipStatusBar:GetRegions():Hide()
		NPCFriendshipStatusBarNotch1:SetColorTexture(0, 0, 0)
		NPCFriendshipStatusBarNotch1:SetSize(1, 16)
		NPCFriendshipStatusBarNotch2:SetColorTexture(0, 0, 0)
		NPCFriendshipStatusBarNotch2:SetSize(1, 16)
		NPCFriendshipStatusBarNotch3:SetColorTexture(0, 0, 0)
		NPCFriendshipStatusBarNotch3:SetSize(1, 16)
		NPCFriendshipStatusBarNotch4:SetColorTexture(0, 0, 0)
		NPCFriendshipStatusBarNotch4:SetSize(1, 16)
		select(7, NPCFriendshipStatusBar:GetRegions()):Hide()

		NPCFriendshipStatusBar.icon:SetPoint("TOPLEFT", -30, 7)
		F.CreateBDFrame(NPCFriendshipStatusBar, .25)

		F.ReskinPortraitFrame(GossipFrame, true)
		F.Reskin(GossipFrameGreetingGoodbyeButton)
		F.ReskinScroll(GossipGreetingScrollFrameScrollBar)

		-- Fight Club Gambling
		GossipFrame:HookScript("OnShow", function()
			C_Timer.After(.01, function()
				local index = 1
				local titleButton = _G["GossipTitleButton"..index]
				while titleButton do
					if titleButton:GetText() ~= nil then
						titleButton:SetText(string.gsub(titleButton:GetText(), ":32:32:0:0", ":32:32:0:0:64:64:5:59:5:59"))
					end
					index = index + 1
					titleButton = _G["GossipTitleButton"..index]
				end
			end)
		end)

		-- Trade Frame

		TradePlayerEnchantInset:DisableDrawLayer("BORDER")
		TradePlayerItemsInset:DisableDrawLayer("BORDER")
		TradeRecipientEnchantInset:DisableDrawLayer("BORDER")
		TradeRecipientItemsInset:DisableDrawLayer("BORDER")
		TradePlayerInputMoneyInset:DisableDrawLayer("BORDER")
		TradeRecipientMoneyInset:DisableDrawLayer("BORDER")
		TradeRecipientBG:Hide()
		TradePlayerEnchantInsetBg:Hide()
		TradePlayerItemsInsetBg:Hide()
		TradePlayerInputMoneyInsetBg:Hide()
		TradeRecipientEnchantInsetBg:Hide()
		TradeRecipientItemsInsetBg:Hide()
		TradeRecipientMoneyBg:Hide()
		TradeRecipientPortraitFrame:Hide()
		TradeRecipientBotLeftCorner:Hide()
		TradeRecipientLeftBorder:Hide()
		select(4, TradePlayerItem7:GetRegions()):Hide()
		select(4, TradeRecipientItem7:GetRegions()):Hide()
		TradeFramePlayerPortrait:Hide()
		TradeFrameRecipientPortrait:Hide()

		F.ReskinPortraitFrame(TradeFrame, true)
		F.Reskin(TradeFrameTradeButton)
		F.Reskin(TradeFrameCancelButton)
		F.ReskinInput(TradePlayerInputMoneyFrameGold)
		F.ReskinInput(TradePlayerInputMoneyFrameSilver)
		F.ReskinInput(TradePlayerInputMoneyFrameCopper)

		TradePlayerInputMoneyFrameSilver:SetPoint("LEFT", TradePlayerInputMoneyFrameGold, "RIGHT", 1, 0)
		TradePlayerInputMoneyFrameCopper:SetPoint("LEFT", TradePlayerInputMoneyFrameSilver, "RIGHT", 1, 0)

		for i = 1, MAX_TRADE_ITEMS do
			local bu1 = _G["TradePlayerItem"..i.."ItemButton"]
			local bu2 = _G["TradeRecipientItem"..i.."ItemButton"]

			_G["TradePlayerItem"..i.."SlotTexture"]:Hide()
			_G["TradePlayerItem"..i.."NameFrame"]:Hide()
			_G["TradeRecipientItem"..i.."SlotTexture"]:Hide()
			_G["TradeRecipientItem"..i.."NameFrame"]:Hide()

			bu1:SetNormalTexture("")
			bu1:SetPushedTexture("")
			bu1.icon:SetTexCoord(.08, .92, .08, .92)
			bu1.IconBorder:SetAlpha(0)
			bu2:SetNormalTexture("")
			bu2:SetPushedTexture("")
			bu2.icon:SetTexCoord(.08, .92, .08, .92)
			bu2.IconBorder:SetAlpha(0)

			local bg1 = CreateFrame("Frame", nil, bu1)
			bg1:SetPoint("TOPLEFT", -1, 1)
			bg1:SetPoint("BOTTOMRIGHT", 1, -1)
			bg1:SetFrameLevel(bu1:GetFrameLevel()-1)
			F.CreateBD(bg1, .25)

			local bg2 = CreateFrame("Frame", nil, bu2)
			bg2:SetPoint("TOPLEFT", -1, 1)
			bg2:SetPoint("BOTTOMRIGHT", 1, -1)
			bg2:SetFrameLevel(bu2:GetFrameLevel()-1)
			F.CreateBD(bg2, .25)
		end

		-- Tutorial Frame

		F.CreateBD(TutorialFrame)

		TutorialFrameBackground:Hide()
		TutorialFrameBackground.Show = F.dummy
		TutorialFrame:DisableDrawLayer("BORDER")

		F.Reskin(TutorialFrameOkayButton, true)
		F.ReskinClose(TutorialFrameCloseButton)
		F.ReskinArrow(TutorialFramePrevButton, "left")
		F.ReskinArrow(TutorialFrameNextButton, "right")

		TutorialFrameOkayButton:ClearAllPoints()
		TutorialFrameOkayButton:SetPoint("BOTTOMLEFT", TutorialFrameNextButton, "BOTTOMRIGHT", 10, 0)

		-- because gradient alpha and OnUpdate doesn't work for some reason...

		if select(14, TutorialFrameOkayButton:GetRegions()) then
			select(14, TutorialFrameOkayButton:GetRegions()):Hide()
			select(15, TutorialFramePrevButton:GetRegions()):Hide()
			select(15, TutorialFrameNextButton:GetRegions()):Hide()
			select(14, TutorialFrameCloseButton:GetRegions()):Hide()
		end
		TutorialFramePrevButton:SetScript("OnEnter", nil)
		TutorialFrameNextButton:SetScript("OnEnter", nil)
		TutorialFrameOkayButton:SetBackdropColor(0, 0, 0, .25)
		TutorialFramePrevButton:SetBackdropColor(0, 0, 0, .25)
		TutorialFrameNextButton:SetBackdropColor(0, 0, 0, .25)

		-- Tabard frame

		TabardFrameMoneyInset:DisableDrawLayer("BORDER")
		TabardFrameCustomizationBorder:Hide()
		TabardFrameMoneyBg:Hide()
		TabardFrameMoneyInsetBg:Hide()

		for i = 19, 28 do
			select(i, TabardFrame:GetRegions()):Hide()
		end

		for i = 1, 5 do
			_G["TabardFrameCustomization"..i.."Left"]:Hide()
			_G["TabardFrameCustomization"..i.."Middle"]:Hide()
			_G["TabardFrameCustomization"..i.."Right"]:Hide()
			F.ReskinArrow(_G["TabardFrameCustomization"..i.."LeftButton"], "left")
			F.ReskinArrow(_G["TabardFrameCustomization"..i.."RightButton"], "right")
		end

		F.ReskinPortraitFrame(TabardFrame, true)
		F.CreateBD(TabardFrameCostFrame, .25)
		F.Reskin(TabardFrameAcceptButton)
		F.Reskin(TabardFrameCancelButton)

		-- Guild registrar frame

		GuildRegistrarFrameTop:Hide()
		GuildRegistrarFrameBottom:Hide()
		GuildRegistrarFrameMiddle:Hide()
		select(19, GuildRegistrarFrame:GetRegions()):Hide()

		GuildRegistrarFrameEditBox:SetHeight(20)

		F.ReskinPortraitFrame(GuildRegistrarFrame, true)
		F.CreateBD(GuildRegistrarFrameEditBox, .25)
		F.Reskin(GuildRegistrarFrameGoodbyeButton)
		F.Reskin(GuildRegistrarFramePurchaseButton)
		F.Reskin(GuildRegistrarFrameCancelButton)

		-- Item text

		select(18, ItemTextFrame:GetRegions()):Hide()
		InboxFrameBg:Hide()
		ItemTextPrevPageButton:GetRegions():Hide()
		ItemTextNextPageButton:GetRegions():Hide()
		ItemTextMaterialTopLeft:SetAlpha(0)
		ItemTextMaterialTopRight:SetAlpha(0)
		ItemTextMaterialBotLeft:SetAlpha(0)
		ItemTextMaterialBotRight:SetAlpha(0)

		F.ReskinPortraitFrame(ItemTextFrame, true)
		F.ReskinScroll(ItemTextScrollFrameScrollBar)
		F.ReskinArrow(ItemTextPrevPageButton, "left")
		F.ReskinArrow(ItemTextNextPageButton, "right")
		ItemTextScrollFrameScrollBar.Middle:Hide()
		ItemTextScrollFrameScrollBar.Background:Hide()
		ItemTextScrollFrameScrollBar.Top:Hide()
		ItemTextScrollFrameScrollBar.Bottom:Hide()
		ItemTextFramePageBg:SetAlpha(0)

		-- Petition frame

		select(18, PetitionFrame:GetRegions()):Hide()
		select(19, PetitionFrame:GetRegions()):Hide()
		select(23, PetitionFrame:GetRegions()):Hide()
		select(24, PetitionFrame:GetRegions()):Hide()
		PetitionFrameTop:Hide()
		PetitionFrameBottom:Hide()
		PetitionFrameMiddle:Hide()

		F.ReskinPortraitFrame(PetitionFrame, true)
		F.Reskin(PetitionFrameSignButton)
		F.Reskin(PetitionFrameRequestButton)
		F.Reskin(PetitionFrameRenameButton)
		F.Reskin(PetitionFrameCancelButton)

		-- Micro button alerts

		local microButtons = {TalentMicroButtonAlert, CollectionsMicroButtonAlert, EJMicroButtonAlert}
			for _, button in pairs(microButtons) do
			button:DisableDrawLayer("BACKGROUND")
			button:DisableDrawLayer("BORDER")
			button.Arrow:Hide()

			F.SetBD(button)
			F.ReskinClose(button.CloseButton)
		end

		-- Cinematic popup

		CinematicFrameCloseDialog:HookScript("OnShow", function(self)
			self:SetScale(UIParent:GetScale())
		end)

		F.CreateBD(CinematicFrameCloseDialog)
		F.CreateSD(CinematicFrameCloseDialog)
		F.Reskin(CinematicFrameCloseDialogConfirmButton)
		F.Reskin(CinematicFrameCloseDialogResumeButton)

		-- Chat config

		hooksecurefunc("ChatConfig_CreateCheckboxes", function(frame, checkBoxTable, checkBoxTemplate)
			if frame.styled then return end

			frame:SetBackdrop(nil)

			local checkBoxNameString = frame:GetName().."CheckBox"

			if checkBoxTemplate == "ChatConfigCheckBoxTemplate" then
				for index, value in ipairs(checkBoxTable) do
					local checkBoxName = checkBoxNameString..index
					local checkbox = _G[checkBoxName]

					checkbox:SetBackdrop(nil)

					local bg = CreateFrame("Frame", nil, checkbox)
					bg:SetPoint("TOPLEFT")
					bg:SetPoint("BOTTOMRIGHT", 0, 1)
					bg:SetFrameLevel(checkbox:GetFrameLevel()-1)
					F.CreateBD(bg, .25)

					F.ReskinCheck(_G[checkBoxName.."Check"])
				end
			elseif checkBoxTemplate == "ChatConfigCheckBoxWithSwatchTemplate" or checkBoxTemplate == "ChatConfigCheckBoxWithSwatchAndClassColorTemplate" then
				for index, value in ipairs(checkBoxTable) do
					local checkBoxName = checkBoxNameString..index
					local checkbox = _G[checkBoxName]

					checkbox:SetBackdrop(nil)

					local bg = CreateFrame("Frame", nil, checkbox)
					bg:SetPoint("TOPLEFT")
					bg:SetPoint("BOTTOMRIGHT", 0, 1)
					bg:SetFrameLevel(checkbox:GetFrameLevel()-1)
					F.CreateBD(bg, .25)

					F.ReskinColourSwatch(_G[checkBoxName.."ColorSwatch"])

					F.ReskinCheck(_G[checkBoxName.."Check"])

					if checkBoxTemplate == "ChatConfigCheckBoxWithSwatchAndClassColorTemplate" then
						F.ReskinCheck(_G[checkBoxName.."ColorClasses"])
					end
				end
			end

			frame.styled = true
		end)

		hooksecurefunc("ChatConfig_CreateTieredCheckboxes", function(frame, checkBoxTable, checkBoxTemplate, subCheckBoxTemplate)
			if frame.styled then return end

			local checkBoxNameString = frame:GetName().."CheckBox"

			for index, value in ipairs(checkBoxTable) do
				local checkBoxName = checkBoxNameString..index

				F.ReskinCheck(_G[checkBoxName])

				if value.subTypes then
					local subCheckBoxNameString = checkBoxName.."_"

					for k, v in ipairs(value.subTypes) do
						F.ReskinCheck(_G[subCheckBoxNameString..k])
					end
				end
			end

			frame.styled = true
		end)

		hooksecurefunc("ChatConfig_CreateColorSwatches", function(frame, swatchTable, swatchTemplate)
			if frame.styled then return end

			frame:SetBackdrop(nil)

			local nameString = frame:GetName().."Swatch"

			for index, value in ipairs(swatchTable) do
				local swatchName = nameString..index
				local swatch = _G[swatchName]

				swatch:SetBackdrop(nil)

				local bg = CreateFrame("Frame", nil, swatch)
				bg:SetPoint("TOPLEFT")
				bg:SetPoint("BOTTOMRIGHT", 0, 1)
				bg:SetFrameLevel(swatch:GetFrameLevel()-1)
				F.CreateBD(bg, .25)

				F.ReskinColourSwatch(_G[swatchName.."ColorSwatch"])
			end

			frame.styled = true
		end)

		for i = 1, 5 do
			_G["CombatConfigTab"..i.."Left"]:Hide()
			_G["CombatConfigTab"..i.."Middle"]:Hide()
			_G["CombatConfigTab"..i.."Right"]:Hide()
		end

		local line = ChatConfigFrame:CreateTexture()
		line:SetSize(1, 460)
		line:SetPoint("TOPLEFT", ChatConfigCategoryFrame, "TOPRIGHT")
		line:SetColorTexture(1, 1, 1, .2)

		ChatConfigCategoryFrame:SetBackdrop(nil)
		ChatConfigBackgroundFrame:SetBackdrop(nil)
		ChatConfigCombatSettingsFilters:SetBackdrop(nil)
		CombatConfigColorsHighlighting:SetBackdrop(nil)
		CombatConfigColorsColorizeUnitName:SetBackdrop(nil)
		CombatConfigColorsColorizeSpellNames:SetBackdrop(nil)
		CombatConfigColorsColorizeDamageNumber:SetBackdrop(nil)
		CombatConfigColorsColorizeDamageSchool:SetBackdrop(nil)
		CombatConfigColorsColorizeEntireLine:SetBackdrop(nil)

		local combatBoxes = {CombatConfigColorsHighlightingLine, CombatConfigColorsHighlightingAbility, CombatConfigColorsHighlightingDamage, CombatConfigColorsHighlightingSchool, CombatConfigColorsColorizeUnitNameCheck, CombatConfigColorsColorizeSpellNamesCheck, CombatConfigColorsColorizeSpellNamesSchoolColoring, CombatConfigColorsColorizeDamageNumberCheck, CombatConfigColorsColorizeDamageNumberSchoolColoring, CombatConfigColorsColorizeDamageSchoolCheck, CombatConfigColorsColorizeEntireLineCheck, CombatConfigFormattingShowTimeStamp, CombatConfigFormattingShowBraces, CombatConfigFormattingUnitNames, CombatConfigFormattingSpellNames, CombatConfigFormattingItemNames, CombatConfigFormattingFullText, CombatConfigSettingsShowQuickButton, CombatConfigSettingsSolo, CombatConfigSettingsParty, CombatConfigSettingsRaid}

		for _, box in next, combatBoxes do
			F.ReskinCheck(box)
		end

		local bg = CreateFrame("Frame", nil, ChatConfigCombatSettingsFilters)
		bg:SetPoint("TOPLEFT", 3, 0)
		bg:SetPoint("BOTTOMRIGHT", 0, 1)
		bg:SetFrameLevel(ChatConfigCombatSettingsFilters:GetFrameLevel()-1)
		F.CreateBD(bg, .25)

		F.Reskin(CombatLogDefaultButton)
		F.Reskin(ChatConfigCombatSettingsFiltersCopyFilterButton)
		F.Reskin(ChatConfigCombatSettingsFiltersAddFilterButton)
		F.Reskin(ChatConfigCombatSettingsFiltersDeleteButton)
		F.Reskin(CombatConfigSettingsSaveButton)
		F.ReskinArrow(ChatConfigMoveFilterUpButton, "up")
		F.ReskinArrow(ChatConfigMoveFilterDownButton, "down")
		F.ReskinInput(CombatConfigSettingsNameEditBox)
		F.ReskinRadio(CombatConfigColorsColorizeEntireLineBySource)
		F.ReskinRadio(CombatConfigColorsColorizeEntireLineByTarget)
		F.ReskinColourSwatch(CombatConfigColorsColorizeSpellNamesColorSwatch)
		F.ReskinColourSwatch(CombatConfigColorsColorizeDamageNumberColorSwatch)
		F.ReskinScroll(ChatConfigCombatSettingsFiltersScrollFrameScrollBar)
		ChatConfigCombatSettingsFiltersScrollFrameScrollBarBorder:Hide()

		ChatConfigMoveFilterUpButton:SetSize(28, 28)
		ChatConfigMoveFilterDownButton:SetSize(28, 28)

		ChatConfigCombatSettingsFiltersAddFilterButton:SetPoint("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0)
		ChatConfigCombatSettingsFiltersCopyFilterButton:SetPoint("RIGHT", ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0)
		ChatConfigMoveFilterUpButton:SetPoint("TOPLEFT", ChatConfigCombatSettingsFilters, "BOTTOMLEFT", 3, 0)
		ChatConfigMoveFilterDownButton:SetPoint("LEFT", ChatConfigMoveFilterUpButton, "RIGHT", 1, 0)

		-- Level up display

		LevelUpDisplaySide:HookScript("OnShow", function(self)
			for i = 1, #self.unlockList do
				local f = _G["LevelUpDisplaySideUnlockFrame"..i]

				if not f.restyled then
					f.icon:SetTexCoord(.08, .92, .08, .92)
					F.CreateBG(f.icon)
				end
			end
		end)

		-- Movie Frame

		MovieFrame.CloseDialog:HookScript("OnShow", function(self)
			self:SetScale(UIParent:GetScale())
		end)

		F.CreateBD(MovieFrame.CloseDialog)
		F.CreateSD(MovieFrame.CloseDialog)
		F.Reskin(MovieFrame.CloseDialog.ConfirmButton)
		F.Reskin(MovieFrame.CloseDialog.ResumeButton)

		-- Pet battle queue popup

		F.CreateBD(PetBattleQueueReadyFrame)
		F.CreateSD(PetBattleQueueReadyFrame)
		F.CreateBG(PetBattleQueueReadyFrame.Art)
		F.Reskin(PetBattleQueueReadyFrame.AcceptButton)
		F.Reskin(PetBattleQueueReadyFrame.DeclineButton)

		-- PVP Ready Dialog

		local PVPReadyDialog = PVPReadyDialog

		PVPReadyDialogBackground:Hide()
		PVPReadyDialogBottomArt:Hide()
		PVPReadyDialogFiligree:Hide()

		PVPReadyDialogRoleIconTexture:SetTexture(C.media.roleIcons)

		do
			local left = PVPReadyDialogRoleIcon:CreateTexture(nil, "OVERLAY")
			left:SetWidth(1.2)
			left:SetTexture(C.media.backdrop)
			left:SetVertexColor(0, 0, 0)
			left:SetPoint("TOPLEFT", 9, -7)
			left:SetPoint("BOTTOMLEFT", 9, 10)

			local right = PVPReadyDialogRoleIcon:CreateTexture(nil, "OVERLAY")
			right:SetWidth(1.2)
			right:SetTexture(C.media.backdrop)
			right:SetVertexColor(0, 0, 0)
			right:SetPoint("TOPRIGHT", -8, -7)
			right:SetPoint("BOTTOMRIGHT", -8, 10)

			local top = PVPReadyDialogRoleIcon:CreateTexture(nil, "OVERLAY")
			top:SetHeight(1.2)
			top:SetTexture(C.media.backdrop)
			top:SetVertexColor(0, 0, 0)
			top:SetPoint("TOPLEFT", 9, -7)
			top:SetPoint("TOPRIGHT", -8, -7)

			local bottom = PVPReadyDialogRoleIcon:CreateTexture(nil, "OVERLAY")
			bottom:SetHeight(1.2)
			bottom:SetTexture(C.media.backdrop)
			bottom:SetVertexColor(0, 0, 0)
			bottom:SetPoint("BOTTOMLEFT", 9, 10)
			bottom:SetPoint("BOTTOMRIGHT", -8, 10)
		end

		F.CreateBD(PVPReadyDialog)
		F.CreateSD(PVPReadyDialog)
		PVPReadyDialog.SetBackdrop = F.dummy

		F.Reskin(PVPReadyDialog.enterButton)
		F.Reskin(PVPReadyDialog.leaveButton)
		F.ReskinClose(PVPReadyDialogCloseButton)

		-- [[ Hide regions ]]

		local bglayers = {"WhoFrameColumnHeader1", "WhoFrameColumnHeader2", "WhoFrameColumnHeader3", "WhoFrameColumnHeader4", "RaidInfoInstanceLabel", "RaidInfoIDLabel", "RaidParentFrame"}
		for i = 1, #bglayers do
			_G[bglayers[i]]:DisableDrawLayer("BACKGROUND")
		end
		local borderlayers = {"WhoFrameListInset", "WhoFrameEditBoxInset", "RaidParentFrame", "RaidParentFrameInset", "RaidFinderFrameRoleInset"}
		for i = 1, #borderlayers do
			local bd = _G[borderlayers[i]]
			if not bd then
				print(borderlayers[i], "not found")
			else
				bd:DisableDrawLayer("BORDER")
			end
		end
		for i = 1, 6 do
			for j = 1, 3 do
				select(i, _G["FriendsTabHeaderTab"..j]:GetRegions()):Hide()
				select(i, _G["FriendsTabHeaderTab"..j]:GetRegions()).Show = F.dummy
			end
			select(i, ScrollOfResurrectionFrameNoteFrame:GetRegions()):Hide()
		end
		OpenStationeryBackgroundLeft:Hide()
		OpenStationeryBackgroundRight:Hide()
		SendStationeryBackgroundLeft:Hide()
		SendStationeryBackgroundRight:Hide()

		StackSplitFrame:GetRegions():Hide()
		RaidInfoDetailFooter:Hide()
		RaidInfoDetailHeader:Hide()
		RaidInfoDetailCorner:Hide()
		RaidInfoFrameHeader:Hide()
		for i = 1, 9 do
			select(i, AddFriendNoteFrame:GetRegions()):Hide()
			select(i, ReportCheatingDialogCommentFrame:GetRegions()):Hide()
		end
		ReadyCheckPortrait:SetAlpha(0)
		select(2, ReadyCheckListenerFrame:GetRegions()):Hide()
		LFDQueueFrameBackground:Hide()
		GhostFrameLeft:Hide()
		GhostFrameRight:Hide()
		GhostFrameMiddle:Hide()
		for i = 3, 6 do
			select(i, GhostFrame:GetRegions()):Hide()
		end
		PaperDollSidebarTabs:GetRegions():Hide()
		select(2, PaperDollSidebarTabs:GetRegions()):Hide()
		select(6, PaperDollEquipmentManagerPaneEquipSet:GetRegions()):Hide()
		for i = 1, 10 do
			select(i, GuildInviteFrame:GetRegions()):Hide()
		end
		InboxPrevPageButton:GetRegions():Hide()
		InboxNextPageButton:GetRegions():Hide()
		LFDQueueFrameRandomScrollFrameScrollBackground:Hide()
		LFDQueueFrameSpecificListScrollFrameScrollBackgroundTopLeft:Hide()
		LFDQueueFrameSpecificListScrollFrameScrollBackgroundBottomRight:Hide()
		local titles = false
		hooksecurefunc("PaperDollTitlesPane_Update", function()
			if titles == false then
				for i = 1, 17 do
					_G["PaperDollTitlesPaneButton"..i]:DisableDrawLayer("BACKGROUND")
				end
				titles = true
			end
		end)
		SendScrollBarBackgroundTop:Hide()
		OpenScrollBarBackgroundTop:Hide()
		WhoListScrollFrame:GetRegions():Hide()
		select(2, WhoListScrollFrame:GetRegions()):Hide()
		WhoFrameListInsetBg:Hide()
		WhoFrameEditBoxInsetBg:Hide()
		RaidFinderQueueFrameBackground:Hide()
		RaidParentFrameInsetBg:Hide()
		RaidFinderFrameRoleInsetBg:Hide()
		RaidFinderFrameRoleBackground:Hide()
		RaidParentFramePortraitFrame:Hide()
		RaidParentFramePortrait:Hide()
		RaidParentFrameTopBorder:Hide()
		RaidParentFrameTopRightCorner:Hide()
		ScrollOfResurrectionSelectionFrameBackground:Hide()

		ReadyCheckFrame:HookScript("OnShow", function(self) if UnitIsUnit("player", self.initiator) then self:Hide() end end)

		-- [[ Text colour functions ]]

		NORMAL_QUEST_DISPLAY = gsub(NORMAL_QUEST_DISPLAY, "000000", "ffffff")
		TRIVIAL_QUEST_DISPLAY = gsub(TRIVIAL_QUEST_DISPLAY, "000000", "ffffff")
		IGNORED_QUEST_DISPLAY = gsub(IGNORED_QUEST_DISPLAY, "000000", "ffffff")

		GameFontBlackMedium:SetTextColor(1, 1, 1)
		QuestFont:SetTextColor(1, 1, 1)
		MailFont_Large:SetTextColor(1, 1, 1)
		MailFont_Large:SetShadowColor(0, 0, 0)
		MailFont_Large:SetShadowOffset(1, -1)
		MailTextFontNormal:SetTextColor(1, 1, 1)
		MailTextFontNormal:SetShadowOffset(1, -1)
		MailTextFontNormal:SetShadowColor(0, 0, 0)
		InvoiceTextFontNormal:SetTextColor(1, 1, 1)
		InvoiceTextFontSmall:SetTextColor(1, 1, 1)
		SpellBookPageText:SetTextColor(.8, .8, .8)
		AvailableServicesText:SetTextColor(1, 1, 1)
		AvailableServicesText:SetShadowColor(0, 0, 0)
		PetitionFrameCharterTitle:SetTextColor(1, 1, 1)
		PetitionFrameCharterTitle:SetShadowColor(0, 0, 0)
		PetitionFrameMasterTitle:SetTextColor(1, 1, 1)
		PetitionFrameMasterTitle:SetShadowColor(0, 0, 0)
		PetitionFrameMemberTitle:SetTextColor(1, 1, 1)
		PetitionFrameMemberTitle:SetShadowColor(0, 0, 0)
		ItemTextPageText:SetTextColor(1, 1, 1)
		ItemTextPageText.SetTextColor = F.dummy
		CoreAbilityFont:SetTextColor(1, 1, 1)

		hooksecurefunc("UpdateProfessionButton", function(self)
			self.spellString:SetTextColor(1, 1, 1);
			self.subSpellString:SetTextColor(1, 1, 1)
		end)

		hooksecurefunc("PaperDollFrame_SetLevel", function()
			local primaryTalentTree = GetSpecialization()
			local classDisplayName, class = UnitClass("player")
			local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or C.classcolours[class]
			local classColorString = format("ff%.2x%.2x%.2x", classColor.r * 255, classColor.g * 255, classColor.b * 255)
			local specName, _

			if primaryTalentTree then
				_, specName = GetSpecializationInfo(primaryTalentTree, nil, nil, nil, UnitSex("player"))
			end

			if specName and specName ~= "" then
				CharacterLevelText:SetFormattedText(PLAYER_LEVEL, UnitLevel("player"), classColorString, specName, classDisplayName)
			else
				CharacterLevelText:SetFormattedText(PLAYER_LEVEL_NO_SPEC, UnitLevel("player"), classColorString, classDisplayName)
			end
		end)

		-- [[ Change positions ]]

		ChatConfigFrameDefaultButton:SetWidth(125)
		ChatConfigFrameDefaultButton:SetPoint("TOPLEFT", ChatConfigCategoryFrame, "BOTTOMLEFT", 0, -4)
		ChatConfigFrameOkayButton:SetPoint("TOPRIGHT", ChatConfigBackgroundFrame, "BOTTOMRIGHT", 0, -4)
		PaperDollEquipmentManagerPaneEquipSet:SetWidth(PaperDollEquipmentManagerPaneEquipSet:GetWidth()-1)
		PaperDollEquipmentManagerPaneSaveSet:SetPoint("LEFT", PaperDollEquipmentManagerPaneEquipSet, "RIGHT", 1, 0)
		GearManagerDialogPopup:SetPoint("LEFT", PaperDollFrame, "RIGHT", 1, 0)
		RaidInfoFrame:SetPoint("TOPLEFT", RaidFrame, "TOPRIGHT", 1, -28)
		TabardCharacterModelRotateRightButton:SetPoint("TOPLEFT", TabardCharacterModelRotateLeftButton, "TOPRIGHT", 1, 0)
		LFDQueueFrameSpecificListScrollFrameScrollBarScrollDownButton:SetPoint("TOP", LFDQueueFrameSpecificListScrollFrameScrollBar, "BOTTOM", 0, 2)
		LFDQueueFrameRandomScrollFrameScrollBarScrollDownButton:SetPoint("TOP", LFDQueueFrameRandomScrollFrameScrollBar, "BOTTOM", 0, 2)
		WhoFrameWhoButton:SetPoint("RIGHT", WhoFrameAddFriendButton, "LEFT", -1, 0)
		WhoFrameAddFriendButton:SetPoint("RIGHT", WhoFrameGroupInviteButton, "LEFT", -1, 0)
		FriendsFrameTitleText:SetPoint("TOP", FriendsFrame, "TOP", 0, -8)

		-- [[ Buttons ]]

		local buttons = {"AudioOptionsFrameOkay", "AudioOptionsFrameCancel", "AudioOptionsFrameDefaults", "ChatConfigFrameOkayButton", "ChatConfigFrameDefaultButton", "ChatConfigFrameRedockButton", "WhoFrameWhoButton", "WhoFrameAddFriendButton", "WhoFrameGroupInviteButton", "RaidFrameRaidInfoButton", "RaidFrameConvertToRaidButton", "StackSplitOkayButton", "StackSplitCancelButton", "GameMenuButtonHelp", "GameMenuButtonWhatsNew", "GameMenuButtonStore", "GameMenuButtonOptions", "GameMenuButtonUIOptions", "GameMenuButtonKeybindings", "GameMenuButtonMacros", "GameMenuButtonAddons", "GameMenuButtonLogout", "GameMenuButtonQuit", "GameMenuButtonContinue", "LFDQueueFrameFindGroupButton", "AddFriendEntryFrameAcceptButton", "AddFriendEntryFrameCancelButton", "FriendsFriendsSendRequestButton", "FriendsFriendsCloseButton", "ColorPickerOkayButton", "ColorPickerCancelButton", "GuildInviteFrameJoinButton", "GuildInviteFrameDeclineButton", "RaidInfoExtendButton", "RaidInfoCancelButton", "PaperDollEquipmentManagerPaneEquipSet", "PaperDollEquipmentManagerPaneSaveSet", "ReadyCheckFrameYesButton", "ReadyCheckFrameNoButton", "GhostFrame", "AddFriendInfoFrameContinueButton", "LFDQueueFramePartyBackfillBackfillButton", "LFDQueueFramePartyBackfillNoBackfillButton", "LFDQueueFrameNoLFDWhileLFRLeaveQueueButton", "RaidFinderFrameFindRaidButton", "RaidFinderQueueFrameIneligibleFrameLeaveQueueButton", "RaidFinderQueueFramePartyBackfillBackfillButton", "RaidFinderQueueFramePartyBackfillNoBackfillButton", "ScrollOfResurrectionSelectionFrameAcceptButton", "ScrollOfResurrectionSelectionFrameCancelButton", "ScrollOfResurrectionFrameAcceptButton", "ScrollOfResurrectionFrameCancelButton", "ReportCheatingDialogReportButton", "ReportCheatingDialogCancelButton"}
		for i = 1, #buttons do
		local reskinbutton = _G[buttons[i]]
			if reskinbutton then
				F.Reskin(reskinbutton)
			else
				print("Aurora: "..buttons[i].." was not found.")
			end
		end

		local closebuttons = {"RaidInfoCloseButton", "ItemRefCloseButton", "RaidParentFrameCloseButton"}
		for i = 1, #closebuttons do
			local bu = _G[closebuttons[i]]
			if not bu then
				print(closebuttons[i], "not found")
			else
				F.ReskinClose(_G[closebuttons[i]])
			end
		end
	end
end)