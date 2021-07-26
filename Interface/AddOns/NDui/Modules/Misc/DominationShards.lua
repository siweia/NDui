local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")
local TT = B:GetModule("Tooltip")

local wipe, pairs, mod, floor = wipe, pairs, mod, floor
local InCombatLockdown = InCombatLockdown
local PickupContainerItem, ClickSocketButton, ClearCursor = PickupContainerItem, ClickSocketButton, ClearCursor
local GetContainerNumSlots, GetContainerItemID, GetContainerItemLink = GetContainerNumSlots, GetContainerItemID, GetContainerItemLink
local GetItemIcon, GetItemCount, GetSocketTypes, GetExistingSocketInfo = GetItemIcon, GetItemCount, GetSocketTypes, GetExistingSocketInfo

local EXTRACTOR_ID = 187532
local foundShards = {}

function M:DomiShard_Equip()
	if not self.itemLink then return end

	PickupContainerItem(self.bagID, self.slotID)
	ClickSocketButton(1)
	ClearCursor()
end

function M:DomiShard_ShowTooltip()
	if not self.itemLink then return end

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
	GameTooltip:SetHyperlink(self.itemLink)
	GameTooltip:Show()
end

function M:DomiShards_Refresh()
	wipe(foundShards)

	for bagID = 0, 4 do
		for slotID = 1, GetContainerNumSlots(bagID) do
			local itemID = GetContainerItemID(bagID, slotID)
			local rank = itemID and TT.DomiRankData[itemID]
			if rank then
				local index = TT.DomiIndexData[itemID]
				if not index then break end

				local button = M.DomiShardsFrame.icons[index]
				button.bagID = bagID
				button.slotID = slotID
				button.itemLink = GetContainerItemLink(bagID, slotID)
				button.count:SetText(rank)
				button.Icon:SetDesaturated(false)

				foundShards[index] = true
			end
		end
	end

	for index, button in pairs(M.DomiShardsFrame.icons) do
		if not foundShards[index] then
			button.itemLink = nil
			button.count:SetText("")
			button.Icon:SetDesaturated(true)
		end
	end
end

function M:DomiShards_ListFrame()
	if M.DomiShardsFrame then return end

	local frame = CreateFrame("Frame", "NDuiDomiShards", ItemSocketingFrame)
	frame:SetSize(102, 102)
	frame:SetPoint("RIGHT", -35, 30)
	frame.icons = {}
	M.DomiShardsFrame = frame

	for index, value in pairs(TT.DomiDataByGroup) do
		for itemID in pairs(value) do
			local button = CreateFrame("Button", nil, frame)
			button:SetSize(30, 30)
			button:SetPoint("TOPLEFT", 3 + mod(index-1, 3)*33, -3 - floor((index-1)/3)*33)
			B.PixelIcon(button, GetItemIcon(itemID), true)
			button:SetScript("OnClick", M.DomiShard_Equip)
			button:SetScript("OnEnter", M.DomiShard_ShowTooltip)
			button:SetScript("OnLeave", B.HideTooltip)
			button.count = B.CreateFS(button, 12, "", "system", "BOTTOMRIGHT", -3, 3)

			frame.icons[index] = button
			break
		end
	end

	M:DomiShards_Refresh()
	B:RegisterEvent("BAG_UPDATE", M.DomiShards_Refresh)
end

function M:DomiShards_ExtractButton()
	if M.DomiExtButton then return end

	if GetItemCount(EXTRACTOR_ID) == 0 then return end
	ItemSocketingSocketButton:SetWidth(80)
	if InCombatLockdown() then return end

	local button = CreateFrame("Button", "NDuiExtractorButton", ItemSocketingFrame, "UIPanelButtonTemplate, SecureActionButtonTemplate")
	button:SetSize(80, 22)
	button:SetText(L["Drop"])
	button:SetPoint("RIGHT", ItemSocketingSocketButton, "LEFT", -3, 0)
	button:SetAttribute("type", "macro")
	button:SetAttribute("macrotext", "/use item:"..EXTRACTOR_ID.."\n/click ItemSocketingSocket1")
	if C.db["Skins"]["BlizzardSkins"] then B.Reskin(button) end

	M.DomiExtButton = button
end

function M:DominationShards()
	hooksecurefunc("ItemSocketingFrame_LoadUI", function()
		if not ItemSocketingFrame then return end

		M:DomiShards_ListFrame()
		M:DomiShards_ExtractButton()

		if M.DomiShardsFrame then
			M.DomiShardsFrame:SetShown(GetSocketTypes(1) == "Domination" and not GetExistingSocketInfo(1))
		end

		if M.DomiExtButton then
			M.DomiExtButton:SetAlpha(GetSocketTypes(1) == "Domination" and GetExistingSocketInfo(1) and 1 or 0)
		end
	end)
end
M:RegisterMisc("DomiShards", M.DominationShards)