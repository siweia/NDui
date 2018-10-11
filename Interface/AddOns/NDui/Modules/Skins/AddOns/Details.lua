local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Skins")

local function ReskinDetails()
	LibStub("LibSharedMedia-3.0"):Register("statusbar", "normTex", DB.normTex)

	if NDuiADB["ResetDetails"] == nil then NDuiADB["ResetDetails"] = true end

	local function createToggle(instance)
		local frame = instance.baseframe

		local close = B.CreateButton(frame, 20, 80, ">", 18)
		close:SetPoint("RIGHT", frame, "LEFT", -2, 0)
		B.CreateSD(close)
		B.CreateTex(close)
		local open = B.CreateButton(UIParent, 20, 80, "<", 18)
		open:Hide()
		open:SetPoint("RIGHT", frame, "RIGHT", 2, 0)
		B.CreateSD(open)
		B.CreateTex(open)

		close:SetScript("OnClick", function()
			open:Show()
			instance:HideWindow()
		end)
		open:SetScript("OnClick", function()
			open:Hide()
			instance:ShowWindow()
		end)
	end

	local function setupInstance(instance)
		if instance.styled then return end

		instance:ChangeSkin("Minimalistic")
		instance:InstanceWallpaper(false)
		instance:DesaturateMenu(true)
		instance:SetBackdropTexture("None")
		instance:AttributeMenu(true, nil, nil, DB.Font[1], 13, {1, 1, 1}, 1, true)
		instance:SetBarSettings(18, NDuiADB["ResetDetails"] and "normTex" or nil)
		instance:SetBarTextSettings(13, DB.Font[1], nil, nil, nil, true, true)

		local bg = B.CreateBG(instance.baseframe)
		bg:SetPoint("TOPLEFT", -1, 18)
		B.CreateBD(bg)
		B.CreateSD(bg)
		B.CreateTex(bg)

		if instance:GetId() <= 2 then
			createToggle(instance)
		end

		instance.styled = true
	end

	local index = 1
	local instance = Details:GetInstance(index)
	while instance do
		setupInstance(instance)
		index = index + 1
		instance = Details:GetInstance(index)
	end

	-- Reanchor
	local instance1 = Details:GetInstance(1)
	local instance2 = Details:GetInstance(2)

	local function EmbedWindow(instance, x, y, width, height)
		instance.baseframe:ClearAllPoints()
		instance.baseframe:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", x, y)
		instance:SetSize(width, height)
		instance:SaveMainWindowPosition()
		instance:RestoreMainWindowPosition()
		instance:LockInstance(true)
	end

	if NDuiADB["ResetDetails"] then
		EmbedWindow(instance1, -3, 25, 320, 190)
		if instance2 then
			instance1:SetSize(320, 95)
			EmbedWindow(instance2, -3, 140, 320, 95)
		end
	end

	local listener = Details:CreateEventListener()
	listener:RegisterEvent("DETAILS_INSTANCE_OPEN")
	function listener:OnDetailsEvent(_, instance)
		setupInstance(instance)

		if instance:GetId() == 2 then
			instance1:SetSize(320, 95)
			EmbedWindow(instance, -3, 140, 320, 95)
		end
	end

	-- Numberize
	local _detalhes = _G._detalhes
	local current = NDuiDB["Settings"]["Format"]
	if current < 3 then
		_detalhes.numerical_system = current
		_detalhes:SelectNumericalSystem()
	end

	NDuiADB["ResetDetails"] = false
end

module:LoadWithAddOn("Details", "Details", ReskinDetails)