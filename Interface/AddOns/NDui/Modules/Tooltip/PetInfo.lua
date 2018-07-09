local _, ns = ...
local B, C, L, DB = unpack(ns)

local function insertPetIcon(self, petType)
	if not self.petIcon then
		local f = self:CreateTexture(nil, "OVERLAY")
		f:SetPoint("TOPRIGHT", -5, -5)
		f:SetSize(35, 35)
		f:SetBlendMode("ADD")
		f:SetTexCoord(.188, .883, 0, .348)
		self.petIcon = f
	end
	self.petIcon:SetTexture("Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[petType])
	self.petIcon:SetAlpha(1)
end

GameTooltip:HookScript("OnTooltipCleared", function(self)
	if self.petIcon and self.petIcon:GetAlpha() ~= 0 then
		self.petIcon:SetAlpha(0)
	end
end)

local function addPetInfo(self)
	local _, unit = self:GetUnit()
	if not unit then return end
	if not UnitIsBattlePet(unit) then return end

	-- Pet Species icon
	insertPetIcon(self, UnitBattlePetType(unit))

	-- Pet ID
	local speciesID = UnitBattlePetSpeciesID(unit)
	self:AddDoubleLine(PET..ID..":", ((DB.InfoColor..speciesID.."|r") or (DB.GreyColor..UNKNOWN.."|r")))
end
GameTooltip:HookScript("OnTooltipSetUnit", addPetInfo)