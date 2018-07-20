local _, ns = ...
local ycc = ns.ycc

hooksecurefunc("WorldStateScoreFrame_Update", function()
	local inArena = IsActiveBattlefieldArena()
	local offset = FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame)

	for i = 1, 20 do
		local index = offset + i
		local name, _, _, _, _, faction, _, _, class = GetBattlefieldScore(index)
		-- faction: Battlegrounds: Horde = 0, Alliance = 1 / Arenas: Green Team = 0, Yellow Team = 1
		if name then
			local n, r = strsplit("-", name, 2)
			n = ycc.classColor[class]..n.."|r"
			if name == ycc.myName then n = "> "..n.." <" end

			if r then
				local color
				if inArena then
					if faction == 1 then
						color = "|cffffd100"
					else
						color = "|cff19ff19"
					end
				else
					if faction == 1 then
						color = "|cff00adf0"
					else
						color = "|cffff1919"
					end
				end
				r = color..r.."|r"
				n = n.."|cffffffff - |r"..r
			end

			local button = _G["WorldStateScoreButton"..i]
			button.name.text:SetText(n)
		end
	end
end)