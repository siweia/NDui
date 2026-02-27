local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

function UF:CreateEnergyTick(self)
	if self.mystyle ~= "player" then return end

	local _, class = UnitClass("player")
	if class ~= "ROGUE" and class ~= "DRUID" then return end

	if not self.Power then return end

	local spark = self.Power:CreateTexture(nil, "OVERLAY")
	spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	spark:SetBlendMode("ADD")
	
	-- Base the spark off the official oUF Energy color (so it naturally blends)
	-- but boost the alpha/brightness so it still pops against the bar
	local energyColor = oUF.colors.power["ENERGY"] or {1, 1, 0}
	spark:SetVertexColor(energyColor[1], energyColor[2], energyColor[3], 1.0)
	
	-- Make spark slightly taller than power bar
	spark:SetSize(12, self.Power:GetHeight() * 2.2) 
	
	self.EnergyTick = spark
end
