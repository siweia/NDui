local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	local function reskinAlertFrame(frame)
		if not frame.styled then
			if frame.OkayButton then B.Reskin(frame.OkayButton) end
			if frame.CloseButton then B.ReskinClose(frame.CloseButton) end

			frame.styled = true
		end
	end

	local microButtons = {
		CharacterMicroButtonAlert,
		TalentMicroButtonAlert,
		CollectionsMicroButtonAlert,
		LFDMicroButtonAlert,
		EJMicroButtonAlert,
		StoreMicroButtonAlert,
		GuildMicroButtonAlert,
		ZoneAbilityButtonAlert,
	}

	for _, frame in pairs(microButtons) do
		reskinAlertFrame(frame)
	end

	hooksecurefunc(HelpTip, "Show", function(self)
		for frame in self.framePool:EnumerateActive() do
			reskinAlertFrame(frame)
		end
	end)
end)