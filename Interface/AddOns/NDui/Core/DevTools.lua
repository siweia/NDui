local _, ns = ...
local B, C, L, DB = unpack(ns)

--[[
	NDui DevTools:
	/rl, reload ui
	/nt, get gametooltip names
	/nf, get frame names
	/ns, get spell name and description
	/ng, show grid on WorldFrame
	/getid, get instance id
	/getnpc, get npc name and id
]]

local dev = {"寧德", "Hunnie"}
local function isDeveloper()
	for _, name in pairs(dev) do
		if UnitName("player") == name then
			return true
		end
	end
end
DB.isDeveloper = isDeveloper()

-- Commands
SlashCmdList["RELOADUI"] = ReloadUI
SLASH_RELOADUI1 = "/rl"

SlashCmdList["NDUI_ENUMTIP"] = function()
	local enumf = EnumerateFrames()
	while enumf do
		if (enumf:GetObjectType() == "GameTooltip" or strfind((enumf:GetName() or ""):lower(), "tip")) and enumf:IsVisible() and enumf:GetPoint() then
			print(enumf:GetName())
		end 
		enumf = EnumerateFrames(enumf)
	end
end
SLASH_NDUI_ENUMTIP1 = "/nt"

SlashCmdList["NDUI_ENUMFRAME"] = function()
	local frame = EnumerateFrames()
	while frame do
		if (frame:IsVisible() and MouseIsOver(frame)) then
			print(frame:GetName() or string.format(UNKNOWN..": [%s]", tostring(frame)))
		end
		frame = EnumerateFrames(frame)
	end
end
SLASH_NDUI_ENUMFRAME1 = "/nf"

SlashCmdList["NDUI_DUMPSPELL"] = function(arg)
	local name = GetSpellInfo(arg)
	local des = GetSpellDescription(arg)
	if not name then return end
	print("|cff70C0F5------------------------")
	print(" \124T"..GetSpellTexture(arg)..":16:16:::64:64:5:59:5:59\124t", DB.InfoColor..arg)
	print(NAME, DB.InfoColor..(name or "nil"))
	print(DESCRIPTION, DB.InfoColor..(des or "nil"))
	print("|cff70C0F5------------------------")
end
SLASH_NDUI_DUMPSPELL1 = "/ns"

SlashCmdList["INSTANCEID"] = function()
	local name, _, _, _, _, _, _, id = GetInstanceInfo()
	print(name, id)
end
SLASH_INSTANCEID1 = "/getid"

SlashCmdList["NDUI_NPCID"] = function()
	local npcName = UnitName("target")
	local npcGuid = UnitGUID("target")
	if npcName and npcGuid then
		local npcID = select(6, strsplit("-", npcGuid))
		print(npcName, DB.InfoColor..(npcID or "nil"))
	end
end
SLASH_NDUI_NPCID1 = "/getnpc"

SlashCmdList["NDUI_GETFONT"] = function(msg)
	local font = _G[msg]
	if not font then print(msg, "not found.") return end
	local a, b, c = font:GetFont()
	print(msg,a,b,c)
end
SLASH_NDUI_GETFONT1 = "/nff"

SlashCmdList["NDUI_CHECK_QUEST"] = function(msg)
	if not msg then return end
	print("QuestID "..msg.." complete:", IsQuestFlaggedCompleted(tonumber(msg)))
end
SLASH_NDUI_CHECK_QUEST1 = "/ncq"

SlashCmdList["NDUI_DEV"] = function()
	UIParentLoadAddOn("Blizzard_Console")
	DeveloperConsole:Toggle()
end
SLASH_NDUI_DEV1 = "/ndev"

do
	local versionList = {}
	C_ChatInfo.RegisterAddonMessagePrefix("NDuiFVC")

	local function SendVerCheck(channel)
		wipe(versionList)
		C_ChatInfo.SendAddonMessage("NDuiFVC", "VersionCheck", channel)

		C_Timer.After(3, function()
			print("----------")
			for name, version in pairs(versionList) do
				print(name.." "..version)
			end
		end)
	end

	local function VerCheckListen(_, ...)
		local prefix, msg, distType, sender = ...

		if prefix == "NDuiFVC" then
			if msg == "VersionCheck" then
				C_ChatInfo.SendAddonMessage("NDuiFVC", "MyVer-"..DB.Version, distType)
			elseif msg:find("MyVer") then
				local _, version = string.split("-", msg)
				versionList[sender] = version.." - "..distType
			end
		end
	end
	B:RegisterEvent("CHAT_MSG_ADDON", VerCheckListen)

	SlashCmdList["NDUI_VER_CHECK"] = function()
		if not DB.isDeveloper then return end
		local channel
		if IsInRaid() then
			channel = "RAID"
		elseif IsInGuild() then
			channel = "GUILD"
		end
		if channel then SendVerCheck(channel) end
	end
	SLASH_NDUI_VER_CHECK1 = "/nduiver"
end

-- Grids
local grid
local boxSize = 32
local function Grid_Create() 
	grid = CreateFrame('Frame', nil, UIParent) 
	grid.boxSize = boxSize 
	grid:SetAllPoints(UIParent) 

	local size = 2 
	local width = GetScreenWidth()
	local ratio = width / GetScreenHeight()
	local height = GetScreenHeight() * ratio

	local wStep = width / boxSize
	local hStep = height / boxSize

	for i = 0, boxSize do 
		local tx = grid:CreateTexture(nil, 'BACKGROUND') 
		if i == boxSize / 2 then 
			tx:SetColorTexture(1, 0, 0, .5) 
		else 
			tx:SetColorTexture(0, 0, 0, .5) 
		end 
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", i*wStep - (size/2), 0) 
		tx:SetPoint('BOTTOMRIGHT', grid, 'BOTTOMLEFT', i*wStep + (size/2), 0) 
	end 
	height = GetScreenHeight()

	do
		local tx = grid:CreateTexture(nil, 'BACKGROUND') 
		tx:SetColorTexture(1, 0, 0, .5)
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2) + (size/2))
		tx:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2 + size/2))
	end

	for i = 1, math.floor((height/2)/hStep) do
		local tx = grid:CreateTexture(nil, 'BACKGROUND') 
		tx:SetColorTexture(0, 0, 0, .5)

		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2+i*hStep) + (size/2))
		tx:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2+i*hStep + size/2))

		tx = grid:CreateTexture(nil, 'BACKGROUND') 
		tx:SetColorTexture(0, 0, 0, .5)

		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2-i*hStep) + (size/2))
		tx:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -(height/2-i*hStep + size/2))
	end
end

local function Grid_Show()
	if not grid then
		Grid_Create()
	elseif grid.boxSize ~= boxSize then
		grid:Hide()
		Grid_Create()
	else
		grid:Show()
	end
end

local isAligning = false
SlashCmdList["TOGGLEGRID"] = function(arg)
	if isAligning or arg == "1" then
		if grid then grid:Hide() end
		isAligning = false
	else
		boxSize = (math.ceil((tonumber(arg) or boxSize) / 32) * 32)
		if boxSize > 256 then boxSize = 256 end    
		Grid_Show()
		isAligning = true
	end
end
SLASH_TOGGLEGRID1 = "/ng"