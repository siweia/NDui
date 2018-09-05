local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Misc")

function module:AddAlerts()
	self:SoloInfo()
	self:RareAlert()
	self:InterruptAlert()
	self:VersionCheck()
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
	B.CreateSD(f)
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

	local function isAllyPet(sourceFlags)
		if sourceFlags == DB.MyPetFlags or (not NDuiDB["Misc"]["OwnInterrupt"] and (sourceFlags == DB.PartyPetFlags or sourceFlags == DB.RaidPetFlags)) then
			return true
		end
	end

	local infoType = {
		["SPELL_INTERRUPT"] = L["Interrupt"],
		["SPELL_STOLEN"] = L["Steal"],
		["SPELL_DISPEL"] = L["Dispel"],
	}

	local function updateAlert(_, ...)
		if not IsInGroup() then return end
		if NDuiDB["Misc"]["AlertInInstance"] and (not IsInInstance() or IsPartyLFG()) then return end

		local _, eventType, _, sourceGUID, sourceName, sourceFlags, _, _, destName, _, _, spellID, _, _, extraskillID = ...
		if not sourceGUID then return end	-- env exclude
		if NDuiDB["Misc"]["OwnInterrupt"] and sourceName ~= UnitName("player") and not isAllyPet(sourceFlags) then return end

		if UnitInRaid(sourceName) or UnitInParty(sourceName) or isAllyPet(sourceFlags) then
			local infoText = infoType[eventType]
			if infoText then
				SendChatMessage(format(infoText, sourceName..GetSpellLink(spellID), destName..GetSpellLink(extraskillID)), IsPartyLFG() and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY")
			end
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