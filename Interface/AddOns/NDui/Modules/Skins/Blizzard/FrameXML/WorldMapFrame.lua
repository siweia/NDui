local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	local WorldMapFrame = WorldMapFrame

	B.ReskinPortraitFrame(WorldMapFrame, 7, 0, -7, 25)
	B.ReskinDropDown(WorldMapZoneMinimapDropDown)
	B.ReskinDropDown(WorldMapContinentDropDown)
	B.ReskinDropDown(WorldMapZoneDropDown)
	B.Reskin(WorldMapZoomOutButton)

	C_Timer.After(3, function()
		if CodexQuestMapDropdown then
			B.ReskinDropDown(CodexQuestMapDropdown)
			CodexQuestMapDropdownButton.SetWidth = B.Dummy
		end

		-- Check all buttons
		for i = 1, WorldMapFrame:GetNumChildren() do
			local child = select(i, WorldMapFrame:GetChildren())
			if child:IsObjectType("Button") and child.Text and not child.__bg then
				B.Reskin(child)
			end
		end
	end)
end)