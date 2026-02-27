local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

local counterOffsets = {
	["TOPLEFT"] = {{6, 1}, {"LEFT", "RIGHT", -2, 0}, {2, -2}},
	["TOPRIGHT"] = {{-6, 1}, {"RIGHT", "LEFT", 2, 0}, {-2, -2}},
	["BOTTOMLEFT"] = {{6, 1},{"LEFT", "RIGHT", -2, 0}, {2, 2}},
	["BOTTOMRIGHT"] = {{-6, 1}, {"RIGHT", "LEFT", 2, 0}, {-2, 2}},
	["LEFT"] = {{6, 1}, {"LEFT", "RIGHT", -2, 0}, {2, 0}},
	["RIGHT"] = {{-6, 1}, {"RIGHT", "LEFT", 2, 0}, {-2, 0}},
	["TOP"] = {{0, 0}, {"RIGHT", "LEFT", 2, 0}, {0, -2}},
	["BOTTOM"] = {{0, 0}, {"RIGHT", "LEFT", 2, 0}, {0, 2}},
}

function UF:SpellsIndicator_OnUpdate(elapsed)
	B.CooldownOnUpdate(self, elapsed, true)
end

UF.CornerSpells = {}
function UF:UpdateCornerSpells()
	wipe(UF.CornerSpells)

	for spellID, value in pairs(C.CornerBuffs[DB.MyClass]) do
		local modData = NDuiADB["CornerSpells"][DB.MyClass]
		if not (modData and modData[spellID]) then
			local r, g, b = unpack(value[2])
			UF.CornerSpells[spellID] = {value[1], {r, g, b}, value[3]}
		end
	end

	for spellID, value in pairs(NDuiADB["CornerSpells"][DB.MyClass]) do
		if next(value) then
			local r, g, b = unpack(value[2])
			UF.CornerSpells[spellID] = {value[1], {r, g, b}, value[3]}
		end
	end
end

local anchors = {"TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}

function UF:CreateSpellsIndicator(self)
	local spellSize = C.db["UFs"]["RaidSpellSize"] or 10

	local buttons = {}
	for _, anchor in pairs(anchors) do
		local button = CreateFrame("Frame", nil, self.Health)
		button:SetFrameLevel(self:GetFrameLevel()+10)
		button:SetSize(spellSize, spellSize)
		local x, y = unpack(counterOffsets[anchor][3])
		button:SetPoint(anchor, x, y)
		button:Hide()

		button.icon = button:CreateTexture(nil, "BORDER")
		button.icon:SetAllPoints()
		button.bg = B.ReskinIcon(button.icon)

		button.cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
		button.cd:SetAllPoints()
		button.cd:SetReverse(true)
		button.cd:SetHideCountdownNumbers(true)

		button.timer = B.CreateFS(button, 12, "", false, "CENTER", -counterOffsets[anchor][2][3], 0)
		button.count = B.CreateFS(button, 12, "")

		button.anchor = anchor
		buttons[anchor] = button

		UF:RefreshBuffIndicator(button)
	end

	self.SpellsIndicator = buttons

	UF.SpellsIndicator_UpdateOptions(self)
end

function UF:SpellsIndicator_UpdateButton(button, aura, r, g, b)
	if C.db["UFs"]["BuffIndicatorType"] == 3 then
		if aura.duration and aura.duration > 0 then
			button.expiration = aura.expiration
			button:SetScript("OnUpdate", UF.SpellsIndicator_OnUpdate)
		else
			button:SetScript("OnUpdate", nil)
		end
		button.timer:SetTextColor(r, g, b)
	else
		if aura.duration and aura.duration > 0 then
			button.cd:SetCooldown(aura.expiration - aura.duration, aura.duration)
			button.cd:Show()
		else
			button.cd:Hide()
		end
		if C.db["UFs"]["BuffIndicatorType"] == 1 then
			button.icon:SetVertexColor(r, g, b)
		else
			button.icon:SetTexture(aura.texture)
		end
	end

	button.count:SetText(aura.count > 1 and aura.count or "")
	button:Show()
end

function UF:SpellsIndicator_HideButtons()
	for _, button in pairs(self.SpellsIndicator) do
		button:Hide()
	end
end

function UF:RefreshBuffIndicator(bu)
	if C.db["UFs"]["BuffIndicatorType"] == 3 then
		local point, anchorPoint, x, y = unpack(counterOffsets[bu.anchor][2])
		bu.timer:Show()
		bu.count:ClearAllPoints()
		bu.count:SetPoint(point, bu.timer, anchorPoint, x, y)
		bu.icon:Hide()
		bu.cd:Hide()
		bu.bg:Hide()
	else
		bu:SetScript("OnUpdate", nil)
		bu.timer:Hide()
		bu.count:ClearAllPoints()
		bu.count:SetPoint("CENTER", unpack(counterOffsets[bu.anchor][1]))
		if C.db["UFs"]["BuffIndicatorType"] == 1 then
			bu.icon:SetTexture(DB.bdTex)
		else
			bu.icon:SetVertexColor(1, 1, 1)
		end
		bu.icon:Show()
		bu.cd:Show()
		bu.bg:Show()
	end
end

function UF:SpellsIndicator_UpdateOptions()
	local spells = self.SpellsIndicator
	if not spells then return end

	for anchor, button in pairs(spells) do
		button:SetScale(C.db["UFs"]["BuffIndicatorScale"])
		UF:RefreshBuffIndicator(button)
	end
end

-- None secret spells in 12.0.1
UF.NonSecretSpells = {
	EVOKER = {
		[355941] = true, -- 梦境吐息
		[363502] = true, -- 梦境飞行
		[364343] = true, -- 回响
		[366155] = true, -- 逆转
		[367364] = true, -- 回响逆转
		[373267] = true, -- 生命绑定
		[376788] = true, -- 回响梦境吐息
		[360827] = true, -- 爆裂龙鳞
		[395152] = true, -- 黑檀之力
		[410089] = true, -- 先见
		[410263] = true, -- 狱火之祝
		[410686] = true, -- 共生之花
		[413984] = true, -- 流沙
	},
	DRUID = {
		[774] = true, -- 回春术
		[8936] = true, -- 愈合
		[33763] = true, -- 生命绽放
		[48438] = true, -- 野性成长
		[155777] = true, -- 萌芽
	},
	PRIEST = {
		[17] = true, -- 真言术:盾
		[194384] = true, -- 救赎
		[1253593] = true, -- 虚空之盾
		[139] = true, -- 恢复
		[41635] = true, -- 愈合祷言
		[77489] = true, -- 圣光回响
	},
	MONK = {
		[115175] = true, -- 抚慰之雾
		[119611] = true, -- 复苏之雾
		[124682] = true, -- 氤氲之雾
		[450769] = true, -- 和谐之姿
	},
	SHAMAN = {
		[974] = true, -- 大地之盾
		[383648] = true, -- 大地之盾
		[61295] = true, -- 激流
	},
	PALADIN = {
		[53563] = true, -- 圣光道标
		[156322] = true, -- 永恒之火
		[156910] = true, -- 信仰道标
		[1244893] = true, -- 救赎者道标
	},
	ROGUE = {
		[2823] = true, -- 致命毒药
		[8679] = true, -- 致伤毒药
		[3408] = true, -- 减速毒药
		[5761] = true, -- 麻痹毒药
		[315584] = true, -- 速效毒药
		[381637] = true, -- 萎缩毒药
		[381664] = true, -- 增效毒药
	},
	OTHERS = {
		[319773] = true, -- 风怒武器
		[319778] = true, -- 火舌武器
		[382021] = true, -- 大地生命武器
		[382022] = true, -- 大地生命武器
		[457496] = true, -- 唤潮者护卫
		[457481] = true, -- 唤潮者护卫
		[462757] = true, -- 雷击结界
		[462742] = true, -- 雷击结界
		[205473] = true, -- 法师:冰刺
		[260286] = true, -- 猎人:矛尖
		[1459] = true, -- 奥术智力
		[6673] = true, -- 战斗怒吼
		[21562] = true, -- 真言术:韧
		[369459] = true, -- 魔法之源
		[462854] = true, -- 天怒
		[474754] = true, -- 共生关系
		[433568] = true, -- 圣化仪式
		[433583] = true, -- 祈告仪式
	}
}