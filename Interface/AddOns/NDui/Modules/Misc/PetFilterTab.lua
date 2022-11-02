local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

-- Credit: PetJournal_QuickFilter, Integer
local PET_TYPE_SUFFIX = PET_TYPE_SUFFIX
local ipairs, IsShiftKeyDown = ipairs, IsShiftKeyDown
local C_PetJournal_SetPetTypeFilter = C_PetJournal.SetPetTypeFilter
local C_PetJournal_IsPetTypeChecked = C_PetJournal.IsPetTypeChecked
local C_PetJournal_SetAllPetTypesChecked = C_PetJournal.SetAllPetTypesChecked

function M:PetTabs_Click(button)
	local activeCount = 0
	for petType in ipairs(PET_TYPE_SUFFIX) do
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
			btn.bg:SetBackdropBorderColor(1, 1, 1)
			activeCount = activeCount + 1
		else
			B.SetBorderColor(btn.bg)
		end
		C_PetJournal_SetPetTypeFilter(btn.petType, btn.isActive)
	end

	if activeCount == 0 then
		C_PetJournal_SetAllPetTypesChecked(true)
	end
end

function M:PetTabs_Create()
	PetJournal.ScrollBox:SetPoint("TOPLEFT", PetJournalLeftInset, 3, -60)

	-- Create the pet type buttons, sorted according weakness
	-- Humanoid > Dragonkin > Magic > Flying > Aquatic > Elemental > Mechanical > Beast > Critter > Undead
	local activeCount = 0
	for petIndex, petType in ipairs({1, 2, 6, 3, 9, 7, 10, 8, 5, 4}) do
		local btn = CreateFrame("Button", "PetJournalQuickFilterButton"..petIndex, PetJournal, "BackdropTemplate")
		btn:SetSize(24, 24)
		btn:SetPoint("TOPLEFT", PetJournalLeftInset, 6 + 25 * (petIndex-1), -33)
		B.PixelIcon(btn, "Interface\\ICONS\\Pet_Type_"..PET_TYPE_SUFFIX[petType], true)

		if C_PetJournal_IsPetTypeChecked(petType) then
			btn.isActive = true
			btn.bg:SetBackdropBorderColor(1, 1, 1)
			activeCount = activeCount + 1
		else
			btn.isActive = false
		end
		btn.petType = petType
		btn:SetScript("OnMouseUp", M.PetTabs_Click)
	end

	if activeCount == #PET_TYPE_SUFFIX then
		for petIndex in ipairs(PET_TYPE_SUFFIX) do
			local btn = _G["PetJournalQuickFilterButton"..petIndex]
			btn.isActive = false
			B.SetBorderColor(btn.bg)
		end
	end
end

function M:PetTabs_Load(addon)
	if addon == "Blizzard_Collections" then
		M:PetTabs_Create()
		B:UnregisterEvent(self, M.PetTabs_Load)
	end
end

function M:PetTabs_Init()
	if not C.db["Misc"]["PetFilter"] then return end

	if IsAddOnLoaded("Blizzard_Collections") then
		M:PetTabs_Create()
	else
		B:RegisterEvent("ADDON_LOADED", M.PetTabs_Load)
	end
end
M:RegisterMisc("PetFilterTab", M.PetTabs_Init)