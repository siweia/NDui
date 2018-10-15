local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Skins")

local function ReskinDetails()
	LibStub("LibSharedMedia-3.0"):Register("statusbar", "normTex", DB.normTex)

	local function setupInstance(instance)
		if instance.styled then return end
		if not instance.baseframe then return end

		instance:ChangeSkin("Minimalistic")
		instance:InstanceWallpaper(false)
		instance:DesaturateMenu(true)
		instance:HideMainIcon(false)
		instance:SetBackdropTexture("None")
		instance:MenuAnchor(16, 3)
		instance:ToolbarMenuButtonsSize(1)
		instance:AttributeMenu(true, 0, 3, DB.Font[1], 13, {1, 1, 1}, 1, true)
		instance:SetBarSettings(18, NDuiADB["ResetDetails"] and "normTex" or nil)
		instance:SetBarTextSettings(13, DB.Font[1], nil, nil, nil, true, true, nil, nil, nil, nil, nil, nil, false, nil, false, nil)

		local bg = B.CreateBG(instance.baseframe)
		bg:SetPoint("TOPLEFT", -1, 18)
		B.CreateBD(bg)
		B.CreateSD(bg)
		B.CreateTex(bg)
		instance.baseframe.bg = bg

		if instance:GetId() <= 2 then
			local open, close = module:CreateToggle(instance.baseframe)
			open:HookScript("OnClick", function()
				instance:ShowWindow()
			end)
			close:HookScript("OnClick", function()
				instance:HideWindow()
			end)
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
	function listener:OnDetailsEvent(event, instance)
		if event == "DETAILS_INSTANCE_OPEN" then
			setupInstance(instance)

			if instance:GetId() == 2 then
				instance1:SetSize(320, 95)
				EmbedWindow(instance, -3, 140, 320, 95)
			end
		end
	end

	-- Numberize
	local _detalhes = _G._detalhes
	local current = NDuiADB["NumberFormat"]
	if current < 3 then
		_detalhes.numerical_system = current
		_detalhes:SelectNumericalSystem()
	end

	NDuiADB["ResetDetails"] = false
end

module:LoadWithAddOn("Details", "Details", ReskinDetails)