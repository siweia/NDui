local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	if AuroraConfig.tooltips then
		for i = 1, 9 do
			select(i, QueueStatusFrame:GetRegions()):Hide()
		end
		F.CreateBD(QueueStatusFrame)
		F.CreateSD(QueueStatusFrame)
	end

	local function SkinEntry(entry)
		for _, roleButton in next, {entry.HealersFound, entry.TanksFound, entry.DamagersFound} do
			roleButton.Texture:SetTexture(C.media.roleIcons)
			roleButton.Cover:SetTexture(C.media.roleIcons)
			local bg = F.CreateBDFrame(roleButton, 1)
			bg:SetPoint("TOPLEFT", 4, -3)
			bg:SetPoint("BOTTOMRIGHT", -5, 6)
		end

		for i = 1, LFD_NUM_ROLES do
			local roleIcon = entry["RoleIcon"..i]
			roleIcon:SetTexture(C.media.roleIcons)

			local bg = F.CreateBDFrame(entry, 1)
			bg:SetPoint("TOPLEFT", roleIcon, 2, -2)
			bg:SetPoint("BOTTOMRIGHT", roleIcon, -2, 3)
			roleIcon.bg = bg
		end

		entry._auroraSkinned = true
	end

	hooksecurefunc("QueueStatusEntry_SetMinimalDisplay", function(entry)
		if not entry._auroraSkinned then
			SkinEntry(entry)
		end

		for i = 1, LFD_NUM_ROLES do
			local roleIcon = entry["RoleIcon"..i]
			roleIcon.bg:Hide()
		end
	end)

	hooksecurefunc("QueueStatusEntry_SetFullDisplay", function(entry)
		if not entry._auroraSkinned then
			SkinEntry(entry)
		end

		for i = 1, LFD_NUM_ROLES do
			local roleIcon = entry["RoleIcon"..i]
			local shown = entry["RoleIcon"..i]:IsShown()
			roleIcon.bg:SetShown(shown)
		end
	end)
end)