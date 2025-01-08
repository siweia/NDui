local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local iconSize = 36

local gemsInfo = {
	[1] = {228638, 228634, 228642, 228648},
	[2] = {228647, 228639, 228644, 228636},
	[3] = {228640, 228646, 228643, 228635},
}

local gemCache = {}
local function GetGemLink(gemID)
	local info = gemCache[gemID]
	if not info then
		info = select(2, C_Item.GetItemInfo(gemID))
		gemCache[gemID] = info
	end
	return info
end

function M:Socket_OnEnter()
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 3)
	GameTooltip:SetHyperlink(GetGemLink(self.gemID))
	GameTooltip:Show()
end

function M:Socket_OnClick()
	local BAG_ID, SLOT_ID

	for bagID = 0, 4 do
		for slotID = 1, C_Container.GetContainerNumSlots(bagID) do
			local itemID = C_Container.GetContainerItemID(bagID, slotID)
			if itemID == self.gemID then
				BAG_ID = bagID
				SLOT_ID = slotID
			end
		end
	end

	if BAG_ID and SLOT_ID then
		C_Container.PickupContainerItem(BAG_ID, SLOT_ID)
		ClickSocketButton(self.socketID)
		ClearCursor()
	end
end

function M:CreateSingingSockets()
	if M.SingingFrames then return end
	M.SingingFrames = {}

	for i = 1, 3 do
		local frame = CreateFrame("Frame", "NDuiSingingSocket"..i, ItemSocketingFrame)
		frame:SetSize(iconSize*2, iconSize*2)
		frame:SetPoint("TOP", _G["ItemSocketingSocket"..i], "BOTTOM", 0, -50)
		B.SetBD(frame)
		M.SingingFrames[i] = frame

		local index = 0
		for _, gemID in next, gemsInfo[i] do
			local button = B.CreateButton(frame, iconSize, iconSize, true, C_Item.GetItemIconByID(gemID))
			button:SetPoint("TOPLEFT", mod(index, 2)*iconSize, -(index>1 and iconSize or 0))
			index = index + 1

			button.socketID = i
			button.gemID = gemID
			button:SetScript("OnEnter", M.Socket_OnEnter)
			button:SetScript("OnClick", M.Socket_OnClick)
			button:SetScript("OnLeave", GameTooltip_Hide)
		end
	end
end

function M:SetupSingingSokcets()
	if not C.db["Misc"]["SingingSocket"] then return end

	hooksecurefunc("ItemSocketingFrame_LoadUI", function()
		if not ItemSocketingFrame then return end

		M:CreateSingingSockets()

		if M.SingingFrames then
			local isSingingSocket = GetSocketTypes(1) == "SingingThunder"
			for i = 1, 3 do
				M.SingingFrames[i]:SetShown(isSingingSocket and not GetExistingSocketInfo(i))
			end
		end
	end)
end

M:RegisterMisc("SingingSockets", M.SetupSingingSokcets)