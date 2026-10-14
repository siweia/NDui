local _, ns = ...
local B, C, L, DB = unpack(ns)

local function replaceHighlight(button)
	button.highlightTexture:SetColorTexture(1, 1, 1, .25)
	button.highlightTexture:SetInside(button.bg)
	button.spellString:SetTextColor(1, 1, 1)
end

local function handleSkillButton(button)
	button:SetCheckedTexture(0)
	button:SetPushedTexture(0)
	button.IconTexture:RemoveMaskTexture(button.OutlineMask)
	button.IconTextureOverlay:SetAlpha(0)
	button.IconTexture:SetInside()
	button.bg = B.ReskinIcon(button.IconTexture)
	button.subSpellString:SetTextColor(.7, .7, .7)
	hooksecurefunc(button, "UpdateButton", replaceHighlight)
	replaceHighlight(button)
end

function B:ReskinProfessionsBook()
	local professions = {"PrimaryProfession1", "PrimaryProfession2", "SecondaryProfession1", "SecondaryProfession2", "SecondaryProfession3"}
	local content = self.ProfessionsContentFrame
	for _, name in ipairs(professions) do
		local profession = content[name]
		profession.Background:SetAlpha(0)
		profession.ProfessionName:SetTextColor(1, 1, 1)
		profession.missingHeader:SetTextColor(1, 1, 1)
		profession.missingText:SetTextColor(.7, .7, .7)
		B.CreateBDFrame(profession, .25):SetInside(nil, 5, 5)
		B.ReskinProfessionsRankBar(profession.StatusBar)

		for _, button in ipairs(profession.spellButtons) do
			handleSkillButton(button)
		end
		if profession.UnlearnButton then
			B.ReskinClose(profession.UnlearnButton, nil, nil, nil, true)
		end
	end
end
