local _, ns = ...
local B, C, L, DB = unpack(ns)
local PA = B:RegisterModule("PrivateAuras")
local A = B:GetModule("Auras")

local MAX_PRIVATE_AURAS = 5
local AddPrivateAuraAnchor = C_UnitAuras.AddPrivateAuraAnchor
local RemovePrivateAuraAnchor = C_UnitAuras.RemovePrivateAuraAnchor
local SetPrivateWarningTextAnchor = C_UnitAuras.SetPrivateWarningTextAnchor

local tempDuration = {
	point = "TOP",
	relativeTo = UIParent,
	relativePoint = "BOTTOM",
	offsetX = 1,
	offsetY = 1,
}

local tempAnchor = {
	unitToken = "player",
	auraIndex = 1,
	parent = UIParent,
	showCountdownFrame = false,
	showCountdownNumbers = false,
	durationAnchor = tempDuration,

	iconInfo = {
		borderScale = 1,
		iconWidth = 16,
		iconHeight = 16,
		iconAnchor = {
			point = "CENTER",
			relativeTo = UIParent,
			relativePoint = "CENTER",
			offsetX = 0,
			offsetY = 0,
		},
	},
}

function PA:CreateAnchor(aura, parent, unit, index, db)
	if not unit then unit = parent.unit end

	local previousAura = parent.auraIcons[index]
	if previousAura then
		PA:RemoveAura(previousAura)
	end

	local iconSize = db.PrivateSize
	if not iconSize then iconSize = 16 end
	tempAnchor.unitToken = unit
	tempAnchor.auraIndex = index
	tempAnchor.parent = aura
	tempAnchor.showCountdownFrame = C.db["Auras"]["CDAnimation"]
	tempAnchor.durationAnchor.relativeTo = aura
	tempAnchor.iconInfo.iconWidth = iconSize
	tempAnchor.iconInfo.iconHeight = iconSize
	tempAnchor.iconInfo.borderScale = iconSize / 16
	tempAnchor.iconInfo.iconAnchor.relativeTo = aura

	return AddPrivateAuraAnchor(tempAnchor)
end

function PA:RemoveAura(aura)
	if aura.anchorID then
		RemovePrivateAuraAnchor(aura.anchorID)
		aura.anchorID = nil
	end
end

function PA:RemoveAuras(parent)
	if parent.auraIcons then
		for _, aura in next, parent.auraIcons do
			PA:RemoveAura(aura)
		end
	end
end

function PA:CreateAura(parent, unit, index, db)
	local aura = parent.auraIcons[index]
	if not aura then
		aura = CreateFrame("Frame", format("%s%d", parent:GetName(), index), parent)
	end

	local reverse = db.ReversePrivate
	local rel1 = reverse and "LEFT" or "RIGHT"
	local rel2 = reverse and "RIGHT" or "LEFT"
	local margin = reverse and C.margin or -C.margin

	aura:ClearAllPoints()
	if index == 1 then
		aura:SetPoint("CENTER", parent, 0, 0)
	else
		aura:SetPoint(rel1, parent.auraIcons[index-1], rel2, margin, 0)
	end
	aura:SetSize(db.PrivateSize, db.PrivateSize)

	aura.anchorID = PA:CreateAnchor(aura, parent, unit or "player", index, db)

	return aura
end

function PA:SetupPrivateAuras(db, parent, unit)
	if not db then db = C.db["Auras"] end

	if not parent then parent = UIParent end
	if not parent.auraIcons then
		parent.auraIcons = {}
	end

	for i = 1, MAX_PRIVATE_AURAS do
		parent.auraIcons[i] = PA:CreateAura(parent, unit or "player", i, db)
	end
end

function PA:Update()
	PA:RemoveAuras(PA.Auras)
	PA.Auras:SetSize(30, 30)
	PA:SetupPrivateAuras(nil, PA.Auras, "player")
end

function PA:OnLogin()
	if not C.db["Auras"]["BuffFrame"] then return end

	PA.Auras = CreateFrame("Frame", "NDui_PrivateAuras", UIParent)
	PA.Auras:SetSize(30, 30)
	PA.Auras.mover = B.Mover(PA.Auras, L["PrivateAuras"], "PrivateAuras", {"TOPRIGHT", A.DebuffFrame.mover, "BOTTOMRIGHT", 0, -12})

	PA:Update()
end