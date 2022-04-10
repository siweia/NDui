local _, ns = ...
local B, C, L, DB = unpack(ns)
local cr, cg, cb = DB.r, DB.g, DB.b

local _G = _G
local type, pairs, tonumber, wipe, next, select, unpack = type, pairs, tonumber, table.wipe, next, select, unpack
local strmatch, gmatch, strfind, format, gsub = string.match, string.gmatch, string.find, string.format, string.gsub
local min, max, floor, rad = math.min, math.max, math.floor, math.rad

-- Math
do
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

	-- Cooldown calculation
	local day, hour, minute = 86400, 3600, 60
	function B.FormatTime(s)
		if s >= day then
			return format("%d"..DB.MyColor.."d", s/day + .5), s%day
		elseif s >= hour then
			return format("%d"..DB.MyColor.."h", s/hour + .5), s%hour
		elseif s >= minute then
			return format("%d"..DB.MyColor.."m", s/minute + .5), s%minute
		elseif s > 10 then
			return format("|cffcccc33%d|r", s + .5), s - floor(s)
		elseif s > 3 then
			return format("|cffffff00%d|r", s + .5), s - floor(s)
		else
			return format("|cffff0000%.1f|r", s), s - format("%.1f", s)
		end
	end

	function B.FormatTimeRaw(s)
		if s >= day then
			return format("%dd", s/day + .5)
		elseif s >= hour then
			return format("%dh", s/hour + .5)
		elseif s >= minute then
			return format("%dm", s/minute + .5)
		else
			return format("%d", s + .5)
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

	-- GUID to npcID
	function B.GetNPCID(guid)
		local id = tonumber(strmatch((guid or ""), "%-(%d-)%-%x-$"))
		return id
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
			word = tonumber(word) or word -- use number if exists, needs review
			list[word] = true
		end
	end
end

-- Color
do
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
end

-- Itemlevel
do
	local iLvlDB = {}
	local itemLevelString = "^"..gsub(ITEM_LEVEL, "%%d", "")
	local RETRIEVING_ITEM_INFO = RETRIEVING_ITEM_INFO

	local tip = CreateFrame("GameTooltip", "NDui_ScanTooltip", nil, "GameTooltipTemplate")
	B.ScanTip = tip

	function B:InspectItemTextures()
		if not tip.gems then
			tip.gems = {}
		else
			wipe(tip.gems)
		end

		for i = 1, 5 do
			local tex = _G[tip:GetName().."Texture"..i]
			local texture = tex and tex:IsShown() and tex:GetTexture()
			if texture then
				tip.gems[i] = texture
			end
		end

		return tip.gems
	end

	function B.GetItemLevel(link, arg1, arg2, fullScan)
		if fullScan then
			tip:SetOwner(UIParent, "ANCHOR_NONE")
			tip:SetInventoryItem(arg1, arg2)

			if not tip.slotInfo then tip.slotInfo = {} else wipe(tip.slotInfo) end

			local slotInfo = tip.slotInfo
			slotInfo.gems = B:InspectItemTextures()

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

			local firstLine = _G.NDui_ScanTooltipTextLeft1:GetText()
			if firstLine == RETRIEVING_ITEM_INFO then
				return "tooSoon"
			end

			for i = 2, 5 do
				local line = _G[tip:GetName().."TextLeft"..i]
				if not line then break end

				local text = line:GetText()
				local found = text and strfind(text, itemLevelString)
				if found then
					local level = strmatch(text, "(%d+)%)?$")
					iLvlDB[link] = tonumber(level)
					break
				end
			end

			return iLvlDB[link]
		end
	end
end

-- Kill regions
do
	function B:Dummy()
		return
	end

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

	function B:HideOption()
		self:SetAlpha(0)
		self:SetScale(.0001)
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
		"Background",
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
		"ScrollUpBorder",
		"ScrollDownBorder",
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
							region:SetAtlas("")
						end
					else
						region:SetTexture("")
						region:SetAtlas("")
					end
				end
			end
		end
	end
end

-- UI widgets
do
	-- HelpTip
	function B:HelpInfoAcknowledge()
		self.__owner:Hide()
		NDuiADB["Help"][self.__arg] = true
		if self.__callback then self.__callback() end
	end

	local helpTipTable = {}
	local pointInfo = {
		["TOP"] = {relF = "BOTTOM", degree = 0, arrowX = 0, arrowY = -5, glowX = 0, glowY = -4},
		["BOTTOM"] = {relF = "TOP", degree = 180, arrowX = 0, arrowY = 5, glowX = 0, glowY = 4},
		["LEFT"] = {relF = "RIGHT", degree = 90, arrowX = 5, arrowY = 0, glowX = 4, glowY = 0},
		["RIGHT"] = {relF = "LEFT", degree = 270, arrowX = -5, arrowY = 0, glowX = -4, glowY = 0},
	}

	function B:ShowHelpTip(parent, text, targetPoint, offsetX, offsetY, callback, callbackArg, arrowX, arrowY)
		local info = helpTipTable[callbackArg]
		if not info then
			local anchorInfo = pointInfo[targetPoint]
			info = CreateFrame("Frame", nil, parent, "MicroButtonAlertTemplate")
			info:SetPoint(anchorInfo.relF, parent, targetPoint, offsetX or 0, offsetY or 0)
			info.Text:SetText(text.."|n|n|n")
			info.CloseButton:Hide()
			info.okay = B.CreateButton(info, 110, 22, L["GotIt"], 14)
			info.okay:SetPoint("BOTTOM", 0, 12)
			info.okay.__owner = info
			info.okay.__arg = callbackArg
			info.okay.__callback = callback
			info.okay:SetScript("OnClick", B.HelpInfoAcknowledge)

			info.Arrow:ClearAllPoints()
			info.Arrow:SetPoint("CENTER", info, anchorInfo.relF, arrowX or anchorInfo.arrowX, arrowY or anchorInfo.arrowY)

			info.Arrow.Glow:ClearAllPoints()
			info.Arrow.Glow:SetPoint("CENTER", info.Arrow.Arrow, "CENTER", anchorInfo.glowX, anchorInfo.glowY)
			info.Arrow.Glow:SetRotation(rad(anchorInfo.degree))
			info.Arrow.Arrow:SetRotation(rad(anchorInfo.degree))

			helpTipTable[callbackArg] = info
		end
		info:Show()
	end

	function B:HideHelpTip(callbackArg)
		local info = helpTipTable[callbackArg]
		if info then
			info:Hide()
		end
	end

	-- Dropdown menu
	B.EasyMenu = CreateFrame("Frame", "NDui_EasyMenu", UIParent, "UIDropDownMenuTemplate")

	-- Fontstring
	function B:CreateFS(size, text, color, anchor, x, y)
		local fs = self:CreateFontString(nil, "OVERLAY")
		fs:SetFont(DB.Font[1], size, DB.Font[3])
		fs:SetText(text)
		fs:SetWordWrap(false)
		if color and type(color) == "boolean" then
			fs:SetTextColor(cr, cg, cb)
		elseif color == "system" then
			fs:SetTextColor(1, .8, 0)
		end
		if anchor and x and y then
			fs:SetPoint(anchor, x, y)
		else
			fs:SetPoint("CENTER", 1, 0)
		end

		return fs
	end

	-- Gametooltip
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
	function B:AddTooltip(anchor, text, color, showTips)
		self.anchor = anchor
		self.text = text
		self.color = color
		if showTips then self.title = L["Tips"] end
		self:SetScript("OnEnter", Tooltip_OnEnter)
		self:SetScript("OnLeave", B.HideTooltip)
	end

	-- Glow parent
	function B:CreateGlowFrame(size)
		local frame = CreateFrame("Frame", nil, self)
		frame:SetPoint("CENTER")
		frame:SetSize(size+8, size+8)

		return frame
	end

	-- Gradient texture
	local orientationAbbr = {
		["V"] = "Vertical",
		["H"] = "Horizontal",
	}
	function B:SetGradient(orientation, r, g, b, a1, a2, width, height)
		orientation = orientationAbbr[orientation]
		if not orientation then return end

		local tex = self:CreateTexture(nil, "BACKGROUND")
		tex:SetTexture(DB.bdTex)
		tex:SetGradientAlpha(orientation, r, g, b, a1, r, g, b, a2)
		if width then tex:SetWidth(width) end
		if height then tex:SetHeight(height) end

		return tex
	end

	-- Background texture
	function B:CreateTex()
		if not C.db["Skins"]["BgTex"] then return end
		if self.__bgTex then return end

		local frame = self
		if self:IsObjectType("Texture") then frame = self:GetParent() end

		local tex = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
		tex:SetAllPoints(self)
		tex:SetTexture(DB.bgTex, true, true)
		tex:SetHorizTile(true)
		tex:SetVertTile(true)
		tex:SetBlendMode("ADD")

		self.__bgTex = tex
	end

	-- Backdrop shadow
	local shadowBackdrop = {edgeFile = DB.glowTex}

	function B:CreateSD(size, override)
		if not override and not C.db["Skins"]["Shadow"] then return end
		if self.__shadow then return end

		local frame = self
		if self:IsObjectType("Texture") then frame = self:GetParent() end

		shadowBackdrop.edgeSize = size or 5
		self.__shadow = CreateFrame("Frame", nil, frame, "BackdropTemplate")
		self.__shadow:SetOutside(self, size or 4, size or 4)
		self.__shadow:SetBackdrop(shadowBackdrop)
		self.__shadow:SetBackdropBorderColor(0, 0, 0, size and 1 or .4)
		self.__shadow:SetFrameLevel(1)

		return self.__shadow
	end
end

-- UI skins
do
	-- Setup backdrop
	C.frames = {}
	local defaultBackdrop = {bgFile = DB.bdTex, edgeFile = DB.bdTex}

	function B:SetBorderColor()
		if C.db["Skins"]["GreyBD"] then
			self:SetBackdropBorderColor(1, 1, 1, .2)
		else
			self:SetBackdropBorderColor(0, 0, 0)
		end
	end

	function B:CreateBD(a)
		defaultBackdrop.edgeSize = C.mult
		self:SetBackdrop(defaultBackdrop)
		self:SetBackdropColor(0, 0, 0, a or C.db["Skins"]["SkinAlpha"])
		B.SetBorderColor(self)
		if not a then tinsert(C.frames, self) end
	end

	function B:CreateGradient()
		local tex = self:CreateTexture(nil, "BORDER")
		tex:SetInside()
		tex:SetTexture(DB.bdTex)
		if C.db["Skins"]["FlatMode"] then
			tex:SetVertexColor(.3, .3, .3, .25)
		else
			tex:SetGradientAlpha("Vertical", 0, 0, 0, .5, .3, .3, .3, .3)
		end

		return tex
	end

	-- Handle frame
	function B:CreateBDFrame(a, gradient)
		local frame = self
		if self:IsObjectType("Texture") then frame = self:GetParent() end
		local lvl = frame:GetFrameLevel()

		local bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
		bg:SetOutside(self)
		bg:SetFrameLevel(lvl == 0 and 0 or lvl - 1)
		B.CreateBD(bg, a)
		if gradient then
			self.__gradient = B.CreateGradient(bg)
		end

		return bg
	end

	function B:SetBD(a, x, y, x2, y2)
		local bg = B.CreateBDFrame(self, a)
		if x then
			bg:SetPoint("TOPLEFT", self, x, y)
			bg:SetPoint("BOTTOMRIGHT", self, x2, y2)
		end
		B.CreateSD(bg)
		B.CreateTex(bg)

		return bg
	end

	-- Handle icons
	function B:ReskinIcon(shadow)
		self:SetTexCoord(unpack(DB.TexCoord))
		local bg = B.CreateBDFrame(self, .25) -- exclude from opacity control
		if shadow then B.CreateSD(bg) end
		return bg
	end

	function B:PixelIcon(texture, highlight)
		self.bg = B.CreateBDFrame(self)
		self.bg:SetAllPoints()
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
		self.CD:SetInside()
		self.CD:SetReverse(true)
		B.PixelIcon(self, nil, highlight)
		B.CreateSD(self)
	end

	function B:CreateGear(name)
		local bu = CreateFrame("Button", name, self)
		bu:SetSize(24, 24)
		bu.Icon = bu:CreateTexture(nil, "ARTWORK")
		bu.Icon:SetAllPoints()
		bu.Icon:SetTexture(DB.gearTex)
		bu.Icon:SetTexCoord(0, .5, 0, .5)
		bu:SetHighlightTexture(DB.gearTex)
		bu:GetHighlightTexture():SetTexCoord(0, .5, 0, .5)

		return bu
	end

	function B:CreateHelpInfo(tooltip)
		local bu = CreateFrame("Button", nil, self)
		bu:SetSize(40, 40)
		bu.Icon = bu:CreateTexture(nil, "ARTWORK")
		bu.Icon:SetAllPoints()
		bu.Icon:SetTexture(616343)
		bu:SetHighlightTexture(616343)
		if tooltip then
			B.AddTooltip(bu, "ANCHOR_BOTTOMLEFT", tooltip, "info", true)
		end

		return bu
	end

	function B:CreateWatermark()
		local logo = self:CreateTexture(nil, "BACKGROUND")
		logo:SetPoint("BOTTOMRIGHT", 10, 0)
		logo:SetTexture(DB.logoTex)
		logo:SetTexCoord(0, 1, 0, .75)
		logo:SetSize(200, 75)
		logo:SetAlpha(.3)
	end

	local AtlasToQuality = {
		["auctionhouse-itemicon-border-gray"] = LE_ITEM_QUALITY_POOR,
		["auctionhouse-itemicon-border-white"] = LE_ITEM_QUALITY_COMMON,
		["auctionhouse-itemicon-border-green"] = LE_ITEM_QUALITY_UNCOMMON,
		["auctionhouse-itemicon-border-blue"] = LE_ITEM_QUALITY_RARE,
		["auctionhouse-itemicon-border-purple"] = LE_ITEM_QUALITY_EPIC,
		["auctionhouse-itemicon-border-orange"] = LE_ITEM_QUALITY_LEGENDARY,
		["auctionhouse-itemicon-border-artifact"] = LE_ITEM_QUALITY_ARTIFACT,
		["auctionhouse-itemicon-border-account"] = LE_ITEM_QUALITY_HEIRLOOM,
	}
	local function updateIconBorderColorByAtlas(self, atlas)
		local quality = AtlasToQuality[atlas]
		local color = DB.QualityColors[quality or 1]
		self.__owner.bg:SetBackdropBorderColor(color.r, color.g, color.b)
	end
	local function updateIconBorderColor(self, r, g, b)
		if not r or (r==.65882 and g==.65882 and b==.65882) or (r>.99 and g>.99 and b>.99) then
			r, g, b = 0, 0, 0
		end
		self.__owner.bg:SetBackdropBorderColor(r, g, b)
	end
	local function resetIconBorderColor(self)
		self.__owner.bg:SetBackdropBorderColor(0, 0, 0)
	end
	function B:ReskinIconBorder(needInit)
		self:SetAlpha(0)
		self.__owner = self:GetParent()
		if not self.__owner.bg then return end
		if self.__owner.useCircularIconBorder then -- for auction item display
			hooksecurefunc(self, "SetAtlas", updateIconBorderColorByAtlas)
		else
			hooksecurefunc(self, "SetVertexColor", updateIconBorderColor)
			if needInit then
				self:SetVertexColor(self:GetVertexColor()) -- for border with color before hook
			end
		end
		hooksecurefunc(self, "Hide", resetIconBorderColor)
	end

	local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
	function B:ClassIconTexCoord(class)
		local tcoords = CLASS_ICON_TCOORDS[class]
		self:SetTexCoord(tcoords[1] + .022, tcoords[2] - .025, tcoords[3] + .022, tcoords[4] - .025)
	end

	-- Handle statusbar
	function B:CreateSB(spark, r, g, b)
		self:SetStatusBarTexture(DB.normTex)
		if r and g and b then
			self:SetStatusBarColor(r, g, b)
		else
			self:SetStatusBarColor(cr, cg, cb)
		end

		local bg = B.SetBD(self)
		self.__shadow = bg.__shadow

		if spark then
			self.Spark = self:CreateTexture(nil, "OVERLAY")
			self.Spark:SetTexture(DB.sparkTex)
			self.Spark:SetBlendMode("ADD")
			self.Spark:SetAlpha(.8)
			self.Spark:SetPoint("TOPLEFT", self:GetStatusBarTexture(), "TOPRIGHT", -10, 10)
			self.Spark:SetPoint("BOTTOMRIGHT", self:GetStatusBarTexture(), "BOTTOMRIGHT", 10, -10)
		end
	end

	function B:CreateAndUpdateBarTicks(bar, ticks, numTicks)
		for i = 1, #ticks do
			ticks[i]:Hide()
		end

		if numTicks and numTicks > 0 then
			local width, height = bar:GetSize()
			local delta = width / numTicks
			for i = 1, numTicks-1 do
				if not ticks[i] then
					ticks[i] = bar:CreateTexture(nil, "OVERLAY")
					ticks[i]:SetTexture(DB.normTex)
					ticks[i]:SetVertexColor(0, 0, 0, .7)
					ticks[i]:SetWidth(C.mult)
					ticks[i]:SetHeight(height)
				end
				ticks[i]:ClearAllPoints()
				ticks[i]:SetPoint("RIGHT", bar, "LEFT", delta * i, 0 )
				ticks[i]:Show()
			end
		end
	end

	-- Handle button
	local function Button_OnEnter(self)
		if not self:IsEnabled() then return end

		if C.db["Skins"]["FlatMode"] then
			self.__gradient:SetVertexColor(cr / 4, cg / 4, cb / 4)
		else
			self.__bg:SetBackdropColor(cr, cg, cb, .25)
		end
		self.__bg:SetBackdropBorderColor(cr, cg, cb)
	end
	local function Button_OnLeave(self)
		if C.db["Skins"]["FlatMode"] then
			self.__gradient:SetVertexColor(.3, .3, .3, .25)
		else
			self.__bg:SetBackdropColor(0, 0, 0, 0)
		end
		B.SetBorderColor(self.__bg)
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
		"Center",
	}
	function B:Reskin(noHighlight, override)
		if self.SetNormalTexture and not override then self:SetNormalTexture("") end
		if self.SetHighlightTexture then self:SetHighlightTexture("") end
		if self.SetPushedTexture then self:SetPushedTexture("") end
		if self.SetDisabledTexture then self:SetDisabledTexture("") end

		local buttonName = self.GetName and self:GetName()
		for _, region in pairs(blizzRegions) do
			region = buttonName and _G[buttonName..region] or self[region]
			if region then
				region:SetAlpha(0)
				region:Hide()
			end
		end

		self.__bg = B.CreateBDFrame(self, 0, true)
		self.__bg:SetFrameLevel(self:GetFrameLevel())
		self.__bg:SetAllPoints()

		if not noHighlight then
			self:HookScript("OnEnter", Button_OnEnter)
			self:HookScript("OnLeave", Button_OnLeave)
		end
	end

	local function Menu_OnEnter(self)
		self.bg:SetBackdropBorderColor(cr, cg, cb)
	end
	local function Menu_OnLeave(self)
		B.SetBorderColor(self.bg)
	end
	local function Menu_OnMouseUp(self)
		self.bg:SetBackdropColor(0, 0, 0, C.db["Skins"]["SkinAlpha"])
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

	-- Handle tabs
	function B:ReskinTab()
		self:DisableDrawLayer("BACKGROUND")

		local bg = B.CreateBDFrame(self)
		bg:SetPoint("TOPLEFT", 8, -3)
		bg:SetPoint("BOTTOMRIGHT", -8, 0)
		self.bg = bg

		self:SetHighlightTexture(DB.bdTex)
		local hl = self:GetHighlightTexture()
		hl:ClearAllPoints()
		hl:SetInside(bg)
		hl:SetVertexColor(cr, cg, cb, .25)

		return bg
	end

	function B:ResetTabAnchor()
		local text = self.Text or (self.GetName and _G[self:GetName().."Text"])
		if text then
			text:SetPoint("CENTER", self)
		end
	end
	hooksecurefunc("PanelTemplates_SelectTab", B.ResetTabAnchor)
	hooksecurefunc("PanelTemplates_DeselectTab", B.ResetTabAnchor)

	-- Handle scrollframe
	local function GrabScrollBarElement(frame, element)
		local frameName = frame:GetDebugName()
		return frame[element] or frameName and (_G[frameName..element] or strfind(frameName, element)) or nil
	end

	function B:ReskinScroll()
		B.StripTextures(self:GetParent())
		B.StripTextures(self)

		local thumb = GrabScrollBarElement(self, "ThumbTexture") or GrabScrollBarElement(self, "thumbTexture") or self.GetThumbTexture and self:GetThumbTexture()
		if thumb then
			thumb:SetAlpha(0)
			thumb:SetWidth(16)
			local bg = B.CreateBDFrame(self, 0, true)
			bg:SetPoint("TOPLEFT", thumb, 0, -2)
			bg:SetPoint("BOTTOMRIGHT", thumb, 0, 4)
			bg:SetBackdropColor(cr, cg, cb, .75)
		end

		local up, down = self:GetChildren()
		B.ReskinArrow(up, "up")
		B.ReskinArrow(down, "down")
	end

	-- WowTrimScrollBar
	local function updateTrimScrollArrow(self, atlas)
		local arrow = self.__owner
		if not arrow.__texture then return end
	
		if atlas == arrow.disabledTexture then
			arrow.__texture:SetVertexColor(.5, .5, .5)
		else
			arrow.__texture:SetVertexColor(1, 1, 1)
		end
	end

	local function reskinTrimScrollArrow(self, direction)
		if not self then return end

		self.Texture:SetAlpha(0)
		self.Overlay:SetAlpha(0)
		local tex = self:CreateTexture(nil, "ARTWORK")
		tex:SetAllPoints()
		B.CreateBDFrame(tex, .25)
		B.SetupArrow(tex, direction)
		self.__texture = tex
	
		self:HookScript("OnEnter", B.Texture_OnEnter)
		self:HookScript("OnLeave", B.Texture_OnLeave)
		self.Texture.__owner = self
		hooksecurefunc(self.Texture, "SetAtlas", updateTrimScrollArrow)
		self.Texture:SetAtlas(self.Texture:GetAtlas())
	end

	function B:ReskinTrimScroll()
		B.StripTextures(self)
		reskinTrimScrollArrow(self.Back, "up")
		reskinTrimScrollArrow(self.Forward, "down")

		local thumb = self:GetThumb()
		if thumb then
			B.StripTextures(thumb, 0)
			B.CreateBDFrame(thumb, 0, true):SetBackdropColor(cr, cg, cb, .75)
		end
	end

	-- Handle dropdown
	function B:ReskinDropDown()
		B.StripTextures(self)

		local frameName = self.GetName and self:GetName()
		local down = self.Button or frameName and (_G[frameName.."Button"] or _G[frameName.."_Button"])

		local bg = B.CreateBDFrame(self, 0, true)
		bg:SetPoint("TOPLEFT", 16, -4)
		bg:SetPoint("BOTTOMRIGHT", -18, 8)

		down:ClearAllPoints()
		down:SetPoint("RIGHT", bg, -2, 0)
		B.ReskinArrow(down, "down")
	end

	-- Handle close button
	function B:Texture_OnEnter()
		if self:IsEnabled() then
			if self.bg then
				self.bg:SetBackdropColor(cr, cg, cb, .25)
			else
				self.__texture:SetVertexColor(cr, cg, cb)
			end
		end
	end

	function B:Texture_OnLeave()
		if self.bg then
			self.bg:SetBackdropColor(0, 0, 0, .25)
		else
			self.__texture:SetVertexColor(1, 1, 1)
		end
	end

	function B:ReskinClose(parent, xOffset, yOffset)
		parent = parent or self:GetParent()
		xOffset = xOffset or -6
		yOffset = yOffset or -6

		self:SetSize(16, 16)
		self:ClearAllPoints()
		self:SetPoint("TOPRIGHT", parent, "TOPRIGHT", xOffset, yOffset)

		B.StripTextures(self)
		local bg = B.CreateBDFrame(self, 0, true)
		bg:SetAllPoints()

		self:SetDisabledTexture(DB.bdTex)
		local dis = self:GetDisabledTexture()
		dis:SetVertexColor(0, 0, 0, .4)
		dis:SetDrawLayer("OVERLAY")
		dis:SetAllPoints()

		local tex = self:CreateTexture()
		tex:SetTexture(DB.closeTex)
		tex:SetAllPoints()
		self.__texture = tex

		self:HookScript("OnEnter", B.Texture_OnEnter)
		self:HookScript("OnLeave", B.Texture_OnLeave)
	end

	-- Handle editbox
	function B:ReskinEditBox(height, width)
		local frameName = self.GetName and self:GetName()
		for _, region in pairs(blizzRegions) do
			region = frameName and _G[frameName..region] or self[region]
			if region then
				region:SetAlpha(0)
			end
		end

		local bg = B.CreateBDFrame(self, 0, true)
		bg:SetPoint("TOPLEFT", -2, 0)
		bg:SetPoint("BOTTOMRIGHT")
		self.bg = bg

		if height then self:SetHeight(height) end
		if width then self:SetWidth(width) end
	end
	B.ReskinInput = B.ReskinEditBox -- Deprecated

	-- Handle arrows
	local arrowDegree = {
		["up"] = 0,
		["down"] = 180,
		["left"] = 90,
		["right"] = -90,
	}
	function B:SetupArrow(direction)
		self:SetTexture(DB.ArrowUp)
		self:SetRotation(rad(arrowDegree[direction]))
	end

	function B:ReskinArrow(direction)
		self:SetSize(16, 16)
		B.Reskin(self, true)

		self:SetDisabledTexture(DB.bdTex)
		local dis = self:GetDisabledTexture()
		dis:SetVertexColor(0, 0, 0, .3)
		dis:SetDrawLayer("OVERLAY")
		dis:SetAllPoints()

		local tex = self:CreateTexture(nil, "ARTWORK")
		tex:SetAllPoints()
		B.SetupArrow(tex, direction)
		self.__texture = tex

		self:HookScript("OnEnter", B.Texture_OnEnter)
		self:HookScript("OnLeave", B.Texture_OnLeave)
	end

	function B:ReskinFilterButton()
		B.StripTextures(self)
		B.Reskin(self)
		self.Text:SetPoint("CENTER")
		B.SetupArrow(self.Icon, "right")
		self.Icon:SetPoint("RIGHT")
		self.Icon:SetSize(14, 14)
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
		B.SetupArrow(tex, "left")
		tex:SetSize(14, 14)
		tex:SetPoint("CENTER")
		overflowButton.__texture = tex

		overflowButton:HookScript("OnEnter", B.Texture_OnEnter)
		overflowButton:HookScript("OnLeave", B.Texture_OnLeave)

		self.navBarStyled = true
	end

	-- Handle checkbox and radio
	function B:ReskinCheck(forceSaturation)
		self:SetNormalTexture("")
		self:SetPushedTexture("")

		local bg = B.CreateBDFrame(self, 0, true)
		bg:SetInside(self, 4, 4)
		self.bg = bg

		self:SetHighlightTexture(DB.bdTex)
		local hl = self:GetHighlightTexture()
		hl:SetInside(bg)
		hl:SetVertexColor(cr, cg, cb, .25)

		local ch = self:GetCheckedTexture()
		ch:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
		ch:SetTexCoord(0, 1, 0, 1)
		ch:SetDesaturated(true)
		ch:SetVertexColor(cr, cg, cb)

		self.forceSaturation = forceSaturation
	end

	function B:ReskinRadio()
		self:SetNormalTexture("")
		self:SetHighlightTexture("")
		self:SetCheckedTexture(DB.bdTex)

		local ch = self:GetCheckedTexture()
		ch:SetInside(self, 4, 4)
		ch:SetVertexColor(cr, cg, cb, .6)

		local bg = B.CreateBDFrame(self, 0, true)
		bg:SetInside(self, 3, 3)
		self.bg = bg

		self:HookScript("OnEnter", Menu_OnEnter)
		self:HookScript("OnLeave", Menu_OnLeave)
	end

	-- Color swatch
	function B:ReskinColorSwatch()
		local frameName = self.GetName and self:GetName()
		local swatchBg = frameName and _G[frameName.."SwatchBg"]
		if swatchBg then
			swatchBg:SetColorTexture(0, 0, 0)
			swatchBg:SetInside(nil, 2, 2)
		end

		self:SetNormalTexture(DB.bdTex)
		self:GetNormalTexture():SetInside(self, 3, 3)
	end

	-- Handle slider
	function B:ReskinSlider(vertical)
		self:SetBackdrop(nil)
		B.StripTextures(self)

		local bg = B.CreateBDFrame(self, 0, true)
		bg:SetPoint("TOPLEFT", 14, -2)
		bg:SetPoint("BOTTOMRIGHT", -15, 3)

		local thumb = self:GetThumbTexture()
		thumb:SetTexture(DB.sparkTex)
		thumb:SetBlendMode("ADD")
		if vertical then thumb:SetRotation(rad(90)) end

		local bar = CreateFrame("StatusBar", nil, bg)
		bar:SetStatusBarTexture(DB.normTex)
		bar:SetStatusBarColor(1, .8, 0, .5)
		if vertical then
			bar:SetPoint("BOTTOMLEFT", bg, C.mult, C.mult)
			bar:SetPoint("BOTTOMRIGHT", bg, -C.mult, C.mult)
			bar:SetPoint("TOP", thumb, "CENTER")
			bar:SetOrientation("VERTICAL")
		else
			bar:SetPoint("TOPLEFT", bg, C.mult, -C.mult)
			bar:SetPoint("BOTTOMLEFT", bg, C.mult, C.mult)
			bar:SetPoint("RIGHT", thumb, "CENTER")
		end
	end

	-- Handle collapse
	local function updateCollapseTexture(texture, collapsed)
		if collapsed then
			texture:SetTexCoord(0, .4375, 0, .4375)
		else
			texture:SetTexCoord(.5625, 1, 0, .4375)
		end
	end

	local function resetCollapseTexture(self, texture)
		if self.settingTexture then return end
		self.settingTexture = true
		self:SetNormalTexture("")

		if texture and texture ~= "" then
			if strfind(texture, "Plus") or strfind(texture, "Closed") then
				self.__texture:DoCollapse(true)
			elseif strfind(texture, "Minus") or strfind(texture, "Open") then
				self.__texture:DoCollapse(false)
			end
			self.bg:Show()
		else
			self.bg:Hide()
		end
		self.settingTexture = nil
	end

	function B:ReskinCollapse(isAtlas)
		self:SetHighlightTexture("")
		self:SetPushedTexture("")
		self:SetDisabledTexture("")

		local bg = B.CreateBDFrame(self, .25, true)
		bg:ClearAllPoints()
		bg:SetSize(13, 13)
		bg:SetPoint("TOPLEFT", self:GetNormalTexture())
		self.bg = bg

		self.__texture = bg:CreateTexture(nil, "OVERLAY")
		self.__texture:SetPoint("CENTER")
		self.__texture:SetSize(7, 7)
		self.__texture:SetTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
		self.__texture.DoCollapse = updateCollapseTexture

		self:HookScript("OnEnter", B.Texture_OnEnter)
		self:HookScript("OnLeave", B.Texture_OnLeave)
		if isAtlas then
			hooksecurefunc(self, "SetNormalAtlas", resetCollapseTexture)
		else
			hooksecurefunc(self, "SetNormalTexture", resetCollapseTexture)
		end
	end

	local buttonNames = {"MaximizeButton", "MinimizeButton"}
	function B:ReskinMinMax()
		for _, name in next, buttonNames do
			local button = self[name]
			if button then
				button:SetSize(16, 16)
				button:ClearAllPoints()
				button:SetPoint("CENTER", -3, 0)
				B.Reskin(button)

				local tex = button:CreateTexture()
				tex:SetAllPoints()
				if name == "MaximizeButton" then
					B.SetupArrow(tex, "up")
				else
					B.SetupArrow(tex, "down")
				end
				button.__texture = tex

				button:SetScript("OnEnter", B.Texture_OnEnter)
				button:SetScript("OnLeave", B.Texture_OnLeave)
			end
		end
	end

	-- UI templates
	function B:ReskinPortraitFrame(x, y, x2, y2)
		B.StripTextures(self)
		local bg = B.SetBD(self, nil, x, y, x2, y2)
		local frameName = self.GetName and self:GetName()
		local portrait = self.PortraitTexture or self.portrait or (frameName and _G[frameName.."Portrait"])
		if portrait then
			portrait:SetAlpha(0)
		end
		local closeButton = self.CloseButton or (frameName and _G[frameName.."CloseButton"])
		if closeButton then
			B.ReskinClose(closeButton)
			closeButton:ClearAllPoints()
			closeButton:SetPoint("TOPRIGHT", bg, -5, -5)
		end
		return bg
	end

	local ReplacedRoleTex = {
		["Adventures-Tank"] = "Soulbinds_Tree_Conduit_Icon_Protect",
		["Adventures-Healer"] = "ui_adv_health",
		["Adventures-DPS"] = "ui_adv_atk",
		["Adventures-DPS-Ranged"] = "Soulbinds_Tree_Conduit_Icon_Utility",
	}
	local function replaceFollowerRole(roleIcon, atlas)
		local newAtlas = ReplacedRoleTex[atlas]
		if newAtlas then
			roleIcon:SetAtlas(newAtlas)
		end
	end

	function B:ReskinGarrisonPortrait()
		local level = self.Level or self.LevelText
		if level then
			level:ClearAllPoints()
			level:SetPoint("BOTTOM", self, 0, 15)
			if self.LevelCircle then self.LevelCircle:Hide() end
			if self.LevelBorder then self.LevelBorder:SetScale(.0001) end
		end

		self.squareBG = B.CreateBDFrame(self.Portrait, 1)

		if self.PortraitRing then
			self.PortraitRing:Hide()
			self.PortraitRingQuality:SetTexture("")
			self.PortraitRingCover:SetColorTexture(0, 0, 0)
			self.PortraitRingCover:SetAllPoints(self.squareBG)
		end

		if self.Empty then
			self.Empty:SetColorTexture(0, 0, 0)
			self.Empty:SetAllPoints(self.Portrait)
		end
		if self.Highlight then self.Highlight:Hide() end
		if self.PuckBorder then self.PuckBorder:SetAlpha(0) end
		if self.TroopStackBorder1 then self.TroopStackBorder1:SetAlpha(0) end
		if self.TroopStackBorder2 then self.TroopStackBorder2:SetAlpha(0) end

		if self.HealthBar then
			self.HealthBar.Border:Hide()

			local roleIcon = self.HealthBar.RoleIcon
			roleIcon:ClearAllPoints()
			roleIcon:SetPoint("CENTER", self.squareBG, "TOPRIGHT")
			replaceFollowerRole(roleIcon, roleIcon:GetAtlas())
			hooksecurefunc(roleIcon, "SetAtlas", replaceFollowerRole)

			local background = self.HealthBar.Background
			background:SetAlpha(0)
			background:ClearAllPoints()
			background:SetPoint("TOPLEFT", self.squareBG, "BOTTOMLEFT", C.mult, 6)
			background:SetPoint("BOTTOMRIGHT", self.squareBG, "BOTTOMRIGHT", -C.mult, C.mult)
			self.HealthBar.Health:SetTexture(DB.normTex)
		end
	end

	function B:StyleSearchButton()
		B.StripTextures(self)
		if self.icon then B.ReskinIcon(self.icon) end
		B.CreateBDFrame(self, .25)

		self:SetHighlightTexture(DB.bdTex)
		local hl = self:GetHighlightTexture()
		hl:SetVertexColor(cr, cg, cb, .25)
		hl:SetInside()
	end

	local function reskinRotation(self, direction)
		self:SetSize(20, 20)
		B.Reskin(self)
		local tex = self:CreateTexture(nil, "ARTWORK")
		tex:SetAllPoints()
		tex:SetTexture("Interface\\Buttons\\UI-RefreshButton")
		if direction == "left" then
			tex:SetTexCoord(1, 0, 0, 1)
		else
			tex:SetTexCoord(0, 1, 0, 1)
		end
	end

	function B:ReskinRotationButtons()
		local name = self.GetName and self:GetName() or self
		local leftButton = _G[name.."RotateRightButton"]
		reskinRotation(leftButton, "left")
		local rightButton = _G[name.."RotateLeftButton"]
		reskinRotation(rightButton, "right")

		leftButton:SetPoint("TOPLEFT", 5, -5)
		rightButton:ClearAllPoints()
		rightButton:SetPoint("LEFT", leftButton, "RIGHT", 3, 0)
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

	-- Role Icons
	function B:GetRoleTexCoord()
		if self == "TANK" then
			return .34/9.03, 2.86/9.03, 3.16/9.03, 5.68/9.03
		elseif self == "DPS" or self == "DAMAGER" then
			return 3.26/9.03, 5.78/9.03, 3.16/9.03, 5.68/9.03
		elseif self == "HEALER" then
			return 3.26/9.03, 5.78/9.03, .28/9.03, 2.78/9.03
		elseif self == "LEADER" then
			return .34/9.03, 2.86/9.03, .28/9.03, 2.78/9.03
		elseif self == "READY" then
			return 6.17/9.03, 8.75/9.03, .28/9.03, 2.78/9.03
		elseif self == "PENDING" then
			return 6.17/9.03, 8.75/9.03, 3.16/9.03, 5.68/9.03
		elseif self == "REFUSE" then
			return 3.26/9.03, 5.78/9.03, 6.03/9.03, 8.61/9.03
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
end

-- GUI elements
do
	function B:CreateButton(width, height, text, fontSize)
		local bu = CreateFrame("Button", nil, self, "BackdropTemplate")
		bu:SetSize(width, height)
		if type(text) == "boolean" then
			B.PixelIcon(bu, fontSize, true)
		else
			B.Reskin(bu)
			bu.text = B.CreateFS(bu, fontSize or 14, text, true)
		end

		return bu
	end

	function B:CreateCheckBox()
		local cb = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
		cb:SetScript("OnClick", nil) -- reset onclick handler
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
		eb.bg = B.CreateBDFrame(eb, 0, true)
		eb.bg:SetAllPoints()
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
		B:TogglePanel(self.__list)
	end

	function B:CreateDropDown(width, height, data)
		local dd = CreateFrame("Frame", nil, self, "BackdropTemplate")
		dd:SetSize(width, height)
		B.CreateBD(dd)
		dd:SetBackdropBorderColor(1, 1, 1, .2)
		dd.Text = B.CreateFS(dd, 14, "", false, "LEFT", 5, 0)
		dd.Text:SetPoint("RIGHT", -5, 0)
		dd.options = {}

		local bu = CreateFrame("Button", nil, dd)
		bu:SetPoint("RIGHT", -5, 0)
		B.ReskinArrow(bu, "down")
		bu:SetSize(18, 18)
		local list = CreateFrame("Frame", nil, dd, "BackdropTemplate")
		list:SetPoint("TOP", dd, "BOTTOM", 0, -2)
		RaiseFrameLevel(list)
		B.CreateBD(list, 1)
		list:SetBackdropBorderColor(1, 1, 1, .2)
		list:Hide()
		bu.__list = list
		bu:SetScript("OnShow", buttonOnShow)
		bu:SetScript("OnClick", buttonOnClick)
		dd.button = bu

		local opt, index = {}, 0
		for i, j in pairs(data) do
			opt[i] = CreateFrame("Button", nil, list, "BackdropTemplate")
			opt[i]:SetPoint("TOPLEFT", 4, -4 - (i-1)*(height+2))
			opt[i]:SetSize(width - 8, height)
			B.CreateBD(opt[i])
			local text = B.CreateFS(opt[i], 14, j, false, "LEFT", 5, 0)
			text:SetPoint("RIGHT", -5, 0)
			opt[i].text = j
			opt[i].index = i
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
		r = B:Round(r, 2)
		g = B:Round(g, 2)
		b = B:Round(b, 2)
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

	local function GetSwatchTexColor(tex)
		local r, g, b = tex:GetVertexColor()
		r = B:Round(r, 2)
		g = B:Round(g, 2)
		b = B:Round(b, 2)
		return r, g, b
	end

	local function resetColorPicker(swatch)
		local defaultColor = swatch.__default
		if defaultColor then
			ColorPickerFrame:SetColorRGB(defaultColor.r, defaultColor.g, defaultColor.b)
		end
	end

	local whiteColor = {r=1, g=1, b=1}
	function B:CreateColorSwatch(name, color)
		color = color or whiteColor

		local swatch = CreateFrame("Button", nil, self, "BackdropTemplate")
		swatch:SetSize(18, 18)
		B.CreateBD(swatch, 1)
		swatch.text = B.CreateFS(swatch, 14, name, false, "LEFT", 26, 0)
		local tex = swatch:CreateTexture()
		tex:SetInside()
		tex:SetTexture(DB.bdTex)
		tex:SetVertexColor(color.r, color.g, color.b)
		tex.GetColor = GetSwatchTexColor

		swatch.tex = tex
		swatch.color = color
		swatch:SetScript("OnClick", openColorPicker)
		swatch:SetScript("OnDoubleClick", resetColorPicker)

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

	local function resetSliderValue(self)
		local slider = self.__owner
		if slider.__default then
			slider:SetValue(slider.__default)
		end
	end

	function B:CreateSlider(name, minValue, maxValue, step, x, y, width)
		local slider = CreateFrame("Slider", nil, self, "OptionsSliderTemplate")
		slider:SetPoint("TOPLEFT", x, y)
		slider:SetWidth(width or 200)
		slider:SetMinMaxValues(minValue, maxValue)
		slider:SetValueStep(step)
		slider:SetObeyStepOnDrag(true)
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

		slider.clicker = CreateFrame("Button", nil, slider)
		slider.clicker:SetAllPoints(slider.Text)
		slider.clicker.__owner = slider
		slider.clicker:SetScript("OnDoubleClick", resetSliderValue)

		return slider
	end

	function B:TogglePanel(frame)
		if frame:IsShown() then
			frame:Hide()
		else
			frame:Show()
		end
	end
end

-- Add API
do
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

	local function SetInside(frame, anchor, xOffset, yOffset, anchor2)
		xOffset = xOffset or C.mult
		yOffset = yOffset or C.mult
		anchor = anchor or frame:GetParent()

		DisablePixelSnap(frame)
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
		frame:SetPoint("BOTTOMRIGHT", anchor2 or anchor, "BOTTOMRIGHT", -xOffset, yOffset)
	end

	local function SetOutside(frame, anchor, xOffset, yOffset, anchor2)
		xOffset = xOffset or C.mult
		yOffset = yOffset or C.mult
		anchor = anchor or frame:GetParent()

		DisablePixelSnap(frame)
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", -xOffset, yOffset)
		frame:SetPoint("BOTTOMRIGHT", anchor2 or anchor, "BOTTOMRIGHT", xOffset, -yOffset)
	end

	local function HideBackdrop(frame)
		if frame.NineSlice then frame.NineSlice:SetAlpha(0) end
		if frame.SetBackdrop then frame:SetBackdrop(nil) end
	end

	local function addapi(object)
		local mt = getmetatable(object).__index
		if not object.SetInside then mt.SetInside = SetInside end
		if not object.SetOutside then mt.SetOutside = SetOutside end
		if not object.HideBackdrop then mt.HideBackdrop = HideBackdrop end
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
		local objectType = object.GetObjectType and object:GetObjectType()
		if objectType and not handled[objectType] and not object:IsForbidden() then
			addapi(object)
			handled[objectType] = true
		end

		object = EnumerateFrames(object)
	end
end