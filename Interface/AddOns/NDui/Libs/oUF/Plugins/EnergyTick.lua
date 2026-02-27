local _, ns = ...
local oUF = ns.oUF

local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax

local function OnUpdate(self, elapsed)
	local element = self.EnergyTick
	if not element then return end

	-- Don't animate if hidden or if it's not currently active
	if not element:IsShown() then return end

	element.timer = (element.timer or 0) + elapsed
	
	-- Reset the 2-second interval bounds
	if element.timer >= 2 then
		element.timer = element.timer % 2
	end

	-- Update the spark position based on the power bar's exact width
	local barWidth = self.Power:GetWidth()
	if barWidth > 0 then
		local position = (element.timer / 2) * barWidth
		element:SetPoint("CENTER", self.Power, "LEFT", position, 0)
	end
end

local function Update(self, event, unit, powerType)
	if self.unit ~= unit or (powerType and powerType ~= "ENERGY") then return end

	local element = self.EnergyTick
	if not element then return end

	-- Use 3 for Energy type
	local currentPower = UnitPower(unit, 3)

	-- If energy has increased from what we last saw, the server just processed a tick
	if event == "UNIT_POWER_UPDATE" then
		if currentPower > (element.lastPower or 0) then
			-- It ticked! Sync the visual spark back to the left side
			element.timer = 0
		end
	end

	element.lastPower = currentPower

	-- Hide the spark gracefully when energy is completely full
	if currentPower >= UnitPowerMax(unit, 3) then
		element:SetAlpha(0)
	else
		element:SetAlpha(element.defaultAlpha or 1)
	end
end

local function Path(self, ...)
	return (self.EnergyTick.Override or Update)(self, ...)
end

local function Enable(self, unit)
	local element = self.EnergyTick
	if element and unit == "player" then
		element.__owner = self
		element.timer = 0
		element.lastPower = UnitPower("player", 3)
		
		-- Fallback alpha configuration
		element.defaultAlpha = element:GetAlpha() == 0 and 1 or element:GetAlpha()

		-- Hook standard events
		self:RegisterEvent("UNIT_POWER_UPDATE", Path)
		self:RegisterEvent("UNIT_MAXPOWER", Path)
		
		-- Tie an OnUpdate script to the player's unitframe to animate it smoothly 
		if not self.EnergyTickUpdateHooked then
			self:HookScript("OnUpdate", OnUpdate)
			self.EnergyTickUpdateHooked = true
		end

		element:Show()
		return true
	end
end

local function Disable(self)
	local element = self.EnergyTick
	if element then
		element:Hide()
		self:UnregisterEvent("UNIT_POWER_UPDATE", Path)
		self:UnregisterEvent("UNIT_MAXPOWER", Path)
	end
end

oUF:AddElement("EnergyTick", Path, Enable, Disable)
