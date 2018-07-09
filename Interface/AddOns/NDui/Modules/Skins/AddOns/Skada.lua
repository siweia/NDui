local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Skins")

function module:SkadaSkin()
	if not NDuiDB["Skins"]["Skada"] then return end
	if not IsAddOnLoaded("Skada") then return end

	local Skada = Skada
	local barSpacing = 0
	local barmod = Skada.displays["bar"]
	local function StripOptions(options)
		options.baroptions.args.barspacing = nil
		options.titleoptions.args.texture = nil
		options.titleoptions.args.bordertexture = nil
		options.titleoptions.args.thickness = nil
		options.titleoptions.args.margin = nil
		options.titleoptions.args.color = nil
		options.windowoptions = nil
		options.baroptions.args.barfont = nil
		options.titleoptions.args.font = nil
	end

	barmod.AddDisplayOptions_ = barmod.AddDisplayOptions
	barmod.AddDisplayOptions = function(self, win, options)
		self:AddDisplayOptions_(win, options)
		StripOptions(options)
	end

	for _, options in pairs(Skada.options.args.windows.args) do
		if options.type == "group" then
			StripOptions(options.args)
		end
	end

	barmod.ApplySettings_ = barmod.ApplySettings
	barmod.ApplySettings = function(self, win)
		barmod.ApplySettings_(self, win)
		local skada = win.bargroup
		if win.db.enabletitle then
			skada.button:SetBackdrop(nil)
		end
		skada:SetSpacing(barSpacing)
		skada:SetFrameLevel(5)
		skada.SetFrameLevel = B.Dummy
		skada:SetBackdrop(nil)

		win.bargroup.button:SetBackdropColor(1, 1, 1, 0)

		if not skada.shadow then
			skada.shadow = B.CreateBG(skada)
			skada.shadow:SetAllPoints()
			skada.shadow:SetFrameLevel(1)
			B.CreateBD(skada.shadow, .5, 3)
			B.CreateTex(skada.shadow)

			local Cskada = B.CreateButton(skada, 20, 80, ">", 18)
			Cskada:SetPoint("RIGHT", skada, "LEFT", 0, 0)
			B.CreateTex(Cskada)
			local Oskada = B.CreateButton(UIParent, 20, 80, "<", 18)
			Oskada:Hide()
			Oskada:SetPoint("RIGHT", skada, "RIGHT", 5, 0)
			B.CreateTex(Oskada)
			Cskada:SetScript("OnClick", function()
				Oskada:Show()
				skada:Hide()
			end)
			Oskada:SetScript("OnClick", function()
				Oskada:Hide()
				skada:Show()
			end)
		end
		skada.shadow:ClearAllPoints()
		if win.db.enabletitle then
			skada.shadow:SetPoint("TOPLEFT", win.bargroup.button, "TOPLEFT", -3, 3)
		else
			skada.shadow:SetPoint("TOPLEFT", win.bargroup, "TOPLEFT", -3, 3)
		end
		skada.shadow:SetPoint("BOTTOMRIGHT", win.bargroup, "BOTTOMRIGHT", 3, -3)
		win.bargroup.button:SetFrameStrata("MEDIUM")
		win.bargroup.button:SetFrameLevel(5)	
		win.bargroup:SetFrameStrata("MEDIUM")
	end

	local function EmbedWindow(window, width, barheight, height, point, relativeFrame, relativePoint, ofsx, ofsy)
		window.db.barwidth = width
		window.db.barheight = barheight
		if window.db.enabletitle then 
			height = height - barheight
		end
		window.db.background.height = height
		window.db.spark = false
		window.db.barslocked = true
		window.bargroup:ClearAllPoints()
		window.bargroup:SetPoint(point, relativeFrame, relativePoint, ofsx, ofsy)
		barmod.ApplySettings(barmod, window)
	end

	local windows = {}
	local function EmbedSkada()
		if #windows == 1 then
			EmbedWindow(windows[1], 320, 18, 198, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -3, 26)
		elseif #windows == 2 then
			EmbedWindow(windows[1], 320, 18, 109,  "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -3, 141)
			EmbedWindow(windows[2], 320, 18, 109,  "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -3, 26)
		end
	end

	for _, window in ipairs(Skada:GetWindows()) do
		window:UpdateDisplay()
	end

	Skada.CreateWindow_ = Skada.CreateWindow
	function Skada:CreateWindow(name, db)
		Skada:CreateWindow_(name, db)
		wipe(windows)
		for _, window in ipairs(Skada:GetWindows()) do
			tinsert(windows, window)
		end
		EmbedSkada()
	end

	Skada.DeleteWindow_ = Skada.DeleteWindow
	function Skada:DeleteWindow(name)
		Skada:DeleteWindow_(name)
		wipe(windows)
		for _, window in ipairs(Skada:GetWindows()) do
			tinsert(windows, window)
		end
		EmbedSkada()
	end

	EmbedSkada()

	-- Change Skada Default Settings
	LibStub("LibSharedMedia-3.0"):Register("statusbar", "normTex", DB.normTex)
	Skada.windowdefaults.bartexture = "normTex"
	Skada.windowdefaults.classicons = false
	Skada.windowdefaults.title.fontflags = "OUTLINE"
	Skada.windowdefaults.title.fontsize = 14
	Skada.windowdefaults.title.color = {r=0,g=0,b=0,a=.3}
	Skada.windowdefaults.barfontflags = "OUTLINE"
	Skada.windowdefaults.barfontsize = 15
	Skada.windowdefaults.barbgcolor = {r=0,g=0,b=0,a=0}

	-- Change Skada NumberFormat
	Skada.options.args.generaloptions.args.numberformat = nil

	function Skada:FormatNumber(number)
		if number then return B.Numb(number) end
	end
end