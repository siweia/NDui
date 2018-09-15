local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Tooltip")

-- Credit: AzeriteTooltip, by jokair9
function module:AzeriteArmor()
	if not NDuiDB["Tooltip"]["AzeriteArmor"] then return end

	local iconString = "|T%s:18:22:0:0:64:64:5:59:5:59"
	local function getIconString(icon, known)
		if known then
			return format(iconString..":255:255:255|t", icon)
		else
			return format(iconString..":120:120:120|t", icon)
		end
	end

	local function getAzeritePowerInfo(id)
		local powerInfo = C_AzeriteEmpoweredItem.GetPowerInfo(id)
		if powerInfo and powerInfo.spellID then
			local name, _, icon = GetSpellInfo(powerInfo.spellID)
			return name, icon
		end
	end

	local function scanAzeriteTooltip(tooltip, powerName)
		for i = 8, tooltip:NumLines() do
			local line = _G[tooltip:GetName().."TextLeft"..i]
			local text = line:GetText()
			if text and text:find("%- "..powerName) then
				return i
			end
		end
	end

	local function updateAzeriteArmor(self)
		local link = select(2, self:GetItem())
		if not link then return end
		if not C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(link) then return end

		local allTierInfo = C_AzeriteEmpoweredItem.GetAllTierInfoByItemID(link)
		if not allTierInfo then return end

		for i = 1, #allTierInfo do
			local powerIDs = allTierInfo[i].azeritePowerIDs
			if powerIDs[1] == 13 then break end

			local tooltipText, lineIndex = ""
			for index, id in ipairs(powerIDs) do
				local name, icon = getAzeritePowerInfo(id)
				local index = scanAzeriteTooltip(self, name)
				if index then
					tooltipText = tooltipText.." "..getIconString(icon, true)
					lineIndex = index
				else
					tooltipText = tooltipText.." "..getIconString(icon)
				end
			end

			if lineIndex then
				local line = _G[self:GetName().."TextLeft"..lineIndex]
				line:SetText(line:GetText()..tooltipText)
			end
		end
	end

	GameTooltip:HookScript("OnTooltipSetItem", updateAzeriteArmor)
	ItemRefTooltip:HookScript("OnTooltipSetItem", updateAzeriteArmor)
	ShoppingTooltip1:HookScript("OnTooltipSetItem", updateAzeriteArmor)
	WorldMapTooltip.ItemTooltip.Tooltip:HookScript("OnTooltipSetItem", updateAzeriteArmor)
end