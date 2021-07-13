local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local dominationData = {
	[187063] = 1,
	[187287] = 2,
	[187296] = 3,
	[187305] = 4,
	[187315] = 5,

	[187073] = 1,
	[187079] = 1,
	[187061] = 1,
	[187057] = 1,
	[187318] = 1,
	[187076] = 1,
	[187059] = 1,
	[187065] = 1,
	[187071] = 1,
	[187312] = 1,
	[187286] = 1,
	[187290] = 1,
	[187308] = 1,
	[187299] = 1,
	[187292] = 1,
	[187284] = 1,
	[187295] = 1,
	[187302] = 1,
	[187293] = 1,
	[187291] = 1,
	[187285] = 1,
	[187320] = 1,
	[187288] = 1,
	[187289] = 1,
	[187301] = 1,
	[187310] = 1,
	[187304] = 1,
	[187294] = 1,
	[187298] = 1,
	[187303] = 1,
	[187314] = 1,
	[187313] = 1,
	[187297] = 1,
	[187307] = 1,
	[187300] = 1,
	[187319] = 1,
	[187316] = 1,
	[187317] = 1,
	[187309] = 1,
	[187306] = 1,
}

local cache = {}
local function showtip(self)
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 3)
	GameTooltip:SetHyperlink(select(2, GetItemInfo(self.id)))
	GameTooltip:Show()
	if not cache[self.id] then
		local name = GetItemInfo(self.id)
		print(name, self.id)
		cache[self.id] = true
	end
end

function TT:ShowDomiInfo()
	local buttons = {}
	local i= 1
	for itemID in pairs(dominationData) do
		local f = CreateFrame("Button", nil, UIParent)
		f:SetSize(50, 50)
		local tex = f:CreateTexture()
		tex:SetAllPoints()
		tex:SetTexture(GetItemIcon(itemID))
		buttons[i] = f

		f.id = itemID
		f:SetScript("OnLeave", B.HideTooltip)
		f:SetScript("OnEnter", showtip)
		if i == 1 then
			f:SetPoint("CENTER", -200, 200)
		elseif mod(i, 9) == 1 then
			f:SetPoint("TOP", buttons[i-9], "BOTTOM", 0, -5)
		else
			f:SetPoint("LEFT", buttons[i-1], "RIGHT", 5, 0)
		end
		i = i + 1
	end
end