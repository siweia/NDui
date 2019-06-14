local addonName, ns = ...
ns[1] = {}			-- B, Basement
ns[2] = {}			-- C, Config
ns[3] = {}			-- L, Locales
ns[4] = {}			-- DB, Database
if IsAddOnLoaded("AuroraClassic") then
	ns[5], ns[6] = unpack(AuroraClassic)
end
NDuiDB, NDuiADB = {}, {}

local B, C, L, DB = unpack(ns)
local pairs, next, tinsert = pairs, next, table.insert

-- Events
local events = {}

local host = CreateFrame("Frame")
host:SetScript("OnEvent", function(_, event, ...)
	for func in pairs(events[event]) do
		if event == "COMBAT_LOG_EVENT_UNFILTERED" then
			func(event, CombatLogGetCurrentEventInfo())
		else
			func(event, ...)
		end
	end
end)

function B:RegisterEvent(event, func, unit1, unit2)
	if not events[event] then
		events[event] = {}
		if unit1 then
			host:RegisterUnitEvent(event, unit1, unit2)
		else
			host:RegisterEvent(event)
		end
	end

	events[event][func] = true
end

function B:UnregisterEvent(event, func)
	local funcs = events[event]
	if funcs and funcs[func] then
		funcs[func] = nil

		if not next(funcs) then
			events[event] = nil
			host:UnregisterEvent(event)
		end
	end
end

-- Modules
local modules, initQueue = {}, {}

function B:RegisterModule(name)
	if modules[name] then print("Module <"..name.."> has been registered.") return end
	local module = {}
	module.name = name
	modules[name] = module

	tinsert(initQueue, module)
	return module
end

function B:GetModule(name)
	if not modules[name] then print("Module <"..name.."> does not exist.") return end

	return modules[name]
end

-- Init
B:RegisterEvent("PLAYER_LOGIN", function()
	for _, module in next, initQueue do
		if module.OnLogin then
			module:OnLogin()
		else
			print("Module <"..module.name.."> does not loaded.")
		end
	end

	B.Modules = modules
end)

_G[addonName] = ns