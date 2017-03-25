local parent, ns = ...
local oUF = ns.oUF

local _, PlayerClass = UnitClass"player"

-- Holds the class specific stuff.
local ClassPowerID, ClassPowerType
local ClassPowerEnable, ClassPowerDisable
local RequireSpec, RequireSpell

local UpdateTexture = function(element)
	local red, green, blue, desaturated
	if(PlayerClass == "MONK") then
		red, green, blue = 0, 1, .59
		desaturated = true
	elseif(PlayerClass == "WARLOCK") then
		red, green, blue = .58, .51, .79
		desaturated = true
	elseif(PlayerClass == "MAGE") then
		red, green, blue = .41, .8, .94
	elseif(PlayerClass == "PALADIN") then
		red, green, blue = .88, .88, .06
		desaturated = true
	elseif(PlayerClass == "ROGUE" or PlayerClass == "DRUID") then
		red, green, blue = .88, .88, .06
		desaturated = true
	end

	for i = 1, #element do
		local icon = element[i]
		if(icon.SetDesaturated) then
			icon:SetDesaturated(desaturated)
		end

		icon:SetStatusBarColor(red, green, blue)
	end
end

local Update = function(self, event, unit, powerType)
	if(unit ~= "player" or powerType ~= ClassPowerType) then
		return
	end

	local element = self.ClassIcons
	if(element.PreUpdate) then
		element:PreUpdate(event)
	end

	local cur, max, oldMax
	if(event ~= "ClassPowerDisable") then
		cur = UnitPower("player", ClassPowerID)
		max = UnitPowerMax("player", ClassPowerID)

		if max <= 6 then
			for i = 1, max do
				if(i <= cur) then
					element[i]:SetAlpha(1)
				else
					element[i]:SetAlpha(.3)
				end
				if element[1]:GetAlpha() == 1 then
					element[i]:Show()
				else
					element[i]:Hide()
				end
			end
		else
			if cur <= 5 then
				for i = 1, 5 do
					if i <= cur then
						element[i]:SetAlpha(1)
					else
						element[i]:SetAlpha(.3)
					end
					if element[1]:GetAlpha() == 1 then
						element[i]:Show()
					else
						element[i]:Hide()
					end
					element[i]:SetStatusBarColor(.88, .88, .06)
				end
			else
				for i = 1, 5 do
					element[i]:Show()
					element[i]:SetAlpha(1)
				end
				for i = 1, cur - 5 do
					element[i]:SetStatusBarColor(1, 0, 0)
				end
				for i = cur - 4, 5 do
					element[i]:SetStatusBarColor(.88, .88, .06)
				end
			end
		end

		oldMax = element.__max
		if(max ~= oldMax) then
			if(max < oldMax) then
				for i = max + 1, oldMax do
					if element[i] then element[i]:Hide() end
				end
			end

			UpdateTexture(element)
			element.__max = max
		end
	end

	if(element.PostUpdate) then
		return element:PostUpdate(cur, max, oldMax ~= max, event)
	end
end

local function Visibility(self, event, unit)
	local element = self.ClassIcons
	local shouldEnable

	if(not UnitHasVehicleUI("player")) then
		if(not RequireSpec or RequireSpec == GetSpecialization()) then
			if(not RequireSpell or IsPlayerSpell(RequireSpell)) then
				self:UnregisterEvent("SPELLS_CHANGED", Visibility)
				shouldEnable = true
			else
				self:RegisterEvent("SPELLS_CHANGED", Visibility, true)
			end
		end
	end

	local isEnabled = element.isEnabled
	if(shouldEnable and not isEnabled) then
		ClassPowerEnable(self)
	elseif(not shouldEnable and (isEnabled or isEnabled == nil)) then
		ClassPowerDisable(self)
	end
end

local UPDATE_VISIBILITY = function(self, event)
	local element = self.ClassIcons
	local myclass = select(2, UnitClass("player"))
	local powerType, powerToken = UnitPowerType("player")
	for i = 1, element.__max do
		if myclass == "DRUID" then
			if powerType == SPELL_POWER_ENERGY then
				if element[1]:GetAlpha() == 1 then
					element[i]:Show()
				else
					element[i]:Hide()
				end
			else
				element[i]:Hide()
			end
		end
	end
	if(element.PostUpdateVisibility) then
		return element:PostUpdateVisibility(self.unit)
	end
end

local Path = function(self, ...)
	return (self.ClassIcons.Override or Update) (self, ...)
end

local VisibilityPath = function(self, ...)
	return (self.ClassIcons.OverrideVisibility or Visibility) (self, ...)
end

local ForceUpdate = function(element)
	return VisibilityPath(element.__owner, "ForceUpdate", element.__owner.unit)
end

do
	ClassPowerEnable = function(self)
		self:RegisterEvent("UNIT_DISPLAYPOWER", Path)
		self:RegisterEvent("UNIT_POWER_FREQUENT", Path)
		self:RegisterEvent("UNIT_DISPLAYPOWER", UPDATE_VISIBILITY)
		Path(self, "ClassPowerEnable", "player", ClassPowerType)
		self.ClassIcons.isEnabled = true
	end

	ClassPowerDisable = function(self)
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
		self:UnregisterEvent("UNIT_POWER_FREQUENT", Path)
		self:UnregisterEvent("UNIT_DISPLAYPOWER", UPDATE_VISIBILITY)

		local element = self.ClassIcons
		for i = 1, #element do
			element[i]:Hide()
		end

		Path(self, "ClassPowerDisable", "player", ClassPowerType)
		self.ClassIcons.isEnabled = false
	end

	if(PlayerClass == "MONK") then
		ClassPowerID = SPELL_POWER_CHI
		ClassPowerType = "CHI"
		RequireSpec = SPEC_MONK_WINDWALKER
	elseif(PlayerClass == "PALADIN") then
		ClassPowerID = SPELL_POWER_HOLY_POWER
		ClassPowerType = "HOLY_POWER"
		RequireSpec = SPEC_PALADIN_RETRIBUTION
	elseif(PlayerClass == "MAGE") then
		ClassPowerID = SPELL_POWER_ARCANE_CHARGES
		ClassPowerType = "ARCANE_CHARGES"
		RequireSpec = SPEC_MAGE_ARCANE
	elseif(PlayerClass == "WARLOCK") then
		ClassPowerID = SPELL_POWER_SOUL_SHARDS
		ClassPowerType = "SOUL_SHARDS"
	elseif(PlayerClass == "ROGUE" or PlayerClass == "DRUID") then
		ClassPowerID = SPELL_POWER_COMBO_POINTS
		ClassPowerType = "COMBO_POINTS"
	end
end

local Enable = function(self, unit)
	if(unit ~= "player" or not ClassPowerID) then return end

	local element = self.ClassIcons
	if(not element) then return end

	element.__owner = self
	element.__max = #element
	element.ForceUpdate = ForceUpdate

	if(RequireSpec) then
		self:RegisterEvent("PLAYER_TALENT_UPDATE", VisibilityPath, true)
	end

	element.ClassPowerEnable = ClassPowerEnable
	element.ClassPowerDisable = ClassPowerDisable

	for i = 1, #element do
		local icon = element[i]
		if(icon:IsObjectType"Texture" and not icon:GetTexture()) then
			icon:SetTexCoord(0.45703125, 0.60546875, 0.44531250, 0.73437500)
			icon:SetTexture([[Interface\PlayerFrame\Priest-ShadowUI]])
		end
	end

	(element.UpdateTexture or UpdateTexture) (element)

	return true
end

local Disable = function(self)
	local element = self.ClassIcons
	if(not element) then return end

	ClassPowerDisable(self)
end

oUF:AddElement("ClassIcons", VisibilityPath, Enable, Disable)