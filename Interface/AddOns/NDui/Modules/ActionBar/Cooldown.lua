local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Cooldown")

local pairs, format, floor, strfind = pairs, format, floor, strfind
local GetTime, GetActionCooldown, tonumber = GetTime, GetActionCooldown, tonumber

local FONT_SIZE = 19
local MIN_DURATION = 2.5                    -- the minimum duration to show cooldown text for
local MIN_SCALE = 0.5                       -- the minimum scale we want to show cooldown counts at, anything below this will be hidden
local ICON_SIZE = 36
local hideNumbers, active, hooked = {}, {}, {}

local day, hour, minute = 86400, 3600, 60
function module.FormattedTimer(s)
	if s >= day then
		return format("%d"..DB.MyColor.."d", s/day + .5), s%day
	elseif s > hour then
		return format("%d"..DB.MyColor.."h", s/hour + .5), s%hour
	elseif s >= minute then
		if s < C.db["Actionbar"]["MmssTH"] then
			return format("%d:%.2d", s/minute, s%minute), s - floor(s)
		else
			return format("%d"..DB.MyColor.."m", s/minute + .5), s%minute
		end
	else
		local colorStr = (s < 3 and "|cffff0000") or (s < 10 and "|cffffff00") or "|cffcccc33"
		if s < C.db["Actionbar"]["TenthTH"] then
			return format(colorStr.."%.1f|r", s), s - format("%.1f", s)
		else
			return format(colorStr.."%d|r", s + .5), s - floor(s)
		end
	end
end

function module:StopTimer()
	self.enabled = nil
	self:Hide()
end

function module:ForceUpdate()
	self.nextUpdate = 0
	self:Show()
end

function module:OnSizeChanged(width, height)
	local fontScale = B:Round((width+height)/2) / ICON_SIZE
	if fontScale == self.fontScale then return end
	self.fontScale = fontScale

	if fontScale < MIN_SCALE then
		self:Hide()
	else
		self.text:SetFont(DB.Font[1], fontScale * FONT_SIZE, DB.Font[3])
		self.text:SetShadowColor(0, 0, 0, 0)

		if self.enabled then
			module.ForceUpdate(self)
		end
	end
end

function module:TimerOnUpdate(elapsed)
	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
	else
		local remain = self.duration - (GetTime() - self.start)
		if remain > 0 then
			local getTime, nextUpdate = module.FormattedTimer(remain)
			self.text:SetText(getTime)
			self.nextUpdate = nextUpdate
		else
			module.StopTimer(self)
		end
	end
end

function module:ScalerOnSizeChanged(...)
	module.OnSizeChanged(self.timer, ...)
end

function module:OnCreate()
	local scaler = CreateFrame("Frame", nil, self)
	scaler:SetAllPoints(self)

	local timer = CreateFrame("Frame", nil, scaler)
	timer:Hide()
	timer:SetAllPoints(scaler)
	timer:SetScript("OnUpdate", module.TimerOnUpdate)
	scaler.timer = timer

	local text = timer:CreateFontString(nil, "BACKGROUND")
	text:SetPoint("CENTER", 1, 0)
	text:SetJustifyH("CENTER")
	timer.text = text

	module.OnSizeChanged(timer, scaler:GetSize())
	scaler:SetScript("OnSizeChanged", module.ScalerOnSizeChanged)

	self.timer = timer
	return timer
end

function module:StartTimer(start, duration)
	if self:IsForbidden() then return end
	if self.noCooldownCount or hideNumbers[self] then return end

	local frameName = self.GetName and self:GetName()
	if C.db["Actionbar"]["OverrideWA"] and frameName and strfind(frameName, "WeakAuras") then
		self.noCooldownCount = true
		return
	end

	local parent = self:GetParent()
    start = tonumber(start) or 0
    duration = tonumber(duration) or 0

	if start > 0 and duration > MIN_DURATION then
		local timer = self.timer or module.OnCreate(self)
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = 0

		-- wait for blizz to fix itself
		local charge = parent and parent.chargeCooldown
		local chargeTimer = charge and charge.timer
		if chargeTimer and chargeTimer ~= timer then
			module.StopTimer(chargeTimer)
		end

		if timer.fontScale >= MIN_SCALE then
			timer:Show()
		end
	elseif self.timer then
		module.StopTimer(self.timer)
	end

	-- hide cooldown flash if barFader enabled
	if parent and parent.__faderParent then
		if self:GetEffectiveAlpha() > 0 then
			self:Show()
		else
			self:Hide()
		end
	end
end

function module:HideCooldownNumbers()
	hideNumbers[self] = true
	if self.timer then module.StopTimer(self.timer) end
end

function module:CooldownOnShow()
	active[self] = true
end

function module:CooldownOnHide()
	active[self] = nil
end

local function shouldUpdateTimer(self, start)
	local timer = self.timer
	if not timer then
		return true
	end
	return timer.start ~= start
end

function module:CooldownUpdate()
	local button = self:GetParent()
	local start, duration = GetActionCooldown(button.action)

	if shouldUpdateTimer(self, start) then
		module.StartTimer(self, start, duration)
	end
end

function module:ActionbarUpateCooldown()
	for cooldown in pairs(active) do
		module.CooldownUpdate(cooldown)
	end
end

function module:RegisterActionButton()
	local cooldown = self.cooldown
	if not hooked[cooldown] then
		cooldown:HookScript("OnShow", module.CooldownOnShow)
		cooldown:HookScript("OnHide", module.CooldownOnHide)

		hooked[cooldown] = true
	end
end

function module:OnLogin()
	if not C.db["Actionbar"]["Cooldown"] then return end

	local cooldownIndex = getmetatable(ActionButton1Cooldown).__index
	hooksecurefunc(cooldownIndex, "SetCooldown", module.StartTimer)

	hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", module.HideCooldownNumbers)

	B:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", module.ActionbarUpateCooldown)

	if _G["ActionBarButtonEventsFrame"].frames then
		for _, frame in pairs(_G["ActionBarButtonEventsFrame"].frames) do
			module.RegisterActionButton(frame)
		end
	end
	hooksecurefunc(ActionBarButtonEventsFrameMixin, "RegisterFrame", module.RegisterActionButton)

	-- Hide Default Cooldown
	SetCVar("countdownForCooldowns", 0)
	B.HideOption(InterfaceOptionsActionBarsPanelCountdownCooldowns)
end