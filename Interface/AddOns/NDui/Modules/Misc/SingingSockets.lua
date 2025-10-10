local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local iconSize = 36

local gemsInfo = {
	[1] = {228638, 228634, 228642, 228648},
	[2] = {228647, 228639, 228644, 228636},
	[3] = {228640, 228646, 228643, 228635}
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
	local info = GetGemLink(self.gemID)
	if not info then return end
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 3)
	GameTooltip:SetHyperlink(info)
	GameTooltip:Show()
end

function M:Socket_OnClick()
	for bagID = 0, 4 do
		for slotID = 1, C_Container.GetContainerNumSlots(bagID) do
			if C_Container.GetContainerItemID(bagID, slotID) == self.gemID then
				C_Container.PickupContainerItem(bagID, slotID)
				C_ItemSocketInfo.ClickSocketButton(self.socketID)
				ClearCursor()
				return
			end
		end
	end
end

function M:CreateSingingSockets()
	if M.SingingFrames then return end
	M.SingingFrames = {}

	for i = 1, 3 do
		local frame = CreateFrame("Frame", "NDuiSingingSocket"..i, ItemSocketingFrame)
		frame:SetSize(iconSize*2, iconSize*2)
		frame:SetPoint("TOP", ItemSocketingFrame.SocketingContainer.SocketFrames[i], "BOTTOM", 0, -50)
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

local fiberSockets = {238044, 238046, 238045, 238042, 238040, 238037, 238039, 238041}

function M:CreateFiberSockets()
	if M.FiberSockets then return end

	local locales = {L["Crit"], L["Mastery"], L["Haste"], L["Versa"]}

	local frame = CreateFrame("Frame", "NDuiFiberSockets", ItemSocketingFrame)
	frame:SetSize(iconSize*4, iconSize*2)
	frame:SetPoint("TOP", ItemSocketingFrame.SocketingContainer.Socket1, "BOTTOM", 0, -50)
	B.SetBD(frame)

	for index, gemID in pairs(fiberSockets)  do
		local button = B.CreateButton(frame, iconSize, iconSize, true, C_Item.GetItemIconByID(gemID))
		button:SetPoint("TOPLEFT", mod(index-1, 4)*(iconSize+5), -(index>4 and (iconSize+5) or 0))
		local colors = DB.QualityColors[index <= 4 and 4 or 3]
		button.bg:SetBackdropBorderColor(colors.r, colors.g, colors.b)
		button.socketID = 1
		button.gemID = gemID
		button:SetScript("OnEnter", M.Socket_OnEnter)
		button:SetScript("OnClick", M.Socket_OnClick)
		button:SetScript("OnLeave", GameTooltip_Hide)
		B.CreateFS(button, 14, locales[mod(index-1,4)+1], "system")
	end

	M.FiberSockets = frame
end

function M:SetupSingingSockets()
	if not C.db["Misc"]["SingingSocket"] then return end

	hooksecurefunc("ItemSocketingFrame_LoadUI", function()
		if not ItemSocketingFrame then return end

		if M.SingingFrames then
			for i = 1, 3 do M.SingingFrames[i]:Hide() end
		end
		if M.FiberSockets then M.FiberSockets:Hide() end

		local socketType = C_ItemSocketInfo.GetSocketTypes(1)
		if socketType == "SingingThunder" then
			M:CreateSingingSockets()
			for i = 1, 3 do
				M.SingingFrames[i]:SetShown(not C_ItemSocketInfo.GetExistingSocketInfo(i))
			end
		elseif socketType == "Fiber" then
			M:CreateFiberSockets()
			M.FiberSockets:SetShown(not C_ItemSocketInfo.GetExistingSocketInfo(1))
		end
	end)
end

M:RegisterMisc("SingingSockets", M.SetupSingingSockets)