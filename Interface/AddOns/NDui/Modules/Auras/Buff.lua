local B, C, L, DB = unpack(select(2, ...))

local _G, BuffFrame = _G, BuffFrame
local IconsPerRow, IconSize, padding = C.Auras.IconsPerRow, C.Auras.IconSize - 2, C.Auras.Spacing

local BuffAnchor = CreateFrame("Frame", "NDuiBuffFrame", UIParent)
BuffAnchor:SetPoint(unpack(C.Auras.BuffPos))
BuffAnchor:SetSize(IconSize, IconSize)
BuffFrame.ignoreFramePositionManager = true

TempEnchant1:ClearAllPoints()
TempEnchant1:SetPoint("TOPRIGHT", BuffAnchor)
TempEnchant2:ClearAllPoints()
TempEnchant2:SetPoint("TOPRIGHT", TempEnchant1, "TOPLEFT", -padding, 0)
TempEnchant3:ClearAllPoints()
TempEnchant3:SetPoint("TOPRIGHT", TempEnchant2, "TOPLEFT", -padding, 0)
TempEnchant3:Hide()

local function styleButton(bu)
	if not bu or (bu and bu.styled) then return end
	local name = bu:GetName()

	local border = _G[name.."Border"]
	if border then border:Hide() end

	local icon = _G[name.."Icon"]
	icon:SetAllPoints()
	icon:SetTexCoord(unpack(DB.TexCoord))
	icon:SetDrawLayer("BACKGROUND", 1)

	local duration = _G[name.."Duration"]
	duration:ClearAllPoints()
	duration:SetPoint("TOP", bu, "BOTTOM", 2, 2)
	duration:SetFont(unpack(DB.Font))

	local count = _G[name.."Count"]
	count:ClearAllPoints()
	count:SetParent(bu)
	count:SetPoint("TOPRIGHT", bu, "TOPRIGHT", -1, -3)
	count:SetFont(unpack(DB.Font))

	bu:SetSize(IconSize, IconSize)
	bu.HL = bu:CreateTexture(nil, "HIGHLIGHT")
	bu.HL:SetColorTexture(1, 1, 1, .3)
	bu.HL:SetAllPoints(icon)
	B.CreateSD(bu, 3, 3)

	bu.styled = true
end

local function ReskinBuffs()
	local buff, previousBuff, aboveBuff, index
	local numBuffs = 0
	local slack = BuffFrame.numEnchants

	for i = 1, BUFF_ACTUAL_DISPLAY do
		buff = _G["BuffButton"..i]
		styleButton(buff)

		numBuffs = numBuffs + 1
		index = numBuffs + slack
		buff:ClearAllPoints()
		if index > 1 and mod(index, IconsPerRow) == 1 then
			if index == IconsPerRow + 1 then
				buff:SetPoint("TOP", BuffAnchor, "BOTTOM", 0, -12)
			else
				buff:SetPoint("TOP", aboveBuff, "BOTTOM", 0, -12)
			end
			aboveBuff = buff
		elseif numBuffs == 1 and slack == 0 then
			buff:SetPoint("TOPRIGHT", BuffAnchor)
		elseif numBuffs == 1 and slack > 0 then
			buff:SetPoint("TOPRIGHT", _G["TempEnchant"..slack], "TOPLEFT", -padding, 0)
		else
			buff:SetPoint("RIGHT", previousBuff, "LEFT", -padding, 0)
		end
		previousBuff = buff
	end
end
hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", ReskinBuffs)

local function ReskinTempEnchant()
	for i = 1, NUM_TEMP_ENCHANT_FRAMES do
		local bu = _G["TempEnchant"..i]
		styleButton(bu)
	end
end
hooksecurefunc("TemporaryEnchantFrame_Update", ReskinTempEnchant)

local function ReskinDebuffs(self, i)
	local debuff = _G["DebuffButton"..i]
	local previous = _G["DebuffButton"..(i-1)]
	styleButton(debuff)

	debuff:ClearAllPoints()
	if i == 1 then
		debuff:SetPoint("TOPRIGHT", BuffAnchor, 0, -130)
	elseif i == IconsPerRow + 1 then
		debuff:SetPoint("TOP", _G["DebuffButton1"], "BOTTOM", 0, -12)
	elseif i < IconsPerRow*2 + 1 then
		debuff:SetPoint("RIGHT", previous, "LEFT", -padding, 0)
	end
end
hooksecurefunc("DebuffButton_UpdateAnchors", ReskinDebuffs)

local function FlashOnEnd(self, elapsed)
	if self.timeLeft < 10 then
		self:SetAlpha(BuffFrame.BuffAlphaValue)
	else
		self:SetAlpha(1)
	end
end
hooksecurefunc("AuraButton_OnUpdate", FlashOnEnd)