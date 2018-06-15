local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	LevelUpDisplaySide:HookScript("OnShow", function(self)
		for i = 1, #self.unlockList do
			local f = _G["LevelUpDisplaySideUnlockFrame"..i]

			if not f.restyled then
				f.icon:SetTexCoord(.08, .92, .08, .92)
				F.CreateBG(f.icon)
			end
		end
	end)
end)