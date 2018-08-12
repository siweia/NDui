local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Auras")

-- Monk Statue
local IconSize = C.Auras.IconSize - 2
local bu
local function StatueGo()
	if bu then bu:Show() return end

	bu = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
	bu:SetSize(IconSize, IconSize)
	B.CreateIF(bu, true, true)
	bu:RegisterForClicks("AnyUp")
	bu:SetAttribute("type1", "macro")
	bu:SetAttribute("type2", "macro")
	bu:SetAttribute("macrotext2", "/click TotemFrameTotem1 RightButton")
	bu:SetScript("OnEnter", function(self)
		if self:GetAlpha() < 1 then return end
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:SetTotem(1)
		GameTooltip:Show()
	end)
	bu:SetScript("OnLeave", GameTooltip_Hide)

	B.Mover(bu, L["Statue"], "Statue", C.Auras.StatuePos, IconSize, IconSize)
end

-- localizaed
local serpentStatue = GetSpellInfo(115313)
local serpentStatueTex = GetSpellTexture(115313)
local oxStatue = GetSpellInfo(115315)
local oxStatueTex = GetSpellTexture(115315)

local function updateStatue()
	local haveTotem, _, start, dur = GetTotemInfo(1)
	if haveTotem then
		bu.CD:SetCooldown(start, dur)
		bu.CD:Show()
		bu:SetAlpha(1)
	else
		bu.CD:Hide()
		bu:SetAlpha(.3)
	end
end

local function checkSpec(event)
	if (GetSpecialization() == 2 and IsPlayerSpell(115313)) or (GetSpecialization() == 1 and IsPlayerSpell(115315)) then
		StatueGo()
		bu:SetAlpha(.3)
		bu.CD:Hide()
		local statue
		if IsPlayerSpell(115313) then
			bu.Icon:SetTexture(serpentStatueTex)
			statue = serpentStatue
		else
			bu.Icon:SetTexture(oxStatueTex)
			statue = oxStatue
		end
		bu:SetAttribute("macrotext1", "/tar "..statue)
		B:RegisterEvent("PLAYER_TOTEM_UPDATE", updateStatue)
	else
		if bu then bu:Hide() end
		B:UnregisterEvent("PLAYER_TOTEM_UPDATE", updateStatue)
	end

	if event == "PLAYER_ENTERING_WORLD" then
		B:UnregisterEvent(event, checkSpec)
	end
end

function module:MonkStatue()
	if not NDuiDB["Auras"]["Statue"] then return end

	B:RegisterEvent("PLAYER_ENTERING_WORLD", checkSpec)
	B:RegisterEvent("PLAYER_TALENT_UPDATE", checkSpec)
end