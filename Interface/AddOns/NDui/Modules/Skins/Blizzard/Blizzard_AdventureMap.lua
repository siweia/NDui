local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_AdventureMap"] = function()
	local dialog = AdventureMapQuestChoiceDialog

	B.StripTextures(dialog, 0)
	B.SetBD(dialog)
	B.Reskin(dialog.AcceptButton)
	B.Reskin(dialog.DeclineButton)
	B.ReskinClose(dialog.CloseButton)
	B.ReskinTrimScroll(dialog.Details.ScrollBar)

	dialog:HookScript("OnShow", function(self)
		if self.styled then return end
		dialog.Details.Child.TitleHeader:SetTextColor(1, .8, 0)
		dialog.Details.Child.ObjectivesHeader:SetTextColor(1, .8, 0)
		self.styled = true
	end)

	local function handleReward(bu)
		if bu.Icon and not bu.bg then
			B.ReskinIcon(bu.Icon)
			local bg = B.CreateBDFrame(bu.Icon, .25)
			bg:SetPoint("BOTTOMRIGHT")
			bu.ItemNameBG:Hide()
			bu.bg = bg
		end
	end
	hooksecurefunc(dialog, "RefreshRewards", function(self)
		for button in self.rewardPool:EnumerateActive() do
			handleReward(button)
		end
	end)
end