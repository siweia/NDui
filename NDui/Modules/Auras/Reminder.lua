local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

local groups = DB.ReminderBuffs[DB.MyClass]
local iconSize = 36
local frames, parentFrame = {}
local InCombatLockdown, GetZonePVPInfo, UnitIsDeadOrGhost = InCombatLockdown, GetZonePVPInfo, UnitIsDeadOrGhost
local IsInInstance, IsPlayerSpell, UnitBuff, GetSpellTexture = IsInInstance, IsPlayerSpell, UnitBuff, GetSpellTexture
local pairs, tinsert, next = pairs, table.insert, next

function A:Reminder_ConvertToName(cfg)
	local cache = {}
	for spellID in pairs(cfg.spells) do
		local name = GetSpellInfo(spellID)
		if name then
			cache[name] = true
		end
	end
	for name in pairs(cache) do
		cfg.spells[name] = true
	end
end

function A:Reminder_CheckMeleeSpell()
	for _, cfg in pairs(groups) do
		local depends = cfg.depends
		if depends then
			for _, spellID in pairs(depends) do
				if IsPlayerSpell(spellID) then
					cfg.dependsKnown = true
					break
				end
			end
		end
	end
end

function A:Reminder_Update(cfg)
	local frame = cfg.frame
	local depend = cfg.depend
	local depends = cfg.depends
	local combat = cfg.combat
	local instance = cfg.instance
	local pvp = cfg.pvp
	local isPlayerSpell, isInCombat, isInInst, isInPVP = true
	local inInst, instType = IsInInstance()

	if depend and not IsPlayerSpell(depend) then isPlayerSpell = false end
	if depends and not cfg.dependsKnown then isPlayerSpell = false end
	if combat and InCombatLockdown() then isInCombat = true end
	if instance and inInst and (instType == "scenario" or instType == "party" or instType == "raid") then isInInst = true end
	if pvp and (instType == "arena" or instType == "pvp" or GetZonePVPInfo() == "combat") then isInPVP = true end
	if not combat and not instance and not pvp then isInCombat, isInInst, isInPVP = true, true, true end

	frame:Hide()
	if isPlayerSpell and (isInCombat or isInInst or isInPVP) and not UnitIsDeadOrGhost("player") then
		for i = 1, 32 do
			local name, _, _, _, _, _, caster = UnitBuff("player", i)
			if not name then break end
			if name and (cfg.spells[name] or cfg.gemini and cfg.gemini[name] and caster == "player") then
				frame:Hide()
				return
			end
		end
		frame:Show()
	end
end

function A:Reminder_Create(cfg)
	local frame = CreateFrame("Frame", nil, parentFrame)
	frame:SetSize(iconSize, iconSize)
	B.PixelIcon(frame)
	B.CreateSD(frame)
	if cfg.texture then
		frame.Icon:SetTexture(cfg.texture)
	else
		for spell in pairs(cfg.spells) do
			frame.Icon:SetTexture(GetSpellTexture(spell))
			break
		end
	end
	frame.text = B.CreateFS(frame, 14, L["Lack"], false, "TOP", 1, 15)
	frame:Hide()
	cfg.frame = frame

	tinsert(frames, frame)
end

function A:Reminder_UpdateAnchor()
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

function A:Reminder_OnEvent()
	for _, cfg in pairs(groups) do
		if not cfg.frame then
			A:Reminder_Create(cfg)
			A:Reminder_ConvertToName(cfg)
		end
		A:Reminder_Update(cfg)
	end
	A:Reminder_UpdateAnchor()
end

function A:InitReminder()
	if not groups then return end

	if C.db["Auras"]["Reminder"] then
		if not parentFrame then
			parentFrame = CreateFrame("Frame", nil, UIParent)
			parentFrame:SetPoint("CENTER", -220, 130)
			parentFrame:SetSize(iconSize, iconSize)
		end
		parentFrame:Show()

		A:Reminder_CheckMeleeSpell()
		B:RegisterEvent("LEARNED_SPELL_IN_TAB", A.Reminder_CheckMeleeSpell)

		A:Reminder_OnEvent()
		B:RegisterEvent("UNIT_AURA", A.Reminder_OnEvent, "player")
		B:RegisterEvent("PLAYER_REGEN_ENABLED", A.Reminder_OnEvent)
		B:RegisterEvent("PLAYER_REGEN_DISABLED", A.Reminder_OnEvent)
		B:RegisterEvent("ZONE_CHANGED_NEW_AREA", A.Reminder_OnEvent)
		B:RegisterEvent("PLAYER_ENTERING_WORLD", A.Reminder_OnEvent)
	else
		if parentFrame then
			parentFrame:Hide()
			B:UnregisterEvent("LEARNED_SPELL_IN_TAB", A.Reminder_CheckMeleeSpell)
			B:UnregisterEvent("UNIT_AURA", A.Reminder_OnEvent)
			B:UnregisterEvent("PLAYER_REGEN_ENABLED", A.Reminder_OnEvent)
			B:UnregisterEvent("PLAYER_REGEN_DISABLED", A.Reminder_OnEvent)
			B:UnregisterEvent("ZONE_CHANGED_NEW_AREA", A.Reminder_OnEvent)
			B:UnregisterEvent("PLAYER_ENTERING_WORLD", A.Reminder_OnEvent)
		end
	end
end