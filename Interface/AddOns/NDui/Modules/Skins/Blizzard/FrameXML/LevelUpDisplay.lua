local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if DB.isNewPatch then return end
	if not C.db["Skins"]["BlizzardSkins"] then return end

	LevelUpDisplaySide:HookScript("OnShow", function(self)
		for i = 1, #self.unlockList do
			local f = _G["LevelUpDisplaySideUnlockFrame"..i]

			if not f.bg then
				f.bg = B.ReskinIcon(f.icon)
			end
		end
	end)
end)