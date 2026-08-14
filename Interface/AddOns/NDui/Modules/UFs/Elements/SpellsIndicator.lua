local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")
local Cooldown = B:GetModule("Cooldown")

local sort, tinsert = table.sort, table.insert

local COUNT_FORMATTER = C_StringUtil.CreateNumericRuleFormatter()
COUNT_FORMATTER:SetBreakpoints({
	{threshold = 0, format = ""},
	{threshold = 2, format = "%d", step = 1, rounding = Enum.NumericRuleFormatRounding.Down},
})

local DURATION_FORMATTER = C_StringUtil.CreateNumericRuleFormatter()
DURATION_FORMATTER:SetBreakpoints({
	{
		threshold = 0,
		format = "%d",
		step = 1,
		rounding = Enum.NumericRuleFormatRounding.Nearest,
	},
	{
		threshold = SECONDS_PER_MIN,
		format = "%dm",
		components = {{div = SECONDS_PER_MIN, step = 1, rounding = Enum.NumericRuleFormatRounding.Nearest}},
	},
	{
		threshold = SECONDS_PER_HOUR,
		format = "%dh",
		components = {{div = SECONDS_PER_HOUR, step = 1, rounding = Enum.NumericRuleFormatRounding.Nearest}},
	},
	{
		threshold = SECONDS_PER_DAY,
		format = "%dd",
		components = {{div = SECONDS_PER_DAY, step = 1, rounding = Enum.NumericRuleFormatRounding.Nearest}},
	},
})

local DURATION_BINDING = C_DurationUtil.CreateDurationTextBinding()
DURATION_BINDING:SetFormatter(DURATION_FORMATTER)
DURATION_BINDING:SetExpiredText("")
DURATION_BINDING:SetZeroDurationText("")

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

UF.CornerSpells = {}
function UF:UpdateCornerSpells()
	wipe(UF.CornerSpells)

	for spellID, value in pairs(C.CornerBuffs[DB.MyClass] or {}) do
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

local function CreateIndicatorButton(element, options, button)
	local anchor = options.__anchor
	local r, g, b = unpack(options.__color)
	local indicatorType = options.__indicatorType

	button:SetFrameLevel(options.__frameLevel)
	button:SetSize(options.size, options.size)
	button:SetScale(options.__scale)
	button:EnableMouse(false)
	button:ClearAllPoints()
	local x, y = unpack(counterOffsets[anchor][3])
	button:SetPoint(anchor, element.__owner.Health, anchor, x, y)

	local count = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	count:SetFont(DB.Font[1], 12, DB.Font[3])
	button.Count = count

	if indicatorType == 3 then
		local timer = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
		timer:SetFont(DB.Font[1], 12, DB.Font[3])
		timer:SetPoint("CENTER", -counterOffsets[anchor][2][3], 0)
		timer:SetTextColor(r, g, b)
		button.Time = timer

		local point, anchorPoint, countX, countY = unpack(counterOffsets[anchor][2])
		count:SetPoint(point, timer, anchorPoint, countX, countY)
		button:SetDurationText(timer, {binding = DURATION_BINDING})
	else
		local icon = button:CreateTexture(nil, "BORDER")
		icon:SetAllPoints()
		button.Icon = icon
		if indicatorType == 1 then
			icon:SetTexture(DB.bdTex)
			icon:SetVertexColor(r, g, b)
		else
			button:SetIcon(icon)
		end
		button.bg = B.ReskinIcon(icon)

		local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
		cooldown:SetAllPoints()
		cooldown:SetReverse(true)
		Cooldown:IgnoreCooldown(cooldown)
		cooldown:SetHideCountdownNumbers(true)
		button.Cooldown = cooldown
		button:SetDurationCooldown(cooldown)

		count:SetPoint("CENTER", unpack(counterOffsets[anchor][1]))
	end

	button:SetApplicationCount(count, {formatter = COUNT_FORMATTER})
end

function UF:CreateSpellsIndicator(self)
	if not C.db["UFs"]["RaidBuffIndicator"] then return end

	local spellIDs = {}
	for spellID in pairs(UF.CornerSpells) do
		tinsert(spellIDs, spellID)
	end
	if #spellIDs == 0 then return end
	sort(spellIDs)

	local element = self:CreateAuras()
	element:SetAllPoints(self.Health)
	element.disableMouse = true

	local spellSize = C.db["UFs"]["RaidSpellSize"] or 10
	local indicatorType = C.db["UFs"]["BuffIndicatorType"]
	local scale = C.db["UFs"]["BuffIndicatorScale"]
	local baseFrameLevel = self:GetFrameLevel() + 10
	for index, spellID in ipairs(spellIDs) do
		local value = UF.CornerSpells[spellID]
		local filter = value[3] and "HELPFUL" or "HELPFUL|PLAYER"
		element:AddSlot(filter, {
			size = spellSize,
			CreateButton = CreateIndicatorButton,
			candidateFilters = {includeSpellIDs = {[spellID] = true}},
			sortMethod = AuraContainerSortMethod.Default,
			sortDirection = AuraContainerSortDirection.Normal,
			__anchor = value[1],
			__color = value[2],
			__indicatorType = indicatorType,
			__scale = scale,
			__frameLevel = baseFrameLevel + index,
		})
	end

	self.SpellsIndicator = element
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
		[369459] = true, -- 魔法之源
	},
	DRUID = {
		[774] = true, -- 回春术
		[8936] = true, -- 愈合
		[33763] = true, -- 生命绽放
		[48438] = true, -- 野性成长
		[155777] = true, -- 萌芽
		[1126] = true, -- 野性印记
		[474754] = true, -- 共生关系
	},
	PRIEST = {
		[17] = true, -- 真言术:盾
		[194384] = true, -- 救赎
		[1253593] = true, -- 虚空之盾
		[139] = true, -- 恢复
		[41635] = true, -- 愈合祷言
		[77489] = true, -- 圣光回响
		[21562] = true, -- 真言术:韧
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
		[207400] = true, -- 先祖活力
		[444490] = true, -- 源水气泡

		[462854] = true, -- 天怒
		--[319773] = true, -- 风怒武器
		--[319778] = true, -- 火舌武器
		--[382021] = true, -- 大地生命武器
		--[382022] = true, -- 大地生命武器
		--[457496] = true, -- 唤潮者护卫
		--[457481] = true, -- 唤潮者护卫
		--[462757] = true, -- 雷击结界
		--[462742] = true, -- 雷击结界
	},
	PALADIN = {
		[53563] = true, -- 圣光道标
		[156322] = true, -- 永恒之火
		[156910] = true, -- 信仰道标
		[1244893] = true, -- 救赎者道标

		[433568] = true, -- 圣化仪式
		[433583] = true, -- 祈告仪式
	},
	MAGE = {
		[1459] = true, -- 奥术智力
		[205473] = true, -- 法师:冰刺
	},
	HUNTER = {
		[260286] = true, -- 猎人:矛尖
	},
	WARRIOR = {
		[6673] = true, -- 战斗怒吼
	},
}
