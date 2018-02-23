-- Initial
local _, ns = ...
ns[1] = {}			-- B, Basement
ns[2] = {}			-- C, Config
ns[3] = {}			-- L, LocaleDB
ns[4] = {}			-- DB, DataBase
ns.modules = {}		-- Addon Modules
ns.initQueue = {}	-- Initialize Queue
NDuiADB = NDuiADB or {}
NDuiDB = NDuiDB or {}

function ns:RegisterModule(name, ...)
	if self.modules[name] then print("Module <"..name.."> has been registered.") return end
	local module = {}
	module.name = name
	module.func = ...

	self.modules[name] = module
	tinsert(ns.initQueue, module)
	return module
end

function ns:GetModule(name)
	if not self.modules[name] then print("Module <"..name.."> not found.") return end
	return self.modules[name]
end

function ns:EventFrame(events)
	local f = CreateFrame("Frame")
	for _, event in pairs(events) do
		f:RegisterEvent(event)
	end
	return f
end

ns:EventFrame{"PLAYER_LOGIN"}:SetScript("OnEvent", function()
	for _, module in pairs(ns.initQueue) do
		module:OnLogin()
	end
end)

NDui = ns