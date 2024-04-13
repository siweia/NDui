local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local r, g, b = DB.r, DB.g, DB.b

	PVEFrameLeftInset:SetAlpha(0)
	PVEFrameBlueBg:SetAlpha(0)
	PVEFrame.shadows:SetAlpha(0)

	PVEFrameTab2:SetPoint("LEFT", PVEFrameTab1, "RIGHT", -15, 0)
	PVEFrameTab3:SetPoint("LEFT", PVEFrameTab2, "RIGHT", -15, 0)

	local iconSize = 60-2*C.mult
	for i = 1, 4 do
		local bu = GroupFinderFrame["groupButton"..i]
		if bu then
			bu.ring:Hide()
			B.Reskin(bu, true)
			bu.bg:SetColorTexture(r, g, b, .25)
			bu.bg:SetInside(bu.__bg)
	
			bu.icon:SetPoint("LEFT", bu, "LEFT")
			bu.icon:SetSize(iconSize, iconSize)
			B.ReskinIcon(bu.icon)
		end
	end

	hooksecurefunc("GroupFinderFrame_SelectGroupButton", function(index)
		for i = 1, 3 do
			local button = GroupFinderFrame["groupButton"..i]
			if i == index then
				button.bg:Show()
			else
				button.bg:Hide()
			end
		end
	end)

	B.ReskinPortraitFrame(PVEFrame)

	for i = 1, 3 do
		local tab = _G["PVEFrameTab"..i]
		if tab then
			B.ReskinTab(tab)
			if i ~= 1 then
				tab:ClearAllPoints()
				tab:SetPoint("TOPLEFT", _G["PVEFrameTab"..(i-1)], "TOPRIGHT", -15, 0)
			end
		end
	end

	if DB.isNewPatch then

	if ScenarioQueueFrame then
		B.StripTextures(ScenarioFinderFrame)
		ScenarioQueueFrameBackground:SetAlpha(0)
		B.ReskinDropDown(ScenarioQueueFrameTypeDropDown)
		B.Reskin(ScenarioQueueFrameFindGroupButton)
		B.ReskinTrimScroll(ScenarioQueueFrameRandomScrollFrame.ScrollBar)
		if ScenarioQueueFrameRandomScrollFrameScrollBar then
			ScenarioQueueFrameRandomScrollFrameScrollBar:SetAlpha(0)
		end
	end

	end
end)