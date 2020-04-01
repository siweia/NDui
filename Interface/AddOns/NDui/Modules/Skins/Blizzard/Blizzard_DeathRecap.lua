local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_DeathRecap"] = function()
	local DeathRecapFrame = DeathRecapFrame

	DeathRecapFrame:DisableDrawLayer("BORDER")
	DeathRecapFrame.Background:Hide()
	DeathRecapFrame.BackgroundInnerGlow:Hide()
	DeathRecapFrame.Divider:Hide()

	B.SetBD(DeathRecapFrame)
	B.Reskin(select(8, DeathRecapFrame:GetChildren())) -- bottom close button has no parentKey
	B.ReskinClose(DeathRecapFrame.CloseXButton)

	for i = 1, NUM_DEATH_RECAP_EVENTS do
		local recap = DeathRecapFrame["Recap"..i].SpellInfo
		recap.IconBorder:Hide()
		B.ReskinIcon(recap.Icon)
	end
end