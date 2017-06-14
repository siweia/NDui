local B, C, L, DB = unpack(select(2, ...))
local UF = NDui:GetModule("UnitFrames")

-- RaidFrame Elements
function UF:CreateRaidIcons(self)
	local parent = CreateFrame("Frame", nil, self)
	parent:SetAllPoints()
	parent:SetFrameLevel(self:GetFrameLevel() + 2)

	local check = parent:CreateTexture(nil, "OVERLAY")
	check:SetSize(16, 16)
	check:SetPoint("CENTER")
	self.ReadyCheckIndicator = check

	local resurrect = parent:CreateTexture(nil, "OVERLAY")
	resurrect:SetSize(20, 20)
	resurrect:SetPoint("CENTER", self, 1, 0)
	self.ResurrectIndicator = resurrect

	local role = parent:CreateTexture(nil, "OVERLAY")
	role:SetSize(12, 12)
	role:SetPoint("TOPLEFT", 12, 8)
	self.RaidRoleIndicator = role
end

local function UpdateTargetBorder(self)
	if UnitIsUnit("target", self.unit) then
		self.TargetBorder:Show()
	else
		self.TargetBorder:Hide()
	end
end

function UF:CreateTargetBorder(self)
	self.TargetBorder = B.CreateBG(self, 2)
	self.TargetBorder:SetBackdrop({edgeFile = DB.bdTex, edgeSize = 1.2})
	self.TargetBorder:SetBackdropBorderColor(.7, .7, .7)
	self.TargetBorder:SetPoint("BOTTOMRIGHT", self.Power, 2, -2)
	self.TargetBorder:Hide()
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTargetBorder)
	self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdateTargetBorder)
end

function UF:CreateRaidDebuffs(self)
	local bu = CreateFrame("Frame", nil, self)
	local size = 18*NDuiDB["UFs"]["RaidScale"]
	bu:SetSize(size, size)
	bu:SetPoint("TOPRIGHT", -10, -2)
	bu:SetFrameLevel(self:GetFrameLevel() + 3)
	B.CreateSD(bu, 2, 2)

	bu.icon = bu:CreateTexture(nil, "ARTWORK")
	bu.icon:SetAllPoints()
	bu.icon:SetTexCoord(unpack(DB.TexCoord))
	bu.count = B.CreateFS(bu, 12, "", false, "BOTTOMRIGHT", 6, -3)
	bu.time = B.CreateFS(bu, 12, "", false, "CENTER", 1, 0)

	bu.ShowDispellableDebuff = true
	bu.EnableTooltip = not NDuiDB["UFs"]["NoTooltip"]
	bu.ShowDebuffBorder = NDuiDB["UFs"]["DebuffBorder"]
	bu.FilterDispellableDebuff = NDuiDB["UFs"]["Dispellable"]
	if NDuiDB["UFs"]["InstanceAuras"] then bu.Debuffs = C.RaidDebuffs end
	self.RaidDebuffs = bu
end