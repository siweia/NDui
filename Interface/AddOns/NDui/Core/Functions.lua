local _, ns = ...
local B, C, L, DB = unpack(ns)
local cr, cg, cb = DB.r, DB.g, DB.b

local type, pairs, tonumber, wipe, next = type, pairs, tonumber, table.wipe, next
local strmatch, gmatch, strfind, format, gsub = string.match, string.gmatch, string.find, string.format, string.gsub
local min, max, floor = math.min, math.max, math.floor

function B:Scale(x)
	local mult = C.mult
	return mult * floor(x / mult + .5)
end

-- Gradient Frame
function B:CreateGF(w, h, o, r, g, b, a1, a2)
	self:SetSize(w, h)
	self:SetFrameStrata("BACKGROUND")
	local gf = self:CreateTexture(nil, "BACKGROUND")
	gf:SetAllPoints()
	gf:SetTexture(DB.normTex)
	gf:SetGradientAlpha(o, r, g, b, a1, r, g, b, a2)
end

-- Background texture
function B:CreateTex()
	if self.Tex then return end

	local frame = self
	if self:GetObjectType() == "Texture" then frame = self:GetParent() end

	self.Tex = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
	self.Tex:SetAllPoints(self)
	self.Tex:SetTexture(DB.bgTex, true, true)
	self.Tex:SetHorizTile(true)
	self.Tex:SetVertTile(true)
	self.Tex:SetBlendMode("ADD")
end

-- Create Shadow
function B:CreateSD(size, override)
	if not override and not NDuiDB["Skins"]["Shadow"] then return end

	if self.Shadow then return end

	local frame = self
	if self:GetObjectType() == "Texture" then frame = self:GetParent() end

	self.Shadow = CreateFrame("Frame", nil, frame)
	self.Shadow:SetOutside(self, size or 4, size or 4)
	self.Shadow:SetBackdrop({edgeFile = DB.glowTex, edgeSize = B:Scale(size or 5)})
	self.Shadow:SetBackdropBorderColor(0, 0, 0, size and 1 or .4)
	self.Shadow:SetFrameLevel(1)

	return self.Shadow
end

-- ls, Azil, and Simpy made this to replace Blizzard's SetBackdrop API while the textures can't snap
local PIXEL_BORDERS = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "TOP", "BOTTOM", "LEFT", "RIGHT"}

function B:SetBackdrop(frame, a)
	local borders = frame.pixelBorders
	if not borders then return end

	local size = C.mult

	borders.CENTER:SetPoint("TOPLEFT", frame)
	borders.CENTER:SetPoint("BOTTOMRIGHT", frame)

	borders.TOPLEFT:SetSize(size, size)
	borders.TOPRIGHT:SetSize(size, size)
	borders.BOTTOMLEFT:SetSize(size, size)
	borders.BOTTOMRIGHT:SetSize(size, size)

	borders.TOP:SetHeight(size)
	borders.BOTTOM:SetHeight(size)
	borders.LEFT:SetWidth(size)
	borders.RIGHT:SetWidth(size)

	B:SetBackdropColor(frame, 0, 0, 0, a)
	B:SetBackdropBorderColor(frame, 0, 0, 0)
end

function B:SetBackdropColor(frame, r, g, b, a)
	if frame.pixelBorders then
		frame.pixelBorders.CENTER:SetVertexColor(r, g, b, a)
	end
end

function B:SetBackdropBorderColor(frame, r, g, b, a)
	if frame.pixelBorders then
		for _, v in pairs(PIXEL_BORDERS) do
			frame.pixelBorders[v]:SetVertexColor(r or 0, g or 0, b or 0, a)
		end
	end
end

function B:SetBackdropColor_Hook(r, g, b, a)
	B:SetBackdropColor(self, r, g, b, a)
end

function B:SetBackdropBorderColor_Hook(r, g, b, a)
	B:SetBackdropBorderColor(self, r, g, b, a)
end

function B:PixelBorders(frame)
	if frame and not frame.pixelBorders then
		local borders = {}
		for _, v in pairs(PIXEL_BORDERS) do
			borders[v] = frame:CreateTexture(nil, "BORDER", nil, 1)
			borders[v]:SetTexture(DB.bdTex)
		end

		borders.CENTER = frame:CreateTexture(nil, "BACKGROUND", nil, -1)
		borders.CENTER:SetTexture(DB.bdTex)

		borders.TOPLEFT:Point("BOTTOMRIGHT", borders.CENTER, "TOPLEFT", 1, -1)
		borders.TOPRIGHT:Point("BOTTOMLEFT", borders.CENTER, "TOPRIGHT", -1, -1)
		borders.BOTTOMLEFT:Point("TOPRIGHT", borders.CENTER, "BOTTOMLEFT", 1, 1)
		borders.BOTTOMRIGHT:Point("TOPLEFT", borders.CENTER, "BOTTOMRIGHT", -1, 1)

		borders.TOP:Point("TOPLEFT", borders.TOPLEFT, "TOPRIGHT", 0, 0)
		borders.TOP:Point("TOPRIGHT", borders.TOPRIGHT, "TOPLEFT", 0, 0)

		borders.BOTTOM:Point("BOTTOMLEFT", borders.BOTTOMLEFT, "BOTTOMRIGHT", 0, 0)
		borders.BOTTOM:Point("BOTTOMRIGHT", borders.BOTTOMRIGHT, "BOTTOMLEFT", 0, 0)

		borders.LEFT:Point("TOPLEFT", borders.TOPLEFT, "BOTTOMLEFT", 0, 0)
		borders.LEFT:Point("BOTTOMLEFT", borders.BOTTOMLEFT, "TOPLEFT", 0, 0)

		borders.RIGHT:Point("TOPRIGHT", borders.TOPRIGHT, "BOTTOMRIGHT", 0, 0)
		borders.RIGHT:Point("BOTTOMRIGHT", borders.BOTTOMRIGHT, "TOPRIGHT", 0, 0)

		hooksecurefunc(frame, "SetBackdropColor", B.SetBackdropColor_Hook)
		hooksecurefunc(frame, "SetBackdropBorderColor", B.SetBackdropBorderColor_Hook)

		frame.pixelBorders = borders
	end
end

-- Create Backdrop
C.frames = {}
function B:CreateBD(a)
	self:SetBackdrop(nil)
	B:PixelBorders(self)
	B:SetBackdrop(self, a or NDuiDB["Skins"]["SkinAlpha"])
	if not a then tinsert(C.frames, self) end
end

function B:CreateGradient()
	local tex = self:CreateTexture(nil, "BORDER")
	tex:SetInside(self)
	tex:SetTexture(DB.bdTex)
	if NDuiDB["Skins"]["FlatMode"] then
		tex:SetVertexColor(.3, .3, .3, .25)
	else
		tex:SetGradientAlpha("Vertical", 0, 0, 0, .5, .3, .3, .3, .3)
	end

	return tex
end

-- Create Background
function B:CreateBDFrame(a, shadow)
	local frame = self
	if self:GetObjectType() == "Texture" then frame = self:GetParent() end
	local lvl = frame:GetFrameLevel()

	local bg = CreateFrame("Frame", nil, frame)
	bg:SetOutside(self)
	bg:SetFrameLevel(lvl == 0 and 0 or lvl - 1)
	B.CreateBD(bg, a)
	if shadow then B.CreateSD(bg) end
	return bg
end

function B:SetBD(x, y, x2, y2)
	local bg = B.CreateBDFrame(self, nil, true)
	if x then
		bg:SetPoint("TOPLEFT", self, x, y)
		bg:SetPoint("BOTTOMRIGHT", self, x2, y2)
	end
	B.CreateTex(bg)

	return bg
end

-- Frame Text
function B:CreateFS(size, text, classcolor, anchor, x, y)
	local fs = self:CreateFontString(nil, "OVERLAY")
	fs:SetFont(DB.Font[1], size, DB.Font[3])
	fs:SetText(text)
	fs:SetWordWrap(false)
	if classcolor and type(classcolor) == "boolean" then
		fs:SetTextColor(cr, cg, cb)
	elseif classcolor == "system" then
		fs:SetTextColor(1, .8, 0)
	end
	if anchor and x and y then
		fs:SetPoint(anchor, x, y)
	else
		fs:SetPoint("CENTER", 1, 0)
	end

	return fs
end

-- GameTooltip
function B:HideTooltip()
	GameTooltip:Hide()
end

local function Tooltip_OnEnter(self)
	GameTooltip:SetOwner(self, self.anchor)
	GameTooltip:ClearLines()
	if self.title then
		GameTooltip:AddLine(self.title)
	end
	if tonumber(self.text) then
		GameTooltip:SetSpellByID(self.text)
	elseif self.text then
		local r, g, b = 1, 1, 1
		if self.color == "class" then
			r, g, b = cr, cg, cb
		elseif self.color == "system" then
			r, g, b = 1, .8, 0
		elseif self.color == "info" then
			r, g, b = .6, .8, 1
		end
		GameTooltip:AddLine(self.text, r, g, b, 1)
	end
	GameTooltip:Show()
end

function B:AddTooltip(anchor, text, color)
	self.anchor = anchor
	self.text = text
	self.color = color
	self:SetScript("OnEnter", Tooltip_OnEnter)
	self:SetScript("OnLeave", B.HideTooltip)
end

-- Icon Style
function B:ReskinIcon(shadow)
	self:SetTexCoord(unpack(DB.TexCoord))
	return B.CreateBDFrame(self, nil, shadow)
end

function B:PixelIcon(texture, highlight)
	B.CreateBD(self)
	self.Icon = self:CreateTexture(nil, "ARTWORK")
	self.Icon:SetInside()
	self.Icon:SetTexCoord(unpack(DB.TexCoord))
	if texture then
		local atlas = strmatch(texture, "Atlas:(.+)$")
		if atlas then
			self.Icon:SetAtlas(atlas)
		else
			self.Icon:SetTexture(texture)
		end
	end
	if highlight and type(highlight) == "boolean" then
		self:EnableMouse(true)
		self.HL = self:CreateTexture(nil, "HIGHLIGHT")
		self.HL:SetColorTexture(1, 1, 1, .25)
		self.HL:SetInside()
	end
end

function B:AuraIcon(highlight)
	self.CD = CreateFrame("Cooldown", nil, self, "CooldownFrameTemplate")
	self.CD:SetAllPoints()
	self.CD:SetReverse(true)
	B.PixelIcon(self, nil, highlight)
	B.CreateSD(self)
end

function B:CreateGear(name)
	local bu = CreateFrame("Button", name, self)
	bu:SetSize(22, 22)
	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()
	bu.Icon:SetTexture(DB.gearTex)
	bu.Icon:SetTexCoord(0, .5, 0, .5)
	bu:SetHighlightTexture(DB.gearTex)
	bu:GetHighlightTexture():SetTexCoord(0, .5, 0, .5)

	return bu
end

-- Statusbar
function B:CreateSB(spark, r, g, b)
	self:SetStatusBarTexture(DB.normTex)
	if r and g and b then
		self:SetStatusBarColor(r, g, b)
	else
		self:SetStatusBarColor(cr, cg, cb)
	end

	local bg = B.SetBD(self)
	self.Shadow = bg.Shadow

	if spark then
		self.Spark = self:CreateTexture(nil, "OVERLAY")
		self.Spark:SetTexture(DB.sparkTex)
		self.Spark:SetBlendMode("ADD")
		self.Spark:SetAlpha(.8)
		self.Spark:SetPoint("TOPLEFT", self:GetStatusBarTexture(), "TOPRIGHT", -10, 10)
		self.Spark:SetPoint("BOTTOMRIGHT", self:GetStatusBarTexture(), "BOTTOMRIGHT", 10, -10)
	end
end


-- Reskin ui widgets
local function Button_OnEnter(self)
	if not self:IsEnabled() then return end

	if NDuiDB["Skins"]["FlatMode"] then
		self.bgTex:SetVertexColor(cr / 4, cg / 4, cb / 4)
	else
		self:SetBackdropColor(cr, cg, cb, .25)
	end
	self:SetBackdropBorderColor(cr, cg, cb)
end

local function Button_OnLeave(self)
	if NDuiDB["Skins"]["FlatMode"] then
		self.bgTex:SetVertexColor(.3, .3, .3, .25)
	else
		self:SetBackdropColor(0, 0, 0, 0)
	end
	self:SetBackdropBorderColor(0, 0, 0)
end

local blizzRegions = {
	"Left",
	"Middle",
	"Right",
	"Mid",
	"LeftDisabled",
	"MiddleDisabled",
	"RightDisabled",
	"TopLeft",
	"TopRight",
	"BottomLeft",
	"BottomRight",
	"TopMiddle",
	"MiddleLeft",
	"MiddleRight",
	"BottomMiddle",
	"MiddleMiddle",
	"TabSpacer",
	"TabSpacer1",
	"TabSpacer2",
	"_RightSeparator",
	"_LeftSeparator",
	"Cover",
	"Border",
	"Background",
	"TopTex",
	"TopLeftTex",
	"TopRightTex",
	"LeftTex",
	"BottomTex",
	"BottomLeftTex",
	"BottomRightTex",
	"RightTex",
	"MiddleTex",
}
function B:Reskin(noHighlight)
	if self.SetNormalTexture then self:SetNormalTexture("") end
	if self.SetHighlightTexture then self:SetHighlightTexture("") end
	if self.SetPushedTexture then self:SetPushedTexture("") end
	if self.SetDisabledTexture then self:SetDisabledTexture("") end

	local buttonName = self.GetName and self:GetName()
	for _, region in pairs(blizzRegions) do
		region = buttonName and _G[buttonName..region] or self[region]
		if region then
			region:SetAlpha(0)
		end
	end

	B.CreateBD(self, 0)

	self.bgTex = B.CreateGradient(self)

	if not noHighlight then
		self:HookScript("OnEnter", Button_OnEnter)
 		self:HookScript("OnLeave", Button_OnLeave)
	end
end

local function Menu_OnEnter(self)
	self.bg:SetBackdropBorderColor(cr, cg, cb)
end
local function Menu_OnLeave(self)
	self.bg:SetBackdropBorderColor(0, 0, 0)
end
local function Menu_OnMouseUp(self)
	self.bg:SetBackdropColor(0, 0, 0, NDuiDB["Skins"]["SkinAlpha"])
end
local function Menu_OnMouseDown(self)
	self.bg:SetBackdropColor(cr, cg, cb, .25)
end
function B:ReskinMenuButton()
	B.StripTextures(self)
	self.bg = B.SetBD(self)
	self:SetScript("OnEnter", Menu_OnEnter)
	self:SetScript("OnLeave", Menu_OnLeave)
	self:HookScript("OnMouseUp", Menu_OnMouseUp)
	self:HookScript("OnMouseDown", Menu_OnMouseDown)
end

-- Tabs
function B:ReskinTab()
	self:DisableDrawLayer("BACKGROUND")

	local bg = B.CreateBDFrame(self)
	bg:SetPoint("TOPLEFT", 8, -3)
	bg:SetPoint("BOTTOMRIGHT", -8, 0)

	self:SetHighlightTexture(DB.bdTex)
	local hl = self:GetHighlightTexture()
	hl:ClearAllPoints()
	hl:SetInside(bg)
	hl:SetVertexColor(cr, cg, cb, .25)
end

local function resetTabAnchor(tab)
	local text = tab.Text or _G[tab:GetName().."Text"]
	if text then
		text:SetPoint("CENTER", tab)
	end
end
hooksecurefunc("PanelTemplates_DeselectTab", resetTabAnchor)
hooksecurefunc("PanelTemplates_SelectTab", resetTabAnchor)

-- Scrollframe
local function Scroll_OnEnter(self)
	local thumb = self.thumb
	if not thumb then return end
	thumb.bg:SetBackdropColor(cr, cg, cb, .25)
	thumb.bg:SetBackdropBorderColor(cr, cg, cb)
end

local function Scroll_OnLeave(self)
	local thumb = self.thumb
	if not thumb then return end
	thumb.bg:SetBackdropColor(0, 0, 0, 0)
	thumb.bg:SetBackdropBorderColor(0, 0, 0)
end

function B:ReskinScroll()
	B.StripTextures(self:GetParent())
	B.StripTextures(self)

	local frameName = self.GetName and self:GetName()
	local thumb = frameName and (_G[frameName.."ThumbTexture"] or _G[frameName.."thumbTexture"]) or self.GetThumbTexture and self:GetThumbTexture()
	if thumb then
		thumb:SetAlpha(0)
		thumb:SetWidth(17)
		self.thumb = thumb

		local bg = B.CreateBDFrame(self, 0)
		bg:SetPoint("TOPLEFT", thumb, 0, -2)
		bg:SetPoint("BOTTOMRIGHT", thumb, 0, 4)
		B.CreateGradient(bg)
		thumb.bg = bg
	end

	local up, down = self:GetChildren()
	B.ReskinArrow(up, "up")
	B.ReskinArrow(down, "down")

	self:HookScript("OnEnter", Scroll_OnEnter)
	self:HookScript("OnLeave", Scroll_OnLeave)
end

-- Dropdown
function B:ReskinDropDown()
	B.StripTextures(self)

	local frameName = self.GetName and self:GetName()
	local down = self.Button or frameName and (_G[frameName.."Button"] or _G[frameName.."_Button"])

	down:ClearAllPoints()
	down:SetPoint("RIGHT", -18, 2)
	B.ReskinArrow(down, "down")
	down:SetSize(20, 20)

	local bg = B.CreateBDFrame(self, 0)
	bg:SetPoint("TOPLEFT", 16, -4)
	bg:SetPoint("BOTTOMRIGHT", -18, 8)
	B.CreateGradient(bg)
end

function B:Texture_OnEnter()
	if self:IsEnabled() then
		if self.pixels then
			for _, pixel in pairs(self.pixels) do
				pixel:SetVertexColor(cr, cg, cb)
			end
		elseif self.bg then
			self.bg:SetBackdropColor(cr, cg, cb, .25)
		else
			self.bgTex:SetVertexColor(cr, cg, cb)
		end
	end
end

function B:Texture_OnLeave()
	if self.pixels then
		for _, pixel in pairs(self.pixels) do
			pixel:SetVertexColor(1, 1, 1)
		end
	elseif self.bg then
		self.bg:SetBackdropColor(0, 0, 0, .25)
	else
		self.bgTex:SetVertexColor(1, 1, 1)
	end
end

-- Closebutton
function B:ReskinClose(a1, p, a2, x, y)
	self:SetSize(17, 17)

	if not a1 then
		self:SetPoint("TOPRIGHT", -6, -6)
	else
		self:ClearAllPoints()
		self:SetPoint(a1, p, a2, x, y)
	end

	B.StripTextures(self)
	B.CreateBD(self, 0)
	B.CreateGradient(self)

	self:SetDisabledTexture(DB.bdTex)
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

	self:HookScript("OnEnter", B.Texture_OnEnter)
 	self:HookScript("OnLeave", B.Texture_OnLeave)
end

-- Editbox
function B:ReskinEditBox(height, width)
	local frameName = self.GetName and self:GetName()
	for _, region in pairs(blizzRegions) do
		region = frameName and _G[frameName..region] or self[region]
		if region then
			region:SetAlpha(0)
		end
	end

	local bg = B.CreateBDFrame(self, 0)
	bg:SetPoint("TOPLEFT", -2, 0)
	bg:SetPoint("BOTTOMRIGHT")
	B.CreateGradient(bg)

	if height then self:SetHeight(height) end
	if width then self:SetWidth(width) end
end
B.ReskinInput = B.ReskinEditBox -- Deprecated

-- Arrows
local direcIndex = {
	["up"] = DB.arrowUp,
	["down"] = DB.arrowDown,
	["left"] = DB.arrowLeft,
	["right"] = DB.arrowRight,
}
function B:ReskinArrow(direction)
	self:SetSize(17, 17)
	B.Reskin(self, true)

	self:SetDisabledTexture(DB.bdTex)
	local dis = self:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .3)
	dis:SetDrawLayer("OVERLAY")
	dis:SetAllPoints()

	local tex = self:CreateTexture(nil, "ARTWORK")
	tex:SetTexture(direcIndex[direction])
	tex:SetSize(8, 8)
	tex:SetPoint("CENTER")
	self.bgTex = tex

	self:HookScript("OnEnter", B.Texture_OnEnter)
	self:HookScript("OnLeave", B.Texture_OnLeave)
end

function B:ReskinFilterButton()
	B.StripTextures(self)
	B.Reskin(self)
	self.Text:SetPoint("CENTER")
	self.Icon:SetTexture(DB.arrowRight)
	self.Icon:SetPoint("RIGHT", self, "RIGHT", -5, 0)
	self.Icon:SetSize(8, 8)
end

function B:ReskinNavBar()
	if self.navBarStyled then return end

	local homeButton = self.homeButton
	local overflowButton = self.overflowButton

	self:GetRegions():Hide()
	self:DisableDrawLayer("BORDER")
	self.overlay:Hide()
	homeButton:GetRegions():Hide()
	B.Reskin(homeButton)
	B.Reskin(overflowButton, true)

	local tex = overflowButton:CreateTexture(nil, "ARTWORK")
	tex:SetTexture(DB.arrowLeft)
	tex:SetSize(8, 8)
	tex:SetPoint("CENTER")
	overflowButton.bgTex = tex

	overflowButton:HookScript("OnEnter", B.Texture_OnEnter)
	overflowButton:HookScript("OnLeave", B.Texture_OnLeave)

	self.navBarStyled = true
end

-- Checkbox
function B:ReskinCheck(forceSaturation)
	self:SetNormalTexture("")
	self:SetPushedTexture("")
	self:SetHighlightTexture(DB.bdTex)
	local hl = self:GetHighlightTexture()
	hl:SetPoint("TOPLEFT", 5, -5)
	hl:SetPoint("BOTTOMRIGHT", -5, 5)
	hl:SetVertexColor(cr, cg, cb, .25)

	local bg = B.CreateBDFrame(self, 0)
	bg:SetPoint("TOPLEFT", 4, -4)
	bg:SetPoint("BOTTOMRIGHT", -4, 4)
	B.CreateGradient(bg)

	local ch = self:GetCheckedTexture()
	ch:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
	ch:SetTexCoord(0, 1, 0, 1)
	ch:SetDesaturated(true)
	ch:SetVertexColor(cr, cg, cb)

	self.forceSaturation = forceSaturation
end

hooksecurefunc("TriStateCheckbox_SetState", function(_, checkButton)
	if checkButton.forceSaturation then
		local tex = checkButton:GetCheckedTexture()
		if checkButton.state == 2 then
			tex:SetDesaturated(true)
			tex:SetVertexColor(cr, cg, cb)
		elseif checkButton.state == 1 then
			tex:SetVertexColor(1, .8, 0, .8)
		end
	end
end)

function B:ReskinRadio()
	self:SetNormalTexture("")
	self:SetHighlightTexture("")
	self:SetCheckedTexture(DB.bdTex)

	local ch = self:GetCheckedTexture()
	ch:SetPoint("TOPLEFT", 4, -4)
	ch:SetPoint("BOTTOMRIGHT", -4, 4)
	ch:SetVertexColor(cr, cg, cb, .6)

	local bg = B.CreateBDFrame(self, 0)
	bg:SetPoint("TOPLEFT", 3, -3)
	bg:SetPoint("BOTTOMRIGHT", -3, 3)
	B.CreateGradient(bg)
	self.bg = bg

	self:HookScript("OnEnter", Menu_OnEnter)
	self:HookScript("OnLeave", Menu_OnLeave)
end

-- Swatch
function B:ReskinColorSwatch()
	local frameName = self.GetName and self:GetName()

	self:SetNormalTexture(DB.bdTex)
	local nt = self:GetNormalTexture()
	nt:SetPoint("TOPLEFT", 3, -3)
	nt:SetPoint("BOTTOMRIGHT", -3, 3)

	local bg = _G[frameName.."SwatchBg"]
	bg:SetColorTexture(0, 0, 0)
	bg:SetPoint("TOPLEFT", 2, -2)
	bg:SetPoint("BOTTOMRIGHT", -2, 2)
end

-- Slider
function B:ReskinSlider(verticle)
	self:SetBackdrop(nil)
	B.StripTextures(self)

	local bg = B.CreateBDFrame(self, 0)
	bg:SetPoint("TOPLEFT", 14, -2)
	bg:SetPoint("BOTTOMRIGHT", -15, 3)
	B.CreateGradient(bg)

	local thumb = self:GetThumbTexture()
	thumb:SetTexture(DB.sparkTex)
	thumb:SetBlendMode("ADD")
	if verticle then thumb:SetRotation(math.rad(90)) end
end

-- Multi elements
local function UpdateExpandOrCollapse(self, texture)
	if self.settingTexture then return end
	self.settingTexture = true
	self:SetNormalTexture("")

	if texture and texture ~= "" then
		if texture:find("Plus") then
			self.expTex:SetTexCoord(0, .4375, 0, .4375)
		elseif texture:find("Minus") then
			self.expTex:SetTexCoord(.5625, 1, 0, .4375)
		end
		self.bg:Show()
	else
		self.bg:Hide()
	end
	self.settingTexture = nil
end

function B:ReskinExpandOrCollapse()
	self:SetHighlightTexture("")
	self:SetPushedTexture("")

	local bg = B.CreateBDFrame(self, .25)
	bg:ClearAllPoints()
	bg:SetSize(13, 13)
	bg:SetPoint("TOPLEFT", self:GetNormalTexture())
	B.CreateGradient(bg)
	self.bg = bg

	self.expTex = bg:CreateTexture(nil, "OVERLAY")
	self.expTex:SetSize(7, 7)
	self.expTex:SetPoint("CENTER")
	self.expTex:SetTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")

	self:HookScript("OnEnter", B.Texture_OnEnter)
	self:HookScript("OnLeave", B.Texture_OnLeave)
	hooksecurefunc(self, "SetNormalTexture", UpdateExpandOrCollapse)
end

function B:ReskinMinMax()
	for _, name in next, {"MaximizeButton", "MinimizeButton"} do
		local button = self[name]
		if button then
			button:SetSize(17, 17)
			button:ClearAllPoints()
			button:SetPoint("CENTER", -3, 0)
			B.Reskin(button)

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

			button:SetScript("OnEnter", B.Texture_OnEnter)
			button:SetScript("OnLeave", B.Texture_OnLeave)
		end
	end
end

-- Templates
function B:ReskinPortraitFrame()
	B.StripTextures(self)
	local bg = B.SetBD(self)
	local frameName = self.GetName and self:GetName()
	local portrait = self.portrait or _G[frameName.."Portrait"]
	if portrait then portrait:SetAlpha(0) end
	local closeButton = self.CloseButton or _G[frameName.."CloseButton"]
	if closeButton then B.ReskinClose(closeButton) end
	return bg
end

function B:ReskinGarrisonPortrait()
	self.Portrait:ClearAllPoints()
	self.Portrait:SetPoint("TOPLEFT", 4, -4)
	self.Portrait:SetMask("Interface\\Buttons\\WHITE8X8")
	self.PortraitRing:Hide()
	self.PortraitRingQuality:SetTexture("")
	if self.Highlight then self.Highlight:Hide() end

	self.LevelBorder:SetScale(.0001)
	self.Level:ClearAllPoints()
	self.Level:SetPoint("BOTTOM", self, 0, 12)

	self.squareBG = B.CreateBDFrame(self.Portrait, 1)

	if self.PortraitRingCover then
		self.PortraitRingCover:SetColorTexture(0, 0, 0)
		self.PortraitRingCover:SetAllPoints(self.squareBG)
	end

	if self.Empty then
		self.Empty:SetColorTexture(0, 0, 0)
		self.Empty:SetAllPoints(self.Portrait)
	end
end

function B:StyleSearchButton()
	B.StripTextures(self)
	if self.icon then B.ReskinIcon(self.icon) end
	B.CreateBD(self, .25)

	self:SetHighlightTexture(DB.bdTex)
	local hl = self:GetHighlightTexture()
	hl:SetVertexColor(cr, cg, cb, .25)
	hl:SetInside()
end

function B:AffixesSetup()
	for _, frame in ipairs(self.Affixes) do
		frame.Border:SetTexture(nil)
		frame.Portrait:SetTexture(nil)
		if not frame.bg then
			frame.bg = B.ReskinIcon(frame.Portrait)
		end

		if frame.info then
			frame.Portrait:SetTexture(CHALLENGE_MODE_EXTRA_AFFIX_INFO[frame.info.key].texture)
		elseif frame.affixID then
			local _, _, filedataid = C_ChallengeMode.GetAffixInfo(frame.affixID)
			frame.Portrait:SetTexture(filedataid)
		end
	end
end

function B:CreateGlowFrame(size)
	local frame = CreateFrame("Frame", nil, self)
	frame:SetPoint("CENTER")
	frame:SetSize(size+8, size+8)

	return frame
end

-- Role Icons
function B:GetRoleTexCoord()
	if self == "TANK" then
		return .32/9.03, 2.04/9.03, 2.65/9.03, 4.3/9.03
	elseif self == "DPS" or self == "DAMAGER" then
		return 2.68/9.03, 4.4/9.03, 2.65/9.03, 4.34/9.03
	elseif self == "HEALER" then
		return 2.68/9.03, 4.4/9.03, .28/9.03, 1.98/9.03
	elseif self == "LEADER" then
		return .32/9.03, 2.04/9.03, .28/9.03, 1.98/9.03
	elseif self == "READY" then
		return 5.1/9.03, 6.76/9.03, .28/9.03, 1.98/9.03
	elseif self == "PENDING" then
		return 5.1/9.03, 6.76/9.03, 2.65/9.03, 4.34/9.03
	elseif self == "REFUSE" then
		return 2.68/9.03, 4.4/9.03, 5.02/9.03, 6.7/9.03
	end
end

function B:ReskinRole(role)
	if self.background then self.background:SetTexture("") end
	local cover = self.cover or self.Cover
	if cover then cover:SetTexture("") end
	local texture = self.GetNormalTexture and self:GetNormalTexture() or self.texture or self.Texture or (self.SetTexture and self) or self.Icon
	if texture then
		texture:SetTexture(DB.rolesTex)
		texture:SetTexCoord(B.GetRoleTexCoord(role))
	end
	self.bg = B.CreateBDFrame(self)

	local checkButton = self.checkButton or self.CheckButton or self.CheckBox
	if checkButton then
		checkButton:SetFrameLevel(self:GetFrameLevel() + 2)
		checkButton:SetPoint("BOTTOMLEFT", -2, -2)
		B.ReskinCheck(checkButton)
	end

	local shortageBorder = self.shortageBorder
	if shortageBorder then
		shortageBorder:SetTexture("")
		local icon = self.incentiveIcon
		icon:SetPoint("BOTTOMRIGHT")
		icon:SetSize(14, 14)
		icon.texture:SetSize(14, 14)
		B.ReskinIcon(icon.texture)
		icon.border:SetTexture("")
	end
end

-- Numberize
function B.Numb(n)
	if NDuiADB["NumberFormat"] == 1 then
		if n >= 1e12 then
			return format("%.2ft", n / 1e12)
		elseif n >= 1e9 then
			return format("%.2fb", n / 1e9)
		elseif n >= 1e6 then
			return format("%.2fm", n / 1e6)
		elseif n >= 1e3 then
			return format("%.1fk", n / 1e3)
		else
			return format("%.0f", n)
		end
	elseif NDuiADB["NumberFormat"] == 2 then
		if n >= 1e12 then
			return format("%.2f"..L["NumberCap3"], n / 1e12)
		elseif n >= 1e8 then
			return format("%.2f"..L["NumberCap2"], n / 1e8)
		elseif n >= 1e4 then
			return format("%.1f"..L["NumberCap1"], n / 1e4)
		else
			return format("%.0f", n)
		end
	else
		return format("%.0f", n)
	end
end

function B:Round(number, idp)
	idp = idp or 0
	local mult = 10 ^ idp
	return floor(number * mult + .5) / mult
end

-- Color code
function B.HexRGB(r, g, b)
	if r then
		if type(r) == "table" then
			if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
		end
		return format("|cff%02x%02x%02x", r*255, g*255, b*255)
	end
end

function B.ClassColor(class)
	local color = DB.ClassColors[class]
	if not color then return 1, 1, 1 end
	return color.r, color.g, color.b
end

function B.UnitColor(unit)
	local r, g, b = 1, 1, 1
	if UnitIsPlayer(unit) then
		local class = select(2, UnitClass(unit))
		if class then
			r, g, b = B.ClassColor(class)
		end
	elseif UnitIsTapDenied(unit) then
		r, g, b = .6, .6, .6
	else
		local reaction = UnitReaction(unit, "player")
		if reaction then
			local color = FACTION_BAR_COLORS[reaction]
			r, g, b = color.r, color.g, color.b
		end
	end
	return r, g, b
end

-- Disable function
B.HiddenFrame = CreateFrame("Frame")
B.HiddenFrame:Hide()

function B:HideObject()
	if self.UnregisterAllEvents then
		self:UnregisterAllEvents()
		self:SetParent(B.HiddenFrame)
	else
		self.Show = self.Hide
	end
	self:Hide()
end

local blizzTextures = {
	"Inset",
	"inset",
	"InsetFrame",
	"LeftInset",
	"RightInset",
	"NineSlice",
	"BG",
	"border",
	"Border",
	"BorderFrame",
	"bottomInset",
	"BottomInset",
	"bgLeft",
	"bgRight",
	"FilligreeOverlay",
	"PortraitOverlay",
	"ArtOverlayFrame",
	"Portrait",
	"portrait",
	"ScrollFrameBorder",
}
function B:StripTextures(kill)
	local frameName = self.GetName and self:GetName()
	for _, texture in pairs(blizzTextures) do
		local blizzFrame = self[texture] or (frameName and _G[frameName..texture])
		if blizzFrame then
			B.StripTextures(blizzFrame, kill)
		end
	end

	if self.GetNumRegions then
		for i = 1, self:GetNumRegions() do
			local region = select(i, self:GetRegions())
			if region and region.IsObjectType and region:IsObjectType("Texture") then
				if kill and type(kill) == "boolean" then
					B.HideObject(region)
				elseif tonumber(kill) then
					if kill == 0 then
						region:SetAlpha(0)
					elseif i ~= kill then
						region:SetTexture("")
					end
				else
					region:SetTexture("")
				end
			end
		end
	end
end

function B:Dummy()
	return
end

function B:HideOption()
	self:SetAlpha(0)
	self:SetScale(.0001)
end

-- Timer Format
local day, hour, minute = 86400, 3600, 60
function B.FormatTime(s)
	if s >= day then
		return format("%d"..DB.MyColor.."d", s/day), s%day
	elseif s >= hour then
		return format("%d"..DB.MyColor.."h", s/hour), s%hour
	elseif s >= minute then
		return format("%d"..DB.MyColor.."m", s/minute), s%minute
	elseif s > 10 then
		return format("|cffcccc33%d|r", s), s - floor(s)
	elseif s > 3 then
		return format("|cffffff00%d|r", s), s - floor(s)
	else
		if NDuiDB["Actionbar"]["DecimalCD"] then
			return format("|cffff0000%.1f|r", s), s - format("%.1f", s)
		else
			return format("|cffff0000%d|r", s + .5), s - floor(s)
		end
	end
end

function B.FormatTimeRaw(s)
	if s >= day then
		return format("%dd", s/day)
	elseif s >= hour then
		return format("%dh", s/hour)
	elseif s >= minute then
		return format("%dm", s/minute)
	elseif s >= 3 then
		return floor(s)
	else
		return format("%d", s)
	end
end

function B:CooldownOnUpdate(elapsed, raw)
	local formatTime = raw and B.FormatTimeRaw or B.FormatTime
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= .1 then
		local timeLeft = self.expiration - GetTime()
		if timeLeft > 0 then
			local text = formatTime(timeLeft)
			self.timer:SetText(text)
		else
			self:SetScript("OnUpdate", nil)
			self.timer:SetText(nil)
		end
		self.elapsed = 0
	end
end

-- Table
function B.CopyTable(source, target)
	for key, value in pairs(source) do
		if type(value) == "table" then
			if not target[key] then target[key] = {} end
			for k in pairs(value) do
				target[key][k] = value[k]
			end
		else
			target[key] = value
		end
	end
end

function B.SplitList(list, variable, cleanup)
	if cleanup then wipe(list) end

	for word in gmatch(variable, "%S+") do
		list[word] = true
	end
end

-- Itemlevel
local iLvlDB = {}
local itemLevelString = gsub(ITEM_LEVEL, "%%d", "")
local enchantString = gsub(ENCHANTED_TOOLTIP_LINE, "%%s", "(.+)")
local essenceTextureID = 2975691
local essenceDescription = GetSpellDescription(277253)
local ITEM_SPELL_TRIGGER_ONEQUIP = ITEM_SPELL_TRIGGER_ONEQUIP
local tip = CreateFrame("GameTooltip", "NDui_iLvlTooltip", nil, "GameTooltipTemplate")

function B:InspectItemTextures()
	if not tip.gems then
		tip.gems = {}
	else
		wipe(tip.gems)
	end

	if not tip.essences then
		tip.essences = {}
	else
		for _, essences in pairs(tip.essences) do
			wipe(essences)
		end
	end

	local step = 1
	for i = 1, 10 do
		local tex = _G[tip:GetName().."Texture"..i]
		local texture = tex and tex:IsShown() and tex:GetTexture()
		if texture then
			if texture == essenceTextureID then
				local selected = (tip.gems[i-1] ~= essenceTextureID and tip.gems[i-1]) or nil
				if not tip.essences[step] then tip.essences[step] = {} end
				tip.essences[step][1] = selected		--essence texture if selected or nil
				tip.essences[step][2] = tex:GetAtlas()	--atlas place 'tooltip-heartofazerothessence-major' or 'tooltip-heartofazerothessence-minor'
				tip.essences[step][3] = texture			--border texture placed by the atlas

				step = step + 1
				if selected then tip.gems[i-1] = nil end
			else
				tip.gems[i] = texture
			end
		end
	end

	return tip.gems, tip.essences
end

function B:InspectItemInfo(text, slotInfo)
	local itemLevel = strfind(text, itemLevelString) and strmatch(text, "(%d+)%)?$")
	if itemLevel then
		slotInfo.iLvl = tonumber(itemLevel)
	end

	local enchant = strmatch(text, enchantString)
	if enchant then
		slotInfo.enchantText = enchant
	end
end

function B:CollectEssenceInfo(index, lineText, slotInfo)
	local step = 1
	local essence = slotInfo.essences[step]
	if essence and next(essence) and (strfind(lineText, ITEM_SPELL_TRIGGER_ONEQUIP, nil, true) and strfind(lineText, essenceDescription, nil, true)) then
		for i = 5, 2, -1 do
			local line = _G[tip:GetName().."TextLeft"..index-i]
			local text = line and line:GetText()

			if text and (not strmatch(text, "^[ +]")) and essence and next(essence) then
				local r, g, b = line:GetTextColor()
				essence[4] = r
				essence[5] = g
				essence[6] = b

				step = step + 1
				essence = slotInfo.essences[step]
			end
		end
	end
end

function B.GetItemLevel(link, arg1, arg2, fullScan)
	if fullScan then
		tip:SetOwner(UIParent, "ANCHOR_NONE")
		tip:SetInventoryItem(arg1, arg2)

		if not tip.slotInfo then tip.slotInfo = {} else wipe(tip.slotInfo) end

		local slotInfo = tip.slotInfo
		slotInfo.gems, slotInfo.essences = B:InspectItemTextures()

		for i = 1, tip:NumLines() do
			local line = _G[tip:GetName().."TextLeft"..i]
			if line then
				local text = line:GetText() or ""
				B:InspectItemInfo(text, slotInfo)
				B:CollectEssenceInfo(i, text, slotInfo)
			end
		end

		return slotInfo
	else
		if iLvlDB[link] then return iLvlDB[link] end

		tip:SetOwner(UIParent, "ANCHOR_NONE")
		if arg1 and type(arg1) == "string" then
			tip:SetInventoryItem(arg1, arg2)
		elseif arg1 and type(arg1) == "number" then
			tip:SetBagItem(arg1, arg2)
		else
			tip:SetHyperlink(link)
		end

		for i = 2, 5 do
			local line = _G[tip:GetName().."TextLeft"..i]
			if line then
				local text = line:GetText() or ""
				local found = strfind(text, itemLevelString)
				if found then
					local level = strmatch(text, "(%d+)%)?$")
					iLvlDB[link] = tonumber(level)
					break
				end
			end
		end

		return iLvlDB[link]
	end
end

-- GUID to npcID
function B.GetNPCID(guid)
	local id = tonumber(strmatch((guid or ""), "%-(%d-)%-%x-$"))
	return id
end

-- Add APIs
local function WatchPixelSnap(frame, snap)
	if (frame and not frame:IsForbidden()) and frame.PixelSnapDisabled and snap then
		frame.PixelSnapDisabled = nil
	end
end

local function DisablePixelSnap(frame)
	if (frame and not frame:IsForbidden()) and not frame.PixelSnapDisabled then
		if frame.SetSnapToPixelGrid then
			frame:SetSnapToPixelGrid(false)
			frame:SetTexelSnappingBias(0)
		elseif frame.GetStatusBarTexture then
			local texture = frame:GetStatusBarTexture()
			if texture and texture.SetSnapToPixelGrid then
				texture:SetSnapToPixelGrid(false)
				texture:SetTexelSnappingBias(0)
			end
		end

		frame.PixelSnapDisabled = true
	end
end

local function Point(frame, arg1, arg2, arg3, arg4, arg5, ...)
	if arg2 == nil then arg2 = frame:GetParent() end

	if type(arg2) == "number" then arg2 = B:Scale(arg2) end
	if type(arg3) == "number" then arg3 = B:Scale(arg3) end
	if type(arg4) == "number" then arg4 = B:Scale(arg4) end
	if type(arg5) == "number" then arg5 = B:Scale(arg5) end

	frame:SetPoint(arg1, arg2, arg3, arg4, arg5, ...)
end

local function SetInside(frame, anchor, xOffset, yOffset, anchor2)
	xOffset = xOffset or C.mult
	yOffset = yOffset or C.mult
	anchor = anchor or frame:GetParent()

	DisablePixelSnap(frame)
	frame:ClearAllPoints()
	frame:Point("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
	frame:Point("BOTTOMRIGHT", anchor2 or anchor, "BOTTOMRIGHT", -xOffset, yOffset)
end

local function SetOutside(frame, anchor, xOffset, yOffset, anchor2)
	xOffset = xOffset or C.mult
	yOffset = yOffset or C.mult
	anchor = anchor or frame:GetParent()

	DisablePixelSnap(frame)
	frame:ClearAllPoints()
	frame:Point("TOPLEFT", anchor, "TOPLEFT", -xOffset, yOffset)
	frame:Point("BOTTOMRIGHT", anchor2 or anchor, "BOTTOMRIGHT", xOffset, -yOffset)
end

local function addapi(object)
	local mt = getmetatable(object).__index
	if not object.Point then mt.Point = Point end
	if not object.SetInside then mt.SetInside = SetInside end
	if not object.SetOutside then mt.SetOutside = SetOutside end
	if not object.DisabledPixelSnap then
		if mt.SetTexture then hooksecurefunc(mt, "SetTexture", DisablePixelSnap) end
		if mt.SetTexCoord then hooksecurefunc(mt, "SetTexCoord", DisablePixelSnap) end
		if mt.CreateTexture then hooksecurefunc(mt, "CreateTexture", DisablePixelSnap) end
		if mt.SetVertexColor then hooksecurefunc(mt, "SetVertexColor", DisablePixelSnap) end
		if mt.SetColorTexture then hooksecurefunc(mt, "SetColorTexture", DisablePixelSnap) end
		if mt.SetSnapToPixelGrid then hooksecurefunc(mt, "SetSnapToPixelGrid", WatchPixelSnap) end
		if mt.SetStatusBarTexture then hooksecurefunc(mt, "SetStatusBarTexture", DisablePixelSnap) end
		mt.DisabledPixelSnap = true
	end
end

local handled = {["Frame"] = true}
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateMaskTexture())

object = EnumerateFrames()
while object do
	if not object:IsForbidden() and not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end

	object = EnumerateFrames(object)
end

-- GUI APIs
function B:CreateButton(width, height, text, fontSize)
	local bu = CreateFrame("Button", nil, self)
	bu:SetSize(width, height)
	if type(text) == "boolean" then
		B.PixelIcon(bu, fontSize, true)
		B.CreateBD(bu, .3)
	else
		B.Reskin(bu)
		bu.text = B.CreateFS(bu, fontSize or 14, text, true)
	end

	return bu
end

function B:CreateCheckBox()
	local cb = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
	B.ReskinCheck(cb)

	cb.Type = "CheckBox"
	return cb
end

local function editBoxClearFocus(self)
	self:ClearFocus()
end

function B:CreateEditBox(width, height)
	local eb = CreateFrame("EditBox", nil, self)
	eb:SetSize(width, height)
	eb:SetAutoFocus(false)
	eb:SetTextInsets(5, 5, 0, 0)
	eb:SetFont(DB.Font[1], DB.Font[2]+2, DB.Font[3])
	B.CreateBD(eb, .3)
	B.CreateGradient(eb)
	eb:SetScript("OnEscapePressed", editBoxClearFocus)
	eb:SetScript("OnEnterPressed", editBoxClearFocus)

	eb.Type = "EditBox"
	return eb
end

local function optOnClick(self)
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
	local opt = self.__owner.options
	for i = 1, #opt do
		if self == opt[i] then
			opt[i]:SetBackdropColor(1, .8, 0, .3)
			opt[i].selected = true
		else
			opt[i]:SetBackdropColor(0, 0, 0, .3)
			opt[i].selected = false
		end
	end
	self.__owner.Text:SetText(self.text)
	self:GetParent():Hide()
end

local function optOnEnter(self)
	if self.selected then return end
	self:SetBackdropColor(1, 1, 1, .25)
end

local function optOnLeave(self)
	if self.selected then return end
	self:SetBackdropColor(0, 0, 0)
end

local function buttonOnShow(self)
	self.__list:Hide()
end

local function buttonOnClick(self)
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
	ToggleFrame(self.__list)
end

function B:CreateDropDown(width, height, data)
	local dd = CreateFrame("Frame", nil, self)
	dd:SetSize(width, height)
	B.CreateBD(dd)
	dd:SetBackdropBorderColor(1, 1, 1, .2)
	dd.Text = B.CreateFS(dd, 14, "", false, "LEFT", 5, 0)
	dd.Text:SetPoint("RIGHT", -5, 0)
	dd.options = {}

	local bu = B.CreateGear(dd)
	bu:SetPoint("LEFT", dd, "RIGHT", -2, 0)
	local list = CreateFrame("Frame", nil, dd)
	list:SetPoint("TOP", dd, "BOTTOM", 0, -2)
	B.CreateBD(list, 1)
	list:SetBackdropBorderColor(1, 1, 1, .2)
	list:Hide()
	bu.__list = list
	bu:SetScript("OnShow", buttonOnShow)
	bu:SetScript("OnClick", buttonOnClick)
	dd.button = bu

	local opt, index = {}, 0
	for i, j in pairs(data) do
		opt[i] = CreateFrame("Button", nil, list)
		opt[i]:SetPoint("TOPLEFT", 4, -4 - (i-1)*(height+2))
		opt[i]:SetSize(width - 8, height)
		B.CreateBD(opt[i])
		local text = B.CreateFS(opt[i], 14, j, false, "LEFT", 5, 0)
		text:SetPoint("RIGHT", -5, 0)
		opt[i].text = j
		opt[i].__owner = dd
		opt[i]:SetScript("OnClick", optOnClick)
		opt[i]:SetScript("OnEnter", optOnEnter)
		opt[i]:SetScript("OnLeave", optOnLeave)

		dd.options[i] = opt[i]
		index = index + 1
	end
	list:SetSize(width, index*(height+2) + 6)

	dd.Type = "DropDown"
	return dd
end

local function updatePicker()
	local swatch = ColorPickerFrame.__swatch
	local r, g, b = ColorPickerFrame:GetColorRGB()
	swatch.tex:SetVertexColor(r, g, b)
	swatch.color.r, swatch.color.g, swatch.color.b = r, g, b
end

local function cancelPicker()
	local swatch = ColorPickerFrame.__swatch
	local r, g, b = ColorPicker_GetPreviousValues()
	swatch.tex:SetVertexColor(r, g, b)
	swatch.color.r, swatch.color.g, swatch.color.b = r, g, b
end

local function openColorPicker(self)
	local r, g, b = self.color.r, self.color.g, self.color.b
	ColorPickerFrame.__swatch = self
	ColorPickerFrame.func = updatePicker
	ColorPickerFrame.previousValues = {r = r, g = g, b = b}
	ColorPickerFrame.cancelFunc = cancelPicker
	ColorPickerFrame:SetColorRGB(r, g, b)
	ColorPickerFrame:Show()
end

function B:CreateColorSwatch(name, color)
	color = color or {r=1, g=1, b=1}

	local swatch = CreateFrame("Button", nil, self)
	swatch:SetSize(18, 18)
	B.CreateBD(swatch, 1)
	swatch.text = B.CreateFS(swatch, 14, name, false, "LEFT", 26, 0)
	local tex = swatch:CreateTexture()
	tex:SetInside()
	tex:SetTexture(DB.bdTex)
	tex:SetVertexColor(color.r, color.g, color.b)

	swatch.tex = tex
	swatch.color = color
	swatch:SetScript("OnClick", openColorPicker)

	return swatch
end

local function updateSliderEditBox(self)
	local slider = self.__owner
	local minValue, maxValue = slider:GetMinMaxValues()
	local text = tonumber(self:GetText())
	if not text then return end
	text = min(maxValue, text)
	text = max(minValue, text)
	slider:SetValue(text)
	self:SetText(text)
	self:ClearFocus()
end

function B:CreateSlider(name, minValue, maxValue, x, y, width)
	local slider = CreateFrame("Slider", nil, self, "OptionsSliderTemplate")
	slider:SetPoint("TOPLEFT", x, y)
	slider:SetWidth(width or 200)
	slider:SetMinMaxValues(minValue, maxValue)
	slider:SetHitRectInsets(0, 0, 0, 0)
	B.ReskinSlider(slider)

	slider.Low:SetText(minValue)
	slider.Low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 10, -2)
	slider.High:SetText(maxValue)
	slider.High:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", -10, -2)
	slider.Text:ClearAllPoints()
	slider.Text:SetPoint("CENTER", 0, 25)
	slider.Text:SetText(name)
	slider.Text:SetTextColor(1, .8, 0)
	slider.value = B.CreateEditBox(slider, 50, 20)
	slider.value:SetPoint("TOP", slider, "BOTTOM")
	slider.value:SetJustifyH("CENTER")
	slider.value.__owner = slider
	slider.value:SetScript("OnEnterPressed", updateSliderEditBox)

	return slider
end