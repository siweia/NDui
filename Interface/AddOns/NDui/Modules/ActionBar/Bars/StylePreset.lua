local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local valueIndex = {
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

	[21] = "BarPetSize",
	[22] = "BarPetFont",
	[23] = "BarPetNum",
	[24] = "BarPetPerRow",
}

function Bar:UpdateActionbarStyle(preset)
	if not preset then return end

	local values = {strsplit(":", preset)}
	if values[1] ~= "NAB" then return end

	for index = 2, #values do
		local value = values[index]
		value = tonumber(value)
		C.db["Actionbar"][valueIndex[index-1]] = value
	end
	Bar:UpdateAllScale()
end