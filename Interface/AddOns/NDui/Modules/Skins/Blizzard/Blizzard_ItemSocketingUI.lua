local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_ItemSocketingUI"] = function()
	local GemTypeInfo = {
		Yellow = {r=0.97, g=0.82, b=0.29},
		Red = {r=1, g=0.47, b=0.47},
		Blue = {r=0.47, g=0.67, b=1},
		Hydraulic = {r=1, g=1, b=1},
		Cogwheel = {r=1, g=1, b=1},
		Meta = {r=1, g=1, b=1},
		Prismatic = {r=1, g=1, b=1},
		PunchcardRed = {r=1, g=0.47, b=0.47},
		PunchcardYellow = {r=0.97, g=0.82, b=0.29},
		PunchcardBlue = {r=0.47, g=0.67, b=1},
	}

	for i = 1, MAX_NUM_SOCKETS do
		local bu = _G["ItemSocketingSocket"..i]
		local shine = _G["ItemSocketingSocket"..i.."Shine"]

		_G["ItemSocketingSocket"..i.."BracketFrame"]:Hide()
		_G["ItemSocketingSocket"..i.."Background"]:SetAlpha(0)
		B.StripTextures(bu)

		bu:SetPushedTexture("")
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		bu.icon:SetTexCoord(unpack(DB.TexCoord))

		shine:ClearAllPoints()
		shine:SetPoint("TOPLEFT", bu)
		shine:SetPoint("BOTTOMRIGHT", bu, 1, 0)

		bu.bg = B.CreateBDFrame(bu, .25)
	end

	hooksecurefunc("ItemSocketingFrame_Update", function()
		for i = 1, MAX_NUM_SOCKETS do
			local color = GemTypeInfo[GetSocketTypes(i)]
			_G["ItemSocketingSocket"..i].bg:SetBackdropBorderColor(color.r, color.g, color.b)
		end

		ItemSocketingDescription:HideBackdrop()
	end)

	if not ItemSocketingFrame.CloseButton then
		ItemSocketingFrame.CloseButton = ItemSocketingCloseButton
	end
	B.ReskinPortraitFrame(ItemSocketingFrame, 10, -10, 0, 15)
	B.CreateBDFrame(ItemSocketingScrollFrame, .25)
	B.Reskin(ItemSocketingSocketButton)
	B.ReskinScroll(ItemSocketingScrollFrameScrollBar)
end