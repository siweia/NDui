local F, C = unpack(select(2, ...))

C.themes["Blizzard_ItemSocketingUI"] = function()
	local title = select(18, ItemSocketingFrame:GetRegions())
	title:ClearAllPoints()
	title:SetPoint("TOP", 0, -5)

	for i = 1, MAX_NUM_SOCKETS do
		local bu = _G["ItemSocketingSocket"..i]
		local shine = _G["ItemSocketingSocket"..i.."Shine"]

		_G["ItemSocketingSocket"..i.."BracketFrame"]:Hide()
		_G["ItemSocketingSocket"..i.."Background"]:SetAlpha(0)
		F.StripTextures(bu)

		bu:SetPushedTexture("")
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		bu.icon:SetTexCoord(.08, .92, .08, .92)

		shine:ClearAllPoints()
		shine:SetPoint("TOPLEFT", bu)
		shine:SetPoint("BOTTOMRIGHT", bu, 1, 0)

		bu.bg = F.CreateBDFrame(bu, .25)
	end

	hooksecurefunc("ItemSocketingFrame_Update", function()
		for i = 1, MAX_NUM_SOCKETS do
			local color = GEM_TYPE_INFO[GetSocketTypes(i)]
			_G["ItemSocketingSocket"..i].bg:SetBackdropBorderColor(color.r, color.g, color.b)
		end

		local num = GetNumSockets()
		if num == 3 then
			ItemSocketingSocket1:SetPoint("BOTTOM", ItemSocketingFrame, "BOTTOM", -75, 39)
		elseif num == 2 then
			ItemSocketingSocket1:SetPoint("BOTTOM", ItemSocketingFrame, "BOTTOM", -35, 39)
		else
			ItemSocketingSocket1:SetPoint("BOTTOM", ItemSocketingFrame, "BOTTOM", 0, 39)
		end
		ItemSocketingDescription:SetBackdrop(nil)
	end)

	F.ReskinPortraitFrame(ItemSocketingFrame, true)
	ItemSocketingFrame.BackgroundColor:SetAlpha(0)
	F.CreateBD(ItemSocketingScrollFrame, .25)
	F.Reskin(ItemSocketingSocketButton)
	F.ReskinScroll(ItemSocketingScrollFrameScrollBar)
end