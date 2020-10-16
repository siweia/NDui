local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:RegisterModule("Auras")

local _G = getfenv(0)
local format, floor, strmatch, select, unpack = format, floor, strmatch, select, unpack
local DebuffTypeColor = _G.DebuffTypeColor
local UnitAura, GetTime = UnitAura, GetTime
local GetInventoryItemQuality, GetInventoryItemTexture, GetItemQualityColor, GetWeaponEnchantInfo = GetInventoryItemQuality, GetInventoryItemTexture, GetItemQualityColor, GetWeaponEnchantInfo

function A:OnLogin()
	-- Config
	A.settings = {
		Buffs = {
			offset = 12,
			size = NDuiDB["Auras"]["BuffSize"],
			wrapAfter = NDuiDB["Auras"]["BuffsPerRow"],
			maxWraps = 3,
			reverseGrow = NDuiDB["Auras"]["ReverseBuffs"],
		},
		Debuffs = {
			offset = 12,
			size = NDuiDB["Auras"]["DebuffSize"],
			wrapAfter = NDuiDB["Auras"]["DebuffsPerRow"],
			maxWraps = 1,
			reverseGrow = NDuiDB["Auras"]["ReverseDebuffs"],
		},
	}

	-- HideBlizz
	B.HideObject(_G.BuffFrame)
	B.HideObject(_G.TemporaryEnchantFrame)

	-- Movers
	A.BuffFrame = A:CreateAuraHeader("HELPFUL")
	A.BuffFrame.mover = B.Mover(A.BuffFrame, "Buffs", "BuffAnchor", C.Auras.BuffPos)
	A.BuffFrame:ClearAllPoints()
	A.BuffFrame:SetPoint("TOPRIGHT", A.BuffFrame.mover)

	A.DebuffFrame = A:CreateAuraHeader("HARMFUL")
	A.DebuffFrame.mover = B.Mover(A.DebuffFrame, "Debuffs", "DebuffAnchor", {"TOPRIGHT", A.BuffFrame.mover, "BOTTOMRIGHT", 0, -12})
	A.DebuffFrame:ClearAllPoints()
	A.DebuffFrame:SetPoint("TOPRIGHT", A.DebuffFrame.mover)

	-- Elements
	A:Totems()
	A:InitReminder()
end

local day, hour, minute = 86400, 3600, 60
function A:FormatAuraTime(s)
	if s >= day then
		return format("%d"..DB.MyColor.."d", s/day), s%day
	elseif s >= hour then
		return format("%s"..DB.MyColor.."h", B:Round(s/hour, 1)), s%hour
	elseif s >= 10*minute then
		return format("%d"..DB.MyColor.."m", s/minute), s%minute
	elseif s >= minute then
		return format("%d:%.2d", s/minute, s%minute), s - floor(s)
	elseif s > 10 then
		return format("%d"..DB.MyColor.."s", s), s - floor(s)
	elseif s > 5 then
		return format("|cffffff00%.1f|r", s), s - format("%.1f", s)
	else
		return format("|cffff0000%.1f|r", s), s - format("%.1f", s)
	end
end

function A:UpdateTimer(elapsed)
	if self.offset then
		local expiration = select(self.offset, GetWeaponEnchantInfo())
		if expiration then
			self.timeLeft = expiration / 1e3
		else
			self.timeLeft = 0
		end
	else
		self.timeLeft = self.timeLeft - elapsed
	end

	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
		return
	end

	if self.timeLeft >= 0 then
		local timer, nextUpdate = A:FormatAuraTime(self.timeLeft)
		self.nextUpdate = nextUpdate
		self.timer:SetText(timer)
	end
end

function A:UpdateAuras(button, index)
	local filter = button:GetParent():GetAttribute("filter")
	local unit = button:GetParent():GetAttribute("unit")
	local name, texture, count, debuffType, duration, expirationTime = UnitAura(unit, index, filter)

	if name then
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
			button:SetScript("OnUpdate", nil)
		end

		if count and count > 1 then
			button.count:SetText(count)
		else
			button.count:SetText("")
		end

		if filter == "HARMFUL" then
			local color = DebuffTypeColor[debuffType or "none"]
			button:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			button:SetBackdropBorderColor(0, 0, 0)
		end

		button.icon:SetTexture(texture)
		button.offset = nil
	end
end

function A:UpdateTempEnchant(button, index)
	local quality = GetInventoryItemQuality("player", index)
	button.icon:SetTexture(GetInventoryItemTexture("player", index))

	local offset = 2
	local weapon = button:GetName():sub(-1)
	if strmatch(weapon, "2") then
		offset = 6
	end

	if quality then
		button:SetBackdropBorderColor(GetItemQualityColor(quality))
	end

	local expirationTime = select(offset, GetWeaponEnchantInfo())
	if expirationTime then
		button.offset = offset
		button:SetScript("OnUpdate", A.UpdateTimer)
		button.nextUpdate = -1
		A.UpdateTimer(button, 0)
	else
		button.offset = nil
		button.timeLeft = nil
		button:SetScript("OnUpdate", nil)
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
	A.settings.Buffs.size = NDuiDB["Auras"]["BuffSize"]
	A.settings.Buffs.wrapAfter = NDuiDB["Auras"]["BuffsPerRow"]
	A.settings.Buffs.reverseGrow = NDuiDB["Auras"]["ReverseBuffs"]
	A.settings.Debuffs.size = NDuiDB["Auras"]["DebuffSize"]
	A.settings.Debuffs.wrapAfter = NDuiDB["Auras"]["DebuffsPerRow"]
	A.settings.Debuffs.reverseGrow = NDuiDB["Auras"]["ReverseDebuffs"]
end

function A:UpdateHeader(header)
	local cfg = A.settings.Debuffs
	if header:GetAttribute("filter") == "HELPFUL" then
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
	header:SetAttribute("unit", "player")
	header:SetAttribute("filter", filter)
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

function A:CreateAuraIcon(button)
	local header = button:GetParent()
	local cfg = A.settings.Debuffs
	if header:GetAttribute("filter") == "HELPFUL" then
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

	button:SetScript("OnAttributeChanged", A.OnAttributeChanged)
end