local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Auras")

-- Style
local totem = {}
local icons = {
	[1] = GetSpellTexture(120217), -- Fire
	[2] = GetSpellTexture(120218), -- Earth
	[3] = GetSpellTexture(120214), -- Water
	[4] = GetSpellTexture(120219), -- Air
}

local function TotemsGo()
	local Totembar = CreateFrame("Frame", nil, UIParent)
	Totembar:SetSize(C.Auras.IconSize, C.Auras.IconSize)
	for i = 1, 4 do
		totem[i] = CreateFrame("Button", nil, Totembar)
		totem[i]:SetSize(C.Auras.IconSize, C.Auras.IconSize)
		if i == 1 then
			totem[i]:SetPoint("CENTER", Totembar)
		else
			totem[i]:SetPoint("LEFT", totem[i-1], "RIGHT", 5, 0)
		end
		B.CreateIF(totem[i], false, true)
		totem[i].Icon:SetTexture(icons[i])
		totem[i]:SetAlpha(.2)

		local defaultTotem = _G["TotemFrameTotem"..i]
		defaultTotem:SetParent(totem[i])
		defaultTotem:SetAllPoints()
		defaultTotem:SetAlpha(0)
		defaultTotem:EnableMouse(NDuiDB["Auras"]["DestroyTotems"])
		totem[i].parent = defaultTotem
	end
	B.Mover(Totembar, L["Totembar"], "Totems", C.Auras.TotemsPos, 140, 32)
end

local function updateTotem()
	for i = 1, 4 do
		local totem = totem[i]
		local defaultTotem = totem.parent
		local slot = defaultTotem.slot

		local haveTotem, name, start, dur, icon = GetTotemInfo(slot)
		if haveTotem and dur > 0 then
			totem.Icon:SetTexture(icon)
			totem.CD:SetCooldown(start, dur)
			totem.CD:Show()
			totem:SetAlpha(1)
		else
			totem:SetAlpha(.2)
			totem.Icon:SetTexture(icons[i])
			totem.CD:Hide()
		end
	end
end

function module:Totems()
	if not NDuiDB["Auras"]["Totems"] then return end

	TotemsGo()
	B:RegisterEvent("PLAYER_TOTEM_UPDATE", updateTotem)
end