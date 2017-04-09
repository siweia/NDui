local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	if not AuroraConfig.tooltips then return end

	local tooltips = {
		GameTooltip,
		ItemRefTooltip,
		ShoppingTooltip1,
		ShoppingTooltip2,
		WorldMapTooltip,
		ChatMenu,
		EmoteMenu,
		LanguageMenu,
		VoiceMacroMenu,
		ReputationParagonTooltip,
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

	for i = 1, #tooltips do
		local t = tooltips[i]
		t:SetBackdrop(nil)
		local bg = CreateFrame("Frame", nil, t)
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("BOTTOMRIGHT")
		bg:SetFrameLevel(t:GetFrameLevel()-1)
		bg:SetBackdrop(backdrop)
		bg:SetBackdropColor(0, 0, 0, .6)
		bg:SetBackdropBorderColor(0, 0, 0)

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

	F.CreateBD(FriendsTooltip)
	IMECandidatesFrame.background:Hide()
	F.CreateBD(IMECandidatesFrame)

	-- [[ Pet battle tooltips ]]

	local tooltips = {PetBattlePrimaryAbilityTooltip, PetBattlePrimaryUnitTooltip, FloatingBattlePetTooltip, BattlePetTooltip, FloatingPetBattleAbilityTooltip}
	for _, f in pairs(tooltips) do
		f:DisableDrawLayer("BACKGROUND")
		local bg = CreateFrame("Frame", nil, f)
		bg:SetAllPoints()
		bg:SetFrameLevel(0)
		F.CreateBD(bg)
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
end)