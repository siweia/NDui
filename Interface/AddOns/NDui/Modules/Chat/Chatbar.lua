local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

function module:Chatbar()
	local chatFrame = SELECTED_DOCK_FRAME
	local editBox = chatFrame.editBox
	local width, height, padding, buttonList = 40, 6, 5, {}

	local Chatbar = CreateFrame("Frame", nil, UIParent)
	Chatbar:SetSize(width, height)
	Chatbar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 5, 9)

	local function AddButton(r, g, b, text, func)
		local bu = CreateFrame("Button", nil, Chatbar, "SecureActionButtonTemplate")
		bu:SetSize(width, height)
		B.CreateIF(bu, true)
		bu.Icon:SetTexture(DB.normTex)
		bu.Icon:SetVertexColor(r, g, b)
		bu:SetHitRectInsets(0, 0, -8, -8)
		bu:RegisterForClicks("AnyUp")
		if text then B.AddTooltip(bu, "ANCHOR_TOP", B.HexRGB(r, g, b)..text) end
		if func then bu:SetScript("OnClick", func) end

		tinsert(buttonList, bu)
		return bu
	end

	-- Create Chatbars
	local buttonInfo = {
		{1, 1, 1, SAY.."/"..YELL, function(_, btn)
			if btn == "RightButton" then
				ChatFrame_OpenChat("/y ", chatFrame)
			else
				ChatFrame_OpenChat("/s ", chatFrame)
			end
		end},
		{1, .5, 1, WHISPER, function(_, btn)
			if btn == "RightButton" then   
				ChatFrame_ReplyTell(chatFrame)
				if not editBox:IsVisible() or editBox:GetAttribute("chatType") ~= "WHISPER" then
					ChatFrame_OpenChat("/w ", chatFrame)
				end
			else   
				if UnitExists("target") and UnitName("target") and UnitIsPlayer("target") and GetDefaultLanguage("player") == GetDefaultLanguage("target") then
					local name = GetUnitName("target", true)
					ChatFrame_OpenChat("/w "..name.." ", chatFrame)
				else
					ChatFrame_OpenChat("/w ", chatFrame)
				end
			end
		end},
		{.65, .65, 1, PARTY, function() ChatFrame_OpenChat("/p ", chatFrame) end},
		{1, .5, 0, INSTANCE.."/"..RAID, function()
			if IsPartyLFG() then
				ChatFrame_OpenChat("/i ", chatFrame)
			else
				ChatFrame_OpenChat("/raid ", chatFrame)
			end
		end},
		{.25, 1, .25, GUILD.."/"..OFFICER, function(_, btn)
			if btn == "RightButton" and CanEditOfficerNote() then
				ChatFrame_OpenChat("/o ", chatFrame)
			else
				ChatFrame_OpenChat("/g ", chatFrame)
			end
		end},
	}
	for _, info in pairs(buttonInfo) do AddButton(unpack(info)) end

	-- ROLL
	local roll = AddButton(.8, 1, .6, LOOT_ROLL)
	roll:SetAttribute("type", "macro")
	roll:SetAttribute("macrotext", "/roll")

	-- COMBATLOG
	local combat = AddButton(1, 1, 0, BINDING_NAME_TOGGLECOMBATLOG)
	combat:SetAttribute("type", "macro")
	combat:SetAttribute("macrotext", "/combatlog")

	-- WORLD CHANNEL
	if DB.Client == "zhCN" then
		local channelName, channelID, channels = L["World Channel Name"]
		local wc = AddButton(0, .8, 1, L["World Channel"])

		local function isInChannel(event)
			C_Timer.After(.1, function()
				channels = {GetChannelList()}
				for i = 1, #channels do
					if channels[i] == channelName then
						wc.inChannel = true
						channelID = channels[i-1]
						break
					end
				end
				if wc.inChannel then
					wc.Icon:SetVertexColor(0, .8, 1)
				else
					wc.Icon:SetVertexColor(1, .1, .1)
				end
			end)

			if event == "PLAYER_ENTERING_WORLD" then
				B:UnregisterEvent(event, isInChannel)
			end
		end
		B:RegisterEvent("PLAYER_ENTERING_WORLD", isInChannel)
		B:RegisterEvent("CHANNEL_UI_UPDATE", isInChannel)

		wc:SetScript("OnClick", function(_, btn)
			if wc.inChannel then
				if btn == "RightButton" then
					LeaveChannelByName(channelName)
					print("|cffFF7F50"..QUIT.."|r "..DB.InfoColor..L["World Channel"])
					wc.inChannel = false
				else
					ChatFrame_OpenChat("/"..channelID, chatFrame)
				end
			else
				JoinPermanentChannel(channelName, nil, 1)
				ChatFrame_AddChannel(ChatFrame1, channelName)
				print("|cff00C957"..JOIN.."|r "..DB.InfoColor..L["World Channel"])
				wc.inChannel = true
			end
		end)
	end

	-- Order Postions
	for i = 1, #buttonList do
		if i == 1 then
			buttonList[i]:SetPoint("LEFT")
		else
			buttonList[i]:SetPoint("LEFT", buttonList[i-1], "RIGHT", padding, 0)
		end
	end
end