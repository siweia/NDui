local _, ns = ...
local B, C, L, DB = unpack(ns)

local function ReskinOptionText(text, r, g, b)
	if text then
		text:SetTextColor(r, g, b)
	end
end

-- Needs review, still buggy on blizz
local function ReskinOptionButton(self)
	if not self or self.__bg then return end

	B.StripTextures(self, true)
	B.Reskin(self)
end

local function ReskinSpellWidget(spell)
	if not spell.bg then
		spell.Border:SetAlpha(0)
		spell.bg = B.ReskinIcon(spell.Icon)
	end

	spell.IconMask:Hide()
	spell.Text:SetTextColor(1, 1, 1)
end

local ignoredTextureKit = {
	["jailerstower"] = true,
	["cypherchoice"] = true,
}
C.themes["Blizzard_PlayerChoice"] = function()
	hooksecurefunc(PlayerChoiceFrame, "TryShow", function(self)
		if not self.bg then
			self.BlackBackground:SetAlpha(0)
			self.Background:SetAlpha(0)
			self.NineSlice:SetAlpha(0)
			self.Title:DisableDrawLayer("BACKGROUND")
			self.Title.Text:SetTextColor(1, .8, 0)
			self.Title.Text:SetFontObject(SystemFont_Huge1)
			B.CreateBDFrame(self.Title, .25)
			B.ReskinClose(self.CloseButton)
			self.bg = B.SetBD(self)
		end

		self.CloseButton:SetPoint("TOPRIGHT", self.bg, -4, -4)
		if self.CloseButton.Border then self.CloseButton.Border:SetAlpha(0) end -- no border for some templates

		self.bg:SetShown(not ignoredTextureKit[self.uiTextureKit])

		if not self.optionFrameTemplate then return end -- isNewPatch

		for optionFrame in self.optionPools:EnumerateActiveByTemplate(self.optionFrameTemplate) do
			local header = optionFrame.Header
			if header then
				ReskinOptionText(header.Text, 1, .8, 0)
				if header.Contents then ReskinOptionText(header.Contents.Text, 1, .8, 0) end
			end
			ReskinOptionText(optionFrame.OptionText, 1, 1, 1)
			B.ReplaceIconString(optionFrame.OptionText.String)

			local optionButtonsContainer = optionFrame.OptionButtonsContainer
			if optionButtonsContainer and optionButtonsContainer.buttonPool then
				for button in optionButtonsContainer.buttonPool:EnumerateActive() do
					ReskinOptionButton(button)
				end
			end

			local rewards = optionFrame.Rewards
			if rewards then
				for rewardFrame in rewards.rewardsPool:EnumerateActiveByTemplate("PlayerChoiceBaseOptionItemRewardTemplate") do
					ReskinOptionText(rewardFrame.Name, .9, .8, .5)
					if not rewardFrame.styled then
						local itemButton = rewardFrame.itemButton
						B.StripTextures(itemButton, 1)
						itemButton.bg = B.ReskinIcon(itemButton:GetRegions(), nil)
						B.ReskinIconBorder(itemButton.IconBorder, true)

						rewardFrame.styled = true
					end
				end

				--[[ unseen templates
					PlayerChoiceBaseOptionCurrencyContainerRewardTemplate
					PlayerChoiceBaseOptionCurrencyRewardTemplate
					PlayerChoiceBaseOptionReputationRewardTemplate
				]]
			end

			local widgetContainer = optionFrame.WidgetContainer
			if widgetContainer and widgetContainer.widgetFrames then
				for _, widgetFrame in pairs(widgetContainer.widgetFrames) do
					ReskinOptionText(widgetFrame.Text, 1, 1, 1)
					if widgetFrame.Spell then
						ReskinSpellWidget(widgetFrame.Spell)
					end
				end
			end
		end
	end)
end