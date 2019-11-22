local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:RegisterModule("Mover")

local cr, cg, cb = DB.r, DB.g, DB.b

-- Frame Mover
local MoverList, f = {}

function M:Mover_OnClick(btn)
	if IsShiftKeyDown() and btn == "RightButton" then
		if self.isAuraWatch then
			UIErrorsFrame:AddMessage(DB.InfoColor..L["AuraWatchToggleError"])
		else
			self:Hide()
		end
	elseif IsControlKeyDown() and btn == "RightButton" then
		self:ClearAllPoints()
		self:SetPoint(unpack(self.__anchor))
		NDuiDB[self.__key][self.__value] = nil
	end
end

function M:Mover_OnEnter()
	self:SetBackdropBorderColor(cr, cg, cb)
	self.text:SetTextColor(1, .8, 0)
end

function M:Mover_OnLeave()
	self:SetBackdropBorderColor(0, 0, 0)
	self.text:SetTextColor(1, 1, 1)
end

function M:Mover_OnDragStart()
	self:StartMoving()
end

function M:Mover_OnDragStop()
	self:StopMovingOrSizing()
	local orig, _, tar, x, y = self:GetPoint()
	x = B:Round(x)
	y = B:Round(y)

	self:ClearAllPoints()
	self:SetPoint(orig, "UIParent", tar, x, y)
	NDuiDB[self.__key][self.__value] = {orig, "UIParent", tar, x, y}
end

function B:Mover(text, value, anchor, width, height, isAuraWatch)
	local key = "Mover"
	if isAuraWatch then key = "AuraWatchMover" end

	local mover = CreateFrame("Frame", nil, UIParent)
	mover:SetWidth(width or self:GetWidth())
	mover:SetHeight(height or self:GetHeight())
	B.CreateBD(mover)
	B.CreateSD(mover)
	B.CreateTex(mover)
	mover:Hide()
	mover.text = B.CreateFS(mover, DB.Font[2], text)
	mover.text:SetWordWrap(true)

	if not NDuiDB[key][value] then
		mover:SetPoint(unpack(anchor))
	else
		mover:SetPoint(unpack(NDuiDB[key][value]))
	end
	mover:EnableMouse(true)
	mover:SetMovable(true)
	mover:SetClampedToScreen(true)
	mover:SetFrameStrata("HIGH")
	mover:RegisterForDrag("LeftButton")
	mover.__key = key
	mover.__value = value
	mover.__anchor = anchor
	mover.isAuraWatch = isAuraWatch
	mover:SetScript("OnEnter", M.Mover_OnEnter)
	mover:SetScript("OnLeave", M.Mover_OnLeave)
	mover:SetScript("OnDragStart", M.Mover_OnDragStart)
	mover:SetScript("OnDragStop", M.Mover_OnDragStop)
	mover:SetScript("OnMouseUp", M.Mover_OnClick)
	if not isAuraWatch then
		tinsert(MoverList, mover)
	end

	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", mover)

	return mover
end

function M:UnlockElements()
	for i = 1, #MoverList do
		local mover = MoverList[i]
		if not mover:IsShown() then
			mover:Show()
		end
	end
	f:Show()
end

function M:LockElements()
	for i = 1, #MoverList do
		local mover = MoverList[i]
		mover:Hide()
	end
	f:Hide()
	SlashCmdList["TOGGLEGRID"]("1")
	SlashCmdList.AuraWatch("lock")
end

StaticPopupDialogs["RESET_MOVER"] = {
	text = L["Reset Mover Confirm"],
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		wipe(NDuiDB["Mover"])
		wipe(NDuiDB["AuraWatchMover"])
		ReloadUI()
	end,
}

-- Mover Console
local function CreateConsole()
	if f then return end

	f = CreateFrame("Frame", nil, UIParent)
	f:SetPoint("TOP", 0, -150)
	f:SetSize(212, 80)
	B.CreateBD(f)
	B.CreateSD(f)
	B.CreateTex(f)
	B.CreateFS(f, 15, L["Mover Console"], "system", "TOP", 0, -8)
	local bu, text = {}, {LOCK, L["Grids"], L["AuraWatch"], RESET}
	for i = 1, 4 do
		bu[i] = B.CreateButton(f, 100, 22, text[i])
		if i == 1 then
			bu[i]:SetPoint("BOTTOMLEFT", 5, 29)
		elseif i == 3 then
			bu[i]:SetPoint("TOP", bu[1], "BOTTOM", 0, -2)
		else
			bu[i]:SetPoint("LEFT", bu[i-1], "RIGHT", 2, 0)
		end
	end

	-- Lock
	bu[1]:SetScript("OnClick", M.LockElements)
	-- Grids
	bu[2]:SetScript("OnClick", function()
		SlashCmdList["TOGGLEGRID"]("64")
	end)
	-- Cancel
	bu[3]:SetScript("OnClick", function(self)
		self.state = not self.state
		if self.state then
			SlashCmdList.AuraWatch("move")
		else
			SlashCmdList.AuraWatch("lock")
		end
	end)
	-- Reset
	bu[4]:SetScript("OnClick", function()
		StaticPopup_Show("RESET_MOVER")
	end)

	local header = CreateFrame("Frame", nil, f)
	header:SetSize(212, 30)
	header:SetPoint("TOP")
	B.CreateMF(header, f)
	local tips = DB.InfoColor.."|nCTRL +"..DB.RightButton..L["Reset anchor"].."|nSHIFT +"..DB.RightButton..L["Hide panel"]
	header.title = L["Tips"]
	B.AddTooltip(header, "ANCHOR_TOP", tips)
	local tex = header:CreateTexture()
	tex:SetSize(40, 40)
	tex:SetPoint("TOPRIGHT", 2, 5)
	tex:SetTexture("Interface\\Common\\Help-i")

	local function showLater(event)
		if event == "PLAYER_REGEN_DISABLED" then
			if f:IsShown() then
				M:LockElements()
				B:RegisterEvent("PLAYER_REGEN_ENABLED", showLater)
			end
		else
			M:UnlockElements()
			B:UnregisterEvent(event, showLater)
		end
	end
	B:RegisterEvent("PLAYER_REGEN_DISABLED", showLater)
end

function M:OnLogin()
	SlashCmdList["NDUI_MOVER"] = function()
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT)
			return
		end
		CreateConsole()
		M:UnlockElements()
	end
	SLASH_NDUI_MOVER1 = "/mm"
end