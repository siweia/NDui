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
	A:InitReminder()
end

function A:HideBlizBuff()
	if not C.db["Auras"]["BuffFrame"] and not C.db["Auras"]["HideBlizBuff"] then return end

	B.HideObject(_G.BuffFrame)
	B.HideObject(_G.TemporaryEnchantFrame)
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

	if self.expiration then
		self.timeLeft = self.expiration / 1e3
	elseif self.timeLeft then
		self.timeLeft = self.timeLeft - elapsed
	end

	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
		return
	end

	if self.timeLeft and self.timeLeft >= 0 then
		local timer, nextUpdate = A:FormatAuraTime(self.timeLeft)
		self.nextUpdate = nextUpdate
		self.timer:SetText(timer)
	end

	if onTooltip then A:Button_SetTooltip(self) end
end

function A:UpdateAuras(button, index)
	local unit, filter = button.header:GetAttribute("unit"), button.filter
	local name, texture, count, debuffType, duration, expirationTime, _, _, _, spellID = UnitAura(unit, index, filter)
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

	button.spellID = spellID
	button.icon:SetTexture(texture)
	button.expiration = nil
end

function A:UpdateTempEnchant(button, index)
	local expirationTime, count = select(button.enchantOffset, GetWeaponEnchantInfo())
	if expirationTime then
		local quality = GetInventoryItemQuality("player", index)
		local color = DB.QualityColors[quality or 1]
		button:SetBackdropBorderColor(color.r, color.g, color.b)
		button.icon:SetTexture(GetInventoryItemTexture("player", index))
		if count and count > 0 then
			button.count:SetText(count)
		else
			button.count:SetText("")
		end

		button.expiration = expirationTime
		button:SetScript("OnUpdate", A.UpdateTimer)
		button.nextUpdate = -1
		A.UpdateTimer(button, 0)
	else
		button.expiration = nil
		button.timeLeft = nil
		button.timer:SetText("")
		button.count:SetText("")
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

		child.count:SetFont(DB.Font[1], fontSize, DB.Font[3])
		child.timer:SetFont(DB.Font[1], fontSize, DB.Font[3])

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
	RegisterStateDriver(header, "visibility", "[petbattle] hide; show")
	RegisterAttributeDriver(header, "unit", "[vehicleui] vehicle; player")

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
	button.count:SetFont(DB.Font[1], fontSize, DB.Font[3])

	button.timer = button:CreateFontString(nil, "ARTWORK")
	button.timer:SetPoint("TOP", button, "BOTTOM", 1, 2)
	button.timer:SetFont(DB.Font[1], fontSize, DB.Font[3])

	button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
	button.highlight:SetColorTexture(1, 1, 1, .25)
	button.highlight:SetInside()

	B.CreateBD(button, .25)
	B.CreateSD(button)

	button:RegisterForClicks("RightButtonUp")
	button:SetScript("OnAttributeChanged", A.OnAttributeChanged)
	--button:HookScript("OnMouseDown", A.RemoveSpellFromIgnoreList)
	button:SetScript("OnEnter", A.Button_OnEnter)
	button:SetScript("OnLeave", B.HideTooltip)
end