local B, C, L, DB = unpack(select(2, ...))
local oUF = NDui.oUF or oUF
local lib = NDui.lib

-- Raid Frame
lib.RaidElements = function(self)
	local check = self:CreateTexture(nil, "OVERLAY")
	check:SetSize(16, 16)
	check:SetPoint("CENTER")
	self.ReadyCheck = check

	local resurrect = self:CreateTexture(nil, "OVERLAY")
	resurrect:SetSize(20, 20)
	resurrect:SetPoint("CENTER", self, 1, 0)
	self.ResurrectIcon = resurrect
end

local function UpdateTargetBorder(self, event, unit)
	if UnitIsUnit("target", self.unit) then
		self.TargetBorder:Show()
	else
		self.TargetBorder:Hide()
	end
end
lib.CreateTargetBorder = function(self)
	self.TargetBorder = B.CreateBG(self, 2)
	self.TargetBorder:SetBackdrop({edgeFile = DB.bdTex, edgeSize = 1.2})
	self.TargetBorder:SetBackdropBorderColor(.7, .7, .7)
	self.TargetBorder:Hide()
	self.TargetBorder:SetPoint("BOTTOMRIGHT", self.Power, 2, -2)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTargetBorder)
	self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdateTargetBorder)
end

lib.genRaidDebuffs = function(self)
	local bu = CreateFrame("Frame", nil, self)
	local size = 18*NDuiDB["UFs"]["RaidScale"]
	bu:SetSize(size, size)
	bu:SetPoint("TOPRIGHT", -10, -2)
	B.CreateSD(bu, 2, 2)

	bu.icon = bu:CreateTexture(nil, "ARTWORK")
	bu.icon:SetAllPoints()
	bu.icon:SetTexCoord(unpack(DB.TexCoord))
	bu.count = B.CreateFS(bu, 12, "", false, "BOTTOMRIGHT", 6, -3)
	bu.time = B.CreateFS(bu, 12, "", false, "CENTER", 1, 0)

	bu.ShowDispellableDebuff = true
	if not NDuiDB["UFs"]["NoTooltip"] then bu.EnableTooltip = true end
	if NDuiDB["UFs"]["DebuffBorder"] then bu.ShowDebuffBorder = true end
	if NDuiDB["UFs"]["Dispellable"] then bu.FilterDispellableDebuff = true end
	if NDuiDB["UFs"]["InstanceAuras"] then bu.Debuffs = C.RaidDebuffs end
	self.RaidDebuffs = bu
end