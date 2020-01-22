local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

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
		B.ReskinClose(alert.CloseButton)
	end
end)