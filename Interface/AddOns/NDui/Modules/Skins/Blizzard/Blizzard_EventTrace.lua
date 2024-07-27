local _, ns = ...
local B, C, L, DB = unpack(ns)

local function ReskinEventTraceButton(button)
	B.Reskin(button)
	button.NormalTexture:SetAlpha(0)
	button.MouseoverOverlay:SetAlpha(0)
end

local function reskinScrollChild(self)
	for i = 1, self.ScrollTarget:GetNumChildren() do
		local child = select(i, self.ScrollTarget:GetChildren())
		local hideButton = child and child.HideButton
		if hideButton and not hideButton.styled then
			B.ReskinClose(hideButton, nil, nil, nil, true)
			hideButton:ClearAllPoints()
			hideButton:SetPoint("LEFT", 3, 0)

			local checkButton = child.CheckButton
			if checkButton then
				B.ReskinCheck(checkButton)
				checkButton:SetSize(22, 22)
			end

			hideButton.styled = true
		end
	end
end

local function reskinEventTraceScrollBox(frame)
	frame:DisableDrawLayer("BACKGROUND")
	B.CreateBDFrame(frame, .25)
	hooksecurefunc(frame, "Update", reskinScrollChild)
end

local function ReskinEventTraceFrame(frame)
	reskinEventTraceScrollBox(frame.ScrollBox)
	B.ReskinTrimScroll(frame.ScrollBar)
end

C.themes["Blizzard_EventTrace"] = function()
	B.ReskinPortraitFrame(EventTrace)

	local subtitleBar = EventTrace.SubtitleBar
	B.ReskinFilterButton(subtitleBar.OptionsDropdown)

	local logBar = EventTrace.Log.Bar
	local filterBar = EventTrace.Filter.Bar
	B.ReskinEditBox(logBar.SearchBox)

	ReskinEventTraceFrame(EventTrace.Log.Events)
	ReskinEventTraceFrame(EventTrace.Log.Search)
	ReskinEventTraceFrame(EventTrace.Filter)

	local buttons = {
		subtitleBar.ViewLog,
		subtitleBar.ViewFilter,
		logBar.DiscardAllButton,
		logBar.PlaybackButton,
		logBar.MarkButton,
		filterBar.DiscardAllButton,
		filterBar.UncheckAllButton,
		filterBar.CheckAllButton,
	}
	for _, button in pairs(buttons) do
		ReskinEventTraceButton(button)
	end
end