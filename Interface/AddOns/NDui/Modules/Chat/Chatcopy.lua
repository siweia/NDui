local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

function module:ChatCopy()
	-- Custom ChatMenu
	local frame = CreateFrame("Frame", "NDuiChatMenu", UIParent)
	frame:SetSize(25, 100)
	frame:SetPoint("TOPLEFT", ChatFrame1, "TOPRIGHT", 10, 0)
	frame:Hide()

	ChatFrameChannelButton:ClearAllPoints()
	ChatFrameChannelButton:SetPoint("TOP", frame)
	ChatFrameChannelButton:SetParent(frame)
	ChatFrameToggleVoiceDeafenButton:SetParent(frame)
	ChatFrameToggleVoiceMuteButton:SetParent(frame)
	QuickJoinToastButton:SetParent(frame)
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
	frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	frame.close:SetPoint("TOPRIGHT", frame, "TOPRIGHT")

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

	local function copyFunc(_, btn)
		if btn == "LeftButton" then
			if not frame:IsShown() then
				local cf = SELECTED_DOCK_FRAME
				local _, size = cf:GetFont()
				FCF_SetChatWindowFontSize(cf, cf, .01)
				frame:Show()
				local ct = 1
				for i = 1, cf:GetNumMessages() do
					local message, r, g, b = cf:GetMessageInfo(i)
					lines[ct] = tostring(message)
					ct = ct + 1
				end
				local lineCt = ct - 1
				local text = table.concat(lines, "\n", 1, lineCt)
				FCF_SetChatWindowFontSize(cf, cf, size)
				editBox:SetText(text)
				wipe(lines)
			else
				frame:Hide()
			end
		elseif btn == "RightButton" then
			if not NDuiChatMenu then
				ChatButtonCollecter()
				NDuiChatMenu:Show()
			else
				ToggleFrame(NDuiChatMenu)
			end
		end
	end

	local copy = CreateFrame("Button", nil, UIParent)
	copy:SetPoint("BOTTOMLEFT", 370, 30)
	copy:SetSize(20, 20)
	copy:SetAlpha(.3)
	copy.Icon = copy:CreateTexture(nil, "ARTWORK")
	copy.Icon:SetAllPoints()
	copy.Icon:SetTexture(DB.copyTex)
	copy:RegisterForClicks("AnyUp")
	copy:SetScript("OnClick", copyFunc)
	B.AddTooltip(copy, "ANCHOR_RIGHT", L["Chat Copy"])
	copy:HookScript("OnEnter", function() copy:SetAlpha(1) end)
	copy:HookScript("OnLeave", function() copy:SetAlpha(.3) end)

	-- Aurora Reskin
	if IsAddOnLoaded("AuroraClassic") then
		local F = unpack(AuroraClassic)
		F.ReskinClose(frame.close)
		F.ReskinScroll(ChatCopyScrollFrameScrollBar)
	end
end