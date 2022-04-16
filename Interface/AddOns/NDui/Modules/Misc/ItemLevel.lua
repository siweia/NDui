local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local pairs, select, next, wipe = pairs, select, next, wipe
local UnitGUID, GetItemInfo = UnitGUID, GetItemInfo
local GetInventoryItemLink = GetInventoryItemLink
local GetTradePlayerItemLink, GetTradeTargetItemLink = GetTradePlayerItemLink, GetTradeTargetItemLink

local inspectSlots = {
	"Head",
	"Neck",
	"Shoulder",
	"Shirt",
	"Chest",
	"Waist",
	"Legs",
	"Feet",
	"Wrist",
	"Hands",
	"Finger0",
	"Finger1",
	"Trinket0",
	"Trinket1",
	"Back",
	"MainHand",
	"SecondaryHand",
	"Ranged",
}

function M:GetSlotAnchor(index)
	if not index then return end

	if index <= 5 or index == 9 or index == 15 then
		return "BOTTOMLEFT", 40, 20
	elseif index == 16 then
		return "BOTTOMRIGHT", -40, 2
	elseif index == 17 then
		return "BOTTOMLEFT", 40, 2
	else
		return "BOTTOMRIGHT", -40, 20
	end
end

function M:CreateItemTexture(slot, relF, x, y)
	local icon = slot:CreateTexture()
	icon:SetPoint(relF, x, y)
	icon:SetSize(14, 14)
	icon.bg = B.ReskinIcon(icon)
	icon.bg:SetFrameLevel(3)
	icon.bg:Hide()

	return icon
end

function M:CreateColorBorder()
	if C.db["Skins"]["BlizzardSkins"] then return end

	local frame = CreateFrame("Frame", nil, self)
	frame:SetAllPoints()
	self.colorBG = B.CreateSD(frame, 4, true)
	self.colorBG:SetFrameLevel(5)
end

function M:CreateItemString(frame, strType)
	if frame.fontCreated then return end

	for index, slot in pairs(inspectSlots) do
		--if index ~= 4 then	-- need color border for some shirts
			local slotFrame = _G[strType..slot.."Slot"]
			slotFrame.iLvlText = B.CreateFS(slotFrame, DB.Font[2]+1)
			slotFrame.iLvlText:ClearAllPoints()
			slotFrame.iLvlText:SetPoint("BOTTOMLEFT", slotFrame, 1, 1)
			local relF, x = M:GetSlotAnchor(index)
			for i = 1, 5 do
				local offset = (i-1)*18 + 5
				local iconX = x > 0 and x+offset or x-offset
				local iconY = index > 15 and 20 or 2
				slotFrame["textureIcon"..i] = M:CreateItemTexture(slotFrame, relF, iconX, iconY)
			end
			M.CreateColorBorder(slotFrame)
		--end
	end

	frame.fontCreated = true
end

function M:ItemBorderSetColor(slotFrame, r, g, b)
	if slotFrame.colorBG then
		slotFrame.colorBG:SetBackdropBorderColor(r, g, b)
	end
	if slotFrame.bg then
		slotFrame.bg:SetBackdropBorderColor(r, g, b)
	end
end

local pending = {}

local gemSlotBlackList = {
	[16]=true, [17]=true, [18]=true,	-- ignore weapons, until I find a better way
}
function M:ItemLevel_UpdateGemInfo(link, unit, index, slotFrame)
	if C.db["Misc"]["GemNEnchant"] and not gemSlotBlackList[index] then
		local info = B.GetItemLevel(link, unit, index, true)
		if info then
			local gemStep = 1
			for i = 1, 5 do
				local texture = slotFrame["textureIcon"..i]
				local bg = texture.bg
				local gem = info.gems and info.gems[gemStep]
				if gem then
					texture:SetTexture(gem)
					bg:SetBackdropBorderColor(0, 0, 0)
					bg:Show()
		
					gemStep = gemStep + 1
				end
			end
		end
	end
end

function M:RefreshButtonInfo()
	local unit = InspectFrame and InspectFrame.unit
	if unit then
		for index, slotFrame in pairs(pending) do
			local link = GetInventoryItemLink(unit, index)
			if link then
				local quality, level = select(3, GetItemInfo(link))
				if quality then
					local color = DB.QualityColors[quality]
					M:ItemBorderSetColor(slotFrame, color.r, color.g, color.b)
					if C.db["Misc"]["ShowItemLevel"] and level and level > 1 and quality > 1 then
						slotFrame.iLvlText:SetText(level)
						slotFrame.iLvlText:SetTextColor(color.r, color.g, color.b)
					end
					M:ItemLevel_UpdateGemInfo(link, unit, index, slotFrame)
					M:UpdateInspectILvl()

					pending[index] = nil
				end
			end
		end

		if not next(pending) then
			self:Hide()
			return
		end
	else
		wipe(pending)
		self:Hide()
	end
end

function M:ItemLevel_SetupLevel(frame, strType, unit)
	if not UnitExists(unit) then return end

	M:CreateItemString(frame, strType)

	for index, slot in pairs(inspectSlots) do
		--if index ~= 4 then
			local slotFrame = _G[strType..slot.."Slot"]
			slotFrame.iLvlText:SetText("")
			for i = 1, 5 do
				local texture = slotFrame["textureIcon"..i]
				texture:SetTexture(nil)
				texture.bg:Hide()
			end
			M:ItemBorderSetColor(slotFrame, 0, 0, 0)

			local itemTexture = GetInventoryItemTexture(unit, index)
			if itemTexture then
				local link = GetInventoryItemLink(unit, index)
				if link then
					local quality, level = select(3, GetItemInfo(link))
					if quality then
						local color = DB.QualityColors[quality]
						M:ItemBorderSetColor(slotFrame, color.r, color.g, color.b)
						if C.db["Misc"]["ShowItemLevel"] and level and level > 1 and quality > 1 then
							slotFrame.iLvlText:SetText(level)
							slotFrame.iLvlText:SetTextColor(color.r, color.g, color.b)
						end

						M:ItemLevel_UpdateGemInfo(link, unit, index, slotFrame)
					else
						pending[index] = slotFrame
						M.QualityUpdater:Show()
					end
				else
					pending[index] = slotFrame
					M.QualityUpdater:Show()
				end
			end
		--end
	end
end

function M:ItemLevel_UpdatePlayer()
	M:ItemLevel_SetupLevel(CharacterFrame, "Character", "player")
end

function M:UpdateInspectILvl()
	if not M.InspectILvl then return end

	M:UpdateUnitILvl(InspectFrame.unit, M.InspectILvl)
	M.InspectILvl:SetFormattedText("iLvl %s", M.InspectILvl:GetText())
end

local anchored
local function AnchorInspectRotate()
	if anchored then return end
	InspectModelFrameRotateRightButton:ClearAllPoints()
	InspectModelFrameRotateRightButton:SetPoint("BOTTOMLEFT", InspectFrameTab1, "TOPLEFT", 0, 2)

	M.InspectILvl = B.CreateFS(InspectPaperDollFrame, 15)
	M.InspectILvl:ClearAllPoints()
	M.InspectILvl:SetPoint("TOP", InspectLevelText, "BOTTOM", 0, -4)

	anchored = true
end

function M:ItemLevel_UpdateInspect(...)
	local guid = ...
	if InspectFrame and InspectFrame.unit and UnitGUID(InspectFrame.unit) == guid then
		AnchorInspectRotate()
		M:ItemLevel_SetupLevel(InspectFrame, "Inspect", InspectFrame.unit)
		M:UpdateInspectILvl()
	end
end

local function GetItemQualityAndLevel(link)
	local _, _, quality, level, _, _, _, _, _, _, _, classID = GetItemInfo(link)
	if quality and quality > 1 and level > 1 and DB.iLvlClassIDs[classID] then
		return quality, level
	end
end

function M:ItemLevel_UpdateMerchant(link)
	if not self.iLvl then
		self.iLvl = B.CreateFS(_G[self:GetName().."ItemButton"], DB.Font[2]+1, "", false, "BOTTOMLEFT", 1, 1)
	end
	self.iLvl:SetText("")
	if link then
		local quality, level = GetItemQualityAndLevel(link)
		if quality and level then
			local color = DB.QualityColors[quality]
			self.iLvl:SetText(level)
			self.iLvl:SetTextColor(color.r, color.g, color.b)
		end
	end
end

function M.ItemLevel_UpdateTradePlayer(index)
	local button = _G["TradePlayerItem"..index]
	local link = GetTradePlayerItemLink(index)
	M.ItemLevel_UpdateMerchant(button, link)
end

function M.ItemLevel_UpdateTradeTarget(index)
	local button = _G["TradeRecipientItem"..index]
	local link = GetTradeTargetItemLink(index)
	M.ItemLevel_UpdateMerchant(button, link)
end

function M:ShowItemLevel()
	if not C.db["Misc"]["ItemLevel"] then return end

	-- iLvl on CharacterFrame
	CharacterFrame:HookScript("OnShow", M.ItemLevel_UpdatePlayer)
	B:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", M.ItemLevel_UpdatePlayer)
	CharacterModelFrameRotateRightButton:ClearAllPoints()
	CharacterModelFrameRotateRightButton:SetPoint("BOTTOMLEFT", CharacterFrameTab1, "TOPLEFT", 0, 2)

	-- iLvl on InspectFrame
	B:RegisterEvent("INSPECT_READY", M.ItemLevel_UpdateInspect)

	-- Update item quality
	M.QualityUpdater = CreateFrame("Frame")
	M.QualityUpdater:Hide()
	M.QualityUpdater:SetScript("OnUpdate", M.RefreshButtonInfo)

	-- iLvl on MerchantFrame
	hooksecurefunc("MerchantFrameItem_UpdateQuality", M.ItemLevel_UpdateMerchant)

	-- iLvl on TradeFrame
	hooksecurefunc("TradeFrame_UpdatePlayerItem", M.ItemLevel_UpdateTradePlayer)
	hooksecurefunc("TradeFrame_UpdateTargetItem", M.ItemLevel_UpdateTradeTarget)
end
M:RegisterMisc("GearInfo", M.ShowItemLevel)