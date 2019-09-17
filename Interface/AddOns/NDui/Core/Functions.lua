local _, ns = ...
local B, C, L, DB, F = unpack(ns)
local cr, cg, cb = DB.r, DB.g, DB.b

local type, pairs, tonumber, wipe = type, pairs, tonumber, table.wipe
local strmatch, gmatch, strfind, format, gsub = string.match, string.gmatch, string.find, string.format, string.gsub
local min, max, abs, floor = math.min, math.max, math.abs, math.floor

-- Gradient Frame
function B:CreateGF(w, h, o, r, g, b, a1, a2)
	self:SetSize(w, h)
	self:SetFrameStrata("BACKGROUND")
	local gf = self:CreateTexture(nil, "BACKGROUND")
	gf:SetAllPoints()
	gf:SetTexture(DB.normTex)
	gf:SetGradientAlpha(o, r, g, b, a1, r, g, b, a2)
end

-- Create Backdrop
function B:CreateBD(a)
	self:SetBackdrop({
		bgFile = DB.bdTex, edgeFile = DB.bdTex, edgeSize = C.mult,
	})
	self:SetBackdropColor(0, 0, 0, a or .5)
	self:SetBackdropBorderColor(0, 0, 0)
end

-- Create Shadow
function B:CreateSD(m, s)
	if self.Shadow then return end

	local frame = self
	if self:GetObjectType() == "Texture" then frame = self:GetParent() end
	local lvl = frame:GetFrameLevel()
	if not m then m, s = 2, 3 end

	self.Shadow = CreateFrame("Frame", nil, frame)
	self.Shadow:SetPoint("TOPLEFT", self, -m, m)
	self.Shadow:SetPoint("BOTTOMRIGHT", self, m, -m)
	self.Shadow:SetBackdrop({edgeFile = DB.glowTex, edgeSize = s})
	self.Shadow:SetBackdropBorderColor(0, 0, 0, 1)
	self.Shadow:SetFrameLevel(lvl == 0 and 0 or lvl - 1)

	return self.Shadow
end

-- Create Background
function B:CreateBG(offset)
	local frame = self
	if self:GetObjectType() == "Texture" then frame = self:GetParent() end
	offset = offset or C.mult
	local lvl = frame:GetFrameLevel()

	local bg = CreateFrame("Frame", nil, frame)
	bg:SetPoint("TOPLEFT", self, -offset, offset)
	bg:SetPoint("BOTTOMRIGHT", self, offset, -offset)
	bg:SetFrameLevel(lvl == 0 and 0 or lvl - 1)
	return bg
end

-- Create Skin
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

function B:SetBackground()
	if F then
		F.SetBD(self)
	else
		B.CreateBD(self)
		B.CreateSD(self)
		B.CreateTex(self)
	end
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

local function tooltipOnEnter(self)
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
	self:SetScript("OnEnter", tooltipOnEnter)
	self:SetScript("OnLeave", B.HideTooltip)
end

-- Button Color
function B:CreateBC(a)
	self:SetNormalTexture("")
	self:SetHighlightTexture("")
	self:SetPushedTexture("")
	self:SetDisabledTexture("")

	if self.Left then self.Left:SetAlpha(0) end
	if self.Middle then self.Middle:SetAlpha(0) end
	if self.Right then self.Right:SetAlpha(0) end
	if self.LeftSeparator then self.LeftSeparator:Hide() end
	if self.RightSeparator then self.RightSeparator:Hide() end

	self:SetScript("OnEnter", function()
		self:SetBackdropBorderColor(cr, cg, cb, 1)
	end)
	self:SetScript("OnLeave", function()
		self:SetBackdropBorderColor(0, 0, 0, 1)
	end)
	self:SetScript("OnMouseDown", function()
		self:SetBackdropColor(cr, cg, cb, a or .3)
	end)
	self:SetScript("OnMouseUp", function()
		self:SetBackdropColor(0, 0, 0, a or .3)
	end)
end

-- Checkbox
function B:CreateCB(a)
	self:SetNormalTexture("")
	self:SetPushedTexture("")
	self:SetHighlightTexture(DB.bdTex)
	local hl = self:GetHighlightTexture()
	hl:SetPoint("TOPLEFT", 5, -5)
	hl:SetPoint("BOTTOMRIGHT", -5, 5)
	hl:SetVertexColor(cr, cg, cb, .25)

	local bd = B.CreateBG(self, -4)
	B.CreateBD(bd, a)

	local ch = self:GetCheckedTexture()
	ch:SetDesaturated(true)
	ch:SetVertexColor(cr, cg, cb)
end

-- Movable Frame
function B:CreateMF(parent, saved)
	local frame = parent or self
	frame:SetMovable(true)
	frame:SetUserPlaced(true)
	frame:SetClampedToScreen(true)

	self:EnableMouse(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", function() frame:StartMoving() end)
	self:SetScript("OnDragStop", function()
		frame:StopMovingOrSizing()
		if not saved then return end
		local orig, _, tar, x, y = frame:GetPoint()
		NDuiDB["TempAnchor"][frame:GetName()] = {orig, "UIParent", tar, x, y}
	end)
end

function B:RestoreMF()
	local name = self:GetName()
	if name and NDuiDB["TempAnchor"][name] then
		self:ClearAllPoints()
		self:SetPoint(unpack(NDuiDB["TempAnchor"][name]))
	end
end

-- Icon Style
function B:PixelIcon(texture, highlight)
	B.CreateBD(self)
	self.Icon = self:CreateTexture(nil, "ARTWORK")
	self.Icon:SetPoint("TOPLEFT", C.mult, -C.mult)
	self.Icon:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
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
		self.HL:SetPoint("TOPLEFT", C.mult, -C.mult)
		self.HL:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
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
	B.CreateSD(self, 3, 3)
	self.BG = self:CreateTexture(nil, "BACKGROUND")
	self.BG:SetAllPoints()
	self.BG:SetTexture(DB.normTex)
	self.BG:SetVertexColor(0, 0, 0, .5)
	B.CreateTex(self.BG)
	if spark then
		self.Spark = self:CreateTexture(nil, "OVERLAY")
		self.Spark:SetTexture(DB.sparkTex)
		self.Spark:SetBlendMode("ADD")
		self.Spark:SetAlpha(.8)
		self.Spark:SetPoint("TOPLEFT", self:GetStatusBarTexture(), "TOPRIGHT", -10, 10)
		self.Spark:SetPoint("BOTTOMRIGHT", self:GetStatusBarTexture(), "BOTTOMRIGHT", 10, -10)
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

function B:StripTextures(kill)
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

function B:Dummy()
	return
end

function B:HideOption()
	self:SetAlpha(0)
	self:SetScale(.0001)
end

-- Smoothy
local smoothing = {}
local f = CreateFrame("Frame")
f:SetScript("OnUpdate", function()
	local limit = 30/GetFramerate()
	for bar, value in pairs(smoothing) do
		local cur = bar:GetValue()
		local new = cur + min((value-cur)/8, max(value-cur, limit))
		if new ~= new then
			new = value
		end
		bar:SetValue_(new)
		if cur == value or abs(new - value) < 1 then
			smoothing[bar] = nil
			bar:SetValue_(value)
		end
	end
end)

local function SetSmoothValue(self, value)
	if value ~= self:GetValue() or value == 0 then
		smoothing[self] = value
	else
		smoothing[self] = nil
	end
end

function B:SmoothBar()
	if not self.SetValue_ then
		self.SetValue_ = self.SetValue
		self.SetValue = SetSmoothValue
	end
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
local tip = CreateFrame("GameTooltip", "NDui_iLvlTooltip", nil, "GameTooltipTemplate")

local texturesDB, essencesDB = {}, {}
function B:InspectItemTextures(clean, grabTextures)
	wipe(texturesDB)
	wipe(essencesDB)

	for i = 1, 5 do
		local tex = _G[tip:GetName().."Texture"..i]
		local texture = tex and tex:GetTexture()
		if not texture then break end

		if grabTextures then
			if texture == essenceTextureID then
				local selected = (texturesDB[i-1] ~= essenceTextureID and texturesDB[i-1]) or nil
				essencesDB[i] = {selected, tex:GetAtlas(), texture}
				if selected then texturesDB[i-1] = nil end
			else
				texturesDB[i] = texture
			end
		end

		if clean then tex:SetTexture() end
	end

	return texturesDB, essencesDB
end

function B:InspectItemInfo(text, iLvl, enchantText)
	local itemLevel = strfind(text, itemLevelString) and strmatch(text, "(%d+)%)?$")
	if itemLevel then iLvl = tonumber(itemLevel) end
	local enchant = strmatch(text, enchantString)
	if enchant then enchantText = enchant end

	return iLvl, enchantText
end

function B.GetItemLevel(link, arg1, arg2, fullScan)
	if fullScan then
		B:InspectItemTextures(true)
		tip:SetOwner(UIParent, "ANCHOR_NONE")
		tip:SetInventoryItem(arg1, arg2)

		local iLvl, enchantText, gems, essences
		gems, essences = B:InspectItemTextures(nil, true)

		for i = 1, tip:NumLines() do
			local line = _G[tip:GetName().."TextLeft"..i]
			if line then
				local text = line:GetText() or ""
				iLvl, enchantText = B:InspectItemInfo(text, iLvl, enchantText)
				if enchantText then break end
			end
		end

		return iLvl, enchantText, gems, essences
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

-- GUI APIs
function B:CreateButton(width, height, text, fontSize)
	local bu = CreateFrame("Button", nil, self)
	bu:SetSize(width, height)
	B.CreateBD(bu, .3)
	if type(text) == "boolean" then
		B.PixelIcon(bu, fontSize, true)
	else
		B.CreateBC(bu)
		bu.text = B.CreateFS(bu, fontSize or 14, text, true)
	end

	return bu
end

function B:CreateCheckBox()
	local cb = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
	B.CreateCB(cb)

	cb.Type = "CheckBox"
	return cb
end

function B:CreateEditBox(width, height)
	local eb = CreateFrame("EditBox", nil, self)
	eb:SetSize(width, height)
	eb:SetAutoFocus(false)
	eb:SetTextInsets(5, 5, 0, 0)
	eb:SetFont(DB.Font[1], DB.Font[2]+2, DB.Font[3])
	B.CreateBD(eb, .3)
	if F then F.CreateGradient(eb) end
	eb:SetScript("OnEscapePressed", function()
		eb:ClearFocus()
	end)
	eb:SetScript("OnEnterPressed", function()
		eb:ClearFocus()
	end)

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
	bu:SetScript("OnShow", function() list:Hide() end)
	bu:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
		ToggleFrame(list)
	end)
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

function B:CreateColorSwatch()
	local swatch = CreateFrame("Button", nil, self)
	swatch:SetSize(18, 18)
	B.CreateBD(swatch, 1)
	local tex = swatch:CreateTexture()
	tex:SetPoint("TOPLEFT", C.mult, -C.mult)
	tex:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
	tex:SetTexture(DB.bdTex)
	swatch.tex = tex

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

	slider.Low:SetText(minValue)
	slider.Low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 10, -2)
	slider.High:SetText(maxValue)
	slider.High:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", -10, -2)
	slider.Text:ClearAllPoints()
	slider.Text:SetPoint("CENTER", 0, 25)
	slider.Text:SetText(name)
	slider.Text:SetTextColor(1, .8, 0)
	slider:SetBackdrop(nil)
	slider.Thumb:SetTexture(DB.sparkTex)
	slider.Thumb:SetBlendMode("ADD")
	local bg = B.CreateBG(slider)
	bg:SetPoint("TOPLEFT", 14, -2)
	bg:SetPoint("BOTTOMRIGHT", -15, 3)
	B.CreateBD(bg, .3)
	slider.value = B.CreateEditBox(slider, 50, 20)
	slider.value:SetPoint("TOP", slider, "BOTTOM")
	slider.value:SetJustifyH("CENTER")
	slider.value.__owner = slider
	slider.value:SetScript("OnEnterPressed", updateSliderEditBox)

	return slider
end