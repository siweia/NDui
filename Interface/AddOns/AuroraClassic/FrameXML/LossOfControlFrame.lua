local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	local styled
	hooksecurefunc("LossOfControlFrame_SetUpDisplay", function(self)
		if not styled then
			self.Icon:SetTexCoord(.08, .92, .08, .92)
			F.CreateBDFrame(self.Icon)

			styled = true
		end
	end)
end)