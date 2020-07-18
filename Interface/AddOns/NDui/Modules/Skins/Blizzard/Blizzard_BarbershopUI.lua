local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_BarbershopUI"] = function()
	local buttons = {"AcceptButton", "CancelButton", "ResetButton"}
	for _, name in pairs(buttons) do
		local button = BarberShopFrame[name]
		B.StripTextures(button, 0)
		B.Reskin(button)
	end
end