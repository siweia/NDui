local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local A = B:RegisterModule("Auras")

local _G = getfenv(0)
local format, floor, strmatch, select, unpack, tonumber = format, floor, strmatch, select, unpack, tonumber
local UnitAura, GetTime = UnitAura, GetTime
local GetInventoryItemQuality, GetInventoryItemTexture, GetWeaponEnchantInfo = GetInventoryItemQuality, GetInventoryItemTexture, GetWeaponEnchantInfo

function A:OnLogin()
	A:HideBlizBuff()
	A:BuildBuffFrame()
	A:Totems()
	A:InitReminder()
end

function A:HideBlizBuff()
	if not C.db["Auras"]["BuffFrame"] and not C.db["Auras"]["HideBlizBuff"] then return end

	B:RegisterEvent("PLAYER_ENTERING_WORLD", function(_, isLogin, isReload)
		if isLogin or isReload then
			B.HideObject(_G.BuffFrame)
			B.HideObject(_G.DebuffFrame)
			BuffFrame.numHideableBuffs = 0 -- fix error when on editmode
		end
	end)
end

function A:BuildBuffFrame()
	if not C.db["Auras"]["BuffFrame"] then return end

	-- Config
	A.settings = {
		Buffs = {
			offset = 12,
			size = C.db["Auras"]["BuffSize"],
			wrapAfter = C.db["Auras"]["BuffsPerRow"],
			maxWraps = 3,
			reverseGrow = C.db["Auras"]["ReverseBuff"],
		},
		Debuffs = {
			offset = 12,
			size = C.db["Auras"]["DebuffSize"],
			wrapAfter = C.db["Auras"]["DebuffsPerRow"],
			maxWraps = 1,
			reverseGrow = C.db["Auras"]["ReverseDebuff"],
		},
	}

	-- Movers
	A.BuffFrame = A:CreateAuraHeader("HELPFUL")
	A.BuffFrame.mover = B.Mover(A.BuffFrame, "Buffs", "BuffAnchor", C.Auras.BuffPos)
	A.BuffFrame:ClearAllPoints()
	A.BuffFrame:SetPoint("TOPRIGHT", A.BuffFrame.mover)

	A.DebuffFrame = A:CreateAuraHeader("HARMFUL")
	A.DebuffFrame.mover = B.Mover(A.DebuffFrame, "Debuffs", "DebuffAnchor", {"TOPRIGHT", A.BuffFrame.mover, "BOTTOMRIGHT", 0, -12})
	A.DebuffFrame:ClearAllPoints()
	A.DebuffFrame:SetPoint("TOPRIGHT", A.DebuffFrame.mover)

	A:CreatePrivateAuras()
end

local day, hour, minute = 86400, 3600, 60
function A:FormatAuraTime(s)
	if s >= day then
		return format("%d"..DB.MyColor.."d", s/day + .5), s%day
	elseif s >= 2*hour then
		return format("%d"..DB.MyColor.."h", s/hour + .5), s%hour
	elseif s >= 10*minute then
		return format("%d"..DB.MyColor.."m", s/minute + .5), s%minute
	elseif s >= minute then
		return format("%d:%.2d", s/minute, s%minute), s - floor(s)
	elseif s > 10 then
		return format("%d"..DB.MyColor.."s", s + .5), s - floor(s)
	elseif s > 5 then
		return format("|cffffff00%.1f|r", s), s - format("%.1f", s)
	else
		return format("|cffff0000%.1f|r", s), s - format("%.1f", s)
	end
end

function A:UpdateTimer(elapsed)
	local onTooltip = GameTooltip:IsOwned(self)

	if not (self.timeLeft or self.expiration or onTooltip) then
		self:SetScript("OnUpdate", nil)
		return
	end

	if self.timeLeft then
		self.timeLeft = self.timeLeft - elapsed
	end

	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
		return
	end

	if self.expiration then
		self.timeLeft = self.expiration / 1e3 - (GetTime() - self.oldTime)
	end

	if self.timeLeft and self.timeLeft >= 0 then
		local timer, nextUpdate = A:FormatAuraTime(self.timeLeft)
		self.nextUpdate = nextUpdate
		self.timer:SetText(timer)
	end

	if onTooltip then A:Button_SetTooltip(self) end
end

function A:GetSpellStat(arg16, arg17, arg18)
	return (arg16 > 0 and L["Versa"]) or (arg17 > 0 and L["Mastery"]) or (arg18 > 0 and L["Haste"]) or L["Crit"]
end

function A:UpdateAuras(button, index)
	local unit, filter = button.header:GetAttribute("unit"), button.filter
	local name, texture, count, debuffType, duration, expirationTime, _, _, _, spellID, _, _, _, _, _, arg16, arg17, arg18 = UnitAura(unit, index, filter)
	if not name then return end

	if duration > 0 and expirationTime then
		local timeLeft = expirationTime - GetTime()
		if not button.timeLeft then
			button.nextUpdate = -1
			button.timeLeft = timeLeft
			button:SetScript("OnUpdate", A.UpdateTimer)
		else
			button.timeLeft = timeLeft
		end
		button.nextUpdate = -1
		A.UpdateTimer(button, 0)
	else
		button.timeLeft = nil
		button.timer:SetText("")
	end

	if count and count > 1 then
		button.count:SetText(count)
	else
		button.count:SetText("")
	end

	if filter == "HARMFUL" then
		local color = oUF.colors.debuff[debuffType or "none"]
		button:SetBackdropBorderColor(color[1], color[2], color[3])
	else
		button:SetBackdropBorderColor(0, 0, 0)
	end

	-- Show spell stat for 'Soleahs Secret Technique'
	if spellID == 368512 then
		button.count:SetText(A:GetSpellStat(arg16, arg17, arg18))
	end

	button.spellID = spellID
	button.icon:SetTexture(texture)
	button.expiration = nil
end

function A:UpdateTempEnchant(button, index)
	local expirationTime = select(button.enchantOffset, GetWeaponEnchantInfo())
	if expirationTime then
		local quality = GetInventoryItemQuality("player", index)
		local color = DB.QualityColors[quality or 1]
		button:SetBackdropBorderColor(color.r, color.g, color.b)
		button.icon:SetTexture(GetInventoryItemTexture("player", index))

		button.expiration = expirationTime
		button.oldTime = GetTime()
		button:SetScript("OnUpdate", A.UpdateTimer)
		button.nextUpdate = -1
		A.UpdateTimer(button, 0)
	else
		button.expiration = nil
		button.timeLeft = nil
		button.timer:SetText("")
	end
end

function A:OnAttributeChanged(attribute, value)
	if attribute == "index" then
		A:UpdateAuras(self, value)
	elseif attribute == "target-slot" then
		A:UpdateTempEnchant(self, value)
	end
end

function A:UpdateOptions()
	A.settings.Buffs.size = C.db["Auras"]["BuffSize"]
	A.settings.Buffs.wrapAfter = C.db["Auras"]["BuffsPerRow"]
	A.settings.Buffs.reverseGrow = C.db["Auras"]["ReverseBuff"]
	A.settings.Debuffs.size = C.db["Auras"]["DebuffSize"]
	A.settings.Debuffs.wrapAfter = C.db["Auras"]["DebuffsPerRow"]
	A.settings.Debuffs.reverseGrow = C.db["Auras"]["ReverseDebuff"]
end

function A:UpdateHeader(header)
	local cfg = A.settings.Debuffs
	if header.filter == "HELPFUL" then
		cfg = A.settings.Buffs
		header:SetAttribute("consolidateTo", 0)
		header:SetAttribute("weaponTemplate", format("NDuiAuraTemplate%d", cfg.size))
	end

	header:SetAttribute("separateOwn", 1)
	header:SetAttribute("sortMethod", "INDEX")
	header:SetAttribute("sortDirection", "+")
	header:SetAttribute("wrapAfter", cfg.wrapAfter)
	header:SetAttribute("maxWraps", cfg.maxWraps)
	header:SetAttribute("point", cfg.reverseGrow and "TOPLEFT" or "TOPRIGHT")
	header:SetAttribute("minWidth", (cfg.size + C.margin)*cfg.wrapAfter)
	header:SetAttribute("minHeight", (cfg.size + cfg.offset)*cfg.maxWraps)
	header:SetAttribute("xOffset", (cfg.reverseGrow and 1 or -1) * (cfg.size + C.margin))
	header:SetAttribute("yOffset", 0)
	header:SetAttribute("wrapXOffset", 0)
	header:SetAttribute("wrapYOffset", -(cfg.size + cfg.offset))
	header:SetAttribute("template", format("NDuiAuraTemplate%d", cfg.size))

	local fontSize = floor(cfg.size/30*12 + .5)
	local index = 1
	local child = select(index, header:GetChildren())
	while child do
		if (floor(child:GetWidth() * 100 + .5) / 100) ~= cfg.size then
			child:SetSize(cfg.size, cfg.size)
		end

		B.SetFontSize(child.count, fontSize)
		B.SetFontSize(child.timer, fontSize)

		--Blizzard bug fix, icons arent being hidden when you reduce the amount of maximum buttons
		if index > (cfg.maxWraps * cfg.wrapAfter) and child:IsShown() then
			child:Hide()
		end

		index = index + 1
		child = select(index, header:GetChildren())
	end
end

function A:CreateAuraHeader(filter)
	local name = "NDuiPlayerDebuffs"
	if filter == "HELPFUL" then name = "NDuiPlayerBuffs" end

	local header = CreateFrame("Frame", name, UIParent, "SecureAuraHeaderTemplate")
	header:SetClampedToScreen(true)
	header:UnregisterEvent("UNIT_AURA") -- we only need to watch player and vehicle
	header:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
	header:SetAttribute("unit", "player")
	header:SetAttribute("filter", filter)
	header.filter = filter
	RegisterAttributeDriver(header, "unit", "[vehicleui] vehicle; player")

	header.visibility = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
	SecureHandlerSetFrameRef(header.visibility, "AuraHeader", header)
	RegisterStateDriver(header.visibility, "customVisibility", "[petbattle] 0;1")
	header.visibility:SetAttribute("_onstate-customVisibility", [[
		local header = self:GetFrameRef("AuraHeader")
		local hide, shown = newstate == 0, header:IsShown()
		if hide and shown then header:Hide() elseif not hide and not shown then header:Show() end
	]]) -- use custom script that will only call hide when it needs to, this prevents spam to `SecureAuraHeader_Update`

	if filter == "HELPFUL" then
		header:SetAttribute("consolidateDuration", -1)
		header:SetAttribute("includeWeapons", 1)
	end

	A:UpdateHeader(header)
	header:Show()

	return header
end

function A:RemoveSpellFromIgnoreList()
	if IsAltKeyDown() and IsControlKeyDown() and self.spellID and C.db["AuraWatchList"]["IgnoreSpells"][self.spellID] then
		C.db["AuraWatchList"]["IgnoreSpells"][self.spellID] = nil
		print(format(L["RemoveFromIgnoreList"], DB.NDuiString, self.spellID))
	end
end

function A:Button_SetTooltip(button)
	if button:GetAttribute("index") then
		GameTooltip:SetUnitAura(button.header:GetAttribute("unit"), button:GetID(), button.filter)
	elseif button:GetAttribute("target-slot") then
		GameTooltip:SetInventoryItem("player", button:GetID())
	end
end

function A:Button_OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -5, -5)
	-- Update tooltip
	self.nextUpdate = -1
	self:SetScript("OnUpdate", A.UpdateTimer)
end

local indexToOffset = {2, 6, 10}

function A:CreateAuraIcon(button)
	button.header = button:GetParent()
	button.filter = button.header.filter
	button.name = button:GetName()
	local enchantIndex = tonumber(strmatch(button.name, "TempEnchant(%d)$"))
	button.enchantOffset = indexToOffset[enchantIndex]

	local cfg = A.settings.Debuffs
	if button.filter == "HELPFUL" then
		cfg = A.settings.Buffs
	end
	local fontSize = floor(cfg.size/30*12 + .5)

	button.icon = button:CreateTexture(nil, "BORDER")
	button.icon:SetInside()
	button.icon:SetTexCoord(unpack(DB.TexCoord))

	button.count = button:CreateFontString(nil, "ARTWORK")
	button.count:SetPoint("TOPRIGHT", -1, -3)
	B.SetFontSize(button.count, fontSize)

	button.timer = button:CreateFontString(nil, "ARTWORK")
	button.timer:SetPoint("TOP", button, "BOTTOM", 1, 2)
	B.SetFontSize(button.timer, fontSize)

	button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
	button.highlight:SetColorTexture(1, 1, 1, .25)
	button.highlight:SetInside()

	B.CreateBD(button, .25)
	B.CreateSD(button)

	button:RegisterForClicks("RightButtonDown")
	button:SetScript("OnAttributeChanged", A.OnAttributeChanged)
	button:HookScript("OnMouseDown", A.RemoveSpellFromIgnoreList)
	button:SetScript("OnEnter", A.Button_OnEnter)
	button:SetScript("OnLeave", B.HideTooltip)
end

local auraAnchor = {
	unitToken = "player",
	auraIndex = 1,
	parent = UIParent,
	showCountdownFrame = true,
	showCountdownNumbers = true,

	iconInfo = {
		iconWidth = 30,
		iconHeight = 30,
		iconAnchor = {
			point = "CENTER",
			relativeTo = UIParent,
			relativePoint = "CENTER",
			offsetX = 0,
			offsetY = 0,
		},
	},

	durationAnchor = {
        point = "TOP",
        relativeTo = UIParent,
        relativePoint = "BOTTOM",
        offsetX = 0,
        offsetY = 0,
    },
}

function A:CreatePrivateAuras()
	local maxButtons = 4 -- only 4 in blzz code, needs review
	local buttonSize = C.db["Auras"]["PrivateSize"]
	local reverse = C.db["Auras"]["ReversePrivate"]

	A.PrivateFrame = CreateFrame("Frame", "NDuiPrivateAuras", UIParent)
	A.PrivateFrame:SetSize((buttonSize + C.margin)*maxButtons - C.margin, buttonSize + 2*C.margin)
	A.PrivateFrame.mover = B.Mover(A.PrivateFrame, "PrivateAuras", "PrivateAuras", {"TOPRIGHT", A.DebuffFrame.mover, "BOTTOMRIGHT", 0, -12})
	A.PrivateFrame:ClearAllPoints()
	A.PrivateFrame:SetPoint("TOPRIGHT", A.PrivateFrame.mover)

	A.PrivateAuras = {}
	local prevButton

	local rel1 = reverse and "TOPLEFT" or "TOPRIGHT"
	local rel2 = reverse and "LEFT" or "RIGHT"
	local rel3 = reverse and "RIGHT" or "LEFT"
	local margin = reverse and C.margin or -C.margin

	for i = 1, maxButtons do
		local button = CreateFrame("Frame", "$parentAnchor"..i, A.PrivateFrame)
		button:SetSize(buttonSize, buttonSize)
		if not prevButton then
			button:SetPoint(rel1, A.PrivateFrame)
		else
			button:SetPoint(rel2, prevButton, rel3, margin, 0)
		end
		prevButton = button

		auraAnchor.auraIndex = i
		auraAnchor.parent = button
		auraAnchor.durationAnchor.relativeTo = button
		auraAnchor.iconInfo.iconWidth = buttonSize
		auraAnchor.iconInfo.iconHeight = buttonSize
		auraAnchor.iconInfo.iconAnchor.relativeTo = button

		C_UnitAuras.RemovePrivateAuraAnchor(i)
		C_UnitAuras.AddPrivateAuraAnchor(auraAnchor)
		A.PrivateAuras[i] = button
	end
end