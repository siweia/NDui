local _, ns = ...
local ycc = ns.ycc

hooksecurefunc("LFRBrowseFrameListButton_SetData", function(button, index)
	local name, level, _, className, _, _, _, class = SearchLFGGetResults(index)
	if name == ycc.myName then return end
	if class and name and level then
		button.name:SetText(ycc.classColor[class]..name)
		button.class:SetText(ycc.classColor[class]..className)
		button.level:SetText(ycc.diffColor[level]..level)
	end
end)