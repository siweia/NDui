local _, ns = ...
local B, C, L, DB = unpack(ns)

local function ReskinEventTraceButton(button)
	B.Reskin(button)
	button.NormalTexture:SetAlpha(0)
	button.MouseoverOverlay:SetAlpha(0)
end

local function reskinScrollArrow(self, direction)
	self.Texture:SetAlpha(0)
	self.Overlay:SetAlpha(0)
	local tex = self:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints()
	B.CreateBDFrame(tex, .25)
	B.SetupArrow(tex, direction)
	self.__texture = tex

	self:HookScript("OnEnter", B.Texture_OnEnter)
	self:HookScript("OnLeave", B.Texture_OnLeave)
end

local function reskinEventTraceScrollBar(scrollBar)
	B.StripTextures(scrollBar)
	reskinScrollArrow(scrollBar.Back, "up")
	reskinScrollArrow(scrollBar.Forward, "down")

	local thumb = scrollBar:GetThumb()
	B.StripTextures(thumb, 0)
	B.CreateBDFrame(thumb, 0, true)
end

local function reskinScrollChild(self)
	for i = 1, self.ScrollTarget:GetNumChildren() do
		local child = select(i, self.ScrollTarget:GetChildren())
		local hideButton = child and child.HideButton
		if hideButton and not hideButton.styled then
			B.ReskinClose(hideButton)
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
	reskinEventTraceScrollBar(frame.ScrollBar)
end

C.themes["Blizzard_EventTrace"] = function()
	B.ReskinPortraitFrame(EventTrace)

	local subtitleBar = EventTrace.SubtitleBar
	B.ReskinFilterButton(subtitleBar.OptionsDropDown)

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