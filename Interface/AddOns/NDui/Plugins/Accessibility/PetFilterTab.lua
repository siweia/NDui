local _, ns = ...
local B, C, L, DB = unpack(ns)
-------------------------------------
-- Pet Quick Filter, by Windrunner
-- NDui MOD
-------------------------------------
local function loadPetFilter()
	PetJournalListScrollFrame:SetPoint("TOPLEFT", PetJournalLeftInset, 3, -60)
	if PetJournalEnhancedListScrollFrame then
		PetJournalEnhancedListScrollFrame:SetPoint("TOPLEFT", PetJournalLeftInset, 3, -60)
	end

	local QuickFilter_Function = function(self, button)
		local activeCount = 0
		for petType, _ in ipairs(PET_TYPE_SUFFIX) do
			local btn = _G["PetJournalQuickFilterButton"..petType]
			if button == "LeftButton" then
				if self == btn then
					btn.isActive = not btn.isActive
				elseif not IsShiftKeyDown() then
					btn.isActive = false
				end
			elseif button == "RightButton" and (self == btn) then
				btn.isActive = not btn.isActive
			end

			if btn.isActive then
				btn.Shadow:SetBackdropBorderColor(1, 1, 0)
				activeCount = activeCount + 1
			else
				btn.Shadow:SetBackdropBorderColor(0, 0, 0)
			end
			C_PetJournal.SetPetTypeFilter(btn.petType, btn.isActive)
		end

		if 0 == activeCount then
			C_PetJournal.SetAllPetTypesChecked(true)
		end

		-- PetJournalEnhanced support
		if PetJournalEnhanced then
			local PJE = PetJournalEnhanced
			if PJE.modules and PJE.modules.Sorting then
				PJE.modules.Sorting:UpdatePets()
			elseif PJE.UpdatePets then
				PJE:UpdatePets()
			end
		end
	end

	-- Create the pet type buttons, sorted according weakness
	-- Humanoid > Dragonkin > Magic > Flying > Aquatic > Elemental > Mechanical > Beast > Critter > Undead
	local activeCount = 0
	for petIndex, petType in ipairs({1, 2, 6, 3, 9, 7, 10, 8, 5, 4}) do
		local btn = CreateFrame("Button", "PetJournalQuickFilterButton"..petIndex, PetJournal)
		btn:SetSize(24, 24)
		btn:SetPoint("TOPLEFT", PetJournalLeftInset, 6 + 25 * (petIndex-1), -33)

		local icon = btn:CreateTexture(nil, "ARTWORK")
		icon:SetTexture("Interface\\ICONS\\Pet_Type_"..PET_TYPE_SUFFIX[petType])
		icon:SetPoint("TOPLEFT", -1, 1)
		icon:SetPoint("BOTTOMRIGHT", 1, -1)
		B.CreateSD(btn, 1, 3)
		if C_PetJournal.IsPetTypeChecked(petType) then
			btn.isActive = true
			btn.Shadow:SetBackdropBorderColor(1, 1, 0)
			activeCount = activeCount + 1
		else
			btn.isActive = false
		end
		btn.petType = petType

		btn:SetHighlightTexture(DB.bdTex)
		local hl = btn:GetHighlightTexture()
		hl:SetVertexColor(1, 1, 1, .25)
		hl:SetPoint("TOPLEFT", 2, -2)
		hl:SetPoint("BOTTOMRIGHT", -2, 2)

		btn:SetScript("OnMouseUp", QuickFilter_Function)
	end

	if #PET_TYPE_SUFFIX == activeCount then
		for petIndex, _ in ipairs(PET_TYPE_SUFFIX) do
			local btn = _G["PetJournalQuickFilterButton"..petIndex]
			btn.isActive = false
			btn.Shadow:SetBackdropBorderColor(0, 0, 0)
		end
	end
end
local function setupPetFilter(event, addon)
	if not NDuiDB["Misc"]["PetFilter"] then
		B:UnregisterEvent(event, setupPetFilter)
	elseif addon == "Blizzard_Collections" then
		loadPetFilter()
		B:UnregisterEvent(event, setupPetFilter)
	end
end
B:RegisterEvent("ADDON_LOADED", setupPetFilter)