local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_StableUI"] = function()
	B.ReskinPortraitFrame(StableFrame)
	B.Reskin(StableFrame.StableTogglePetButton)
	B.Reskin(StableFrame.ReleasePetButton)

	local stabledPetList = StableFrame.StabledPetList
	B.StripTextures(stabledPetList)
	B.StripTextures(stabledPetList.ListCounter)
	B.CreateBDFrame(stabledPetList.ListCounter, .25)
	B.ReskinEditBox(stabledPetList.FilterBar.SearchBox)
	B.ReskinFilterButton(stabledPetList.FilterBar.FilterDropdown)
	B.ReskinTrimScroll(stabledPetList.ScrollBar)

	local modelScene = StableFrame.PetModelScene
	if modelScene then
		local petInfo = modelScene.PetInfo
		if petInfo then
			hooksecurefunc(petInfo.Type, "SetText", B.ReplaceIconString)
		end

		local list = modelScene.AbilitiesList
		if list then
			hooksecurefunc(list, "Layout", function(self)
				for frame in self.abilityPool:EnumerateActive() do
					if not frame.styled then
						B.ReskinIcon(frame.Icon)
						frame.styled = true
					end
				end
			end)
		end

		B.ReskinModelControl(modelScene)
	end
end