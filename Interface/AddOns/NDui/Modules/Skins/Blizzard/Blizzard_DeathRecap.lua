local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_DeathRecap"] = function()
	local DeathRecapFrame = DeathRecapFrame

	DeathRecapFrame:DisableDrawLayer("BORDER")
	DeathRecapFrame.Background:Hide()
	DeathRecapFrame.BackgroundInnerGlow:Hide()
	DeathRecapFrame.Divider:Hide()

	B.SetBD(DeathRecapFrame)
	B.Reskin(DeathRecapFrame.CloseButton) -- bottom close button has no parentKey
	B.ReskinClose(DeathRecapFrame.CloseXButton)

	local function updateEntry(button)
		local recap = button.SpellInfo
		if not recap or recap.styled then return end

		if recap.Icon then
			B.ReskinIcon(recap.Icon)
		end
		recap.IconBorder:Hide()
		recap.styled = true
	end

	B.ReskinTrimScroll(DeathRecapFrame.ScrollBar)
	hooksecurefunc(DeathRecapFrame.ScrollBox, "Update", function(self)
		self:ForEachFrame(updateEntry)
	end)
end