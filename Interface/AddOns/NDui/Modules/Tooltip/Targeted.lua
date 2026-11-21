local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local IsInGroup, IsInRaid = IsInGroup, IsInRaid
local GetNumGroupMembers, GetNumSubgroupMembers = GetNumGroupMembers, GetNumSubgroupMembers
local UnitIsUnit, UnitIsDeadOrGhost = UnitIsUnit, UnitIsDeadOrGhost
local UnitNameUnmodified, UnitClass = UnitNameUnmodified, UnitClass

local function GetTargetingMemberName(member, unit)
	local memberTarget = member.."target"
	if not TT:UnitExists(member) or not TT:UnitExists(memberTarget) then return end

	local isTargeted = UnitIsUnit(unit, memberTarget)
	if B:IsSecretValue(isTargeted) or not isTargeted then return end

	local isPlayer = UnitIsUnit(member, "player")
	local isDead = UnitIsDeadOrGhost(member)
	if B:IsSecretValue(isPlayer) or isPlayer or B:IsSecretValue(isDead) or isDead then return end

	local name, surname = UnitNameUnmodified(member)
	if B:IsSecretValue(name) or not name then return end
	if B:NotSecretValue(surname) and surname and surname ~= "" then
		name = name.." "..surname
	end

	local _, class = UnitClass(member)
	if B:IsSecretValue(class) then class = nil end
	return B.ClassColorString(class)..name.."|r"
end

function TT:ShowTargetedBy(tooltip, unit)
	if not C.db["Tooltip"]["TargetBy"] or not IsInGroup() then return end
	if not self:UnitExists(unit) then return end

	local inRaid = IsInRaid()
	local unitPrefix = inRaid and "raid" or "party"
	local numMembers = inRaid and GetNumGroupMembers() or GetNumSubgroupMembers()
	local targetedBy = {}

	for i = 1, numMembers do
		local name = GetTargetingMemberName(unitPrefix..i, unit)
		if name then
			targetedBy[#targetedBy + 1] = name
		end
	end

	if #targetedBy > 0 then
		tooltip:AddLine(L["Targeted By"].." "..DB.InfoColor.."("..#targetedBy..")|r "..table.concat(targetedBy, ", "), 1, 1, 1, true)
	end
end
