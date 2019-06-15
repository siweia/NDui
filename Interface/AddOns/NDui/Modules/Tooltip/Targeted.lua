local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local targetTable = {}

function TT:ScanTargets(unit)
	wipe(targetTable)

	for i = 1, GetNumGroupMembers() do
		local member = (IsInRaid() and "raid"..i or "party"..i)
		if UnitIsUnit(unit, member.."target") and not UnitIsUnit("player", member) and not UnitIsDeadOrGhost(member) then
			local color = B.HexRGB(B.UnitColor(member))
			local name = color..UnitName(member).."|r"
			tinsert(targetTable, name)
		end
	end

	if #targetTable > 0 then
		GameTooltip:AddLine(L["Targeted By"]..DB.InfoColor.."("..#targetTable..")|r "..table.concat(targetTable, ", "), nil, nil, nil, 1)
	end
end

function TT:TargetedInfo()
	GameTooltip:HookScript("OnTooltipSetUnit", function(self)
		if not NDuiDB["Tooltip"]["TargetBy"] then return end
		if not IsInGroup() then return end
	
		local _, unit = self:GetUnit()
		if UnitExists(unit) then
			TT:ScanTargets(unit)
		end
	end)
end