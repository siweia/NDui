local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

local _G = _G
local GetTotemInfo = GetTotemInfo

-- Style
local totems = {}

function A:TotemBar_Init()
	local margin = C.margin
	local vertical = C.db["Auras"]["VerticalTotems"]
	local iconSize = C.db["Auras"]["TotemSize"]
	local width = vertical and (iconSize + margin*2) or (iconSize*4 + margin*5)
	local height = vertical and (iconSize*4 + margin*5) or (iconSize + margin*2)

	local totemBar = _G["NDui_TotemBar"]
	if not totemBar then
		totemBar = CreateFrame("Frame", "NDui_TotemBar", UIParent)
	end
	totemBar:SetSize(width, height)

	if not totemBar.mover then
		totemBar.mover = B.Mover(totemBar, L["Totembar"], "Totems", C.Auras.TotemsPos)
	end
	totemBar.mover:SetSize(width, height)

	for i = 1, 4 do
		local totem = totems[i]
		if not totem then
			totem = CreateFrame("Frame", nil, totemBar)
			B.AuraIcon(totem)
			totem:SetAlpha(0)
			totems[i] = totem

			local blizzTotem = _G["TotemFrameTotem"..i]
			blizzTotem:SetParent(totem)
			blizzTotem:SetAllPoints()
			blizzTotem:SetAlpha(0)
			totem.__owner = blizzTotem
		end

		totem:SetSize(iconSize, iconSize)
		totem:ClearAllPoints()
		if i == 1 then
			totem:SetPoint("BOTTOMLEFT", margin, margin)
		elseif vertical then
			totem:SetPoint("BOTTOM", totems[i-1], "TOP", 0, margin)
		else
			totem:SetPoint("LEFT", totems[i-1], "RIGHT", margin, 0)
		end
	end
end

function A:TotemBar_Update()
	for i = 1, 4 do
		local totem = totems[i]
		local defaultTotem = totem.__owner
		local slot = defaultTotem.slot

		local haveTotem, _, start, dur, icon = GetTotemInfo(slot)
		if haveTotem and dur > 0 then
			totem.Icon:SetTexture(icon)
			totem.CD:SetCooldown(start, dur)
			totem.CD:Show()
			totem:SetAlpha(1)
		else
			totem.Icon:SetTexture("")
			totem.CD:Hide()
			totem:SetAlpha(0)
		end
	end
end

function A:Totems()
	if not C.db["Auras"]["Totems"] then return end

	A:TotemBar_Init()
	B:RegisterEvent("PLAYER_ENTERING_WORLD", A.TotemBar_Update)
	B:RegisterEvent("PLAYER_TOTEM_UPDATE", A.TotemBar_Update)
end