local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:RegisterModule("Mover")

local cr, cg, cb = DB.r, DB.g, DB.b

-- Movable Frame
function B:CreateMF(parent, saved)
	local frame = parent or self
	frame:SetMovable(true)
	frame:SetUserPlaced(true)
	frame:SetClampedToScreen(true)

	self:EnableMouse(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", function() frame:StartMoving() end)
	self:SetScript("OnDragStop", function()
		frame:StopMovingOrSizing()
		if not saved then return end
		local orig, _, tar, x, y = frame:GetPoint()
		x, y = B:Round(x), B:Round(y)
		C.db["TempAnchor"][frame:GetName()] = {orig, "UIParent", tar, x, y}
	end)
end

function B:RestoreMF()
	local name = self:GetName()
	if name and C.db["TempAnchor"][name] then
		self:ClearAllPoints()
		self:SetPoint(unpack(C.db["TempAnchor"][name]))
	end
end

function B:UpdateBlizzFrame()
	if InCombatLockdown() then return end
	if self.isRestoring then return end
	self.isRestoring = true
	B.RestoreMF(self)
	self.isRestoring = nil
end

function B:RestoreBlizzFrame()
	if IsControlKeyDown() then
		C.db["TempAnchor"][self:GetName()] = nil
		UpdateUIPanelPositions(self)
	end
end

function B:BlizzFrameMover(frame)
	B.CreateMF(frame, nil, true)
	hooksecurefunc(frame, "SetPoint", B.UpdateBlizzFrame)
	frame:HookScript("OnMouseUp", B.RestoreBlizzFrame)
end

-- Frame Mover
local MoverList, f = {}
local updater

function B:Mover(text, value, anchor, width, height, isAuraWatch)
	local key = "Mover"
	if isAuraWatch then key = "AuraWatchMover" end

	local mover = CreateFrame("Frame", nil, UIParent)
	mover:SetWidth(width or self:GetWidth())
	mover:SetHeight(height or self:GetHeight())
	mover.bg = B.SetBD(mover)
	mover:Hide()
	mover.text = B.CreateFS(mover, DB.Font[2], text)
	mover.text:SetWordWrap(true)

	if not C.db[key][value] then
		mover:SetPoint(unpack(anchor))
	else
		mover:SetPoint(unpack(C.db[key][value]))
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

function M:CalculateMoverPoints(mover, trimX, trimY)
	local screenWidth = B:Round(UIParent:GetRight())
	local screenHeight = B:Round(UIParent:GetTop())
	local screenCenter = B:Round(UIParent:GetCenter(), nil)
	local x, y = mover:GetCenter()

	local LEFT = screenWidth / 3
	local RIGHT = screenWidth * 2 / 3
	local TOP = screenHeight / 2
	local point

	if y >= TOP then
		point = "TOP"
		y = -(screenHeight - mover:GetTop())
	else
		point = "BOTTOM"
		y = mover:GetBottom()
	end

	if x >= RIGHT then
		point = point.."RIGHT"
		x = mover:GetRight() - screenWidth
	elseif x <= LEFT then
		point = point.."LEFT"
		x = mover:GetLeft()
	else
		x = x - screenCenter
	end

	x = x + (trimX or 0)
	y = y + (trimY or 0)
	x, y = B:Round(x), B:Round(y)

	return x, y, point
end

function M:UpdateTrimFrame()
	if not f then return end -- for aurawatch preview

	local x, y = M:CalculateMoverPoints(self)
	f.__x:SetText(x)
	f.__y:SetText(y)
	f.__x.__current = x
	f.__y.__current = y
	f.__trimText:SetText(self.text:GetText())
end

function M:DoTrim(trimX, trimY)
	local mover = updater.__owner
	if mover then
		local x, y, point = M:CalculateMoverPoints(mover, trimX, trimY)
		f.__x:SetText(x)
		f.__y:SetText(y)
		f.__x.__current = x
		f.__y.__current = y
		mover:ClearAllPoints()
		mover:SetPoint(point, UIParent, point, x, y)
		C.db[mover.__key][mover.__value] = {point, "UIParent", point, x, y}
	end
end

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
		C.db[self.__key][self.__value] = nil
	end
	updater.__owner = self
	M.UpdateTrimFrame(self)
end

function M:Mover_OnEnter()
	self.bg:SetBackdropBorderColor(cr, cg, cb)
	self.text:SetTextColor(1, .8, 0)
end

function M:Mover_OnLeave()
	B.SetBorderColor(self.bg)
	self.text:SetTextColor(1, 1, 1)
end

function M:Mover_OnDragStart()
	self:StartMoving()
	M.UpdateTrimFrame(self)
	updater.__owner = self
	updater:Show()
end

function M:Mover_OnDragStop()
	self:StopMovingOrSizing()
	local orig, _, tar, x, y = self:GetPoint()
	x = B:Round(x)
	y = B:Round(y)

	self:ClearAllPoints()
	self:SetPoint(orig, "UIParent", tar, x, y)
	C.db[self.__key][self.__value] = {orig, "UIParent", tar, x, y}
	M.UpdateTrimFrame(self)
	updater:Hide()
end

function M:UnlockElements()
	for i = 1, #MoverList do
		local mover = MoverList[i]
		if not mover:IsShown() and not mover.isDisable then
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
		wipe(C.db["Mover"])
		wipe(C.db["AuraWatchMover"])
		ReloadUI()
	end,
}

-- Mover Console
local function CreateConsole()
	if f then return end

	f = CreateFrame("Frame", nil, UIParent)
	f:SetPoint("TOP", 0, -150)
	f:SetSize(212, 80)
	B.SetBD(f)
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

	local helpInfo = B.CreateHelpInfo(header, "|nCTRL +"..DB.RightButton..L["Reset anchor"].."|nSHIFT +"..DB.RightButton..L["Hide panel"])
	helpInfo:SetPoint("TOPRIGHT", 2, 5)

	local frame = CreateFrame("Frame", nil, f)
	frame:SetSize(212, 73)
	frame:SetPoint("TOP", f, "BOTTOM", 0, -3)
	B.SetBD(frame)
	f.__trimText = B.CreateFS(frame, 12, NONE, "system", "BOTTOM", 0, 5)

	local xBox = B.CreateEditBox(frame, 60, 22)
	xBox:SetPoint("TOPRIGHT", frame, "TOP", -12, -5)
	B.CreateFS(xBox, 14, "X", "system", "LEFT", -20, 0)
	xBox:SetJustifyH("CENTER")
	xBox.__current = 0
	xBox:HookScript("OnEnterPressed", function(self)
		local text = self:GetText()
		text = tonumber(text)
		if text then
			local diff = text - self.__current
			self.__current = text
			M:DoTrim(diff)
		end
	end)
	f.__x = xBox

	local yBox = B.CreateEditBox(frame, 60, 22)
	yBox:SetPoint("TOPRIGHT", frame, "TOP", -12, -29)
	B.CreateFS(yBox, 14, "Y", "system", "LEFT", -20, 0)
	yBox:SetJustifyH("CENTER")
	yBox.__current = 0
	yBox:HookScript("OnEnterPressed", function(self)
		local text = self:GetText()
		text = tonumber(text)
		if text then
			local diff = text - self.__current
			self.__current = text
			M:DoTrim(nil, diff)
		end
	end)
	f.__y = yBox

	local arrows = {}
	local arrowIndex = {
		[1] = {degree = 180, offset = -1, x = 28, y = 9},
		[2] = {degree = 0, offset = 1, x = 72, y = 9},
		[3] = {degree = 90, offset = 1, x = 50, y = 20},
		[4] = {degree = -90, offset = -1, x = 50, y = -2},
	}
	local function arrowOnClick(self)
		local modKey = IsModifierKeyDown()
		if self.__index < 3 then
			M:DoTrim(self.__offset * (modKey and 10 or 1))
		else
			M:DoTrim(nil, self.__offset * (modKey and 10 or 1))
		end
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end

	for i = 1, 4 do
		arrows[i] = CreateFrame("Button", nil, frame)
		arrows[i]:SetSize(20, 20)
		B.PixelIcon(arrows[i], "Interface\\OPTIONSFRAME\\VoiceChat-Play", true)
		local arrowData = arrowIndex[i]
		arrows[i].__index = i
		arrows[i].__offset = arrowData.offset
		arrows[i]:SetScript("OnClick", arrowOnClick)
		arrows[i]:SetPoint("CENTER", arrowData.x, arrowData.y)
		arrows[i].Icon:SetPoint("TOPLEFT", 3, -3)
		arrows[i].Icon:SetPoint("BOTTOMRIGHT", -3, 3)
		arrows[i].Icon:SetRotation(math.rad(arrowData.degree))
	end

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

SlashCmdList["NDUI_MOVER"] = function()
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT)
		return
	end
	CreateConsole()
	M:UnlockElements()
end
SLASH_NDUI_MOVER1 = "/mm"
SLASH_NDUI_MOVER2 = "/mmm"

function M:OnLogin()
	updater = CreateFrame("Frame")
	updater:Hide()
	updater:SetScript("OnUpdate", function()
		M.UpdateTrimFrame(updater.__owner)
	end)
end