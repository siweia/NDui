local B, C, L, DB = unpack(select(2, ...))
local module = NDui:GetModule("Chat")

function module:ChatCopy()
	local lines = {}
	local frame = CreateFrame("Frame", "NDuiChatCopy", UIParent)
	frame:SetPoint("CENTER", UIParent, "CENTER")
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

	local function copyFunc()
		local cf = SELECTED_DOCK_FRAME
		local _, size = cf:GetFont()
		FCF_SetChatWindowFontSize(cf, cf, .01)
		local ct = 1
		for i = select("#", cf.FontStringContainer:GetRegions()), 1, -1 do
			local region = select(i, cf.FontStringContainer:GetRegions())
			if region:GetObjectType() == "FontString" then
				if region:GetText() ~= nil then
					lines[ct] = tostring(region:GetText())
					ct = ct + 1
				end
			end
		end
		local lineCt = ct - 1
		local text = table.concat(lines, "\n", 1, lineCt)
		FCF_SetChatWindowFontSize(cf, cf, size)
		frame:Show()
		editBox:SetText(text)
		editBox:HighlightText(0)
		wipe(lines)
	end

	local copy = CreateFrame("Button", nil, UIParent)
	copy:SetPoint("BOTTOMLEFT", 370, 30)
	copy:SetSize(20, 20)
	copy:SetAlpha(.2)
	copy.Icon = copy:CreateTexture(nil, "ARTWORK")
	copy.Icon:SetAllPoints()
	copy.Icon:SetTexture(DB.copyTex)
	copy:SetScript("OnDoubleClick", copyFunc)
	B.CreateGT(copy, "ANCHOR_RIGHT", L["Chat Copy"], "system")
	copy:HookScript("OnEnter", function() copy:SetAlpha(1) end)
	copy:HookScript("OnLeave", function() copy:SetAlpha(.2) end)

	-- Aurora Reskin
	if IsAddOnLoaded("Aurora") then
		local F = unpack(Aurora)
		F.ReskinClose(frame.close)
		F.ReskinScroll(ChatCopyScrollFrameScrollBar)
	end
end