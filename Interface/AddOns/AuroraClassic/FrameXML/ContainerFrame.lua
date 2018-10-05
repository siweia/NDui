local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	if not AuroraConfig.bags then return end

	local r, g, b = C.r, C.g, C.b

	BackpackTokenFrame:GetRegions():Hide()

	local function onEnter(self)
		self.bg:SetBackdropBorderColor(r, g, b)
	end

	local function onLeave(self)
		self.bg:SetBackdropBorderColor(0, 0, 0)
	end

	for i = 1, 12 do
		local con = _G["ContainerFrame"..i]
		local name = _G["ContainerFrame"..i.."Name"]

		for j = 1, 5 do
			select(j, con:GetRegions()):SetAlpha(0)
		end
		select(7, con:GetRegions()):SetAlpha(0)

		con.PortraitButton.Highlight:SetTexture("")

		name:ClearAllPoints()
		name:SetPoint("TOP", 0, -10)

		for k = 1, MAX_CONTAINER_ITEMS do
			local item = "ContainerFrame"..i.."Item"..k
			local button = _G[item]
			local border = button.IconBorder
			local searchOverlay = button.searchOverlay
			local questTexture = _G[item.."IconQuestTexture"]
			local newItemTexture = button.NewItemTexture

			questTexture:SetDrawLayer("BACKGROUND")
			questTexture:SetSize(1, 1)

			button:SetNormalTexture("")
			button:SetPushedTexture("")
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

			button.icon:SetTexCoord(.08, .92, .08, .92)

			button.bg = F.CreateBDFrame(button, 0)

			-- easiest way to 'hide' it without breaking stuff
			newItemTexture:SetDrawLayer("BACKGROUND")
			newItemTexture:SetSize(1, 1)

			border:SetPoint("TOPLEFT", -1.2, 1.2)
			border:SetPoint("BOTTOMRIGHT", 1.2, -1.2)
			border:SetDrawLayer("BACKGROUND", 1)

			searchOverlay:SetPoint("TOPLEFT", -1.2, 1.2)
			searchOverlay:SetPoint("BOTTOMRIGHT", 1.2, -1.2)

			button:HookScript("OnEnter", onEnter)
			button:HookScript("OnLeave", onLeave)
		end

		local f = F.CreateBDFrame(con)
		f:SetPoint("TOPLEFT", 8, -4)
		f:SetPoint("BOTTOMRIGHT", -4, 3)

		F.ReskinClose(_G["ContainerFrame"..i.."CloseButton"], "TOPRIGHT", con, "TOPRIGHT", -6, -6)
	end

	for i = 1, 3 do
		local ic = _G["BackpackTokenFrameToken"..i.."Icon"]
		ic:SetDrawLayer("OVERLAY")
		ic:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(ic)
	end

	F.ReskinInput(BagItemSearchBox)

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

			itemButton.IconBorder:SetTexture(C.media.backdrop)
			if _G[name.."Item"..i.."IconQuestTexture"]:IsShown() then
				itemButton.IconBorder:SetVertexColor(1, 1, 0)
			end
		end
	end)

	BagItemAutoSortButton:GetNormalTexture():SetTexCoord(.17, .83, .17, .83)
	BagItemAutoSortButton:GetPushedTexture():SetTexCoord(.17, .83, .17, .83)
	F.CreateBG(BagItemAutoSortButton)
end)