local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local wipe, tinsert, tconcat = table.wipe, table.insert, table.concat
local IsInGroup, IsInRaid, GetNumGroupMembers = IsInGroup, IsInRaid, GetNumGroupMembers
local UnitExists, UnitIsUnit, UnitIsDeadOrGhost, UnitName = UnitExists, UnitIsUnit, UnitIsDeadOrGhost, UnitName

local targetTable = {}

function TT:ScanTargets()
	if not C.db["Tooltip"]["TargetBy"] then return end
	if not IsInGroup() then return end

	local _, unit = self:GetUnit()
	if not UnitExists(unit) then return end

	wipe(targetTable)

	local isInRaid = IsInRaid()
	for i = 1, GetNumGroupMembers() do
		local member = (isInRaid and "raid"..i or "party"..i)
		if UnitIsUnit(unit, member.."target") and not UnitIsUnit("player", member) and not UnitIsDeadOrGhost(member) then
			local color = B.HexRGB(B.UnitColor(member))
			local name = color..UnitName(member).."|r"
			tinsert(targetTable, name)
		end
	end

	if #targetTable > 0 then
		GameTooltip:AddLine(L["Targeted By"]..DB.InfoColor.."("..#targetTable..")|r "..tconcat(targetTable, ", "), nil, nil, nil, 1)
	end
end

function TT:TargetedInfo()
	GameTooltip:HookScript("OnTooltipSetUnit", TT.ScanTargets)
end