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
