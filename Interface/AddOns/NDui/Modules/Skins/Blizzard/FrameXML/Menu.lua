local _, ns = ...
local B, C, L, DB = unpack(ns)
if not DB.isWW then return end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	if not Menu then return end

	local menuManagerProxy = Menu.GetManager()

	local styled
	hooksecurefunc(menuManagerProxy, "OpenMenu", function()
		local menuFrame = menuManagerProxy:GetOpenMenu()
		if menuFrame then
			B.StripTextures(menuFrame)
			if not styled then
				B.SetBD(menuFrame)
				B.ReskinTrimScroll(menuFrame.ScrollBar)
				styled = true
			end

			for i = 1, menuFrame:GetNumChildren() do
				local child = select(i, menuFrame:GetChildren())

				local minLevel = child.MinLevel
				if minLevel and not minLevel.styled then
					B.ReskinEditBox(minLevel)
					minLevel.styled = true
				end

				local maxLevel = child.MaxLevel
				if maxLevel and not maxLevel.styled then
					B.ReskinEditBox(maxLevel)
					maxLevel.styled = true
				end
			end
		end
	end)
end)