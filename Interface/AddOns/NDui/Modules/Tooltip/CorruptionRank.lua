local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local select, strmatch, gmatch, format, next, wipe = select, strmatch, gmatch, format, next, wipe
local ITEM_MOD_CORRUPTION = ITEM_MOD_CORRUPTION
local IsCorruptedItem, GetSpellInfo = IsCorruptedItem, GetSpellInfo
local GetInventoryItemLink, UnitGUID = GetInventoryItemLink, UnitGUID

local corruptionData = {
	-- Credit: CorruptionNameTooltips
	["6483"] = {spellID = 315607, level = "I (|cffffffff10|r/15/20)"},
	["6484"] = {spellID = 315608, level = "II (10/|cffffffff15|r/20)"},
	["6485"] = {spellID = 315609, level = "III (10/15/|cffffffff20|r)"},
	["6474"] = {spellID = 315544, level = "I (|cffffffff10|r/15/20)"},
	["6475"] = {spellID = 315545, level = "II (10/|cffffffff15|r/20)"},
	["6476"] = {spellID = 315546, level = "III (10/15/|cffffffff20|r)"},
	["6471"] = {spellID = 315529, level = "I (|cffffffff10|r/15/20)"},
	["6472"] = {spellID = 315530, level = "II (10/|cffffffff15|r/20)"},
	["6473"] = {spellID = 315531, level = "III (10/15/|cffffffff20|r)"},
	["6480"] = {spellID = 315554, level = "I (|cffffffff10|r/15/20)"},
	["6481"] = {spellID = 315557, level = "II (10/|cffffffff15|r/20)"},
	["6482"] = {spellID = 315558, level = "III (10/15/|cffffffff20|r)"},
	["6477"] = {spellID = 315549, level = "I (|cffffffff10|r/15/20)"},
	["6478"] = {spellID = 315552, level = "II (10/|cffffffff15|r/20)"},
	["6479"] = {spellID = 315553, level = "III (10/15/|cffffffff20|r)"},
	["6493"] = {spellID = 315590, level = "I (|cffffffff10|r/15/20)"},
	["6494"] = {spellID = 315591, level = "II (10/|cffffffff15|r/20)"},
	["6495"] = {spellID = 315592, level = "III (10/15/|cffffffff20|r)"},
	["6437"] = {spellID = 315277, level = "I (|cffffffff10|r/15/20)"},
	["6438"] = {spellID = 315281, level = "II (10/|cffffffff15|r/20)"},
	["6439"] = {spellID = 315282, level = "III (10/15/|cffffffff20|r)"},
	["6555"] = {spellID = 318266, level = "I (|cffffffff15|r/20/35)"},
	["6559"] = {spellID = 318492, level = "II (15/|cffffffff20|r/35)"},
	["6560"] = {spellID = 318496, level = "III (15/20/|cffffffff35|r)"},
	["6556"] = {spellID = 318268, level = "I (|cffffffff15|r/20/35)"},
	["6561"] = {spellID = 318493, level = "II (15/|cffffffff20|r/35)"},
	["6562"] = {spellID = 318497, level = "III (15/20/|cffffffff35|r)"},
	["6558"] = {spellID = 318270, level = "I (|cffffffff15|r/20/35)"},
	["6565"] = {spellID = 318495, level = "II (15/|cffffffff20|r/35)"},
	["6566"] = {spellID = 318499, level = "III (15/20/|cffffffff35|r)"},
	["6557"] = {spellID = 318269, level = "I (|cffffffff15|r/20/35)"},
	["6563"] = {spellID = 318494, level = "II (15/|cffffffff20|r/35)"},
	["6564"] = {spellID = 318498, level = "III (15/20/|cffffffff35|r)"},
	["6549"] = {spellID = 318280, level = "I (|cffffffff25|r/35/60)"},
	["6550"] = {spellID = 318485, level = "II (25/|cffffffff35|r/60)"},
	["6551"] = {spellID = 318486, level = "III (25/35/|cffffffff60|r)"},
	["6552"] = {spellID = 318274, level = "I (|cffffffff25|r/50/75)"},
	["6553"] = {spellID = 318487, level = "II (25/|cffffffff50|r/75)"},
	["6554"] = {spellID = 318488, level = "III (25/50/|cffffffff75|r)"},
	["6547"] = {spellID = 318303, level = "I (|cffffffff12|r/30)"},
	["6548"] = {spellID = 318484, level = "II (12/|cffffffff30|r)"},
	["6537"] = {spellID = 318276, level = "I (|cffffffff25|r/50/75)"},
	["6538"] = {spellID = 318477, level = "II (25/|cffffffff50|r/75)"},
	["6539"] = {spellID = 318478, level = "III (25/50/|cffffffff75|r)"},
	["6543"] = {spellID = 318481, level = "I (|cffffffff10|r/35/66)"},
	["6544"] = {spellID = 318482, level = "II (10/|cffffffff35|r/66)"},
	["6545"] = {spellID = 318483, level = "III (10/35/|cffffffff66|r)"},
	["6540"] = {spellID = 318286, level = "I (|cffffffff15|r/35/66)"},
	["6541"] = {spellID = 318479, level = "II (15/|cffffffff35|r/66)"},
	["6542"] = {spellID = 318480, level = "III (15/35/|cffffffff66|r)"},
	["6573"] = {spellID = 318272, level = "(|cffffffff15|r)"},
	["6546"] = {spellID = 318239, level = "(|cffffffff15|r)"},
	["6571"] = {spellID = 318293, level = "(|cffffffff30|r)"},
	["6572"] = {spellID = 316651, level = "(|cffffffff50|r)"},
	["6567"] = {spellID = 318294, level = "(|cffffffff35|r)"},
	["6568"] = {spellID = 316780, level = "(|cffffffff25|r)"},
	["6570"] = {spellID = 318299, level = "(|cffffffff20|r)"},
	["6569"] = {spellID = 317290, level = "(|cffffffff25|r)"},
}

local linkCache = {}
function TT:Corruption_Search(link)
	local value = linkCache[link]
	if not value then
		local itemString = strmatch(link, "item:([%-?%d:]+)")
		for index in gmatch(itemString, "%d+") do
			if corruptionData[index] then
				value = corruptionData[index]
				linkCache[link] = value
				break
			end
		end
	end
	return value
end

local function getIconString(icon)
	return format("|T%s:14:14:0:0:64:64:5:59:5:59|t ", icon)
end

function TT:Corruption_Convert(name, icon, level)
	for i = 5, self:NumLines() do
		local line = _G[self:GetName().."TextLeft"..i]
		local text = line:GetText()
		if text and strmatch(text, ITEM_MOD_CORRUPTION) then
			line:SetText(text.." - "..getIconString(icon)..name.." "..level)
			return
		end
	end
end

function TT:Corruption_UpdateSpell(value)
	if not value.name or not value.icon then
		value.name, _, value.icon = GetSpellInfo(value.spellID)
	end
end

function TT:Corruption_Update()
	local link = select(2, self:GetItem())
	if link and IsCorruptedItem(link) then
		local value = TT:Corruption_Search(link)
		if value then
			TT:Corruption_UpdateSpell(value)
			TT.Corruption_Convert(self, value.name, value.icon, value.level)
		end
	end
end

local corruptionR, corruptionG, corruptionB = .584, .428, .82
local summaries = {}
function TT:Corruption_Summary(unit)
	wipe(summaries)

	for i = 1, 17 do
		local link = GetInventoryItemLink(unit, i)
		if link and IsCorruptedItem(link) then
			local value = TT:Corruption_Search(link)
			if value then
				TT:Corruption_UpdateSpell(value)
				summaries[value] = (summaries[value] or 0) + 1
			end
		end
	end

	GameTooltip:AddLine(" ")
	for value, count in next, summaries do
		GameTooltip:AddLine(count.." "..getIconString(value.icon)..value.name.." "..value.level, corruptionR, corruptionG, corruptionB)
	end
	if not next(summaries) then
		GameTooltip:AddLine(NONE, corruptionR, corruptionG, corruptionB)
	end
	GameTooltip:Show()
end

function TT:Corruption_PlayerSummary()
	TT:Corruption_Summary("player")
end

function TT:Corruption_InspectSummary()
	if not self.guid then return end
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["CorruptionSummary"], 1,1,1)
	TT:Corruption_Summary(InspectFrame.unit)
end

function TT:Corruption_CreateEye()
	if not InspectFrame.__eye then
		local eye = CreateFrame("Button", nil, InspectFrame)
		eye:SetPoint("BOTTOM", InspectHandsSlot, "TOP", 0, 10)
		eye:SetSize(50, 50)
		eye:SetScript("OnEnter", TT.Corruption_InspectSummary)
		eye:SetScript("OnLeave", B.HideTooltip)

		local tex = eye:CreateTexture()
		tex:SetPoint("TOPRIGHT", 18, 5)
		tex:SetSize(60, 60)
		tex:SetAtlas("bfa-threats-cornereye")

		local hl = eye:CreateTexture(nil, "HIGHLIGHT")
		hl:SetAllPoints(tex)
		hl:SetAtlas("bfa-threats-cornereye")
		hl:SetBlendMode("ADD")

		InspectFrame.__eye = eye
	end
end

function TT:Corruption_UpdateInspect(...)
	if not InspectFrame then return end
	TT:Corruption_CreateEye()

	local guid = ...
	local eye = InspectFrame.__eye
	if InspectFrame.unit and UnitGUID(InspectFrame.unit) == guid then
		eye.guid = guid
	else
		eye.guid = nil
	end
end

function TT:CorruptionRank()
	if not NDuiDB["Tooltip"]["CorruptionRank"] then return end
	if IsAddOnLoaded("CorruptionTooltips") then return end
	if IsAddOnLoaded("CorruptionNameTooltips") then return end

	GameTooltip:HookScript("OnTooltipSetItem", TT.Corruption_Update)
	ItemRefTooltip:HookScript("OnTooltipSetItem", TT.Corruption_Update)
	ShoppingTooltip1:HookScript("OnTooltipSetItem", TT.Corruption_Update)
	ShoppingTooltip2:HookScript("OnTooltipSetItem", TT.Corruption_Update)
	EmbeddedItemTooltip:HookScript("OnTooltipSetItem", TT.Corruption_Update)

	hooksecurefunc("CharacterFrameCorruption_OnEnter", TT.Corruption_PlayerSummary)
	CharacterStatsPane.ItemLevelFrame.Corruption:HookScript("OnEnter", TT.Corruption_PlayerSummary)
	B:RegisterEvent("INSPECT_READY", TT.Corruption_UpdateInspect)
end