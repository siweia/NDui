local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	local WorldMapFrame = WorldMapFrame

	local mapBg = B.ReskinPortraitFrame(WorldMapFrame, 7, 0, -7, 25)
	mapBg:SetFrameStrata("BACKGROUND")

	local function updateMapBG(map)
		if map.isMaximized then
			mapBg:SetPoint("TOPLEFT", 7, 0)
		else
			mapBg:SetPoint("TOPLEFT", 18, 0)
		end
	end
	updateMapBG(WorldMapFrame)
	hooksecurefunc(WorldMapFrame, "SynchronizeDisplayState", updateMapBG)

	B.ReskinDropDown(WorldMapZoneMinimapDropdown)
	B.ReskinDropDown(WorldMapContinentDropdown)
	B.ReskinDropDown(WorldMapZoneDropdown)
	B.Reskin(WorldMapZoomOutButton)

	if MiniBorderLeft then MiniBorderLeft:Hide() end
	if MiniBorderRight then MiniBorderRight:Hide() end
	B.ReskinMinMax(WorldMapFrame.MaximizeMinimizeFrame)
	B.ReskinCheck(WorldMapTrackQuest)
	if not DB.isMop then
		B.ReskinCheck(WorldMapQuestShowObjectives)
		B.ReskinCheck(WorldMapShowDigsites)
	end

	B.ReskinTrimScroll(QuestScrollFrame.ScrollBar)
	B.ReskinScroll(QuestMapDetailsScrollFrameScrollBar)
	B.ReskinDropDown(WorldMapFrame.WorldMapOptionsDropDown)

	C_Timer.After(3, function()
		if CodexQuestMapDropdown then
			B.ReskinDropDown(CodexQuestMapDropdown)
			CodexQuestMapDropdownButton.SetWidth = B.Dummy
		end

		-- Check all buttons
		for i = 1, WorldMapFrame:GetNumChildren() do
			local child = select(i, WorldMapFrame:GetChildren())
			if child:IsObjectType("Button") and child.Text and not child.bg then
				B.Reskin(child)
			end
		end
	end)

	B.StripTextures(OpacityFrame)
	B.SetBD(OpacityFrame)
	B.ReskinSlider(OpacityFrameSlider, true)
end)