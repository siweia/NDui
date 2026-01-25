local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

local tinsert, pairs = tinsert, pairs
local C_GuildInfo_IsGuildOfficer = C_GuildInfo.IsGuildOfficer

local chatSwitchInfo = {
	text = L["ChatSwitchHelp"],
	buttonStyle = HelpTip.ButtonStyle.GotIt,
	targetPoint = HelpTip.Point.TopEdgeCenter,
	offsetY = 50,
	onAcknowledgeCallback = B.HelpInfoAcknowledge,
	callbackArg = "ChatSwitch",
}

local function chatSwitchTip()
	if not NDuiADB["Help"]["ChatSwitch"] then
		HelpTip:Show(ChatFrame1, chatSwitchInfo)
	end
end

function module:Chatbar()
	if not C.db["Chat"]["Chatbar"] then return end

	local chatFrame = SELECTED_DOCK_FRAME
	local editBox = chatFrame.editBox
	local width, height, padding, buttonList = 40, 8, 5, {}

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
		if func then
			bu:SetScript("OnClick", func)
			bu:HookScript("OnClick", chatSwitchTip)
		end

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
			if IsPartyLFG() or C_PartyInfo.IsPartyWalkIn() then
				ChatFrame_OpenChat("/i ", chatFrame)
			else
				ChatFrame_OpenChat("/raid ", chatFrame)
			end
		end},
		{.25, 1, .25, GUILD.."/"..OFFICER, function(_, btn)
			if btn == "RightButton" and C_GuildInfo_IsGuildOfficer() then
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
	roll:RegisterForClicks("AnyUp", "AnyDown")

	-- COMBATLOG
	local combat = AddButton(1, 1, 0, BINDING_NAME_TOGGLECOMBATLOG)
	combat:SetAttribute("type", "macro")
	combat:SetAttribute("macrotext", "/combatlog")
	combat:RegisterForClicks("AnyUp", "AnyDown")

	-- WORLD CHANNEL
	if GetCVar("portal") == "CN" then
		local channelName = "大脚世界频道"
		local wcButton = AddButton(0, .8, 1, L["World Channel"])

		local function updateChannelInfo()
			local id = GetChannelName(channelName)
			if not id or id == 0 then
				module.InWorldChannel = false
				module.WorldChannelID = nil
				wcButton.Icon:SetVertexColor(1, .1, .1)
			else
				module.InWorldChannel = true
				module.WorldChannelID = id
				wcButton.Icon:SetVertexColor(0, .8, 1)
			end
		end

		local function checkChannelStatus()
			C_Timer.After(.2, updateChannelInfo)
		end
		checkChannelStatus()
		B:RegisterEvent("CHANNEL_UI_UPDATE", checkChannelStatus)
		hooksecurefunc("ChatConfigChannelSettings_UpdateCheckboxes", checkChannelStatus) -- toggle in chatconfig

		wcButton:SetScript("OnClick", function(_, btn)
			if module.InWorldChannel then
				if btn == "RightButton" then
					LeaveChannelByName(channelName)
					print("|cffFF7F50"..QUIT.."|r "..DB.InfoColor..L["World Channel"])
					module.InWorldChannel = false
				elseif module.WorldChannelID then
					ChatFrame_OpenChat("/"..module.WorldChannelID, chatFrame)
				end
			else
				JoinPermanentChannel(channelName, nil, 1)
				ChatFrame1:AddChannel(channelName)
				print("|cff00C957"..JOIN.."|r "..DB.InfoColor..L["World Channel"])
				module.InWorldChannel = true
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