local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	if not NDuiDB["Skins"]["DefaultBags"] then return end

	local r, g, b = DB.r, DB.g, DB.b

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
			B.CreateBDFrame(button, .25)

			-- easiest way to 'hide' it without breaking stuff
			newItemTexture:SetDrawLayer("BACKGROUND")
			newItemTexture:SetSize(1, 1)

			border:SetPoint("TOPLEFT", -C.mult, C.mult)
			border:SetPoint("BOTTOMRIGHT", C.mult, -C.mult)
			border:SetDrawLayer("BACKGROUND", 1)

			searchOverlay:SetPoint("TOPLEFT", -C.mult, C.mult)
			searchOverlay:SetPoint("BOTTOMRIGHT", C.mult, -C.mult)
		end

		local f = B.CreateBDFrame(con)
		f:SetPoint("TOPLEFT", 8, -4)
		f:SetPoint("BOTTOMRIGHT", -4, 3)
		B.CreateSD(f)

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

			itemButton.IconBorder:SetTexture(DB.bdTex)
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