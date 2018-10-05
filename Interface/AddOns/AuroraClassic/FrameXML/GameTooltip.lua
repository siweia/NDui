local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	F.ReskinClose(ItemRefCloseButton)

	if not AuroraConfig.tooltips then return end

	local tooltips = {
		ChatMenu,
		EmoteMenu,
		LanguageMenu,
		VoiceMacroMenu,
		GameTooltip,
		EmbeddedItemTooltip,
		ItemRefTooltip,
		ItemRefShoppingTooltip1,
		ItemRefShoppingTooltip2,
		ShoppingTooltip1,
		ShoppingTooltip2,
		AutoCompleteBox,
		FriendsTooltip,
		WorldMapTooltip,
		WorldMapCompareTooltip1,
		WorldMapCompareTooltip2,
		QuestScrollFrame.StoryTooltip,
		GeneralDockManagerOverflowButtonList,
		ReputationParagonTooltip,
		QuestScrollFrame.WarCampaignTooltip,
		NamePlateTooltip,
	}

	local backdrop = {
		bgFile = C.media.backdrop,
		edgeFile = C.media.backdrop,
		edgeSize = 1,
	}

	-- so other stuff which tries to look like GameTooltip doesn't mess up
	local getBackdrop = function()
		return backdrop
	end

	local getBackdropColor = function()
		return 0, 0, 0, .6
	end

	local getBackdropBorderColor = function()
		return 0, 0, 0
	end

	hooksecurefunc("GameTooltip_SetBackdropStyle", function(self)
		if not self.auroraTip then return end
		self:SetBackdrop(nil)
	end)

	for i = 1, #tooltips do
		local t = tooltips[i]
		t:SetBackdrop(nil)
		local bg = F.CreateBDFrame(t, .6)
		F.CreateSD(bg)

		t.auroraTip = true
		t.GetBackdrop = getBackdrop
		t.GetBackdropColor = getBackdropColor
		t.GetBackdropBorderColor = getBackdropBorderColor
	end

	local sb = _G["GameTooltipStatusBar"]
	sb:SetHeight(3)
	sb:ClearAllPoints()
	sb:SetPoint("BOTTOMLEFT", GameTooltip, "BOTTOMLEFT", 1, 1)
	sb:SetPoint("BOTTOMRIGHT", GameTooltip, "BOTTOMRIGHT", -1, 1)
	sb:SetStatusBarTexture(C.media.backdrop)

	local sep = GameTooltipStatusBar:CreateTexture(nil, "ARTWORK")
	sep:SetHeight(1)
	sep:SetPoint("BOTTOMLEFT", 0, 3)
	sep:SetPoint("BOTTOMRIGHT", 0, 3)
	sep:SetTexture(C.media.backdrop)
	sep:SetVertexColor(0, 0, 0)

	IMECandidatesFrame.background:Hide()
	F.CreateBD(IMECandidatesFrame)
	F.CreateSD(IMECandidatesFrame)

	-- [[ Pet battle tooltips ]]

	local tooltips = {PetBattlePrimaryAbilityTooltip, PetBattlePrimaryUnitTooltip, FloatingBattlePetTooltip, BattlePetTooltip, FloatingPetBattleAbilityTooltip}
	for _, f in pairs(tooltips) do
		f:DisableDrawLayer("BACKGROUND")
		local bg = CreateFrame("Frame", nil, f)
		bg:SetAllPoints()
		bg:SetFrameLevel(0)
		F.CreateBD(bg)
		F.CreateSD(bg)
	end

	PetBattlePrimaryUnitTooltip.Delimiter:SetColorTexture(0, 0, 0)
	PetBattlePrimaryUnitTooltip.Delimiter:SetHeight(1)
	PetBattlePrimaryAbilityTooltip.Delimiter1:SetHeight(1)
	PetBattlePrimaryAbilityTooltip.Delimiter1:SetColorTexture(0, 0, 0)
	PetBattlePrimaryAbilityTooltip.Delimiter2:SetHeight(1)
	PetBattlePrimaryAbilityTooltip.Delimiter2:SetColorTexture(0, 0, 0)
	FloatingPetBattleAbilityTooltip.Delimiter1:SetHeight(1)
	FloatingPetBattleAbilityTooltip.Delimiter1:SetColorTexture(0, 0, 0)
	FloatingPetBattleAbilityTooltip.Delimiter2:SetHeight(1)
	FloatingPetBattleAbilityTooltip.Delimiter2:SetColorTexture(0, 0, 0)
	FloatingBattlePetTooltip.Delimiter:SetColorTexture(0, 0, 0)
	FloatingBattlePetTooltip.Delimiter:SetHeight(1)
	F.ReskinClose(FloatingBattlePetTooltip.CloseButton)
	F.ReskinClose(FloatingPetBattleAbilityTooltip.CloseButton)

	-- Tooltip rewards icon
	local newString = "0:0:64:64:5:59:5:59"
	_G.BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT = "|T%1$s:16:16:"..newString.."|t |cffffffff%2$s|r %3$s"
	_G.BONUS_OBJECTIVE_REWARD_FORMAT = "|T%1$s:16:16:"..newString.."|t %2$s"

	local function ReskinRewardIcon(self)
		if self and self.Icon then
			self.Icon:SetTexCoord(.08, .92, .08, .92)
			self.IconBorder:Hide()
		end
	end
	hooksecurefunc("EmbeddedItemTooltip_SetItemByQuestReward", ReskinRewardIcon)
	hooksecurefunc("EmbeddedItemTooltip_SetItemByID", ReskinRewardIcon)
	hooksecurefunc("EmbeddedItemTooltip_SetCurrencyByID", ReskinRewardIcon)
	hooksecurefunc("QuestUtils_AddQuestCurrencyRewardsToTooltip", function(_, _, self) ReskinRewardIcon(self) end)
end)