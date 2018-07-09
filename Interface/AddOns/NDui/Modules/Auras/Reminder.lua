local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Auras")

local groups = DB.ReminderBuffs[DB.MyClass]
local iconSize = C.Auras.IconSize + 4
local frames, parentFrame = {}

local function UpdateReminder(cfg)
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
			if name and cfg.spells[spellID] then
				frame:Hide()
				return
			end
		end
		frame:Show()
	end
end

local function AddReminder(cfg)
	local frame = CreateFrame("Frame", nil, parentFrame)
	frame:SetSize(iconSize, iconSize)
	B.CreateIF(frame)
	for spell in pairs(cfg.spells) do
		frame.Icon:SetTexture(GetSpellTexture(spell))
		break
	end
	frame.text = B.CreateFS(frame, 14, L["Lack"], false, "TOP", 1, 15)
	frame:Hide()
	cfg.frame = frame

	tinsert(frames, frame)
end

local function UpdateAnchor()
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

local function UpdateEvent()
	for _, cfg in pairs(groups) do
		if not cfg.frame then AddReminder(cfg) end
		UpdateReminder(cfg)
	end
	UpdateAnchor()
end

function module:InitReminder()
	if not groups then return end
	if not NDuiDB["Auras"]["Reminder"] then return end

	parentFrame = CreateFrame("Frame", nil, UIParent)
	parentFrame:SetPoint("CENTER", -220, 130)
	parentFrame:SetSize(iconSize, iconSize)

	B:RegisterEvent("UNIT_AURA", UpdateEvent, "player")
	B:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateEvent)
	B:RegisterEvent("PLAYER_REGEN_ENABLED", UpdateEvent)
	B:RegisterEvent("PLAYER_REGEN_DISABLED", UpdateEvent)
	B:RegisterEvent("ZONE_CHANGED_NEW_AREA", UpdateEvent)
	B:RegisterEvent("UNIT_ENTERED_VEHICLE", UpdateEvent)
	B:RegisterEvent("UNIT_EXITED_VEHICLE", UpdateEvent)
end