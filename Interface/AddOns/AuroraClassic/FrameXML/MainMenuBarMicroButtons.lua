local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local microButtons = {TalentMicroButtonAlert, CollectionsMicroButtonAlert, EJMicroButtonAlert}
		for _, button in pairs(microButtons) do
		button:DisableDrawLayer("BACKGROUND")
		button:DisableDrawLayer("BORDER")
		button.Arrow:Hide()

		F.SetBD(button)
		F.ReskinClose(button.CloseButton)
	end
end)