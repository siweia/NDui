local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Auras")

local BuffFrame = BuffFrame
local buffsPerRow, buffSize, margin, offset = C.Auras.IconsPerRow, C.Auras.IconSize - 2, C.Auras.Spacing, 12
local debuffsPerRow, debuffSize = C.Auras.IconsPerRow - 4, C.Auras.IconSize + 3
local parentFrame, buffAnchor, debuffAnchor

function module:OnLogin()
	parentFrame = CreateFrame("Frame", nil, UIParent)
	parentFrame:SetSize(buffSize, buffSize)
	buffAnchor = B.Mover(parentFrame, "Buffs", "BuffAnchor", C.Auras.BuffPos, (buffSize + margin)*buffsPerRow, (buffSize + offset)*3)
	debuffAnchor = B.Mover(parentFrame, "Debuffs", "DebuffAnchor", {"TOPRIGHT", buffAnchor, "BOTTOMRIGHT", 0, -offset}, (debuffSize + margin)*debuffsPerRow, (debuffSize + offset)*2)
	parentFrame:ClearAllPoints()
	parentFrame:SetPoint("TOPRIGHT", buffAnchor)

	for i = 1, 3 do
		local enchant = _G["TempEnchant"..i]
		enchant:ClearAllPoints()
		if i == 1 then
			enchant:SetPoint("TOPRIGHT", buffAnchor)
		else
			enchant:SetPoint("TOPRIGHT", _G["TempEnchant"..(i-1)], "TOPLEFT", -margin, 0)
		end
	end
	TempEnchant3:Hide()
	BuffFrame.ignoreFramePositionManager = true

	-- Elements
	if DB.MyClass == "MONK" then
		self:MonkStatue()
	elseif DB.MyClass == "SHAMAN" then
		self:Totems()
	end
	self:InitReminder()
end

local function styleButton(bu, isDebuff)
	if not bu or bu.styled then return end
	local name = bu:GetName()

	local iconSize, fontSize = buffSize, DB.Font[2]
	if isDebuff then iconSize, fontSize = debuffSize, DB.Font[2] + 2 end

	local border = _G[name.."Border"]
	if border then border:Hide() end

	local icon = _G[name.."Icon"]
	icon:SetAllPoints()
	icon:SetTexCoord(unpack(DB.TexCoord))
	icon:SetDrawLayer("BACKGROUND", 1)

	local duration = _G[name.."Duration"]
	duration:ClearAllPoints()
	duration:SetPoint("TOP", bu, "BOTTOM", 2, 2)
	duration:SetFont(DB.Font[1], fontSize, DB.Font[3])

	local count = _G[name.."Count"]
	count:ClearAllPoints()
	count:SetParent(bu)
	count:SetPoint("TOPRIGHT", bu, "TOPRIGHT", -1, -3)
	count:SetFont(DB.Font[1], fontSize, DB.Font[3])

	bu:SetSize(iconSize, iconSize)
	bu.HL = bu:CreateTexture(nil, "HIGHLIGHT")
	bu.HL:SetColorTexture(1, 1, 1, .25)
	bu.HL:SetAllPoints(icon)
	B.CreateSD(bu, 3, 3)

	bu.styled = true
end

local function reskinBuffs()
	local buff, previousBuff, aboveBuff, index
	local numBuffs = 0
	local slack = BuffFrame.numEnchants

	for i = 1, BUFF_ACTUAL_DISPLAY do
		buff = _G["BuffButton"..i]
		styleButton(buff)

		numBuffs = numBuffs + 1
		index = numBuffs + slack
		buff:ClearAllPoints()
		if index > 1 and mod(index, buffsPerRow) == 1 then
			if index == buffsPerRow + 1 then
				buff:SetPoint("TOP", parentFrame, "BOTTOM", 0, -offset)
			else
				buff:SetPoint("TOP", aboveBuff, "BOTTOM", 0, -offset)
			end
			aboveBuff = buff
		elseif numBuffs == 1 and slack == 0 then
			buff:SetPoint("TOPRIGHT", buffAnchor)
		elseif numBuffs == 1 and slack > 0 then
			buff:SetPoint("TOPRIGHT", _G["TempEnchant"..slack], "TOPLEFT", -margin, 0)
		else
			buff:SetPoint("RIGHT", previousBuff, "LEFT", -margin, 0)
		end
		previousBuff = buff
	end
end
hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", reskinBuffs)

local function reskinTempEnchant()
	for i = 1, NUM_TEMP_ENCHANT_FRAMES do
		local bu = _G["TempEnchant"..i]
		styleButton(bu)
	end
end
hooksecurefunc("TemporaryEnchantFrame_Update", reskinTempEnchant)

local function reskinDebuffs(buttonName, i)
	local debuff = _G[buttonName..i]
	styleButton(debuff, true)

	debuff:ClearAllPoints()
	if i > 1 and mod(i, debuffsPerRow) == 1 then
		debuff:SetPoint("TOP", _G[buttonName..(i-debuffsPerRow)], "BOTTOM", 0, -offset)
	elseif i == 1 then
		debuff:SetPoint("TOPRIGHT", debuffAnchor)
	else
		debuff:SetPoint("RIGHT", _G[buttonName..(i-1)], "LEFT", -margin, 0)
	end
end
hooksecurefunc("DebuffButton_UpdateAnchors", reskinDebuffs)

local function updateDebuffBorder(buttonName, index, filter)
	local unit = PlayerFrame.unit
	local name, _, _, debuffType = UnitAura(unit, index, filter)
	if not name then return end
	local bu = _G[buttonName..index]
	if not (bu and bu.Shadow) then return end

	if filter == "HARMFUL" then
		local color = DebuffTypeColor[debuffType or "none"]
		bu.Shadow:SetBackdropBorderColor(color.r, color.g, color.b)
	end
end
hooksecurefunc("AuraButton_Update", updateDebuffBorder)

local function flashOnEnd(self)
	if self.timeLeft < 10 then
		self:SetAlpha(BuffFrame.BuffAlphaValue)
	else
		self:SetAlpha(1)
	end
end
hooksecurefunc("AuraButton_OnUpdate", flashOnEnd)

local function formatAuraTime(seconds)
	local d, h, m, str = 0, 0, 0
	if seconds >= 86400 then
		d = seconds/86400
		seconds = seconds%86400
	end
	if seconds >= 3600 then
		h = seconds/3600
		seconds = seconds%3600
	end
	if seconds >= 60 then
		m = seconds/60
		seconds = seconds%60
	end
	if d > 0 then
		str = format("%d"..DB.MyColor.."d", d)
	elseif h > 0 then
		str = format("%d"..DB.MyColor.."h", h)
	elseif m >= 10 then
		str = format("%d"..DB.MyColor.."m", m)
	elseif m > 0 and m < 10 then
		str = format("%d:%.2d", m, seconds)
	else
		if seconds <= 5 then
			str = format("|cffff0000%.1f|r", seconds) -- red
		elseif seconds <= 10 then
			str = format("|cffffff00%.1f|r", seconds) -- yellow
		else
			str = format("%d"..DB.MyColor.."s", seconds)
		end
	end

	return str
end

hooksecurefunc("AuraButton_UpdateDuration", function(button, timeLeft)
	local duration = button.duration
	if SHOW_BUFF_DURATIONS == "1" and timeLeft then
		duration:SetText(formatAuraTime(timeLeft))
		duration:SetVertexColor(1, 1, 1)
		duration:Show()
	else
		duration:Hide()
	end
end)