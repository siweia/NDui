local _, ns = ...
local B, C, L, DB = unpack(ns)

local ContainerIDToInventoryID = C_Container and C_Container.ContainerIDToInventoryID or ContainerIDToInventoryID

local backpackTexture = "Interface\\Buttons\\Button-Backpack-Up"

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

local function styleBankButton(bu)
	bu:SetNormalTexture(0)
	bu:SetPushedTexture(0)
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

	local highlightTexture = bu.HighlightFrame and bu.HighlightFrame.HighlightTexture
	if highlightTexture then
		highlightTexture:SetColorTexture(1, .8, 0, .5)
	end
end

tinsert(C.defaultThemes, function()
	if C.db["Bags"]["Enable"] then return end
	if not C.db["Skins"]["DefaultBags"] then return end

	-- Bags

	for i = 1, 12 do
		local con = _G["ContainerFrame"..i]
		local name = _G["ContainerFrame"..i.."Name"]

		B.StripTextures(con, 0)
		createBagIcon(con, i)
		name:ClearAllPoints()
		name:SetPoint("TOP", 0, -10)

		for k = 1, MAX_CONTAINER_ITEMS do
			local item = "ContainerFrame"..i.."Item"..k
			local button = _G[item]
			local questTexture = _G[item.."IconQuestTexture"]

			questTexture:SetDrawLayer("BACKGROUND")
			questTexture:SetSize(1, 1)

			button:SetNormalTexture(0)
			button:SetPushedTexture(0)
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

			button.icon:SetTexCoord(unpack(DB.TexCoord))
			button.bg = B.CreateBDFrame(button, .25)

			button.searchOverlay:SetOutside()
			B.ReskinIconBorder(button.IconBorder)
		end

		local f = B.SetBD(con)
		f:SetPoint("TOPLEFT", 8, -4)
		f:SetPoint("BOTTOMRIGHT", -4, 3)

		B.ReskinClose(_G["ContainerFrame"..i.."CloseButton"], con, -6, -6)
	end

	hooksecurefunc("ContainerFrame_Update", function(frame)
		local id = frame:GetID()
		local name = frame:GetName()

		for i = 1, frame.size do
			local itemButton = _G[name.."Item"..i]
			if _G[name.."Item"..i.."IconQuestTexture"]:IsShown() then
				itemButton.IconBorder:SetVertexColor(1, 1, 0)
			end
		end

		if frame.bagIcon and id ~= 0 then
			local invID = ContainerIDToInventoryID(id)
			if invID then
				local icon = GetInventoryItemTexture("player", invID)
				frame.bagIcon:SetTexture(icon or backpackTexture)
			end
		end
	end)

	-- Bank

	BankFrame.CloseButton = BankCloseButton
	B.ReskinPortraitFrame(BankFrame, 15, -10, 10, 80)
	B.Reskin(BankFramePurchaseButton)
	BankSlotsFrame:DisableDrawLayer("BORDER")
	BankPortraitTexture:Hide()

	for i = 1, NUM_BANKGENERIC_SLOTS do
		styleBankButton(_G["BankFrameItem"..i])
	end

	for i = 1, NUM_BANKBAGSLOTS do
		styleBankButton(BankSlotsFrame["Bag"..i])
	end

	hooksecurefunc("BankFrameItemButton_Update", function(button)
		if not button.isBag and button.IconQuestTexture:IsShown() then
			button.IconBorder:SetVertexColor(1, 1, 0)
		end
	end)
end)