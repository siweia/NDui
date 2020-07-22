local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	local styled
	hooksecurefunc("LossOfControlFrame_SetUpDisplay", function(self)
		if not styled then
			B.ReskinIcon(self.Icon, true)
			self.Cooldown:SetInside()

			styled = true
		end
	end)
end)