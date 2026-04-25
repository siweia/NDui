local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Cooldown")

local numberFormatter = C_StringUtil.CreateNumericRuleFormatter()
numberFormatter:SetBreakpoints({
	{ threshold = 0, format = CreateColor(1, 0, 0, 1):WrapTextInColorCode("%.1f"), components = {{step = .1, rounding = Enum.NumericRuleFormatRounding.Up}} },
	{ threshold = 3, format = CreateColor(1, 1, 0, 1):WrapTextInColorCode("%d"), components = {{div = 1, step = 1, rounding = Enum.NumericRuleFormatRounding.Up}} },
	{ threshold = 10, format = CreateColor(.8, .8, .2, 1):WrapTextInColorCode("%d"), components = {{div = 1, step = 1, rounding = Enum.NumericRuleFormatRounding.Up}} },
	{ threshold = 60, format = "%d:%02d", components = {{div = 60}, {mod = 60}} },
	{ threshold = 60*10, format = "%d"..DB.MyColor.."m", components = {{div = 60, step = 1, rounding = Enum.NumericRuleFormatRounding.Nearest}} }, -- 10 minutes
	{ threshold = 3600*2, format = "%d"..DB.MyColor.."h", components = {{div = 3600, step = 1, rounding = Enum.NumericRuleFormatRounding.Nearest}} }, -- 2 hour
	{ threshold = 86400, format = "%d"..DB.MyColor.."d", components = {{div = 86400, step = 1, rounding = Enum.NumericRuleFormatRounding.Nearest}} }, -- 1 day
})

local numberFormatter2 = C_StringUtil.CreateNumericRuleFormatter()
numberFormatter2:SetBreakpoints({
	{ threshold = 0, format = "%.1f", components = {{step = .1, rounding = Enum.NumericRuleFormatRounding.Up}} },
	{ threshold = 3, format = "%d", components = {{div = 1, step = 1, rounding = Enum.NumericRuleFormatRounding.Up}} },
	{ threshold = 60, format = "%d:%02d", components = {{div = 60}, {mod = 60}} },
	{ threshold = 60*10, format = "%dm", components = {{div = 60, step = 1, rounding = Enum.NumericRuleFormatRounding.Nearest}} }, -- 10 minutes
	{ threshold = 3600*2, format = "%dh", components = {{div = 3600, step = 1, rounding = Enum.NumericRuleFormatRounding.Nearest}} }, -- 2 hour
	{ threshold = 86400, format = "%dd", components = {{div = 86400, step = 1, rounding = Enum.NumericRuleFormatRounding.Nearest}} }, -- 1 day
})

function module:UpdateCooldown()
	local mode = C.db["Actionbar"]["CDFormat"]
	if mode == 1 then -- color
		self:SetCountdownFormatter(numberFormatter)
	elseif mode == 2 then -- white
		self:SetCountdownFormatter(numberFormatter2)
	else -- blizz
		self:SetCountdownFormatter(nil)
	end
end

function module:OnLogin()
	local cooldown_mt = getmetatable(ActionButton1Cooldown).__index
	hooksecurefunc(cooldown_mt, "SetCooldown", module.UpdateCooldown)
	hooksecurefunc(cooldown_mt, "SetCooldownDuration", module.UpdateCooldown)
	hooksecurefunc(cooldown_mt, "Clear", module.UpdateCooldown)
	hooksecurefunc(cooldown_mt, "SetHideCountdownNumbers", module.UpdateCooldown)
	hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", module.UpdateCooldown)
	hooksecurefunc(cooldown_mt, "SetCooldownFromDurationObject", module.UpdateCooldown)

	SetCVar("countdownForCooldowns", C.db["Actionbar"]["CDFormat"] ~= 4 and 1 or 0)
end