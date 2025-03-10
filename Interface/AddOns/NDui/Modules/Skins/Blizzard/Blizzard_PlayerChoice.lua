local _, ns = ...
local B, C, L, DB = unpack(ns)

local Type_ItemDisplay = Enum.UIWidgetVisualizationType.ItemDisplay

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
	["genericplayerchoice"] = true,
}

local uglyBackground = {
	["ui-frame-genericplayerchoice-cardparchment"] = true
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

			if GenericPlayerChoiceToggleButton then
				B.Reskin(GenericPlayerChoiceToggleButton)
			end
		end

		if self.CloseButton.Border then self.CloseButton.Border:SetAlpha(0) end -- no border for some templates

		local isIgnored = ignoredTextureKit[self.uiTextureKit]
		self.bg:SetShown(not isIgnored)

		if not self.optionFrameTemplate then return end

		for optionFrame in self.optionPools:EnumerateActiveByTemplate(self.optionFrameTemplate) do
			local header = optionFrame.Header
			if header then
				ReskinOptionText(header.Text, 1, .8, 0)
				if header.Contents then ReskinOptionText(header.Contents.Text, 1, .8, 0) end
			end
			ReskinOptionText(optionFrame.OptionText, 1, 1, 1)
			B.ReplaceIconString(optionFrame.OptionText.String)

			if optionFrame.Artwork and isIgnored then optionFrame.Artwork:SetSize(64, 64) end -- fix high resolution icons

			local optionBG = optionFrame.Background
			if optionBG then
				if not optionBG.bg then
					optionBG.bg = B.SetBD(optionBG)
					optionBG.bg:SetInside(optionBG, 4, 4)
				end
				local isUgly = uglyBackground[optionBG:GetAtlas()]
				optionBG:SetShown(not isUgly)
				optionBG.bg:SetShown(isUgly)
			end

			local optionButtonsContainer = optionFrame.OptionButtonsContainer
			if optionButtonsContainer and optionButtonsContainer.buttonFramePool then
				for frame in optionButtonsContainer.buttonFramePool:EnumerateActive() do
					ReskinOptionButton(frame.Button)
				end
			end

			local rewards = optionFrame.Rewards
			if rewards then
				for rewardFrame in rewards.rewardsPool:EnumerateActive() do
					local text = rewardFrame.Name or rewardFrame.Text -- .Text for PlayerChoiceBaseOptionReputationRewardTemplate
					if text then
						ReskinOptionText(text, .9, .8, .5)
					end

					if not rewardFrame.styled then
						-- PlayerChoiceBaseOptionItemRewardTemplate, PlayerChoiceBaseOptionCurrencyContainerRewardTemplate
						local itemButton = rewardFrame.itemButton
						if itemButton then
							B.StripTextures(itemButton, 1)
							itemButton.bg = B.ReskinIcon((itemButton:GetRegions()))
							B.ReskinIconBorder(itemButton.IconBorder, true)
						end
						-- PlayerChoiceBaseOptionCurrencyRewardTemplate
						local count = rewardFrame.Count
						if count then
							rewardFrame.bg = B.ReskinIcon(rewardFrame.Icon)
							B.ReskinIconBorder(rewardFrame.IconBorder, true)
						end

						rewardFrame.styled = true
					end
				end
			end

			local widgetContainer = optionFrame.WidgetContainer
			if widgetContainer and widgetContainer.widgetFrames then
				for _, widgetFrame in pairs(widgetContainer.widgetFrames) do
					ReskinOptionText(widgetFrame.Text, 1, 1, 1)
					if widgetFrame.Spell then
						ReskinSpellWidget(widgetFrame.Spell)
					end
					if widgetFrame.widgetType == Type_ItemDisplay then
						local item = widgetFrame.Item
						if item then
							item.IconMask:Hide()
							item.NameFrame:SetAlpha(0)
							if not item.bg then
								item.bg = B.ReskinIcon(item.Icon)
								item.bg:SetFrameLevel(item.bg:GetFrameLevel() + 1)
								B.ReskinIconBorder(item.IconBorder, true)
							end
						end
					end
				end
			end
		end
	end)
end