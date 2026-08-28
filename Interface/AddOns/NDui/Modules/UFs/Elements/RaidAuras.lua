local _, ns = ...
local B = unpack(ns)
local UF = B:GetModule("UnitFrames")

function UF:CreateRaidAuras(self)
	UF:CreateSpellsIndicator(self)
end
