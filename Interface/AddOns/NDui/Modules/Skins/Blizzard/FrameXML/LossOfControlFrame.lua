local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.themes["AuroraClassic"], function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	local styled
	hooksecurefunc("LossOfControlFrame_SetUpDisplay", function(self)
		if not styled then
			self.Icon:SetTexCoord(.08, .92, .08, .92)
			local bg = B.CreateBDFrame(self.Icon)
			B.CreateSD(bg)

			styled = true
		end
	end)
end)