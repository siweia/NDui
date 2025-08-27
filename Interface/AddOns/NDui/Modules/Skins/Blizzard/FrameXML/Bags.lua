local _, ns = ...
local B, C, L, DB = unpack(ns)

local MAX_CONTAINER_ITEMS = 36
local backpackTexture = "Interface\\Icons\\inv_misc_bag_08"

local function handleMoneyFrame(frame)
	if frame.MoneyFrame then
		B.StripTextures(frame.MoneyFrame)
		B.CreateBDFrame(frame.MoneyFrame, .25)
	end
end

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
	handleMoneyFrame(frame)
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
	if not bu then return end
	bu:SetNormalTexture(0)
	bu:SetPushedTexture(0)
	if bu.Background then bu.Background:SetAlpha(0) end
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

	local hl = bu.SlotHighlightTexture
	if hl then
		hl:SetColorTexture(1, .8, 0, .5)
	end
end

local function updateContainer(frame)
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
		local questTexture = _G[name.."Item"..i.."IconQuestTexture"]
		if itemButton and questTexture:IsShown() then
			itemButton.IconBorder:SetVertexColor(1, 1, 0)
		end
	end

	if frame.bagIcon and id ~= 0 then
		local invID = C_Container.ContainerIDToInventoryID(id)
		if invID then
			local icon = GetInventoryItemTexture("player", invID)
			frame.bagIcon:SetTexture(icon or backpackTexture)
		end
	end
end

local function emptySlotBG(button)
	if button.ItemSlotBackground then
		button.ItemSlotBackground:Hide()
	end
end

local function handleBagSlots(self)
	for button in self.itemButtonPool:EnumerateActive() do
		if not button.bg then
			ReskinBagSlot(button)
		end
	end
end

local function handleBankTab(tab)
	if not tab.styled then
		tab.Border:SetAlpha(0)
		tab:SetNormalTexture(0)
		tab:SetPushedTexture(0)
		tab:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		tab.SelectedTexture:SetTexture(DB.pushedTex)
		B.CreateBDFrame(tab)
		tab.Icon:SetTexCoord(unpack(DB.TexCoord))

		tab.styled = true
	end
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	for i = 1, 13 do
		local frameName = "ContainerFrame"..i
		local frame = _G[frameName]
		if frame then
			local name = frame.TitleText or _G[frameName.."TitleText"]
			name:SetDrawLayer("OVERLAY")
			name:ClearAllPoints()
			name:SetPoint("TOP", 0, -10)
			B.ReskinClose(frame.CloseButton)

			B.StripTextures(frame)
			B.SetBD(frame)
			frame.PortraitContainer:Hide()
			if frame.Bg then frame.Bg:Hide() end
			createBagIcon(frame, i)
			hooksecurefunc(frame, "Update", updateContainer)
			hooksecurefunc(frame, "UpdateItemSlots", handleBagSlots)
		end
	end

	B.StripTextures(BackpackTokenFrame)
	B.CreateBDFrame(BackpackTokenFrame, .25)

	hooksecurefunc(BackpackTokenFrame, "Update", function(self)
		local tokens = self.Tokens
		if next(tokens) then
			for i = 1, #tokens do
				local token = tokens[i]
				if not token.styled then
					B.ReskinIcon(token.Icon)
					token.styled = true
				end
			end
		end
	end)

	B.ReskinEditBox(BagItemSearchBox)
	ReskinSortButton(BagItemAutoSortButton)

	-- Combined bags
	B.ReskinPortraitFrame(ContainerFrameCombinedBags)
	createBagIcon(ContainerFrameCombinedBags, 1)
	ContainerFrameCombinedBags.PortraitButton.Highlight:SetTexture("")
	hooksecurefunc(ContainerFrameCombinedBags, "UpdateItemSlots", handleBagSlots)

	-- [[ Bank ]]

	handleMoneyFrame(BankPanel)
	B.StripTextures(BankPanel)
	BankPanel.EdgeShadows:Hide()
	ReskinSortButton(BankPanel.AutoSortButton)
	B.Reskin(BankPanel.AutoDepositFrame.DepositButton)
	B.ReskinCheck(BankPanel.AutoDepositFrame.IncludeReagentsCheckbox)
	B.Reskin(BankPanel.MoneyFrame.WithdrawButton)
	B.Reskin(BankPanel.MoneyFrame.DepositButton)

	hooksecurefunc(BankPanel, "GenerateItemSlotsForSelectedTab", handleBagSlots)

	hooksecurefunc(BankPanel, "RefreshBankTabs", function(self)
		for tab in self.bankTabPool:EnumerateActive() do
			handleBankTab(tab)
		end
	end)
	handleBankTab(BankPanel.PurchaseTab)

	for i = 1, 3 do
		local tab = select(i, BankFrame.TabSystem:GetChildren())
		if tab then
			B.ReskinTab(tab)
		end
	end

	B.ReskinPortraitFrame(BankFrame)
	B.ReskinInput(BankItemSearchBox)

	local popup = BankCleanUpConfirmationPopup
	if popup then
		B.StripTextures(popup)
		B.SetBD(popup)
		B.Reskin(popup.AcceptButton)
		B.Reskin(popup.CancelButton)
		B.ReskinCheck(popup.HidePopupCheckbox.Checkbox)
	end

	local menu = BankPanel.TabSettingsMenu
	if menu then
		B.StripTextures(menu)
		B.ReskinIconSelector(menu)
		menu.DepositSettingsMenu:DisableDrawLayer("OVERLAY")

		for _, child in pairs({menu.DepositSettingsMenu:GetChildren()}) do
			if child:IsObjectType("CheckButton") then
				B.ReskinCheck(child)
				child:SetSize(24, 24)
			elseif child.Arrow then
				B.ReskinDropDown(child)
			end
		end
	end
end)