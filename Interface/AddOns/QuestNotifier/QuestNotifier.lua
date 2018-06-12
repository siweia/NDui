local QHisFirst = true
local lastList
local L = QN_Locale
local RGBStr = {
	R = "|CFFFF0000",
	G = "|CFF00FF00",
	B = "|CFF0000FF",
	Y = "|CFFFFFF00",
	K = "|CFF00FFFF",
	D = "|C0000AAFF",
	P = "|CFFD74DE1"
}

local function UpdateChk()
	QNOchk_Switch:SetChecked(QN_Settings.Switch)
	if QN_Settings.Switch == true then
		QNOchk_Instance:Enable()
		QNOchk_Raid:Enable()
		QNOchk_Party:Enable()
		QNOchk_Solo:Enable()
		QNOchk_Sound:Enable()
		QNOchk_Debug:Enable()
		QNOchk_NoDetail:Enable()
		QNOchk_CompleteX:Enable()
	else
		QNOchk_Instance:Disable()
		QNOchk_Raid:Disable()
		QNOchk_Party:Disable()
		QNOchk_Solo:Disable()
		QNOchk_Sound:Disable()
		QNOchk_Debug:Disable()
		QNOchk_NoDetail:Disable()
		QNOchk_CompleteX:Disable()
	end
	QNOchk_Instance:SetChecked(QN_Settings.Instance)
	QNOchk_Raid:SetChecked(QN_Settings.Raid)
	QNOchk_Party:SetChecked(QN_Settings.Party)
	QNOchk_Solo:SetChecked(QN_Settings.Solo)
	QNOchk_Sound:SetChecked(QN_Settings.Sound)
	QNOchk_Debug:SetChecked(QN_Settings.Debug)
	QNOchk_NoDetail:SetChecked(QN_Settings.NoDetail)
	QNOchk_CompleteX:SetChecked(QN_Settings.CompleteX)
end

local function RScanQuests()
	local QuestList = {}
	local qIndex = 1
	local qLink
	local splitdot = L["Colon"]
	while GetQuestLogTitle(qIndex) do
		local qTitle, qLevel, qGroup, qisHeader, qisCollapsed, qisComplete, qisDaily, qID = GetQuestLogTitle(qIndex)
		if not qisHeader then
			qLink = GetQuestLink(qID)
			QuestList[qID]={
				Title    	= qTitle,			-- String
				Level    	= qLevel,       	-- Integer
				Group    	= qGroup,       	-- Integer
				Header   	= qisHeader,    	-- boolean
				Collapsed	= qisCollapsed, 	-- boolean
				Complete 	= qisComplete,  	-- Integer
				Daily    	= qisDaily,     	-- Integer
				QuestID  	= qID,          	-- Integer
				Link     	= qLink
			}
			if qisComplete == 1 and (IsQuestWatched(qIndex)) and QN_Settings.CompleteX == true then
				RemoveQuestWatch(qIndex)
			end
			for i = 1, GetNumQuestLeaderBoards(qIndex) do
				local description, itemType, isComplete = GetQuestLogLeaderBoard(i, qIndex)
				if description then
					local numstr, itemName = strsplit(" ", description)
					local numItems, numNeeded = strsplit("/", numstr)
					QuestList[qID][i]={
						NeedItem = itemName,			-- String
						NeedNum  = numNeeded,			-- Integer
						DoneNum  = numItems				-- Integer
					}
				end
			end
		end
		qIndex = qIndex + 1
	end
	return QuestList
end

local function PrtChatMsg(msg)
	if IsPartyLFG() then
		if QN_Settings.Instance == true then
			SendChatMessage(msg, "instance_chat", nil)
		end
	elseif IsInRaid() then
		if QN_Settings.Raid == true then
			SendChatMessage(msg, "raid", nil)
		end
	elseif IsInGroup() and not IsInRaid() then
		if QN_Settings.Party == true then
			SendChatMessage(msg, "party", nil)
		end
	else
		if QN_Settings.Solo == true then
			SendChatMessage(msg, "say", nil)
		end
	end
end

local function DebugMsg(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg)
end

function QN_OnEvent(event)
	if event ==  "VARIABLES_LOADED" then
		if not QN_Settings then
			QN_Settings = {
				Switch		= true,
				Instance	= true,					
				Raid		= false,
				Party		= true,
				Solo		= false,
				Sound		= true,
				Debug		= false,
				NoDetail	= true,
				CompleteX	= false
			}
		end
		QuestNotifierOptionFrame:RegisterEvent("QUEST_LOG_UPDATE")
		UpdateChk()
	end
	if QN_Settings.Switch == false then return end
	if event == "QUEST_LOG_UPDATE" then
		local QN_Progress = L["Progress"]
		local QN_ItemMsg, QN_ItemColorMsg = " ", " "
		if QHisFirst then
			lastList = RScanQuests()
			QHisFirst = false
		end
		local currList = RScanQuests()
		for i,v in pairs(currList) do
			if lastList[i] then
				if not lastList[i].Complete then
					if (#currList[i] > 0) and (#lastList[i] > 0) then
						for j=1, #currList[i] do
							if (currList[i][j] and currList[i][j].DoneNum) and (lastList[i][j] and lastList[i][j].DoneNum) and currList[i][j].NeedNum and currList[i][j].NeedItem then
								if currList[i][j].DoneNum > lastList[i][j].DoneNum then
									QN_ItemMsg = currList[i].Link..QN_Progress..": "..currList[i][j].NeedItem..": "..currList[i][j].DoneNum.."/"..currList[i][j].NeedNum
									QN_ItemColorMsg = "NDui "..RGBStr.G..L["Quest"].."|r"..RGBStr.P.."["..currList[i].Level.."]|r "..currList[i].Link..RGBStr.G..QN_Progress..":|r"..RGBStr.K..currList[i][j].NeedItem..":|r"..RGBStr.Y..currList[i][j].DoneNum.."/"..currList[i][j].NeedNum.."|r"
									if QN_Settings.NoDetail == false then
										PrtChatMsg(QN_ItemMsg)
									end
									if not IsInGroup() then
										if QN_Settings.Debug == true then
											DebugMsg(QN_ItemColorMsg)
										end
									end
								end
							end
						end
					end
				end
				if (#currList[i] > 0) and (#lastList[i] > 0) and (currList[i].Complete == 1) then
					if not lastList[i].Complete then
						QN_ItemMsg = L["Quest"]..": ["..currList[i].Level.."]"..currList[i].Link.." "..L["Complete"]
						QN_ItemColorMsg = "NDui "..RGBStr.G..L["Quest"].."|r"..RGBStr.P.."["..currList[i].Level.."]|r "..currList[i].Link..RGBStr.K..L["Complete"].."|r"
						PrtChatMsg(QN_ItemMsg)
						if not IsInGroup() then
							if QN_Settings.Debug == true then
								DebugMsg(QN_ItemColorMsg)
							end
						end
						if QN_Settings.Sound == true then
							PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_3, "master")
						end
						--UIErrorsFrame:AddMessage(QN_ItemColorMsg)
					end
				end
			end
			if not lastList[i] then  -- last List have not the Quest, New Quest Accepted
				if currList[i].Daily == LE_QUEST_FREQUENCY_DAILY then
					QN_ItemMsg = L["Accept"]..": ["..currList[i].Level.."]".."[" .. DAILY .. "]"..currList[i].Link
				else
					QN_ItemMsg = L["Accept"]..": ["..currList[i].Level.."]"..currList[i].Link
				end
				QN_ItemColorMsg = "NDui "..RGBStr.K .. L["Accept"]..": |r" .. RGBStr.P .."["..currList[i].Level.."]|r"..currList[i].Link
				PrtChatMsg(QN_ItemMsg)
				if not IsInGroup() then
					if QN_Settings.Debug == true then
						DebugMsg(QN_ItemColorMsg)
					end
				end
			end
		end
		lastList = currList
	end
end

function QN_OPtionPrePanel(self)
	self:RegisterEvent("VARIABLES_LOADED")
	self.name = "|cff0080ffQuestNotifier|r"
	InterfaceOptions_AddCategory(self)
end