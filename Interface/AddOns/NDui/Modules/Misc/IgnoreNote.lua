local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local unitName
local noteString = "|T"..DB.copyTex..":12|t %s"

local function GetButtonName(button)
	local name = button.name:GetText()
	if not name then return end
	if not strmatch(name, "-") then
		name = name.."-"..DB.MyRealm
	end
	return name
end

function M:IgnoreButton_OnClick()
	unitName = GetButtonName(self)
	StaticPopup_Show("NDUI_IGNORE_NOTE", unitName)
end

function M:IgnoreButton_OnEnter()
	local name = GetButtonName(self)
	local savedNote = NDuiADB["IgnoreNotes"][name]
	if savedNote then
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 35, 0)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(name)
		GameTooltip:AddLine(format(noteString, savedNote), 1,1,1, 1)
		GameTooltip:Show()
	end
end

function M:IgnoreButton_Hook()
	if self.Title then return end

	if not self.hooked then
		self.name:SetFontObject(Game14Font)
		self:HookScript("OnDoubleClick", M.IgnoreButton_OnClick)
		self:HookScript("OnEnter", M.IgnoreButton_OnEnter)
		self:HookScript("OnLeave", B.HideTooltip)
	
		self.noteTex = self:CreateTexture()
		self.noteTex:SetSize(16, 16)
		self.noteTex:SetTexture(DB.copyTex)
		self.noteTex:SetPoint("RIGHT", -5, 0)
	
		self.hooked = true
	end

	self.noteTex:SetShown(NDuiADB["IgnoreNotes"][GetButtonName(self)])
end

StaticPopupDialogs["NDUI_IGNORE_NOTE"] = {
	text = SET_FRIENDNOTE_LABEL,
	button1 = OKAY,
	button2 = CANCEL,
	OnShow = function(self)
		local savedNote = NDuiADB["IgnoreNotes"][unitName]
		if savedNote then
			self.EditBox:SetText(savedNote)
			self.EditBox:HighlightText()
		end
	end,
	OnAccept = function(self)
		local text = self.EditBox:GetText()
		if text and text ~= "" then
			NDuiADB["IgnoreNotes"][unitName] = text
		else
			NDuiADB["IgnoreNotes"][unitName] = nil
		end
	end,
	EditBoxOnEscapePressed = function(editBox)
		editBox:GetParent():Hide()
	end,
	EditBoxOnEnterPressed = function(editBox)
		local text = editBox:GetText()
		if text and text ~= "" then
			NDuiADB["IgnoreNotes"][unitName] = text
		else
			NDuiADB["IgnoreNotes"][unitName] = nil
		end
		editBox:GetParent():Hide()
	end,
	whileDead = 1,
	hasEditBox = 1,
	editBoxWidth = 250,
}

function M:IgnoreNote()
	local ignoreHelpInfo = {
		text = L["IgnoreNoteHelp"],
		buttonStyle = HelpTip.ButtonStyle.GotIt,
		targetPoint = HelpTip.Point.RightEdgeCenter,
		onAcknowledgeCallback = B.HelpInfoAcknowledge,
		callbackArg = "IgnoreNote",
	}
	IgnoreListFrame:HookScript("OnShow", function(frame)
		if not NDuiADB["Help"]["IgnoreNote"] then
			HelpTip:Show(frame, ignoreHelpInfo)
		end
	end)

	hooksecurefunc(IgnoreListFrame.ScrollBox, "Update", function(self)
		self:ForEachFrame(M.IgnoreButton_Hook)
	end)

	FriendsFrameUnsquelchButton:HookScript("OnClick", function()
		local name = C_FriendList.GetIgnoreName(C_FriendList.GetSelectedIgnore())
		if name then
			if not strmatch(name, "-") then
				name = name.."-"..DB.MyRealm
			end
			NDuiADB["IgnoreNotes"][name] = nil
		end
	end)
end

M:RegisterMisc("IgnoreNote", M.IgnoreNote)