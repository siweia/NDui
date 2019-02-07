local F, C = unpack(select(2, ...))

C.themes["Blizzard_OrderHallUI"] = function()
	-- Talent Frame
	local OrderHallTalentFrame = OrderHallTalentFrame

	F.ReskinPortraitFrame(OrderHallTalentFrame)
	F.Reskin(OrderHallTalentFrame.BackButton)
	F.ReskinIcon(OrderHallTalentFrame.Currency.Icon)
	OrderHallTalentFrame.OverlayElements:SetAlpha(0)

	hooksecurefunc(OrderHallTalentFrame, "RefreshAllData", function(self)
		if self.CloseButton.Border then self.CloseButton.Border:SetAlpha(0) end
		if self.CurrencyBG then self.CurrencyBG:SetAlpha(0) end
		F.StripTextures(self)

		for i = 1, self:GetNumChildren() do
			local bu = select(i, self:GetChildren())
			if bu and bu.talent then
				bu.Border:SetAlpha(0)
				if not bu.bg then
					bu.Icon:SetTexCoord(.08, .92, .08, .92)
					bu.Highlight:SetColorTexture(1, 1, 1, .25)
					bu.bg = F.CreateBDFrame(bu.Icon)
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