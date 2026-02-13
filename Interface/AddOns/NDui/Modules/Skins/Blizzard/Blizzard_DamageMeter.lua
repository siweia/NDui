local _, ns = ...
local B, C, L, DB = unpack(ns)

local function UpdateButtonState(button)
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

local function ReskinMeterWindow(frame)
	if not frame or frame.styled then return end

	frame.Header:SetTexture()
	local bg = B.SetBD(frame.Header)
	bg:SetPoint("TOPLEFT", frame.Header, 17, -2)
	bg:SetPoint("BOTTOMRIGHT", frame.Header, -17, 2)

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

	UpdateButtonState(frame.SettingsDropdown)
	hooksecurefunc(frame.SettingsDropdown, "OnButtonStateChanged", UpdateButtonState)

	B.ReskinTrimScroll(frame.SourceWindow.ScrollBar)
	frame.SourceWindow.Background:SetTexture()
	B.SetBD(frame.SourceWindow.Background):SetInside(nil, 2, 2)

	frame.styled = true
end

C.themes["Blizzard_DamageMeter"] = function()
	if not C.db["Skins"]["DamageMeter"] then return end

	hooksecurefunc(DamageMeter, "SetupSessionWindow", function(_, windowData)
		ReskinMeterWindow(windowData.sessionWindow)
	end)

	for i = 1, 3 do
		local frame = _G["DamageMeterSessionWindow"..i]
		if frame then
			ReskinMeterWindow(frame)
		end
	end
end