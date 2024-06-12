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
	/getenc, get selected encounters info
]]

local strfind, format, strsplit = string.find, string.format, string.split
local gsub, pairs, tonumber, tostring = gsub, pairs, tonumber, tostring
local floor, ceil = math.floor, math.ceil
local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted
local GetSpellDescription = C_Spell.GetSpellDescription or GetSpellDescription

DB.Devs = {
	["寧德-加尔"] = true,
	["图咿-万色星辰"] = true,
	["打蛋獵手-地獄吼"] = true,
	["Huniverster-Koranos"] = true,
}
local function isDeveloper()
	local rawName = gsub(DB.MyFullName, "%s", "")
	return DB.Devs[rawName]
end
DB.isDeveloper = isDeveloper()

-- Commands
SlashCmdList["RELOADUI"] = ReloadUI
SLASH_RELOADUI1 = "/rl"

SlashCmdList["NDUI_ENUMTIP"] = function()
	local enumf = EnumerateFrames()
	while enumf do
		if (enumf:IsObjectType("GameTooltip") or strfind((enumf:GetName() or ""):lower(), "tip")) and enumf:IsVisible() and enumf:GetPoint() then
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
			print(frame:GetName() or format(UNKNOWN..": [%s]", tostring(frame)))
		end
		frame = EnumerateFrames(frame)
	end
end
SLASH_NDUI_ENUMFRAME1 = "/nf"

SlashCmdList["NDUI_DUMPSPELL"] = function(arg)
	local name = GetSpellInfo(arg)
	if not name then return end
	local des = GetSpellDescription(arg)
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
	local name = UnitName("target")
	local guid = UnitGUID("target")
	if name and guid then
		local npcID = B.GetNPCID(guid)
		print(name, DB.InfoColor..(npcID or "nil"))
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

do
	local versionList = {}
	C_ChatInfo.RegisterAddonMessagePrefix("NDuiFVC")

	local function PrintVerCheck()
		print("----------")
		for name, version in pairs(versionList) do
			print(name.." "..version)
		end
	end

	local function SendVerCheck(channel)
		wipe(versionList)
		C_ChatInfo.SendAddonMessage("NDuiFVC", "VersionCheck", channel)
		C_Timer.After(3, PrintVerCheck)
	end

	local function VerCheckListen(_, ...)
		local prefix, msg, distType, sender = ...

		if prefix == "NDuiFVC" then
			if msg == "VersionCheck" then
				C_ChatInfo.SendAddonMessage("NDuiFVC", "MyVer-"..DB.Version, distType)
			elseif strfind(msg, "MyVer") then
				local _, version = strsplit("-", msg)
				versionList[sender] = version.." - "..distType
			end
		end
	end
	B:RegisterEvent("CHAT_MSG_ADDON", VerCheckListen)

	SlashCmdList["NDUI_VER_CHECK"] = function(msg)
		local channel
		if IsPartyLFG() then
			channel = "INSTANCE_CHAT"
		elseif IsInRaid() then
			channel = "RAID"
		elseif IsInGroup() then
			channel = "PARTY"
		elseif IsInGuild() then
			channel = "GUILD"
		end
		if msg ~= "" then channel = msg end
		if channel then SendVerCheck(channel) end
	end
	SLASH_NDUI_VER_CHECK1 = "/nduiver"
end

SlashCmdList["NDUI_GET_INSTANCES"] = function()
	if not EncounterJournal then return end
	local tierID = EJ_GetCurrentTier()
	print("local _, ns = ...")
	print("local B, C, L, DB = unpack(ns)")
	print("local module = B:GetModule(\"AurasTable\")")
	print("local TIER = "..tierID)
	print("local INSTANCE")
	local i = 0
	while true do
		i = i + 1
		local instID, instName = EJ_GetInstanceByIndex(i, false)
		if not instID then return end
		print("INSTANCE = "..instID.." -- "..instName)
	end
end
SLASH_NDUI_GET_INSTANCES1 = "/getinst"

SlashCmdList["NDUI_GET_ENCOUNTERS"] = function()
	if not EncounterJournal then return end
	local tierID = EJ_GetCurrentTier()
	local instID = EncounterJournal.instanceID
	EJ_SelectInstance(instID)
	local instName = EJ_GetInstanceInfo()
	print("local _, ns = ...")
	print("local B, C, L, DB = unpack(ns)")
	print("local module = B:GetModule(\"AurasTable\")")
	print("local TIER = "..tierID)
	print("local INSTANCE = "..instID.." -- "..instName)
	print("local BOSS")
	local i = 0
	while true do
		i = i + 1
		local name, _, boss = EJ_GetEncounterInfoByIndex(i)
		if not name then return end
		print("BOSS = "..boss.." -- "..name)
	end
end
SLASH_NDUI_GET_ENCOUNTERS1 = "/getenc"

SlashCmdList["NDUI_DUMPSPELLS"] = function(arg)
	for spell in gmatch(arg, "%d+") do
		local name = GetSpellInfo(spell)
		if name then
			print("module:RegisterDebuff(TIER, INSTANCE, BOSS, "..spell..") -- "..name)
		end
	end
end
SLASH_NDUI_DUMPSPELLS1 = "/getss"

SlashCmdList["NDUI_GET_TIERSETS"] = function()
	if not EncounterJournal then return end
	local frame = EncounterJournal.LootJournalItems.ItemSetsFrame
	local classFilter = frame:GetClassAndSpecFilters()
	local classInfo = C_CreatureInfo.GetClassInfo(classFilter)
	local sets = frame.itemSets
	local setID = sets and sets[1].setID
	if not setID then return end
	local data = C_LootJournal.GetItemSetItems(setID)
	local text = ""
	for i = 1, 5 do
		local d = data[i]
		text = "["..d.itemID.."] = true, "..text
	end
	print("--", classInfo.classFile)
	print(text)
end
SLASH_NDUI_GET_TIERSETS1 = "/getts"

-- Grids
local grid
local boxSize = 32
local function Grid_Create()
	grid = CreateFrame("Frame", nil, UIParent)
	grid.boxSize = boxSize
	grid:SetAllPoints(UIParent)

	local size = 2
	local width = GetScreenWidth()
	local ratio = width / GetScreenHeight()
	local height = GetScreenHeight() * ratio

	local wStep = width / boxSize
	local hStep = height / boxSize

	for i = 0, boxSize do
		local tx = grid:CreateTexture(nil, "BACKGROUND")
		if i == boxSize / 2 then
			tx:SetColorTexture(1, 0, 0, .5)
		else
			tx:SetColorTexture(0, 0, 0, .5)
		end
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", i*wStep - (size/2), 0)
		tx:SetPoint("BOTTOMRIGHT", grid, "BOTTOMLEFT", i*wStep + (size/2), 0)
	end
	height = GetScreenHeight()

	do
		local tx = grid:CreateTexture(nil, "BACKGROUND")
		tx:SetColorTexture(1, 0, 0, .5)
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2) + (size/2))
		tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height/2 + size/2))
	end

	for i = 1, floor((height/2)/hStep) do
		local tx = grid:CreateTexture(nil, "BACKGROUND")
		tx:SetColorTexture(0, 0, 0, .5)

		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2+i*hStep) + (size/2))
		tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height/2+i*hStep + size/2))

		tx = grid:CreateTexture(nil, "BACKGROUND")
		tx:SetColorTexture(0, 0, 0, .5)

		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2-i*hStep) + (size/2))
		tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height/2-i*hStep + size/2))
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
		boxSize = (ceil((tonumber(arg) or boxSize) / 32) * 32)
		if boxSize > 256 then boxSize = 256 end
		Grid_Show()
		isAligning = true
	end
end
SLASH_TOGGLEGRID1 = "/ng"