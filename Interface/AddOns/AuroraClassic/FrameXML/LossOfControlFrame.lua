local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local styled
	hooksecurefunc("LossOfControlFrame_SetUpDisplay", function(self)
		if not styled then
			self.Icon:SetTexCoord(.08, .92, .08, .92)
			local bg = F.CreateBDFrame(self.Icon)
			F.CreateSD(bg)

			styled = true
		end
	end)
end)