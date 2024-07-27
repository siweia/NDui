local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_ScrappingMachineUI"] = function()
	B.ReskinPortraitFrame(ScrappingMachineFrame)
	B.Reskin(ScrappingMachineFrame.ScrapButton)

	local ItemSlots = ScrappingMachineFrame.ItemSlots
	B.StripTextures(ItemSlots)

	hooksecurefunc(ScrappingMachineFrame, "SetupScrapButtonPool", function(self)
		for button in self.ItemSlots.scrapButtons:EnumerateActive() do
			if not button.bg then
				B.StripTextures(button)
				button.Icon:SetTexCoord(unpack(DB.TexCoord))
				button.bg = B.CreateBDFrame(button.Icon, .25)
				B.ReskinIconBorder(button.IconBorder)
				local hl = button:GetHighlightTexture()
				hl:SetColorTexture(1, 1, 1, .25)
				hl:SetAllPoints(button.Icon)
			end
		end
	end)
end