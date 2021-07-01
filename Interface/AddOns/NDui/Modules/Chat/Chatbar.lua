local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

function module:Chatbar()
	if not C.db["Chat"]["Chatbar"] then return end

	local chatFrame = SELECTED_DOCK_FRAME
	local editBox = chatFrame.editBox
	local width, height, padding, buttonList = 40, 8, 5, {}
	local tinsert, pairs = table.insert, pairs

	local Chatbar = CreateFrame("Frame", "NDui_ChatBar", UIParent)
	Chatbar:SetSize(width, height)

	local function AddButton(r, g, b, text, func)
		local bu = CreateFrame("Button", nil, Chatbar, "SecureActionButtonTemplate, BackdropTemplate")
		bu:SetSize(width, height)
		B.PixelIcon(bu, DB.normTex, true)
		B.CreateSD(bu)
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
			if btn == "RightButton" and C_GuildInfo.CanEditOfficerNote() then
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
	if GetCVar("portal") == "CN" then
		local channelName, channelID = "大脚世界频道"
		local wc = AddButton(0, .8, 1, L["World Channel"])

		local function updateChannelInfo()
			local id = GetChannelName(channelName)
			if not id or id == 0 then
				wc.inChannel = false
				channelID = nil
				wc.Icon:SetVertexColor(1, .1, .1)
			else
				wc.inChannel = true
				channelID = id
				wc.Icon:SetVertexColor(0, .8, 1)
			end
		end

		local function isInChannel(event)
			C_Timer.After(.2, updateChannelInfo)

			if event == "PLAYER_ENTERING_WORLD" then
				B:UnregisterEvent(event, isInChannel)
			end
		end
		B:RegisterEvent("PLAYER_ENTERING_WORLD", isInChannel)
		B:RegisterEvent("CHANNEL_UI_UPDATE", isInChannel)
		hooksecurefunc("ChatConfigChannelSettings_UpdateCheckboxes", isInChannel) -- toggle in chatconfig

		wc:SetScript("OnClick", function(_, btn)
			if wc.inChannel then
				if btn == "RightButton" then
					LeaveChannelByName(channelName)
					print("|cffFF7F50"..QUIT.."|r "..DB.InfoColor..L["World Channel"])
					wc.inChannel = false
				elseif channelID then
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

	-- Mover
	local width = (#buttonList-1)*(padding+width) + width
	local mover = B.Mover(Chatbar, L["Chatbar"], "Chatbar", {"BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 3}, width, 20)
	Chatbar:ClearAllPoints()
	Chatbar:SetPoint("BOTTOMLEFT", mover, 5, 5)

	module:ChatBarBackground()
end

function module:ChatBarBackground()
	if not C.db["Skins"]["ChatbarLine"] then return end

	local cr, cg, cb = 0, 0, 0
	if C.db["Skins"]["ClassLine"] then cr, cg, cb = DB.r, DB.g, DB.b end

	local parent = _G["NDui_ChatBar"]
	local width, height, alpha = 450, 18, .5
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetPoint("LEFT", parent, "LEFT", -5, 0)
	frame:SetSize(width, height)

	local tex = B.SetGradient(frame, "H", 0, 0, 0, alpha, 0, width, height)
	tex:SetPoint("CENTER")
	local bottomLine = B.SetGradient(frame, "H", cr, cg, cb, alpha, 0, width, C.mult)
	bottomLine:SetPoint("TOP", frame, "BOTTOM")
	local topLine = B.SetGradient(frame, "H", cr, cg, cb, alpha, 0, width, C.mult)
	topLine:SetPoint("BOTTOM", frame, "TOP")
end