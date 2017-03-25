local B, C, L, DB = unpack(select(2, ...))

local tab = DB.ReminderBuffs[DB.MyClass]
if not tab then tab = {} end
local function OnEvent(self)
	if UnitLevel("player") < 10 then return end
	local group = tab[self.id]
	if not group.spells and not group.stance then return end
	if not GetActiveSpecGroup() then return end
	if group.level and UnitLevel("player") < group.level then return end

	self.icon:SetTexture(nil)
	self:Hide()
	if group.negate_spells then
		for buff, value in pairs(group.negate_spells) do
			if value == true then
				local name = GetSpellInfo(buff)
				if (name and UnitBuff("player", name)) then
					return
				end
			end
		end
	end

	if group.spells then
		for buff, value in pairs(group.spells) do
			if value == true then
				local usable, nomana = IsUsableSpell(buff)
				if (usable or nomana) then
					self.icon:SetTexture(GetSpellTexture(buff))
					break
				end
			end
		end
	end

	local role = group.role
	local tree = group.tree
	local requirespell = group.requirespell
	local combat = group.combat
	local personal = group.personal
	local instance = group.instance
	local pvp = group.pvp
	local reversecheck = group.reversecheck
	local negate_reversecheck = group.negate_reversecheck
	local rolepass, treepass, combatpass, instancepass, pvppass, requirepass
	local inInstance, instanceType = IsInInstance()

	if role and role ~= DB.Role then
		rolepass = false
	else
		rolepass = true
	end

	if tree and tree ~= GetSpecialization() then
		treepass = false
	else
		treepass = true
	end

	if requirespell and not IsPlayerSpell(requirespell) then
		requirepass = false
	else
		requirepass = true
	end

	if combat and UnitAffectingCombat("player") then
		combatpass = true
	else
		combatpass = false
	end

	if instance and inInstance and (instanceType == "scenario" or instanceType == "party" or instanceType == "raid") then
		instancepass = true
	else
		instancepass = false
	end

	if pvp and (instanceType == "arena" or instanceType == "pvp" or GetZonePVPInfo() == "combat") then
		pvppass = true
	else
		pvppass = false
	end

	if not instance and not pvp then
		instancepass = true
		pvppass = true
	end
	--Prevent user error
	if reversecheck ~= nil and (role == nil and tree == nil) then reversecheck = nil end

	if group.spells then
		if treepass and rolepass and requirepass and (combatpass or instancepass or pvppass) and not (UnitInVehicle("player") and self.icon:GetTexture()) then	
			for buff, value in pairs(group.spells) do
				if value == true then
					local name = GetSpellInfo(buff)
					local _, _, icon, _, _, _, _, unitCaster, _, _, _ = UnitBuff("player", name)
					if personal and personal == true then
						if (name and icon and unitCaster == "player") then
							self:Hide()
							return
						end
					else
						if (name and icon) then
							self:Hide()
							return
						end
					end
				end
			end
			self:Show()
			B.CreateFS(self, 14, L["Lack"].." "..self.id, true, "BOTTOM", 0, -18)
		elseif (combatpass or instancepass or pvppass) and reversecheck and not (UnitInVehicle("player") and self.icon:GetTexture()) then
			if negate_reversecheck and negate_reversecheck == GetSpecialization() then self:Hide() return end
			for buff, value in pairs(group.spells) do
				if value == true then
					local name = GetSpellInfo(buff)
					local _, _, icon, _, _, _, _, unitCaster, _, _, _ = UnitBuff("player", name)
					if (name and icon and unitCaster == "player") then
						self:Show()
						B.CreateFS(self, 14, CANCEL.." "..self.id, true, "BOTTOM", 0, -18)
						return
					end	
				end
			end
		end
	end
end

local i = 0
for groupName, _ in pairs(tab) do
	i = i + 1
	local frame = CreateFrame("Frame", "ReminderFrame"..i, UIParent)
	frame:SetSize(42,42)
	frame:SetPoint("CENTER", UIParent, "CENTER", -220, 130)
	frame:SetFrameLevel(1)
	frame.id = groupName
	frame.icon = frame:CreateTexture(nil, "OVERLAY")
	frame.icon:SetTexCoord(unpack(DB.TexCoord))
	frame.icon:SetAllPoints()
	frame:Hide()
	B.CreateSD(frame, 4, 4)

	frame:RegisterUnitEvent("UNIT_AURA", "player")
	frame:RegisterEvent("PLAYER_TALENT_UPDATE")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	frame:RegisterEvent("UNIT_ENTERING_VEHICLE")
	frame:RegisterEvent("UNIT_ENTERED_VEHICLE")
	frame:RegisterEvent("UNIT_EXITING_VEHICLE")
	frame:RegisterEvent("UNIT_EXITED_VEHICLE")
	frame:SetScript("OnEvent", function(self)
		if not NDuiDB["Auras"]["Reminder"] then return end
		OnEvent(self)
	end)
	frame:SetScript("OnUpdate", function(self, elapsed)
		if not self.icon:GetTexture() then
			self:Hide()
		end
	end)
	frame:SetScript("OnShow", function(self)
		if not self.icon:GetTexture() then
			self:Hide()
		end
	end)
end