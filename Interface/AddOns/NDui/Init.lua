-- Initial
local addonName, ns = ...
ns[1] = {}			-- B, Basement
ns[2] = {}			-- C, Config
ns[3] = {}			-- L, LocaleDB
ns[4] = {}			-- DB, DataBase
NDuiADB = NDuiADB or {}
NDuiDB = NDuiDB or {}

-- Modules
local modules, initQueue = {}, {}

function ns:RegisterModule(name)
	if modules[name] then print("Module <"..name.."> has been registered.") return end
	modules[name] = {}

	tinsert(initQueue, modules[name])
	return modules[name]
end

function ns:GetModule(name)
	if not modules[name] then print("Module <"..name.."> does not exist.") return end

	return modules[name]
end

function ns:EventFrame(events)
	local f = CreateFrame("Frame")
	for _, event in pairs(events) do
		f:RegisterEvent(event)
	end

	return f
end

ns:EventFrame{"PLAYER_LOGIN"}:SetScript("OnEvent", function()
	for _, module in pairs(initQueue) do
		if module.OnLogin then
			module:OnLogin()
		else
			print("Module <"..name.."> does not loaded.")
		end
	end
end)

_G[addonName] = ns