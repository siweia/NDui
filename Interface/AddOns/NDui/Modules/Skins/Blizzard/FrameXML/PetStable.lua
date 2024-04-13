local _, ns = ...
local B, C, L, DB = unpack(ns)

if DB.isNewPatch then return end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local class = select(2, UnitClass("player"))
	if class ~= "HUNTER" then return end

	local x1, x2, y1, y2 = unpack(DB.TexCoord)

	PetStableBottomInset:Hide()
	PetStableLeftInset:Hide()
	PetStableFrameModelBg:Hide()
	PetStablePrevPageButtonIcon:SetTexture("")
	PetStableNextPageButtonIcon:SetTexture("")
	PetStableDietTexture:SetTexture(132165)
	PetStableDietTexture:SetTexCoord(x1, x2, y1, y2)

	B.ReskinPortraitFrame(PetStableFrame)
	B.ReskinArrow(PetStablePrevPageButton, "left")
	B.ReskinArrow(PetStableNextPageButton, "right")
	B.ReskinIcon(PetStableSelectedPetIcon)

	for i = 1, NUM_PET_ACTIVE_SLOTS do
		local bu = _G["PetStableActivePet"..i]
		bu.Background:Hide()
		bu.Border:Hide()
		bu:SetNormalTexture(0)
		bu:SetPushedTexture(0)
		bu.Checked:SetTexture(DB.pushedTex)
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

		_G["PetStableActivePet"..i.."IconTexture"]:SetTexCoord(x1, x2, y1, y2)
		B.CreateBDFrame(bu, .25)
	end

	for i = 1, NUM_PET_STABLE_SLOTS do
		local bu = _G["PetStableStabledPet"..i]
		bu:SetNormalTexture(0)
		bu:SetPushedTexture(0)
		bu.Checked:SetTexture(DB.pushedTex)
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		bu:DisableDrawLayer("BACKGROUND")

		_G["PetStableStabledPet"..i.."IconTexture"]:SetTexCoord(x1, x2, y1, y2)
		B.CreateBDFrame(bu, .25)
	end
end)