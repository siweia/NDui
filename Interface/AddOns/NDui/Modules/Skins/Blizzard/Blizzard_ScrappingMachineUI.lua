local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_ScrappingMachineUI"] = function()
	B.ReskinPortraitFrame(ScrappingMachineFrame)
	B.Reskin(ScrappingMachineFrame.ScrapButton)

	local ItemSlots = ScrappingMachineFrame.ItemSlots
	B.StripTextures(ItemSlots)

	for button in pairs(ItemSlots.scrapButtons.activeObjects) do
		B.StripTextures(button)
		button.IconBorder:SetAlpha(0)
		button.Icon:SetTexCoord(unpack(DB.TexCoord))
		button.bg = B.CreateBDFrame(button.Icon, .25)
		local hl = button:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetAllPoints(button.Icon)
		B.HookIconBorderColor(button.IconBorder)
	end
end