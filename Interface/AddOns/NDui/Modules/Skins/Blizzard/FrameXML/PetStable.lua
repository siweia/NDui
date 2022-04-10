local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	B.ReskinPortraitFrame(PetStableFrame, 15, -15, -35, 73)
	B.Reskin(PetStablePurchaseButton)
	B.ReskinRotationButtons(PetStableModel)

	local slots = {
		PetStableCurrentPet,
		PetStableStabledPet1,
		PetStableStabledPet2,
	}

	for _, bu in pairs(slots) do
		bu:SetNormalTexture("")
		bu:SetPushedTexture("")
		bu:SetCheckedTexture(DB.textures.pushed)
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		bu:DisableDrawLayer("BACKGROUND")

		_G[bu:GetName().."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
		bu.bg = B.CreateBDFrame(bu, .25)
	end

	hooksecurefunc("PetStable_Update", function()
		for i = 1, 2 do
			local bu = _G["PetStableStabledPet"..i]
			if i <= GetNumStableSlots() then
				bu.bg:SetBackdropBorderColor(0, 0, 0)
			else
				bu.bg:SetBackdropBorderColor(1, 0, 0)
			end
		end
	end)
end)