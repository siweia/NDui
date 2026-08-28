local _, ns = ...
local B = unpack(ns)
local UF = B:GetModule("UnitFrames")

function UF:CreateRaidAuras(self)
	UF:CreateSpellsIndicator(self)
end

function UF:AuraButton_OnEnter()
	if not self.index then return end
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
	GameTooltip:ClearLines()
	GameTooltip:SetUnitAura(self.unit, self.index, self.filter)
	GameTooltip:Show()
end
