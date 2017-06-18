local B, C, L, DB = unpack(select(2, ...))
local cast = NDui.cast
local UF = NDui:GetModule("UnitFrames")

-- Init
function UF:SetupCVars()
	if NDuiDB["Nameplate"]["InsideView"] then
		SetCVar("nameplateOtherTopInset", .05)
		SetCVar("nameplateOtherBottomInset", .08)
	else
		SetCVar("nameplateOtherTopInset", -1)
		SetCVar("nameplateOtherBottomInset", -1)
	end
	SetCVar("nameplateMaxDistance", NDuiDB["Nameplate"]["Distance"])
	SetCVar("nameplateOverlapH", .5)
	SetCVar("nameplateOverlapV", .7)
	SetCVar("nameplateMinAlpha", NDuiDB["Nameplate"]["MinAlpha"])
	SetCVar("nameplateOccludedAlphaMult", .2)
end

function UF:BlockAddons()
	if DBM and DBM.Nameplate then
		function DBM.Nameplate:SupportedNPMod()
			return true
		end
	end
end

local CustomUnits = {}
function UF:CreateUnitTable()
	if not NDuiDB["Nameplate"]["CustomUnitColor"] then return end

	local list = {string.split(" ", NDuiDB["Nameplate"]["UnitList"])}
	for _, value in pairs(list) do
		CustomUnits[value] = true
	end
end

C.ShowPowerList = {
	["Scrubber"] = true,
	["清扫器"] = true,
	["清掃者"] = true,
}
function UF:CreatePowerUnitTable()
	if not NDuiDB["Nameplate"]["ShowUnitPower"] then return end

	local list = {string.split(" ", NDuiDB["Nameplate"]["ShowPowerList"])}
	for _, value in pairs(list) do
		C.ShowPowerList[value] = true
	end
end

-- Elements
local function UpdateColor(element, unit)
	local name = GetUnitName(unit) or UNKNOWN
	local status = UnitThreatSituation("player", unit) or false		-- just in case
	local reaction = UnitReaction(unit, "player")
	local r, g, b

	if not UnitIsConnected(unit) then
		r, g, b = .7, .7, .7
	else
		if UnitIsUnit("player", unit) then	-- PlayerPlate
			r, g, b = B.UnitColor(unit)
		elseif CustomUnits and CustomUnits[name] then
			r, g, b = 0, .8, .3
		elseif UnitIsPlayer(unit) and (reaction and reaction >= 5) then
			if NDuiDB["Nameplate"]["FriendlyCC"] then
				r, g, b = B.UnitColor(unit)
			else
				r, g, b = .3, .3, 1
			end
		elseif UnitIsPlayer(unit) and (reaction and reaction <= 4) and NDuiDB["Nameplate"]["HostileCC"] then
			r, g, b = B.UnitColor(unit)
		elseif UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) then
			r, g, b = .6, .6, .6
		else
			r, g, b = UnitSelectionColor(unit, true)
			if status and (NDuiDB["Nameplate"]["TankMode"] or DB.Role == "Tank") then
				if status == 3 then
					r, g, b = 1, 0, 1
				elseif status == 2 or status == 1 then
					r, g, b = 1, .8, 0
				end
			end
		end
	end

	if r or g or b then
		element:SetStatusBarColor(r, g, b)
	end

	if not NDuiDB["Nameplate"]["TankMode"] and DB.Role ~= "Tank" then
		if status and status == 3 then
			element.Shadow:SetBackdropBorderColor(1, 0, 0)
		elseif status and (status == 2 or status == 1) then
			element.Shadow:SetBackdropBorderColor(1, 1, 0)
		else
			element.Shadow:SetBackdropBorderColor(0, 0, 0)
		end
	else
		element.Shadow:SetBackdropBorderColor(0, 0, 0)
	end
end

local function UpdateThreatColor(self, event, unit)
	if unit ~= self.unit then return end
	UpdateColor(self.Health, unit)
end

local function UpdateTargetMark(self)
	local mark = self.targetMark
	if not mark then return end

	if UnitIsUnit(self.unit, "target") and not UnitIsUnit(self.unit, "player") then
		mark:Show()
	else
		mark:Hide()
	end
end

local function CreatePlates(self, unit)
	self.mystyle = "nameplate"
	if unit:match("nameplate") then
		self:SetSize(NDuiDB["Nameplate"]["Width"] * 1.4, NDuiDB["Nameplate"]["Height"])
		self:SetPoint("CENTER", 0, -3)

		local health = CreateFrame("StatusBar", nil, self)
		health:SetAllPoints()
		health:SetFrameLevel(self:GetFrameLevel() - 2)
		B.CreateSB(health)
		B.SmoothBar(health)
		self.Health = health
		self.Health.frequentUpdates = true
		self.Health.UpdateColor = UpdateColor

		UF:CreateHealthText(self)
		UF:CreateCastBar(self)
		UF:CreateRaidMark(self)
		UF:CreatePrediction(self)
		UF:CreateAuras(self)
		UF:CreatePowerBar(self)

		self.powerText = B.CreateFS(self, 15, "", false, "LEFT", 0, 0)
		self.powerText:SetPoint("LEFT", self, "RIGHT", 2, 0)
		self:Tag(self.powerText, "[nppp]")

		if NDuiDB["Nameplate"]["Arrow"] then
			local arrow = self:CreateTexture(nil, "OVERLAY")
			arrow:SetSize(50, 50)
			arrow:SetTexture(DB.arrowTex)
			arrow:SetPoint("BOTTOM", self, "TOP", 0, 14)
			arrow:Hide()
			self.targetMark = arrow
		else
			local glow = CreateFrame("Frame", nil, self)
			glow:SetPoint("TOPLEFT", -5, 5)
			glow:SetPoint("BOTTOMRIGHT", 5, -5)
			glow:SetBackdrop({edgeFile = DB.glowTex, edgeSize = 4})
			glow:SetBackdropBorderColor(1, 1, 1)
			glow:SetFrameLevel(0)
			glow:Hide()
			self.targetMark = glow
		end
		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTargetMark)

		local cicon = self:CreateTexture(nil, "OVERLAY")
		cicon:SetPoint("LEFT", self, "TOPLEFT", 0, 2)
		cicon:SetSize(15, 15)
		cicon:SetAlpha(.75)
		self.creatureIcon = cicon

		local threatIndicator = CreateFrame("Frame", nil, self)
		self.ThreatIndicator = threatIndicator
		self.ThreatIndicator.Override = UpdateThreatColor
	end
end
UF.CreatePlates = CreatePlates

local classtex = {
	rare = {"Interface\\MINIMAP\\ObjectIcons", .391, .487, .644, .74},
	elite = {"Interface\\MINIMAP\\Minimap_skull_elite", 0, 1, 0, 1},
	rareelite = {"Interface\\MINIMAP\\ObjectIcons", .754, .875, .624, .749},
	worldboss = {"Interface\\MINIMAP\\ObjectIcons", .879, 1, .754, .879},
}

local function enableElement(self, name, element)
	if not self:IsElementEnabled(name) then
		self:EnableElement(name)
		element:ForceUpdate()
	end
end

local function disableElement(self, name)
	if self:IsElementEnabled(name) then
		self:DisableElement(name)
	end
end

local function UpdatePlates(self, event, unit)
	-- Update Mark
	UpdateTargetMark(self)

	-- Unit Classification
	local class = UnitClassification(unit)
	if self.creatureIcon then
		if class and classtex[class] then
			local tex, a, b, c, d = unpack(classtex[class])
			self.creatureIcon:SetTexture(tex)
			self.creatureIcon:SetTexCoord(a, b, c, d)
		else
			self.creatureIcon:SetTexture(nil)
		end
	end

	-- Update PlayerPlate
	if event == "NAME_PLATE_UNIT_ADDED" then
		if UnitIsUnit(unit, "player") then
			self:SetScale(.75)
			self.nameFrame:Hide()
			enableElement(self, "Power", self.Power)
			disableElement(self, "Castbar")
		else
			self:SetScale(1)
			self.nameFrame:Show()
			disableElement(self, "Power")
			enableElement(self, "Castbar", self.Castbar)
		end
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		self:SetScale(1)
		self.nameFrame:Hide()
		disableElement(self, "Power")
		disableElement(self, "Castbar")
	end

	-- Update ClassPowerBar
	local myBar, bar = _G.oUF_Player, _G.oUF_ClassPowerBar
	if not (myBar or bar) then return end

	if GetCVar("nameplateShowSelf") == "1" then
		if event == "NAME_PLATE_UNIT_ADDED" and UnitIsUnit(unit, "player") then
			local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player")
			if namePlatePlayer and GetCVar("nameplateShowSelf") == "1" then
				if bar:GetParent() ~= self then
					bar:SetParent(self)
					bar:ClearAllPoints()
					bar:SetPoint("BOTTOM", self.Health, "TOP", 0, 3)
				end
				bar:Show()
			end
		elseif event == "NAME_PLATE_UNIT_REMOVED" and UnitIsUnit(unit, "player") then
			bar:Hide()
		end
	else
		if bar:GetParent() ~= myBar then
			bar:SetParent(myBar)
			bar:ClearAllPoints()
			bar:SetPoint(unpack(C.UFs.BarPoint))
			bar:Show()
		end
	end
end
UF.PostUpdatePlates = UpdatePlates