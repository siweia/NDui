local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if NDuiDB["Bags"]["Enable"] then return end
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end
	if not NDuiDB["Skins"]["DefaultBags"] then return end

	BackpackTokenFrame:GetRegions():Hide()

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
			local questTexture = _G[item.."IconQuestTexture"]
			local newItemTexture = button.NewItemTexture

			questTexture:SetDrawLayer("BACKGROUND")
			questTexture:SetSize(1, 1)

			button:SetNormalTexture("")
			button:SetPushedTexture("")
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

			button.icon:SetTexCoord(unpack(DB.TexCoord))
			button.bg = B.CreateBDFrame(button.icon, .25)

			-- easiest way to 'hide' it without breaking stuff
			newItemTexture:SetDrawLayer("BACKGROUND")
			newItemTexture:SetSize(1, 1)

			button.searchOverlay:SetOutside()
			B.HookIconBorderColor(button.IconBorder)
		end

		local f = B.CreateBDFrame(con, nil, true)
		f:SetPoint("TOPLEFT", 8, -4)
		f:SetPoint("BOTTOMRIGHT", -4, 3)

		B.ReskinClose(_G["ContainerFrame"..i.."CloseButton"], "TOPRIGHT", con, "TOPRIGHT", -6, -6)
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
	end)

	BagItemAutoSortButton:GetNormalTexture():SetTexCoord(.17, .83, .17, .83)
	BagItemAutoSortButton:GetPushedTexture():SetTexCoord(.17, .83, .17, .83)
	B.CreateBDFrame(BagItemAutoSortButton)

	local highlight = BagItemAutoSortButton:GetHighlightTexture()
	highlight:SetColorTexture(1, 1, 1, .25)
	highlight:SetAllPoints(BagItemAutoSortButton)
end)