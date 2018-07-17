local F, C = unpack(select(2, ...))

C.themes["Blizzard_DeathRecap"] = function()
	local DeathRecapFrame = DeathRecapFrame

	DeathRecapFrame:DisableDrawLayer("BORDER")
	DeathRecapFrame.Background:Hide()
	DeathRecapFrame.BackgroundInnerGlow:Hide()
	DeathRecapFrame.Divider:Hide()

	F.CreateBD(DeathRecapFrame)
	F.CreateSD(DeathRecapFrame)
	F.Reskin(select(8, DeathRecapFrame:GetChildren())) -- bottom close button has no parentKey
	F.ReskinClose(DeathRecapFrame.CloseXButton)

	for i = 1, NUM_DEATH_RECAP_EVENTS do
		local recap = DeathRecapFrame["Recap"..i].SpellInfo
		recap.IconBorder:Hide()
		recap.Icon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(recap.Icon)
	end
end