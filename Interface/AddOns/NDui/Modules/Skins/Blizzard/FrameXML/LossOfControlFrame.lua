local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local styled
	hooksecurefunc(LossOfControlFrame, "SetUpDisplay", function(self)
		if not styled then
			B.ReskinIcon(self.Icon, true)

			styled = true
		end
	end)
end)