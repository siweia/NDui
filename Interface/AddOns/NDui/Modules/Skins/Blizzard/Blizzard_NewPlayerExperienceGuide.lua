local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_NewPlayerExperienceGuide"] = function()
	local GuideFrame = GuideFrame

	B.ReskinPortraitFrame(GuideFrame)
	GuideFrame.Title:SetTextColor(1, .8, 0)
	GuideFrame.ScrollFrame.Child.Text:SetTextColor(1, 1, 1)
	B.ReskinScroll(GuideFrame.ScrollFrame.ScrollBar)
	B.Reskin(GuideFrame.ScrollFrame.ConfirmationButton)
end