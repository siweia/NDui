local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	-- Tooltips
	function B:ReskinGarrisonTooltip()
		for i = 1, 9 do
			select(i, self:GetRegions()):Hide()
		end
		if self.Icon then B.ReskinIcon(self.Icon) end
		if self.CloseButton then B.ReskinClose(self.CloseButton) end
	end

	B.ReskinGarrisonTooltip(FloatingGarrisonMissionTooltip)
	B.ReskinGarrisonTooltip(GarrisonFollowerTooltip)
	B.ReskinGarrisonTooltip(FloatingGarrisonFollowerTooltip)
	B.ReskinGarrisonTooltip(GarrisonFollowerAbilityTooltip)
	B.ReskinGarrisonTooltip(FloatingGarrisonFollowerAbilityTooltip)
	B.ReskinGarrisonTooltip(GarrisonShipyardFollowerTooltip)
	B.ReskinGarrisonTooltip(FloatingGarrisonShipyardFollowerTooltip)

	B.ReskinClose(ItemRefCloseButton)
	B.ReskinClose(FloatingBattlePetTooltip.CloseButton)
	B.ReskinClose(FloatingPetBattleAbilityTooltip.CloseButton)

	hooksecurefunc("GarrisonFollowerTooltipTemplate_SetGarrisonFollower", function(tooltipFrame)
		-- Abilities
		if tooltipFrame.numAbilitiesStyled == nil then
			tooltipFrame.numAbilitiesStyled = 1
		end

		local numAbilitiesStyled = tooltipFrame.numAbilitiesStyled
		local abilities = tooltipFrame.Abilities
		local ability = abilities[numAbilitiesStyled]
		while ability do
			B.ReskinIcon(ability.Icon)

			numAbilitiesStyled = numAbilitiesStyled + 1
			ability = abilities[numAbilitiesStyled]
		end

		tooltipFrame.numAbilitiesStyled = numAbilitiesStyled

		-- Traits
		if tooltipFrame.numTraitsStyled == nil then
			tooltipFrame.numTraitsStyled = 1
		end

		local numTraitsStyled = tooltipFrame.numTraitsStyled
		local traits = tooltipFrame.Traits
		local trait = traits[numTraitsStyled]
		while trait do
			B.ReskinIcon(trait.Icon)

			numTraitsStyled = numTraitsStyled + 1
			trait = traits[numTraitsStyled]
		end

		tooltipFrame.numTraitsStyled = numTraitsStyled
	end)
end)