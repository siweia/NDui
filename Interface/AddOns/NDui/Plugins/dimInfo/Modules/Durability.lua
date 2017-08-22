local addon, ns = ...
local cfg = ns.cfg
local init = ns.init

if cfg.Durability == true then
	local Stat = CreateFrame("Frame", nil, UIParent)
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)
	Stat:SetHitRectInsets(0, 0, -10, 0)
	local Text = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(unpack(cfg.Fonts))
	Text:SetPoint(unpack(cfg.DurabilityPoint))
	Stat:SetAllPoints(Text)

	local localSlots = {
		[1] = {1, INVTYPE_HEAD, 1000},
		[2] = {3, INVTYPE_SHOULDER, 1000},
		[3] = {5, INVTYPE_CHEST, 1000},
		[4] = {6, INVTYPE_WAIST, 1000},
		[5] = {9, INVTYPE_WRIST, 1000},
		[6] = {10, infoL["Hands"], 1000},
		[7] = {7, INVTYPE_LEGS, 1000},
		[8] = {8, infoL["Feet"], 1000},
		[9] = {16, INVTYPE_WEAPONMAINHAND, 1000},
		[10] = {17, INVTYPE_WEAPONOFFHAND, 1000}
	}

	local inform = CreateFrame("Frame", nil, nil, "MicroButtonAlertTemplate")
	inform:SetPoint("BOTTOM", Text, "TOP", 0, 23)
	inform.Text:SetText(infoL["Low Durability"])
	inform:Hide()

	local Total = 0
	local function OnEvent(self)
		if not diminfo.RepairType then diminfo.RepairType = 1 end
		for i = 1, 10 do
			if GetInventoryItemLink("player", localSlots[i][1]) ~= nil then
				local current, max = GetInventoryItemDurability(localSlots[i][1])
				if current then 
					localSlots[i][3] = current/max
					Total = Total + 1
				end
			else
				localSlots[i][3] = 1000
			end
		end
		table.sort(localSlots, function(a, b) return a[3] < b[3] end)

		for i = 1, 10 do
			if localSlots[i][3] < .25 then
				inform:Show()
				break
			end
		end

		if Total > 0 then
			Text:SetText(format(gsub("[color]%d|r%%"..infoL["D"], "%[color%]", (init.gradient(floor(localSlots[1][3]*100)/100))), floor(localSlots[1][3]*100)))
		else
			Text:SetText(infoL["D"]..": "..init.Colored..NONE)
		end
		Total = 0
	end

	Stat:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	Stat:RegisterEvent("MERCHANT_SHOW")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnEvent", OnEvent)
	Stat:SetScript("OnMouseUp", function(self, button)
		if button == "RightButton" then
			diminfo.RepairType = diminfo.RepairType + 1
			if diminfo.RepairType == 3 then diminfo.RepairType = 0 end
			self:GetScript("OnEnter")(self)
		else
			ToggleCharacter("PaperDollFrame")
		end
	end)

	local repairlist = {
		[0] = "|cffff5555"..VIDEO_OPTIONS_DISABLED,
		[1] = "|cff55ff55"..VIDEO_OPTIONS_ENABLED,
		[2] = "|cffffff55"..infoL["NFG"]
	}
	Stat:SetScript("OnEnter", function(self)
		local total, equipped = GetAverageItemLevel()
		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 15)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(DURABILITY, format("%s: %d/%d", STAT_AVERAGE_ITEM_LEVEL, equipped, total), 0,.6,1, 0,.6,1)
		GameTooltip:AddLine(" ")

		for i = 1, 10 do
			if localSlots[i][3] ~= 1000 then
				local green = localSlots[i][3]*2
				local red = 1 - green
				local slotIcon = "|T"..GetInventoryItemTexture("player", localSlots[i][1])..":13:15:0:0:50:50:4:46:4:46|t " or ""
				GameTooltip:AddDoubleLine(slotIcon..localSlots[i][2]..":", floor(localSlots[i][3]*100).."%", 1,1,1, red+1,green,0)
			end
		end

		GameTooltip:AddDoubleLine(" ", "--------------", 1,1,1, .5,.5,.5)
		GameTooltip:AddDoubleLine(" ", init.LeftButton..infoL["PlayerPanel"], 1,1,1, .6,.8,1)
		GameTooltip:AddDoubleLine(" ", init.RightButton..infoL["AutoRepair"]..": "..repairlist[diminfo.RepairType], 1,1,1, .6,.8,1)
		GameTooltip:Show()
	end)
	Stat:SetScript("OnLeave", GameTooltip_Hide)

	-- Auto repair
	local g = CreateFrame("Frame")
	g:RegisterEvent("MERCHANT_SHOW")
	g:SetScript("OnEvent", function()
		if (diminfo.RepairType ~= 0 and CanMerchantRepair()) then
			local cost = GetRepairAllCost()
			if cost > 0 then
				local money = GetMoney()
				if IsInGuild() and diminfo.RepairType == 1 then
					local guildMoney = GetGuildBankWithdrawMoney()
					if guildMoney > GetGuildBankMoney() then
						guildMoney = GetGuildBankMoney()
					end
					if guildMoney >= cost and CanGuildBankRepair() then
					   RepairAllItems(1)
					   print(format("|cff99CCFF"..infoL["Repair cost covered by G-Bank"]..":|r %s", GetMoneyString(cost)))
					   return
					elseif guildMoney == 0 and IsGuildLeader() then
					   RepairAllItems(1)
					   print(format("|cff99CCFF"..infoL["Repair cost covered by G-Bank"]..":|r %s", GetMoneyString(cost)))
					   return
					end
				end
				if money > cost then
					RepairAllItems()
					print(format("|cff99CCFF"..infoL["Repair cost"]..":|r %s", GetMoneyString(cost)))
				else
					print("|cff99CCFF"..infoL["Go farm newbie"].."|r")
				end
			end
		end
	end)
end