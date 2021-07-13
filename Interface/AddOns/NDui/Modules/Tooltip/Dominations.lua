local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

TT.DomiData = {
	[187063] = 1, -- 克尔碎片
	[187287] = 2, -- 不祥克尔碎片
	[187296] = 3, -- 荒芜克尔碎片
	[187305] = 4, -- 预感克尔碎片
	[187315] = 5, -- 征兆克尔碎片
	
	[187071] = 1, -- 泰尔碎片
	[187289] = 2, -- 不祥泰尔碎片
	[187298] = 3, -- 荒芜泰尔碎片
	[187307] = 4, -- 预感泰尔碎片
	[187317] = 5, -- 征兆泰尔碎片
	
	[187079] = 1, -- 泽德碎片
	[187292] = 2, -- 不祥泽德碎片
	[187301] = 3, -- 荒芜泽德碎片
	[187310] = 4, -- 预感泽德碎片
	[187320] = 5, -- 征兆泽德碎片
	
	[187057] = 1, -- 贝克碎片
	[187284] = 2, -- 不祥贝克碎片
	[187293] = 3, -- 荒芜贝克碎片
	[187302] = 4, -- 预感贝克碎片
	[187312] = 5, -- 征兆贝克碎片
	
	[187065] = 1, -- 基尔碎片
	[187288] = 2, -- 不祥基尔碎片
	[187297] = 3, -- 荒芜基尔碎片
	[187306] = 4, -- 预感基尔碎片
	[187316] = 5, -- 征兆基尔碎片
	
	[187073] = 1, -- 迪兹碎片
	[187290] = 2, -- 不祥迪兹碎片
	[187299] = 3, -- 荒芜迪兹碎片
	[187308] = 4, -- 预感迪兹碎片
	[187318] = 5, -- 征兆迪兹碎片
	
	[187059] = 1, -- 亚斯碎片
	[187285] = 2, -- 不祥亚斯碎片
	[187294] = 3, -- 荒芜亚斯碎片
	[187303] = 4, -- 预感亚斯碎片
	[187313] = 5, -- 征兆亚斯碎片
	
	[187076] = 1, -- 欧兹碎片
	[187291] = 2, -- 不祥欧兹碎片
	[187300] = 3, -- 荒芜欧兹碎片
	[187309] = 4, -- 预感欧兹碎片
	[187319] = 5, -- 征兆欧兹碎片
	
	[187061] = 1, -- 雷弗碎片
	[187286] = 2, -- 不祥雷弗碎片
	[187295] = 3, -- 荒芜雷弗碎片
	[187304] = 4, -- 预感雷弗碎片
	[187314] = 5, -- 征兆雷弗碎片
}

local cache = {}
local function showtip(self)
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 3)
	GameTooltip:SetHyperlink(select(2, GetItemInfo(self.id)))
	GameTooltip:Show()
	if not cache[self.id] then
		local name = GetItemInfo(self.id)
		print("["..self.id.."] = 1, -- "..name)
		cache[self.id] = true
	end
end

function TT:TestDomi()
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

function TT:Donimation_CheckStatus()
	local _, link = self:GetItem()
	if not link then return end

	local itemID = GetItemInfoFromHyperlink(link)
	local rank = itemID and TT.DomiData[itemID]

	if rank then
		local textLine = _G[self:GetName().."TextLeft2"]
		local text = textLine and textLine:GetText()
		if text and strfind(text, "|cFF66BBFF") then
			textLine:SetText(text.." "..rank.."/5")
		end
	end
end

function TT:ShowDomiInfo()
	GameTooltip:HookScript("OnTooltipSetItem", TT.Donimation_CheckStatus)
	ItemRefTooltip:HookScript("OnTooltipSetItem", TT.Donimation_CheckStatus)
	ShoppingTooltip1:HookScript("OnTooltipSetItem", TT.Donimation_CheckStatus)
	GameTooltipTooltip:HookScript("OnTooltipSetItem", TT.Donimation_CheckStatus)
	EmbeddedItemTooltip:HookScript("OnTooltipSetItem", TT.Donimation_CheckStatus)
end