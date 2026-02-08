local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	local microButtons = {
		CharacterMicroButtonAlert,
		TalentMicroButtonAlert,
		CollectionsMicroButtonAlert,
		LFDMicroButtonAlert,
		EJMicroButtonAlert,
		StoreMicroButtonAlert,
		ZoneAbilityButtonAlert,
	}

	for _, alert in pairs(microButtons) do
		if alert.CloseButton then
			B.ReskinClose(alert.CloseButton)
		end
	end
end)