local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")
local M = B:GetModule("Mover")

local strsplit, tonumber, strmatch, ipairs = strsplit, tonumber, strmatch, ipairs

local optionValues = {
	[1] = "Bar1Size",
	[2] = "Bar1Font",
	[3] = "Bar1Num",
	[4] = "Bar1PerRow",

	[5] = "Bar2Size",
	[6] = "Bar2Font",
	[7] = "Bar2Num",
	[8] = "Bar2PerRow",

	[9] = "Bar3Size",
	[10] = "Bar3Font",
	[11] = "Bar3Num",
	[12] = "Bar3PerRow",

	[13] = "Bar4Size",
	[14] = "Bar4Font",
	[15] = "Bar4Num",
	[16] = "Bar4PerRow",

	[17] = "Bar5Size",
	[18] = "Bar5Font",
	[19] = "Bar5Num",
	[20] = "Bar5PerRow",

	[21] = "Bar6Size",
	[22] = "Bar6Font",
	[23] = "Bar6Num",
	[24] = "Bar6PerRow",

	[25] = "Bar7Size",
	[26] = "Bar7Font",
	[27] = "Bar7Num",
	[28] = "Bar7PerRow",

	[29] = "Bar8Size",
	[30] = "Bar8Font",
	[31] = "Bar8Num",
	[32] = "Bar8PerRow",

	[33] = "BarPetSize",
	[34] = "BarPetFont",
	[35] = "BarPetPerRow",

	[36] = "BarStanceSize",
	[37] = "BarStanceFont",
	[38] = "BarStancePerRow",
}

local moverValues = {
	[1] = "Bar1",
	[2] = "Bar2",
	[3] = "Bar3L",
	[4] = "Bar3R",
	[5] = "Bar4",
	[6] = "Bar5",
	[7] = "Bar6",
	[8] = "Bar7",
	[9] = "Bar8",
	[10] = "PetBar",
	[11] = "StanceBar",
}

local abbrToAnchor = {
	["TL"] = "TOPLEFT",
	["T"] = "TOP",
	["TR"] = "TOPRIGHT",
	["L"] = "LEFT",
	["R"] = "RIGHT",
	["BL"] = "BOTTOMLEFT",
	["B"] = "BOTTOM",
	["BR"] = "BOTTOMRIGHT",
}

local anchorToAbbr = {}
for abbr, anchor in pairs(abbrToAnchor) do
	anchorToAbbr[anchor] = abbr
end

function Bar:ImportActionbarStyle(preset)
	if not preset then return end

	local values = {strsplit(":", preset)}
	if values[1] ~= "NAB" then return end -- NDui Actionbar

	local numValues = #values
	local maxOptions = #optionValues + 1

	for index = 2, maxOptions do
		local value = values[index]
		value = tonumber(value)
		if not value then -- stop if string incorrect
			UIErrorsFrame:AddMessage(DB.InfoColor..L["StyleStringError"])
			return
		end
		C.db["Actionbar"][optionValues[index-1]] = value
	end
	Bar:UpdateAllSize()

	for index = maxOptions+1, numValues do
		local moverIndex = index - maxOptions
		local mover = Bar.movers[moverIndex]
		if mover then
			local x, point, y = strmatch(values[index], "(-*%d+)(%a+)(-*%d+)")
			x, y = tonumber(x), tonumber(y)
			point = abbrToAnchor[point]
			if point and x and y then
				mover:ClearAllPoints()
				mover:SetPoint(point, UIParent, point, x, y)
				C.db["Mover"][moverValues[moverIndex]] = {point, "UIParent", point, x, y}
			else
				UIErrorsFrame:AddMessage(DB.InfoColor..L["StyleStringError"])
				return
			end
		end
	end
end

function Bar:ExportActionbarStyle()
	local styleStr = "NAB"
	for _, value in ipairs(optionValues) do
		styleStr = styleStr..":"..C.db["Actionbar"][value]
	end

	for _, mover in ipairs(Bar.movers) do
		local x, y, point = M:CalculateMoverPoints(mover)
		styleStr = styleStr..":"..x..anchorToAbbr[point]..y
	end

	return styleStr
end