local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Cooldown")

local DISABLE_INDEX = 5
local numberFormatter = C_StringUtil.CreateNumericRuleFormatter()
local hookedCooldownFrames = {}

local ROUNDING_UP = Enum.NumericRuleFormatRounding.Up
local ROUNDING_NEAREST = Enum.NumericRuleFormatRounding.Nearest
local COLOR_RED = CreateColor(1, 0, 0, 1)
local COLOR_YELLOW = CreateColor(1, 1, 0, 1)
local COLOR_DARK = CreateColor(.8, .8, .2, 1)

local breakPoints = {
	[1] = {
		{ threshold = 0, format = COLOR_RED:WrapTextInColorCode("%.1f"), components = {{step = .1, rounding = ROUNDING_UP}} },
		{ threshold = 3, format = COLOR_YELLOW:WrapTextInColorCode("%d"), components = {{div = 1, step = 1, rounding = ROUNDING_UP}} },
		{ threshold = 10, format = COLOR_DARK:WrapTextInColorCode("%d"), components = {{div = 1, step = 1, rounding = ROUNDING_UP}} },
		{ threshold = 60, format = "%d:%02d", components = {{div = 60}, {mod = 60}} },
		{ threshold = 60*10, format = "%d"..DB.MyColor.."m", components = {{div = 60, step = 1, rounding = ROUNDING_NEAREST}} }, -- 10 minutes
		{ threshold = 3600*2, format = "%d"..DB.MyColor.."h", components = {{div = 3600, step = 1, rounding = ROUNDING_NEAREST}} }, -- 2 hour
		{ threshold = 86400, format = "%d"..DB.MyColor.."d", components = {{div = 86400, step = 1, rounding = ROUNDING_NEAREST}} }, -- 1 day
	},
	[2] = {
		{ threshold = 0, format = COLOR_RED:WrapTextInColorCode("%d"), components = {{div = 1, step = 1, rounding = ROUNDING_UP}} },
		{ threshold = 3, format = COLOR_YELLOW:WrapTextInColorCode("%d"), components = {{div = 1, step = 1, rounding = ROUNDING_UP}} },
		{ threshold = 10, format = COLOR_DARK:WrapTextInColorCode("%d"), components = {{div = 1, step = 1, rounding = ROUNDING_UP}} },
		{ threshold = 60, format = "%d:%02d", components = {{div = 60}, {mod = 60}} },
		{ threshold = 60*10, format = "%d"..DB.MyColor.."m", components = {{div = 60, step = 1, rounding = ROUNDING_NEAREST}} }, -- 10 minutes
		{ threshold = 3600*2, format = "%d"..DB.MyColor.."h", components = {{div = 3600, step = 1, rounding = ROUNDING_NEAREST}} }, -- 2 hour
		{ threshold = 86400, format = "%d"..DB.MyColor.."d", components = {{div = 86400, step = 1, rounding = ROUNDING_NEAREST}} }, -- 1 day
	},
	[3] = {
		{ threshold = 0, format = "%.1f", components = {{step = .1, rounding = ROUNDING_UP}} },
		{ threshold = 3, format = "%d", components = {{div = 1, step = 1, rounding = ROUNDING_UP}} },
		{ threshold = 60, format = "%d:%02d", components = {{div = 60}, {mod = 60}} },
		{ threshold = 60*10, format = "%dm", components = {{div = 60, step = 1, rounding = ROUNDING_NEAREST}} }, -- 10 minutes
		{ threshold = 3600*2, format = "%dh", components = {{div = 3600, step = 1, rounding = ROUNDING_NEAREST}} }, -- 2 hour
		{ threshold = 86400, format = "%dd", components = {{div = 86400, step = 1, rounding = ROUNDING_NEAREST}} }, -- 1 day
	},
	[4] = {
		{ threshold = 0, format = "%d", components = {{div = 1, step = 1, rounding = ROUNDING_UP}} },
		{ threshold = 60, format = "%d:%02d", components = {{div = 60}, {mod = 60}} },
		{ threshold = 60*10, format = "%dm", components = {{div = 60, step = 1, rounding = ROUNDING_NEAREST}} }, -- 10 minutes
		{ threshold = 3600*2, format = "%dh", components = {{div = 3600, step = 1, rounding = ROUNDING_NEAREST}} }, -- 2 hour
		{ threshold = 86400, format = "%dd", components = {{div = 86400, step = 1, rounding = ROUNDING_NEAREST}} }, -- 1 day
	},
}

function module:UpdateBreakPoints()
	local mode = C.db["Actionbar"]["CDFormat"]
	if mode ~= DISABLE_INDEX then
		numberFormatter:SetBreakpoints(breakPoints[mode])
	end
end

local function updateCooldown(cooldown)
	if not cooldown or hookedCooldownFrames[cooldown] then return end

	local isEnable = C.db["Actionbar"]["CDFormat"] ~= DISABLE_INDEX
	cooldown:SetCountdownFormatter(isEnable and numberFormatter or nil)
	hookedCooldownFrames[cooldown] = true
end

function module:UpdateCooldownFormat()
	local mode = C.db["Actionbar"]["CDFormat"]
	if mode == DISABLE_INDEX then
		SetCVar("countdownForCooldowns", 0)
		return
	end

	SetCVar("countdownForCooldowns", 1)
	numberFormatter:SetBreakpoints(breakPoints[mode])

	for cooldown in pairs(hookedCooldownFrames) do
		cooldown:SetCountdownFormatter(numberFormatter)
	end
end


function module:OnLogin()
	module:UpdateBreakPoints()

	local cooldown_mt = getmetatable(ActionButton1Cooldown).__index
	local methods = {"SetCooldown", "SetCooldownDuration", "SetHideCountdownNumbers", "SetCooldownFromDurationObject"}
	for _, method in pairs(methods) do
		hooksecurefunc(cooldown_mt, method, updateCooldown)
	end
	hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", updateCooldown)

	SetCVar("countdownForCooldowns", C.db["Actionbar"]["CDFormat"] ~= DISABLE_INDEX and 1 or 0)
end