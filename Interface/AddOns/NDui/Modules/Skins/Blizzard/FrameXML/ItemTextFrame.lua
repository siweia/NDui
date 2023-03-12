local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	InboxFrameBg:Hide()
	ItemTextPrevPageButton:GetRegions():Hide()
	ItemTextNextPageButton:GetRegions():Hide()
	ItemTextMaterialTopLeft:SetAlpha(0)
	ItemTextMaterialTopRight:SetAlpha(0)
	ItemTextMaterialBotLeft:SetAlpha(0)
	ItemTextMaterialBotRight:SetAlpha(0)

	B.ReskinPortraitFrame(ItemTextFrame)
	if DB.isPatch10_1 then
		B.ReskinTrimScroll(ItemTextScrollFrame.ScrollBar)
	else
		B.ReskinScroll(ItemTextScrollFrameScrollBar)
	end
	B.ReskinArrow(ItemTextPrevPageButton, "left")
	B.ReskinArrow(ItemTextNextPageButton, "right")
	ItemTextFramePageBg:SetAlpha(0)
	ItemTextPageText:SetTextColor("P", 1, 1, 1)
	ItemTextPageText.SetTextColor = B.Dummy
end)