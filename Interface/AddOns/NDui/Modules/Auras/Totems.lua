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
		totemBar = CreateFrame("Frame", "NDui_TotemBar", A.PetBattleFrameHider)
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

	local activeTotems = 0
	for button in _G.TotemFrame.totemPool:EnumerateActive() do
		activeTotems = activeTotems + 1

		local haveTotem, _, start, dur, icon = GetTotemInfo(button.slot)
		local totem = totems[activeTotems]
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

		button:ClearAllPoints()
		button:SetParent(totem)
		button:SetAllPoints(totem)
		button:SetAlpha(0)
		button:SetFrameLevel(totem:GetFrameLevel() + 1)
	end

	for i = activeTotems+1, 4 do
		local totem = totems[i]
		totem.Icon:SetTexture("")
		totem.CD:Hide()
		totem:SetAlpha(0)
	end
end

function A:Totems()
	if not C.db["Auras"]["Totems"] then return end

	A:TotemBar_Init()
	hooksecurefunc(TotemFrame, "Update", A.TotemBar_Update)
end