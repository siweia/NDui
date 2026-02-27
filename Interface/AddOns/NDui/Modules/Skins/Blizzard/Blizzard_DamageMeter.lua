local _, ns = ...
local B, C, L, DB = unpack(ns)

local function updateButtonState(button)
	button.Icon:SetTexture("Interface\\WorldMap\\GEAR_64GREY")
	button.Icon:SetInside(nil, 2, 2)
	if button:IsOver() then
		button.Icon:SetVertexColor(1, .8, 0)
	else
		button.Icon:SetVertexColor(1, 1, 1)
	end
end

local function updateBGAlpha(self, alpha)
	self.bg:SetAlpha(alpha)
end

local function updateBar(frame)
	local bar = frame.StatusBar
	if not bar then return end

	if not bar.styled then
		B.CreateBDFrame(bar, .25)
		bar:GetStatusBarTexture():ClearTextureSlice()
		bar:SetStatusBarTexture(DB.normTex)
		bar:DisableDrawLayer("BACKGROUND")
		bar.styled = true
	end
	if bar.BackgroundEdge then
		bar.BackgroundEdge:Hide()
	end
end

local function updateBox(self)
	self:ForEachFrame(updateBar)
end

local function ReskinMeterWindow(frame)
	if not frame or frame.styled then return end

	frame:SetClampedToScreen(false)
	frame.Header:SetTexture()
	local bg = B.SetBD(frame.Header)
	bg:SetPoint("TOPLEFT", frame.Header, 17, -2)
	bg:SetPoint("BOTTOMRIGHT", frame.Header, -17, 2)

	B.ReskinTrimScroll(frame.ScrollBar)
	frame.ScrollBox:ForEachFrame(updateBar)
	hooksecurefunc(frame.ScrollBox, "Update", updateBox)

	local background = frame.Background
	if background then
		background:SetTexture()
		background.bg = B.SetBD(background, 1)
		background.bg:SetPoint("TOPLEFT", bg, "BOTTOMLEFT", 0, -2)
		background.bg:SetPoint("BOTTOMRIGHT", background, -7, 0)
		updateBGAlpha(background, background:GetAlpha())
		hooksecurefunc(background, "SetAlpha", updateBGAlpha)
	end
	B.ReskinDropDown(frame.DamageMeterTypeDropdown)
	B.Reskin(frame.SessionDropdown)
	frame.SessionDropdown:SetSize(60, 22)
	frame.SessionDropdown:SetPoint("RIGHT", frame.SettingsDropdown, "LEFT", -8, 0)
	frame.SessionDropdown.Text:SetAlpha(0)

	updateButtonState(frame.SettingsDropdown)
	hooksecurefunc(frame.SettingsDropdown, "OnButtonStateChanged", updateButtonState)

	B.ReskinTrimScroll(frame.SourceWindow.ScrollBar)
	frame.SourceWindow.Background:SetTexture()
	B.SetBD(frame.SourceWindow.Background):SetInside(nil, 2, 2)
	frame.SourceWindow.ScrollBox:ForEachFrame(updateBar)
	hooksecurefunc(frame.SourceWindow.ScrollBox, "Update", updateBox)

	local localEntry = frame.LocalPlayerEntry
	if localEntry then
		updateBar(localEntry)
	end

	frame.styled = true
end

C.themes["Blizzard_DamageMeter"] = function()
	if not C.db["Skins"]["DamageMeter"] then return end

	C_Timer.After(1, function() -- delay to prevent taint
		hooksecurefunc(DamageMeter, "SetupSessionWindow", function(_, windowData)
			ReskinMeterWindow(windowData.sessionWindow)
		end)

		for i = 1, 3 do
			local frame = _G["DamageMeterSessionWindow"..i]
			if frame then
				ReskinMeterWindow(frame)
			end
		end

		DamageMeter:SetClampedToScreen(false)
	end)
end