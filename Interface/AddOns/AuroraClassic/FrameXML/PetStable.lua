local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local class = select(2, UnitClass("player"))
	if class ~= "HUNTER" then return end

	PetStableBottomInset:DisableDrawLayer("BACKGROUND")
	PetStableBottomInset:DisableDrawLayer("BORDER")
	PetStableLeftInset:DisableDrawLayer("BACKGROUND")
	PetStableLeftInset:DisableDrawLayer("BORDER")
	PetStableModelShadow:Hide()
	PetStableModelRotateLeftButton:Hide()
	PetStableModelRotateRightButton:Hide()
	PetStableFrameModelBg:Hide()
	PetStablePrevPageButtonIcon:SetTexture("")
	PetStableNextPageButtonIcon:SetTexture("")

	F.ReskinPortraitFrame(PetStableFrame, true)
	F.ReskinArrow(PetStablePrevPageButton, "left")
	F.ReskinArrow(PetStableNextPageButton, "right")

	PetStableSelectedPetIcon:SetTexCoord(.08, .92, .08, .92)
	F.CreateBG(PetStableSelectedPetIcon)

	for i = 1, NUM_PET_ACTIVE_SLOTS do
		local bu = _G["PetStableActivePet"..i]
		bu.Background:Hide()
		bu.Border:Hide()
		bu:SetNormalTexture("")
		bu.Checked:SetTexture(C.media.checked)

		_G["PetStableActivePet"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
		F.CreateBD(bu, .25)
	end

	for i = 1, NUM_PET_STABLE_SLOTS do
		local bu = _G["PetStableStabledPet"..i]
		local bd = CreateFrame("Frame", nil, bu)
		bd:SetPoint("TOPLEFT", -1, 1)
		bd:SetPoint("BOTTOMRIGHT", 1, -1)
		F.CreateBD(bd, .25)
		bu:SetNormalTexture("")
		bu:DisableDrawLayer("BACKGROUND")
		_G["PetStableStabledPet"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
	end
end)