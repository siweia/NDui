local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Auras")

local groups = DB.ReminderBuffs[DB.MyClass]
local iconSize = C.Auras.IconSize + 4
local frames, parentFrame = {}
local GetSpecialization, InCombatLockdown, GetZonePVPInfo, UnitInVehicle = GetSpecialization, InCombatLockdown, GetZonePVPInfo, UnitInVehicle
local IsInInstance, IsPlayerSpell, UnitBuff, GetSpellTexture = IsInInstance, IsPlayerSpell, UnitBuff, GetSpellTexture
local pairs, tinsert, next = pairs, table.insert, next

function module:UpdateReminder(cfg)
	local frame = cfg.frame
	local depend = cfg.depend
	local spec = cfg.spec
	local combat = cfg.combat
	local instance = cfg.instance
	local pvp = cfg.pvp
	local isPlayerSpell, isRightSpec, isInCombat, isInInst, isInPVP = true, true
	local inInst, instType = IsInInstance()

	if depend and not IsPlayerSpell(depend) then isPlayerSpell = false end
	if spec and spec ~= GetSpecialization() then isRightSpec = false end
	if combat and InCombatLockdown() then isInCombat = true end
	if instance and inInst and (instType == "scenario" or instType == "party" or instType == "raid") then isInInst = true end
	if pvp and (instType == "arena" or instType == "pvp" or GetZonePVPInfo() == "combat") then isInPVP = true end
	if not combat and not instance and not pvp then isInCombat, isInInst, isInPVP = true, true, true end

	frame:Hide()
	if isPlayerSpell and isRightSpec and (isInCombat or isInInst or isInPVP) and not UnitInVehicle("player") then
		for i = 1, 32 do
			local name, _, _, _, _, _, _, _, _, spellID = UnitBuff("player", i)
			if not name then break end
			if name and cfg.spells[spellID] then
				frame:Hide()
				return
			end
		end
		frame:Show()
	end
end

function module:AddReminder(cfg)
	local frame = CreateFrame("Frame", nil, parentFrame)
	frame:SetSize(iconSize, iconSize)
	B.PixelIcon(frame)
	B.CreateSD(frame)
	for spell in pairs(cfg.spells) do
		frame.Icon:SetTexture(GetSpellTexture(spell))
		break
	end
	frame.text = B.CreateFS(frame, 14, L["Lack"], false, "TOP", 1, 15)
	frame:Hide()
	cfg.frame = frame

	tinsert(frames, frame)
end

function module:UpdateAnchor()
	local index = 0
	local offset = iconSize + 5
	for _, frame in next, frames do
		if frame:IsShown() then
			frame:SetPoint("LEFT", offset * index, 0)
			index = index + 1
		end
	end
	parentFrame:SetWidth(offset * index)
end

function module:EventUpdate()
	for _, cfg in pairs(groups) do
		if not cfg.frame then module:AddReminder(cfg) end
		module:UpdateReminder(cfg)
	end
	module:UpdateAnchor()
end

function module:InitReminder()
	if not groups then return end
	if not NDuiDB["Auras"]["Reminder"] then return end

	parentFrame = CreateFrame("Frame", nil, UIParent)
	parentFrame:SetPoint("CENTER", -220, 130)
	parentFrame:SetSize(iconSize, iconSize)

	B:RegisterEvent("UNIT_AURA", module.EventUpdate, "player")
	B:RegisterEvent("UNIT_EXITED_VEHICLE", module.EventUpdate)
	B:RegisterEvent("UNIT_ENTERED_VEHICLE", module.EventUpdate)
	B:RegisterEvent("PLAYER_REGEN_ENABLED", module.EventUpdate)
	B:RegisterEvent("PLAYER_REGEN_DISABLED", module.EventUpdate)
	B:RegisterEvent("ZONE_CHANGED_NEW_AREA", module.EventUpdate)
	B:RegisterEvent("PLAYER_ENTERING_WORLD", module.EventUpdate)
end