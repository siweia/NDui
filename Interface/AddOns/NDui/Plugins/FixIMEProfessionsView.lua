--[[
MIT License

Copyright (c) 2023 plusmouse

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local function FixIMESearch(self)
	SearchBoxTemplate_OnTextChanged(self)
	local text = self:GetText()
	if not self:IsInIMECompositionMode() then
		ProfessionsFrame.CraftingPage.RecipeList.SearchBox:SetText(text)
		ProfessionsFrame.CraftingPage.MinimizedSearchBox:SetText(text)
		Professions.OnRecipeListSearchTextChanged(text)
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("TRADE_SKILL_SHOW")
frame:SetScript("OnEvent", function(_, event)
	frame:UnregisterEvent(event)

	ProfessionsFrame.CraftingPage.RecipeList.SearchBox:SetScript("OnTextChanged", FixIMESearch)
	ProfessionsFrame.CraftingPage.MinimizedSearchBox:SetScript("OnTextChanged", FixIMESearch)
end)