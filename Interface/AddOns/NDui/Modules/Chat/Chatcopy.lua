local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

function module:ChatCopy()
	-- Custom ChatMenu
	local menu = CreateFrame("Frame", nil, UIParent)
	menu:SetSize(25, 100)
	menu:SetPoint("TOPLEFT", ChatFrame1, "TOPRIGHT", 10, 0)
	menu:SetShown(NDuiDB["Chat"]["ChatMenu"])

	ChatFrameMenuButton:ClearAllPoints()
	ChatFrameMenuButton:SetPoint("TOP", menu)
	ChatFrameMenuButton:SetParent(menu)
	ChatFrameChannelButton:ClearAllPoints()
	ChatFrameChannelButton:SetPoint("TOP", ChatFrameMenuButton, "BOTTOM", 0, -2)
	ChatFrameChannelButton:SetParent(menu)
	ChatFrameToggleVoiceDeafenButton:SetParent(menu)
	ChatFrameToggleVoiceMuteButton:SetParent(menu)
	QuickJoinToastButton:SetParent(menu)
	ChatAlertFrame:ClearAllPoints()
	ChatAlertFrame:SetPoint("BOTTOMLEFT", ChatFrame1Tab, "TOPLEFT", 5, 25)

	-- Chat Copy
	local lines = {}
	local frame = CreateFrame("Frame", "NDuiChatCopy", UIParent)
	frame:SetPoint("CENTER")
	frame:SetSize(700, 400)
	frame:Hide()
	frame:SetFrameStrata("DIALOG")
	B.CreateMF(frame)
	B.CreateBD(frame)
	B.CreateSD(frame)
	B.CreateTex(frame)
	frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	frame.close:SetPoint("TOPRIGHT", frame)

	local scrollArea = CreateFrame("ScrollFrame", "ChatCopyScrollFrame", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -30)
	scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)

	local editBox = CreateFrame("EditBox", nil, frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:SetWidth(scrollArea:GetWidth())
	editBox:SetHeight(270)
	editBox:SetScript("OnEscapePressed", function(f) f:GetParent():GetParent():Hide() f:SetText("") end)
	scrollArea:SetScrollChild(editBox)

	local function colorReplace(msg, r, g, b)
		local hexRGB = B.HexRGB(r, g, b)
		local hexReplace = format("|r%s", hexRGB)
		msg = gsub(msg, "|r", hexReplace)
		msg = format("%s%s|r", hexRGB, msg)

		return msg
	end

	local function copyFunc(_, btn)
		if btn == "LeftButton" then
			if not frame:IsShown() then
				local chatframe = SELECTED_DOCK_FRAME
				local _, fontSize = chatframe:GetFont()
				FCF_SetChatWindowFontSize(chatframe, chatframe, .01)
				frame:Show()

				local index = 1
				for i = 1, chatframe:GetNumMessages() do
					local message, r, g, b = chatframe:GetMessageInfo(i)
					r = r or 1
					g = g or 1
					b = b or 1
					message = colorReplace(message, r, g, b)

					lines[index] = tostring(message)
					index = index + 1
				end

				local lineCt = index - 1
				local text = table.concat(lines, "\n", 1, lineCt)
				FCF_SetChatWindowFontSize(chatframe, chatframe, fontSize)
				editBox:SetText(text)

				wipe(lines)
			else
				frame:Hide()
			end
		elseif btn == "RightButton" then
			ToggleFrame(menu)
			NDuiDB["Chat"]["ChatMenu"] = menu:IsShown()
		end
	end

	local copy = CreateFrame("Button", nil, UIParent)
	copy:SetPoint("BOTTOMLEFT", 370, 30)
	copy:SetSize(20, 20)
	copy:SetAlpha(.5)
	copy.Icon = copy:CreateTexture(nil, "ARTWORK")
	copy.Icon:SetAllPoints()
	copy.Icon:SetTexture(DB.copyTex)
	copy:RegisterForClicks("AnyUp")
	copy:SetScript("OnClick", copyFunc)
	B.AddTooltip(copy, "ANCHOR_RIGHT", L["Chat Copy"])
	copy:HookScript("OnEnter", function() copy:SetAlpha(1) end)
	copy:HookScript("OnLeave", function() copy:SetAlpha(.5) end)

	-- Aurora Reskin
	if IsAddOnLoaded("AuroraClassic") then
		local F = unpack(AuroraClassic)
		F.ReskinClose(frame.close)
		F.ReskinScroll(ChatCopyScrollFrameScrollBar)
	end
end