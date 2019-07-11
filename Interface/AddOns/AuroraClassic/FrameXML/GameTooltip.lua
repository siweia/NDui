local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	F.ReskinClose(ItemRefCloseButton)
	F.ReskinClose(FloatingBattlePetTooltip.CloseButton)
	F.ReskinClose(FloatingPetBattleAbilityTooltip.CloseButton)

	if not AuroraConfig.tooltips then return end

	local function getBackdrop(self) return self.bg:GetBackdrop() end
	local function getBackdropColor() return 0, 0, 0, .7 end
	local function getBackdropBorderColor() return 0, 0, 0 end

	function F:ReskinTooltip()
		if not self.auroraTip then
			self:SetBackdrop(nil)
			self:DisableDrawLayer("BACKGROUND")
			local bg = F.CreateBDFrame(self, .7)
			F.CreateSD(bg)
			self.bg = bg

			self.GetBackdrop = getBackdrop
			self.GetBackdropColor = getBackdropColor
			self.GetBackdropBorderColor = getBackdropBorderColor
			self.auroraTip = true
		end
	end

	hooksecurefunc("GameTooltip_SetBackdropStyle", function(self)
		if not self.auroraTip then return end
		self:SetBackdrop(nil)
	end)

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
		GeneralDockManagerOverflowButtonList,
		ReputationParagonTooltip,
		NamePlateTooltip,
		QueueStatusFrame,
		BattlePetTooltip,
		PetBattlePrimaryAbilityTooltip,
		PetBattlePrimaryUnitTooltip,
		FloatingBattlePetTooltip,
		FloatingPetBattleAbilityTooltip,
		IMECandidatesFrame,
	}
	for _, tooltip in pairs(tooltips) do
		F.ReskinTooltip(tooltip)
	end

	C_Timer.After(5, function()
		if LibDBIconTooltip then
			F.ReskinTooltip(LibDBIconTooltip)
		end
	end)

	local sb = _G["GameTooltipStatusBar"]
	sb:SetHeight(3)
	sb:ClearAllPoints()
	sb:SetPoint("BOTTOMLEFT", GameTooltip, "BOTTOMLEFT", 1, 1)
	sb:SetPoint("BOTTOMRIGHT", GameTooltip, "BOTTOMRIGHT", -1, 1)
	sb:SetStatusBarTexture(C.media.backdrop)

	local sep = GameTooltipStatusBar:CreateTexture(nil, "ARTWORK")
	sep:SetHeight(C.mult)
	sep:SetPoint("BOTTOMLEFT", 0, 3)
	sep:SetPoint("BOTTOMRIGHT", 0, 3)
	sep:SetTexture(C.media.backdrop)
	sep:SetVertexColor(0, 0, 0)

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

	-- Tooltip rewards icon
	local function updateBackdropColor(self, r, g, b)
		self:GetParent().bg:SetBackdropBorderColor(r, g, b)
	end

	local function resetBackdropColor(self)
		self:GetParent().bg:SetBackdropBorderColor(0, 0, 0)
	end

	local function reskinRewardIcon(self)
		self.Icon:SetTexCoord(.08, .92, .08, .92)
		self.bg = F.CreateBDFrame(self.Icon)

		local iconBorder = self.IconBorder
		iconBorder:SetAlpha(0)
		hooksecurefunc(iconBorder, "SetVertexColor", updateBackdropColor)
		hooksecurefunc(iconBorder, "Hide", resetBackdropColor)
	end

	reskinRewardIcon(GameTooltip.ItemTooltip)
	reskinRewardIcon(EmbeddedItemTooltip.ItemTooltip)

	-- Other addons
	local listener = CreateFrame("Frame")
	listener:RegisterEvent("ADDON_LOADED")
	listener:SetScript("OnEvent", function(_, _, addon)
		if addon == "MethodDungeonTools" then
			local styledMDT
			hooksecurefunc(MethodDungeonTools, "ShowInterface", function()
				if not styledMDT then
					F.ReskinTooltip(MethodDungeonTools.tooltip)
					F.ReskinTooltip(MethodDungeonTools.pullTooltip)
					styledMDT = true
				end
			end)
		elseif addon == "BattlePetBreedID" then
			hooksecurefunc("BPBID_SetBreedTooltip", function(parent)
				if parent == FloatingBattlePetTooltip then
					F.ReskinTooltip(BPBID_BreedTooltip2)
				else
					F.ReskinTooltip(BPBID_BreedTooltip)
				end
			end)
		end
	end)
end)