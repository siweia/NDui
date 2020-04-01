local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_WarboardUI"] = function()
	local function forceProgressText(self)
		if self.styled then return end

		self:SetTextColor(1, 1, 1)
		self.SetTextColor = B.Dummy
		self.styled = true
	end

	hooksecurefunc(WarboardQuestChoiceFrame, "Update", function(self)
		if not self.bg then
			self.Background:Hide()
			self.NineSlice:Hide()
			self.Title:DisableDrawLayer("BACKGROUND")
			self.Title.Text:SetTextColor(1, .8, 0)
			self.Title.Text:SetFontObject(SystemFont_Huge2)
			self.BorderFrame.Header:SetAlpha(0)
			B.CreateBDFrame(self.Title, .25)
			B.ReskinClose(self.CloseButton)
			self.CloseButton.Border:SetAlpha(0)
			self.bg = B.SetBD(self)
		end

		self.CloseButton:SetPoint("TOPRIGHT", -2, -2)

		for i = 1, self:GetNumOptions() do
			local option = self.Options[i]
			option.Header.Text:SetTextColor(1, .8, 0)
			option.OptionText:SetTextColor(1, 1, 1)

			for i = 1, option.WidgetContainer:GetNumChildren() do
				local child = select(i, option.WidgetContainer:GetChildren())
				if child.Text then
					child.Text:SetTextColor(1, 1, 1)
				end

				if child.Spell then
					if not child.Spell.bg then
						child.Spell.Border:SetTexture("")
						child.Spell.IconMask:Hide()
						child.Spell.bg = B.ReskinIcon(child.Spell.Icon)
					end

					child.Spell.Text:SetTextColor(1, 1, 1)
				end

				for j = 1, child:GetNumChildren() do
					local child2 = select(j, child:GetChildren())
					if child2 then
						if child2.Text then forceProgressText(child2.Text) end
						if child2.LeadingText then forceProgressText(child2.LeadingText) end
						if child2.Icon and not child2.Icon.bg then
							child2.Icon.bg = B.ReskinIcon(child2.Icon)
						end
					end
				end
			end

			if not option.bg then
				B.Reskin(option.OptionButtonsContainer.OptionButton1)
				B.Reskin(option.OptionButtonsContainer.OptionButton2)
				option.Background:SetAlpha(0)
				local bg = B.CreateBDFrame(option, .25)
				bg:SetPoint("TOPLEFT", -4, 0)
				bg:SetPoint("BOTTOMRIGHT", 4, 0)
				option.bg = bg
			end
		end
	end)
end