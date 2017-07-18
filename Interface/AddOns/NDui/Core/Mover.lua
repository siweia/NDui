local B, C, L, DB = unpack(select(2, ...))

-- Frame Mover
local MoverList, BackupTable, f = {}, {}
B.Mover = function(Frame, Text, key, Pos, w, h)
	if not NDuiDB["Mover"] then NDuiDB["Mover"] = {} end
	local Mover = CreateFrame("Frame", nil, UIParent)
	Mover:SetWidth(w or Frame:GetWidth())
	Mover:SetHeight(h or Frame:GetHeight())
	B.CreateBD(Mover)
	B.CreateTex(Mover)
	B.CreateFS(Mover, DB.Font[2], Text)
	tinsert(MoverList, Mover)

	if not NDuiDB["Mover"][key] then 
		Mover:SetPoint(unpack(Pos))
	else
		Mover:SetPoint(unpack(NDuiDB["Mover"][key]))
	end
	Mover:EnableMouse(true)
	Mover:SetMovable(true)
	Mover:SetClampedToScreen(true)
	Mover:SetFrameStrata("HIGH")
	Mover:RegisterForDrag("LeftButton")
	Mover:SetScript("OnDragStart", function(self) self:StartMoving() end)
	Mover:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local orig, _, tar, x, y = self:GetPoint()
		NDuiDB["Mover"][key] = {orig, "UIParent", tar, x, y}
	end)
	Mover:Hide()
	Frame:SetPoint("TOPLEFT", Mover)

	return Mover
end

local function UnlockElements()
	for i = 1, #MoverList do
		local mover = MoverList[i]
		if not mover:IsShown() then
			mover:Show()
		end
	end
	B.CopyTable(NDuiDB["Mover"], BackupTable)
end

local function LockElements()
	for i = 1, #MoverList do
		local mover = MoverList[i]
		mover:Hide()
	end
end

StaticPopupDialogs["RESET_MOVER"] = {
	text = L["Reset Mover Confirm"],
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		wipe(NDuiDB["Mover"])
		ReloadUI()
	end,
}

StaticPopupDialogs["CANCEL_MOVER"] = {
	text = L["Cancel Mover Confirm"],
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		B.CopyTable(BackupTable, NDuiDB["Mover"])
		ReloadUI()
	end,
}

-- Mover Console
local function CreateConsole()
	if f then f:Show() return end

	f = CreateFrame("Frame", nil, UIParent)
	f:SetPoint("TOP", 0, -150)
	f:SetSize(296, 65)
	B.CreateBD(f)
	B.CreateTex(f)
	B.CreateMF(f)
	local lable = B.CreateFS(f, 15, L["Mover Console"], false, "TOP", 0, -10)
	lable:SetTextColor(1, .8, 0)
	local bu, text = {}, {LOCK, CANCEL, L["Grids"], RESET}
	for i = 1, 4 do
		bu[i] = B.CreateButton(f, 70, 30, text[i])
		if i == 1 then
			bu[i]:SetPoint("BOTTOMLEFT", 5, 5)
		else
			bu[i]:SetPoint("LEFT", bu[i-1], "RIGHT", 2, 0)
		end
	end
	-- Lock
	bu[1]:SetScript("OnClick", function()
		f:Hide()
		LockElements()
		SlashCmdList["TOGGLEGRID"]("1")
	end)
	-- Cancel
	bu[2]:SetScript("OnClick", function()
		StaticPopup_Show("CANCEL_MOVER")
	end)
	-- Grids
	bu[3]:SetScript("OnClick", function()
		SlashCmdList["TOGGLEGRID"]("32")
	end)
	-- Reset
	bu[4]:SetScript("OnClick", function()
		StaticPopup_Show("RESET_MOVER")
	end)

	NDui:EventFrame("PLAYER_REGEN_DISABLED"):SetScript("OnEvent", function(self, event)
		if event == "PLAYER_REGEN_DISABLED" then
			if f:IsShown() then
				f:Hide()
				LockElements()
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			end
		else
			f:Show()
			UnlockElements()
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
	end)
end

SlashCmdList["NDUI_MOVER"] = function(msg)
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT)
		return
	end
	CreateConsole()
	UnlockElements()
end
SLASH_NDUI_MOVER1 = "/mm"