local _, ns = ...
local B, C, L, DB = unpack(ns)

local function ReskinEventTraceButton(button)
	B.Reskin(button)
	button.NormalTexture:SetAlpha(0)
	button.MouseoverOverlay:SetAlpha(0)
end

local function reskinScrollArrow(self, direction)
	self.Texture:SetAlpha(0)
	local tex = self:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints()
	B.CreateBDFrame(tex, .25)
	B.SetupArrow(tex, direction)
end

local function ReskinEventTraceScroll(scrollBar)
	B.StripTextures(scrollBar)
	reskinScrollArrow(scrollBar.Back, "up")
	reskinScrollArrow(scrollBar.Forward, "down")

	local thumb = scrollBar.Track.Thumb
	B.StripTextures(thumb, 0)
	B.CreateBDFrame(thumb, 0, true)
end

C.themes["Blizzard_EventTrace"] = function()
	B.ReskinPortraitFrame(EventTrace)

	local subtitleBar = EventTrace.SubtitleBar
	B.ReskinFilterButton(subtitleBar.OptionsDropDown)

	local logBar = EventTrace.Log.Bar
	local filterBar = EventTrace.Filter.Bar
	B.ReskinEditBox(logBar.SearchBox)

	ReskinEventTraceScroll(EventTrace.Log.Events.ScrollBar)
	ReskinEventTraceScroll(EventTrace.Filter.ScrollBar)

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