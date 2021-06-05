local _, ns = ...
local B, C, L, DB = unpack(ns)

local MAX_CONTAINER_ITEMS = 36

local backpackTexture = "Interface\\Buttons\\Button-Backpack-Up"
local bagIDToInvID = {
	[1] = 20,
	[2] = 21,
	[3] = 22,
	[4] = 23,
	[5] = 80,
	[6] = 81,
	[7] = 82,
	[8] = 83,
	[9] = 84,
	[10] = 85,
	[11] = 86,
}

local function createBagIcon(frame, index)
	if not frame.bagIcon then
		frame.bagIcon = frame.PortraitButton:CreateTexture()
		B.ReskinIcon(frame.bagIcon)
		frame.bagIcon:SetPoint("TOPLEFT", 5, -3)
		frame.bagIcon:SetSize(32, 32)
	end
	if index == 1 then
		frame.bagIcon:SetTexture(backpackTexture) -- backpack
	end
end

local function replaceSortTexture(texture)
	texture:SetTexture("Interface\\Icons\\INV_Pet_Broom") -- HD version
	texture:SetTexCoord(unpack(DB.TexCoord))
end

local function ReskinSortButton(button)
	replaceSortTexture(button:GetNormalTexture())
	replaceSortTexture(button:GetPushedTexture())
	B.CreateBDFrame(button)

	local highlight = button:GetHighlightTexture()
	highlight:SetColorTexture(1, 1, 1, .25)
	highlight:SetAllPoints(button)
end

local function ReskinBagSlot(bu)
	bu:SetNormalTexture("")
	bu:SetPushedTexture("")
	bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	bu.searchOverlay:SetOutside()

	bu.icon:SetTexCoord(unpack(DB.TexCoord))
	bu.bg = B.CreateBDFrame(bu.icon, .25)
	B.ReskinIconBorder(bu.IconBorder)

	local questTexture = bu.IconQuestTexture
	if questTexture then
		questTexture:SetDrawLayer("BACKGROUND")
		questTexture:SetSize(1, 1)
	end
end

tinsert(C.defaultThemes, function()
	if C.db["Bags"]["Enable"] then return end
	if not C.db["Skins"]["BlizzardSkins"] then return end
	if not C.db["Skins"]["DefaultBags"] then return end

	-- [[ Bags ]]

	BackpackTokenFrame:GetRegions():Hide()

	for i = 1, 12 do
		local con = _G["ContainerFrame"..i]
		local name = _G["ContainerFrame"..i.."Name"]

		B.StripTextures(con, true)
		con.PortraitButton.Highlight:SetTexture("")
		createBagIcon(con, i)

		name:ClearAllPoints()
		name:SetPoint("TOP", 0, -10)

		for k = 1, MAX_CONTAINER_ITEMS do
			local item = "ContainerFrame"..i.."Item"..k
			local button = _G[item]
			if not button.IconQuestTexture then
				button.IconQuestTexture = _G[item.."IconQuestTexture"]
			end
			ReskinBagSlot(button)
		end

		local f = B.SetBD(con)
		f:SetPoint("TOPLEFT", 8, -4)
		f:SetPoint("BOTTOMRIGHT", -4, 3)

		B.ReskinClose(_G["ContainerFrame"..i.."CloseButton"])
	end

	for i = 1, 3 do
		local ic = _G["BackpackTokenFrameToken"..i.."Icon"]
		B.ReskinIcon(ic)
	end

	B.ReskinInput(BagItemSearchBox)

	hooksecurefunc("ContainerFrame_Update", function(frame)
		local id = frame:GetID()
		local name = frame:GetName()

		if id == 0 then
			BagItemSearchBox:ClearAllPoints()
			BagItemSearchBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 50, -35)
			BagItemAutoSortButton:ClearAllPoints()
			BagItemAutoSortButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -9, -31)
		end

		for i = 1, frame.size do
			local itemButton = _G[name.."Item"..i]
			if _G[name.."Item"..i.."IconQuestTexture"]:IsShown() then
				itemButton.IconBorder:SetVertexColor(1, 1, 0)
			end
		end

		if frame.bagIcon then
			local invID = bagIDToInvID[id]
			if invID then
				local icon = GetInventoryItemTexture("player", invID)
				frame.bagIcon:SetTexture(icon or backpackTexture)
			end
		end
	end)

	ReskinSortButton(BagItemAutoSortButton)

	-- [[ Bank ]]

	BankSlotsFrame:DisableDrawLayer("BORDER")
	BankPortraitTexture:Hide()
	BankFrameMoneyFrameInset:Hide()
	BankFrameMoneyFrameBorder:Hide()

	-- "item slots" and "bag slots" text
	select(9, BankSlotsFrame:GetRegions()):SetDrawLayer("OVERLAY")
	select(10, BankSlotsFrame:GetRegions()):SetDrawLayer("OVERLAY")

	B.ReskinPortraitFrame(BankFrame)
	B.Reskin(BankFramePurchaseButton)
	B.ReskinTab(BankFrameTab1)
	B.ReskinTab(BankFrameTab2)
	B.ReskinInput(BankItemSearchBox)

	for i = 1, 28 do
		ReskinBagSlot(_G["BankFrameItem"..i])
	end

	for i = 1, 7 do
		ReskinBagSlot(BankSlotsFrame["Bag"..i])
	end

	ReskinSortButton(BankItemAutoSortButton)

	hooksecurefunc("BankFrameItemButton_Update", function(button)
		if not button.isBag and button.IconQuestTexture:IsShown() then
			button.IconBorder:SetVertexColor(1, 1, 0)
		end
	end)

	-- [[ Reagent bank ]]

	ReagentBankFrame:DisableDrawLayer("BACKGROUND")
	ReagentBankFrame:DisableDrawLayer("BORDER")
	ReagentBankFrame:DisableDrawLayer("ARTWORK")

	B.Reskin(ReagentBankFrame.DespositButton)
	B.Reskin(ReagentBankFrameUnlockInfoPurchaseButton)

	-- make button more visible
	B.StripTextures(ReagentBankFrameUnlockInfo)
	ReagentBankFrameUnlockInfoBlackBG:SetColorTexture(.1, .1, .1)

	local reagentButtonsStyled = false
	ReagentBankFrame:HookScript("OnShow", function()
		if not reagentButtonsStyled then
			for i = 1, 98 do
				local button = _G["ReagentBankFrameItem"..i]
				ReskinBagSlot(button)
				BankFrameItemButton_Update(button)
			end
			reagentButtonsStyled = true
		end
	end)
end)