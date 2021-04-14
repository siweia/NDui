local _, ns = ...
local B, C, L, DB = unpack(ns)

local function WhitenProgressText(self)
	if self.styled then return end

	self:SetTextColor(1, 1, 1)
	self.SetTextColor = B.Dummy
	self.styled = true
end

local function ReskinFirstOptionButton(self)
	if not self or self.__bg then return end

	B.StripTextures(self, true)
	B.Reskin(self)
end

local function ReskinSecondOptionButton(self)
	if not self or self.__bg then return end

	B.Reskin(self, nil, true)
end

-- Note: isNewPatch, PlayerChoiceUI rename to PlayerChoice
C.themes["Blizzard_PlayerChoiceUI"] = function()
	hooksecurefunc(PlayerChoiceFrame, "Update", function(self)
		if not self.bg then
			self.BlackBackground:SetAlpha(0)
			self.Background:SetAlpha(0)
			self.NineSlice:SetAlpha(0)
			self.Title:DisableDrawLayer("BACKGROUND")
			self.Title.Text:SetTextColor(1, .8, 0)
			self.Title.Text:SetFontObject(SystemFont_Huge1)
			self.BorderFrame.Header:SetAlpha(0)
			B.CreateBDFrame(self.Title, .25)
			B.ReskinClose(self.CloseButton)
			self.CloseButton.Border:SetAlpha(0)
			self.bg = B.SetBD(self)
		end

		self.CloseButton:SetPoint("TOPRIGHT", self.bg, -2, -2)
		self.bg:SetShown(not IsInJailersTower())

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
						if child2.Text then
							WhitenProgressText(child2.Text)
						end
						if child2.LeadingText then
							WhitenProgressText(child2.LeadingText)
						end
						if child2.Icon and not child2.Icon.bg then
							child2.Icon.bg = B.ReskinIcon(child2.Icon)
						end
					end
				end
			end

			ReskinFirstOptionButton(option.OptionButtonsContainer.button1)
			ReskinSecondOptionButton(option.OptionButtonsContainer.button2)
		end
	end)

	-- artifact selection
	hooksecurefunc(PlayerChoiceFrame, "SetupRewards", function(self)
		for i = 1, self.numActiveOptions do
			local optionFrameRewards = self.Options[i].RewardsFrame.Rewards
			for button in optionFrameRewards.ItemRewardsPool:EnumerateActive() do
				if not button.styled then
					button.Name:SetTextColor(.9, .8, .5)
					B.HideObject(button.IconBorder)
					B.ReskinIcon(button.Icon)

					button.styled = true
				end
			end
		end
		--[[
			pools haven't seen yet:
			optionFrameRewards.CurrencyRewardsPool
			optionFrameRewards.ReputationRewardsPool
		]]
	end)
end