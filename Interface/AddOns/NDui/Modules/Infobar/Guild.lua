local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Guild then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar(C.Infobar.GuildPos)

local r, g, b = DB.cc.r, DB.cc.g, DB.cc.b
local infoFrame = CreateFrame("Frame", "NDuiGuildInfobar", info)
infoFrame:SetSize(335, 495)
infoFrame:SetPoint("TOPLEFT", UIParent, 15, -30)
infoFrame:SetClampedToScreen(true)
infoFrame:SetFrameStrata("TOOLTIP")
B.CreateBD(infoFrame, .7)
B.CreateSD(infoFrame)
B.CreateTex(infoFrame)
infoFrame:Hide()

local gName = B.CreateFS(infoFrame, 18, "Guild", true, "TOPLEFT", 15, -10)
local gOnline = B.CreateFS(infoFrame, 13, "Online", false, "TOPLEFT", 15, -35)
local gApps = B.CreateFS(infoFrame, 13, "Applications", false, "TOPRIGHT", -15, -35)
local gRank = B.CreateFS(infoFrame, 13, "Rank", false, "TOPLEFT", 15, -51)

local bu = {}
local width = {30, 35, 126, 126}
for i = 1, 4 do
	bu[i] = CreateFrame("Button", nil, infoFrame)
	bu[i]:SetSize(width[i], 22)
	bu[i]:SetFrameLevel(infoFrame:GetFrameLevel() + 3)
	if i == 1 then
		bu[i]:SetPoint("TOPLEFT", 12, -75)
	else
		bu[i]:SetPoint("LEFT", bu[i-1], "RIGHT", -2, 0)
	end
	bu[i].HL = bu[i]:CreateTexture(nil, "HIGHLIGHT")
	bu[i].HL:SetAllPoints(bu[i])
	bu[i].HL:SetColorTexture(r, g, b, .2)
end
B.CreateFS(bu[1], 13, LEVEL_ABBR)
B.CreateFS(bu[2], 13, CLASS_ABBR)
B.CreateFS(bu[3], 13, NAME, false, "LEFT", 5, 0)
B.CreateFS(bu[4], 13, ZONE, false, "RIGHT", -5, 0)

B.CreateFS(infoFrame, 13, DB.LineString, false, "BOTTOMRIGHT", -12, 58)
local whspInfo = DB.InfoColor..DB.RightButton..L["Whisper"]
B.CreateFS(infoFrame, 13, whspInfo, false, "BOTTOMRIGHT", -15, 42)
local invtInfo = DB.InfoColor.."ALT +"..DB.LeftButton..L["Invite"]
B.CreateFS(infoFrame, 13, invtInfo, false, "BOTTOMRIGHT", -15, 26)
local copyInfo = DB.InfoColor.."SHIFT +"..DB.LeftButton..L["Copy Name"]
B.CreateFS(infoFrame, 13, copyInfo, false, "BOTTOMRIGHT", -15, 10)

local scrollFrame = CreateFrame("ScrollFrame", nil, infoFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetSize(312, 320)
scrollFrame:SetPoint("TOPLEFT", 10, -100)
scrollFrame.ScrollBar:Hide()
scrollFrame.ScrollBar.Show = B.Dummy
scrollFrame:SetScript("OnMouseWheel", function(_, delta)
	local scrollBar = scrollFrame.ScrollBar
	scrollBar:SetValue(scrollBar:GetValue() - delta*50)
end)
local roster = CreateFrame("Frame", nil, scrollFrame)
roster:SetSize(312, 1)
scrollFrame:SetScrollChild(roster)

local guildTable, frames, previous = {}, {}, 0
local function createRoster(i)
	local button = CreateFrame("Button", nil, roster)
	button:SetSize(312, 20)
	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetAllPoints()
	button.HL:SetColorTexture(r, g, b, .2)

	button.level = B.CreateFS(button, 13, "Level", false)
	button.level:SetPoint("TOP", button, "TOPLEFT", 16, -4)
	button.class = button:CreateTexture(nil, "ARTWORK")
	button.class:SetPoint("LEFT", 35, 0)
	button.class:SetSize(16, 16)
	button.class:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
	button.name = B.CreateFS(button, 13, "Name", false, "LEFT", 65, 0)
	button.name:SetPoint("RIGHT", button, "LEFT", 185, 0)
	button.name:SetJustifyH("LEFT")
	button.zone = B.CreateFS(button, 13, "Zone", false, "RIGHT", -2, 0)
	button.zone:SetPoint("LEFT", button, "RIGHT", -120, 0)
	button.zone:SetJustifyH("RIGHT")

	button:RegisterForClicks("AnyUp")
	button:SetScript("OnClick", function(_, btn)
		local name = guildTable[i][3]
		if btn == "LeftButton" then
			if IsAltKeyDown() then
				InviteToGroup(name)
			elseif IsShiftKeyDown() then
				if MailFrame:IsShown() then
					MailFrameTab_OnClick(nil, 2)
					SendMailNameEditBox:SetText(name)
					SendMailNameEditBox:HighlightText()
				else
					local editBox = ChatEdit_ChooseBoxForSend()
					local hasText = (editBox:GetText() ~= "")
					ChatEdit_ActivateChat(editBox)
					editBox:Insert(name)
					if not hasText then editBox:HighlightText() end
				end
			end
		else
			ChatFrame_OpenChat("/w "..name.." ", SELECTED_DOCK_FRAME)
		end
	end)

	return button
end

local function refreshData()
	wipe(guildTable)
	GuildRoster()
	local count = 0
	local total, _, online = GetNumGuildMembers()
	local guildName, guildRank = GetGuildInfo("player")

	gName:SetText("|cff0099ff<"..(guildName or "")..">")
	gOnline:SetText(format(DB.InfoColor.."%s:".." %d/%d", GUILD_ONLINE_LABEL, online, total))
	gApps:SetText(format(DB.InfoColor..GUILDINFOTAB_APPLICANTS, GetNumGuildApplicants()))
	gRank:SetText(DB.InfoColor..RANK..": "..(guildRank or ""))

	for i = 1, total do
		local name, _, _, level, _, zone, _, _, connected, status, class, _, _, mobile = GetGuildRosterInfo(i)
		if connected or mobile then
			if mobile and not connected then
				zone = REMOTE_CHAT
				if status == 1 then
					status = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0:16:16:0:16:0:16|t"
				elseif status == 2 then
					status = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-BusyMobile:14:14:0:0:16:16:0:16:0:16|t"
				else
					status = ChatFrame_GetMobileEmbeddedTexture(73/255, 177/255, 73/255)
				end
			else
				if status == 1 then
					status = DB.AFKTex
				elseif status == 2 then
					status = DB.DNDTex
				else
					status = " "
				end
			end
			if not zone then zone = UNKNOWN end

			count = count + 1
			guildTable[count] = {level, class, name, zone, status}
		end
	end

	if count > previous then
		for i = previous+1, count do
			if not frames[i] then
				frames[i] = createRoster(i)
			end
		end
	elseif count < previous then
		for i = count+1, previous do
			frames[i]:Hide()
		end
	end
	previous = count
end

local function setPosition()
	for i = 1, previous do
		if i == 1 then
			frames[i]:SetPoint("TOPLEFT")
		else
			frames[i]:SetPoint("TOP", frames[i-1], "BOTTOM")
		end
		frames[i]:Show()
	end
end

local function applyData()
	sort(guildTable, function(a, b)
		if a and b then
			if NDuiADB["GuildSortOrder"] then
				return a[NDuiADB["GuildSortBy"]] < b[NDuiADB["GuildSortBy"]]
			else
				return a[NDuiADB["GuildSortBy"]] > b[NDuiADB["GuildSortBy"]]
			end
		end
	end)

	for i = 1, previous do
		local level, class, name, zone, status = unpack(guildTable[i])

		local levelcolor = B.HexRGB(GetQuestDifficultyColor(level))
		frames[i].level:SetText(levelcolor..level)

		local tcoords = CLASS_ICON_TCOORDS[class]
		frames[i].class:SetTexCoord(tcoords[1] + .022, tcoords[2] - .025, tcoords[3] + .022, tcoords[4] - .025)

		local namecolor = B.HexRGB(B.ClassColor(class))
		frames[i].name:SetText(namecolor..Ambiguate(name, "guild")..status)

		local zonecolor = "|cffa6a6a6"
		if GetRealZoneText() == zone then zonecolor = "|cff4cff4c" end
		frames[i].zone:SetText(zonecolor..zone)
	end
end

for i = 1, 4 do
	bu[i]:SetScript("OnClick", function()
		NDuiADB["GuildSortBy"] = i
		NDuiADB["GuildSortOrder"] = not NDuiADB["GuildSortOrder"]
		applyData()
	end)
end

info.eventList = {
	"PLAYER_ENTERING_WORLD",
	"GUILD_ROSTER_UPDATE",
	"PLAYER_GUILD_UPDATE",
}

info.onEvent = function(self)
	if not IsInGuild() then
		self.text:SetText(GUILD..": "..DB.MyColor..NONE)
		return
	end

	GuildRoster()
	local _, _, online = GetNumGuildMembers()
	self.text:SetText(GUILD..": "..DB.MyColor..online)

	if infoFrame:IsShown() then
		refreshData()
		setPosition()
		applyData()
	end
end

info.onEnter = function()
	if not IsInGuild() then return end
	refreshData()
	setPosition()
	applyData()
	infoFrame:Show()
end

info.onLeave = function()
	C_Timer.After(.1, function()
		if MouseIsOver(infoFrame) then return end
		infoFrame:Hide()
	end)
end

info.onMouseUp = function()
	if not IsInGuild() then return end
	infoFrame:Hide()
	if not GuildFrame then LoadAddOn("Blizzard_GuildUI") end
	ToggleFrame(GuildFrame)
end

infoFrame:SetScript("OnLeave", function(self)
	self:SetScript("OnUpdate", function(self, elapsed)
		self.timer = (self.timer or 0) + elapsed
		if self.timer > .1 then
			if not infoFrame:IsMouseOver() then
				self:Hide()
				self:SetScript("OnUpdate", nil)
			end

			self.timer = 0 
		end
	end)
end)