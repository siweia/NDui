local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	ScenarioFinderFrameInset:DisableDrawLayer("BORDER")
	ScenarioQueueFrame.Bg:Hide()
	ScenarioFinderFrameInset:Hide()
	ScenarioQueueFrameRandomScrollFrame:SetWidth(304)

	B.Reskin(ScenarioQueueFrameFindGroupButton)
	B.ReskinDropDown(ScenarioQueueFrameTypeDropDown)
	B.ReskinScroll(ScenarioQueueFrameRandomScrollFrameScrollBar)
	B.ReskinScroll(ScenarioQueueFrameSpecificScrollFrameScrollBar)
end)