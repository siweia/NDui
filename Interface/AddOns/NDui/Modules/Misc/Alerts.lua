local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Misc")

function module:AddAlerts()
	self:SoloInfo()
	self:RareAlert()
	self:InterruptAlert()
	self:BeamTool()
	self:ReflectingAlert()
	self:SwappingAlert()
	self:VersionCheck()
	self:SistersAlert()
	self:AntoranBlast()
end

--[[
	SoloInfo是一个告知你当前副本难度的小工具，防止我有时候单刷时进错难度了。
	instList左侧是副本ID，你可以使用"/getid"命令来获取当前副本的ID；右侧的是副本难度，常用的一般是：2为5H，4为25普通，6为25H。
]]

function module:SoloInfo()
	if not NDuiDB["Misc"]["SoloInfo"] then return end

	local instList = {
		[556] = 2,		-- 塞塔克大厅，乌鸦
		[575] = 2,		-- 乌特加德之巅，蓝龙
		[585] = 2,		-- 魔导师平台，白鸡
		[631] = 6,		-- 冰冠堡垒，无敌
	}

	local f = CreateFrame("Frame", nil, UIParent)
	f:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
	f:SetSize(150, 70)
	f:Hide()
	B.CreateBD(f)
	B.CreateTex(f)
	f.Text = B.CreateFS(f, 12, "")
	f.Text:SetWordWrap(true)
	f:SetScript("OnMouseUp", function() f:Hide() end)

	local function updateAlert()
		local name, _, instType, diffname, _, _, _, id = GetInstanceInfo()
		if IsInInstance() and instType ~= 24 then
			if instList[id] and instList[id] ~= instType then
				f:Show()
				f.Text:SetText(DB.InfoColor..name..DB.MyColor.."\n( "..diffname.." )\n\n"..DB.InfoColor..L["Wrong Difficulty"])
			else
				f:Hide()
			end
		else
			f:Hide()
		end
	end

	B:RegisterEvent("ZONE_CHANGED_NEW_AREA", updateAlert)
	B:RegisterEvent("PLAYER_DIFFICULTY_CHANGED", updateAlert)
	B:RegisterEvent("PLAYER_ENTERING_WORLD", updateAlert)
end

--[[
	发现稀有/事件时的通报插件
]]
function module:RareAlert()
	if not NDuiDB["Misc"]["RareAlerter"] then return end

	local isIgnored = {
		[1153] = true,		-- 部落要塞
		[1159] = true,		-- 联盟要塞
		[1803] = true,		-- 涌泉海滩
	}

	local cache = {}
	local function updateAlert(_, id)
		local instID = select(8, GetInstanceInfo())
		if isIgnored[instID] then return end

		if id and not cache[id] then
			local info = C_VignetteInfo.GetVignetteInfo(id)
			if not info then return end
			local filename, width, height, txLeft, txRight, txTop, txBottom = GetAtlasInfo(info.atlasName)
			if not filename then return end

			local atlasWidth = width/(txRight-txLeft)
			local atlasHeight = height/(txBottom-txTop)
			local tex = string.format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t", filename, 0, 0, atlasWidth, atlasHeight, atlasWidth*txLeft, atlasWidth*txRight, atlasHeight*txTop, atlasHeight*txBottom)
			UIErrorsFrame:AddMessage(DB.InfoColor..L["Rare Found"]..tex..(info.name or ""))
			if NDuiDB["Misc"]["AlertinChat"] then
				print("  -> "..DB.InfoColor..L["Rare Found"]..tex..(info.name or ""))
			end
			PlaySoundFile("Sound\\Interface\\PVPFlagTakenMono.ogg", "master")
			cache[id] = true
		end
		if #cache > 666 then wipe(cache) end
	end

	B:RegisterEvent("VIGNETTE_MINIMAP_UPDATED", updateAlert)
end

--[[
	闭上你的嘴！
	打断、偷取及驱散法术时的警报
]]
function module:InterruptAlert()
	if not NDuiDB["Misc"]["Interrupt"] then return end

	local infoType = {
		["SPELL_INTERRUPT"] = L["Interrupt"],
		["SPELL_STOLEN"] = L["Steal"],
		["SPELL_DISPEL"] = L["Dispel"],
	}

	local function updateAlert(_, ...)
		if not IsInGroup() then return end
		local _, eventType, _, _, sourceName, _, _, _, destName, _, _, spellID, _, _, extraskillID = ...
		if UnitInRaid(sourceName) or UnitInParty(sourceName) then
			if NDuiDB["Misc"]["OwnInterrupt"] and sourceName ~= UnitName("player") then return end

			local infoText = infoType[eventType]
			if infoText then
				SendChatMessage(format(infoText, sourceName..GetSpellLink(spellID), destName..GetSpellLink(extraskillID)), IsPartyLFG() and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY")
			end
		end
	end

	B:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", updateAlert)
end

--[[
	向左走向右走
	克洛苏斯给没脑子的助手
]]
function module:BeamTool()
	local f
	local function KrosusGo()
		if f then f:Show() return end
		f = CreateFrame("Frame", "NDui_BeamTool", UIParent)
		f:SetSize(100, 100)
		f:SetPoint("BOTTOMRIGHT", -350, 50)
		B.CreateBD(f)
		B.CreateTex(f)
		B.CreateMF(f)
		B.CreateFS(f, 14, "First Beam:", false, "TOP", 0, -5)
		f.text = B.CreateFS(f, 20, "", false, "TOP", 0, -25)

		local close = CreateFrame("Button", nil, f)
		close:SetPoint("BOTTOM")
		close:SetSize(20, 20)
		B.CreateFS(close, 14, "X")
		B.AddTooltip(close, "ANCHOR_TOP", CLOSE, "system")
		close:SetScript("OnClick", function()
			f:Hide()
			f.text:SetText("")
		end)

		local function CreateBu(anchor, text)
			local bu = B.CreateButton(f, 40, 40, text, 20)
			bu:SetPoint(anchor)
			bu:SetScript("OnClick", function()
				f.text:SetText(text)
				if text == "左" then
					if DBMUpdateKrosusBeam then DBMUpdateKrosusBeam(true) end
					if BigWigsKrosusFirstBeamWasLeft then BigWigsKrosusFirstBeamWasLeft(true) end
					print("First beam on LEFT")
				else
					if DBMUpdateKrosusBeam then DBMUpdateKrosusBeam(false) end
					if BigWigsKrosusFirstBeamWasLeft then BigWigsKrosusFirstBeamWasLeft(false) end
					print("First beam on RIGHT")
				end
			end)
		end
		CreateBu("BOTTOMLEFT", "左")
		CreateBu("BOTTOMRIGHT", "右")
	end

	SlashCmdList["NDUI_BEAMTOOL"] = function() KrosusGo() end
	SLASH_NDUI_BEAMTOOL1 = "/kro"
end

--[[
	骂那些用反光棱镜的臭傻逼
]]
function module:ReflectingAlert()
	if not NDuiDB["Misc"]["ReflectingAlert"] then return end

	local name, itemLink = GetItemInfo(112384)
	local function updateAlert(_, unit, _, spell)
		if not IsInGroup() then return end
		if spell ~= 163219 then return end
		if unit:match("raid") or unit:match("party") and not UnitInRaid(unit) then
			local unitName = GetUnitName(unit)
			SendChatMessage(format(L["Reflecting Prism"], unitName, itemLink or name or ""), IsPartyLFG() and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY")
		end
	end

	B:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", updateAlert)
end

--[[
	工程移形换影装置使用通报
]]
function module:SwappingAlert()
	if not NDuiDB["Misc"]["SwapingAlert"] then return end

	local name, itemLink = GetItemInfo(111820)
	local function updateAlert(_, ...)
		if not IsInGroup() then return end
		local _, eventType, _, _, sourceName, _, _, _, destName, _, _, spellID, spellName = ...
		if eventType ~= "SPELL_CAST_SUCCESS" or spellID ~= 161399 then return end
		if UnitInRaid(sourceName) or UnitInParty(sourceName) then
			SendChatMessage(format(L["Swapblaster"], sourceName, destName, itemLink or name or spellName), IsPartyLFG() and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY")
		end
	end

	B:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", updateAlert)
end

--[[
	NDui版本过期提示
]]
function module:VersionCheck()
	if not NDuiDB["Settings"]["VersionCheck"] then return end
	if not NDuiADB["DetectVersion"] then NDuiADB["DetectVersion"] = DB.Version end
	if not IsInGuild() then return end

	local f = CreateFrame("Frame", nil, nil, "MicroButtonAlertTemplate")
	f:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 20, 70)
	f.Text:SetText("")
	f:Hide()

	local function CompareVersion(new, old)
		local new1, new2 = string.split(".", new)
		new1, new2 = tonumber(new1), tonumber(new2)
		local old1, old2 = string.split(".", old)
		old1, old2 = tonumber(old1), tonumber(old2)
		if new1 > old1 or new2 > old2 then
			return "IsNew"
		elseif new1 < old1 or new2 < old2 then
			return "IsOld"
		end
	end

	local checked
	local function UpdateVersionCheck(_, ...)
		local prefix, msg, distType = ...
		if distType ~= "GUILD" then return end

		if prefix == "NDuiVersionCheck" then
			if CompareVersion(msg, NDuiADB["DetectVersion"]) == "IsNew" then
				NDuiADB["DetectVersion"] = msg
			end

			if not checked then
				local status = CompareVersion(NDuiADB["DetectVersion"], DB.Version)
				if status == "IsNew" then
					f.Text:SetText(format(L["Outdated NDui"], NDuiADB["DetectVersion"]))
					f:Show()
				elseif status == "IsOld" then
					C_ChatInfo.SendAddonMessage("NDuiVersionCheck", DB.Version, "GUILD")
				end
				checked = true
			end
		end
	end

	B:RegisterEvent("CHAT_MSG_ADDON", UpdateVersionCheck)
	C_ChatInfo.RegisterAddonMessagePrefix("NDuiVersionCheck")
	C_ChatInfo.SendAddonMessage("NDuiVersionCheck", DB.Version, "GUILD")
end

--[[
	通报M月之姐妹的星界易伤情况
]]
function module:SistersAlert()
	if not NDuiDB["Misc"]["SistersAlert"] then return end

	local data = {}
	local tarSpell = 236330
	local tarSpellName = GetSpellInfo(tarSpell)
	local myID = UnitGUID("player")

	local function updateAlert(_, ...)
		if not UnitIsGroupAssistant("player") and not UnitIsGroupLeader("player") then return end

		local _, eventType, _, _, sourceName, _, _, destGUID, _, _, _, spellID = ...
		if eventType == "SPELL_DAMAGE" and spellID == 234998 and destGUID == myID then
			local name, _, count = UnitDebuff("player", tarSpellName)
			if not name then return end
			if not data[sourceName] then data[sourceName] = {} end
			if count == 0 then count = 1 end
			tinsert(data[sourceName], count)
		elseif eventType == "SPELL_AURA_REMOVED" and spellID == tarSpell and destGUID == myID then
			SendChatMessage("------------", "RAID")
			for player, value in pairs(data) do
				SendChatMessage(player..": "..table.concat(value, ", "), "RAID")
			end
			wipe(data)
		end
	end

	B:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", updateAlert)
end

--[[
	通报安托兰议会踩雷的CSB
]]
function module:AntoranBlast()
	if not NDuiDB["Misc"]["AntoranBlast"] then return end

	local names, cache = {}, {}
	local function updateAlert(event, ...)
		if not UnitIsGroupAssistant("player") and not UnitIsGroupLeader("player") then return end

		local _, eventType, _, sourceGUID, _, _, _, _, destName, _, _, spellID = ...
		if eventType == "SPELL_DAMAGE" and spellID == 245121 and not GetPlayerInfoByGUID(sourceGUID) and not cache[sourceGUID] then
			if not names[destName] then names[destName] = 0 end
			names[destName] = names[destName] + 1
			SendChatMessage(destName.."  "..L["Spotted"]..names[destName], "RAID")
			cache[sourceGUID] = true
		end
	end

	local function emptyData()
		wipe(names)
		wipe(cache)
	end

	B:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", updateAlert)
	B:RegisterEvent("ENCOUNTER_END", emptyData)
end