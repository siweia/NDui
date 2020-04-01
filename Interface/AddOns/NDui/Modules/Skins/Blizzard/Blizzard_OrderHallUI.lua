local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_OrderHallUI"] = function()
	-- Talent Frame
	local OrderHallTalentFrame = OrderHallTalentFrame

	B.ReskinPortraitFrame(OrderHallTalentFrame)
	B.Reskin(OrderHallTalentFrame.BackButton)
	B.ReskinIcon(OrderHallTalentFrame.Currency.Icon)
	OrderHallTalentFrame.OverlayElements:SetAlpha(0)

	hooksecurefunc(OrderHallTalentFrame, "RefreshAllData", function(self)
		if self.CloseButton.Border then self.CloseButton.Border:SetAlpha(0) end
		if self.CurrencyBG then self.CurrencyBG:SetAlpha(0) end
		B.StripTextures(self)

		for i = 1, self:GetNumChildren() do
			local bu = select(i, self:GetChildren())
			if bu and bu.talent then
				bu.Border:SetAlpha(0)
				if not bu.bg then
					bu.Highlight:SetColorTexture(1, 1, 1, .25)
					bu.bg = B.ReskinIcon(bu.Icon)
				end

				if bu.talent.selected then
					bu.bg:SetBackdropBorderColor(1, 1, 0)
				else
					bu.bg:SetBackdropBorderColor(0, 0, 0)
				end
			end
		end
	end)
end