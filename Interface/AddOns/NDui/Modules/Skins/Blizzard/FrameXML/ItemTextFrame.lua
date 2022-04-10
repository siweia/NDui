local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	InboxFrameBg:Hide()
	ItemTextPrevPageButton:GetRegions():Hide()
	ItemTextNextPageButton:GetRegions():Hide()
	ItemTextMaterialTopLeft:SetAlpha(0)
	ItemTextMaterialTopRight:SetAlpha(0)
	ItemTextMaterialBotLeft:SetAlpha(0)
	ItemTextMaterialBotRight:SetAlpha(0)

	ItemTextFrame.CloseButton = ItemTextCloseButton
	B.ReskinPortraitFrame(ItemTextFrame, 15, -15, -30, 65)
	B.ReskinScroll(ItemTextScrollFrameScrollBar)
	B.ReskinArrow(ItemTextPrevPageButton, "left")
	B.ReskinArrow(ItemTextNextPageButton, "right")
	--ItemTextFramePageBg:SetAlpha(0)
	ItemTextPageText:SetTextColor(1, 1, 1)
	ItemTextPageText.SetTextColor = B.Dummy

	-- fix scrollbar bg, need reviewed
	ItemTextScrollFrame:DisableDrawLayer("ARTWORK")
	ItemTextScrollFrame:DisableDrawLayer("BACKGROUND")
end)