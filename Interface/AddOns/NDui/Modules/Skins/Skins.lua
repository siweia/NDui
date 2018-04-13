local B, C, L, DB = unpack(select(2, ...))
local module = NDui:RegisterModule("Skins")

function module:OnLogin()
	local cr, cg, cb = 0, 0, 0
	if NDuiDB["Skins"]["ClassLine"] then cr, cg, cb = DB.cc.r, DB.cc.g, DB.cc.b end

	-- TOPLEFT
	if NDuiDB["Skins"]["InfobarLine"] then
		local Tinfobar = CreateFrame("Frame", nil, UIParent)
		Tinfobar:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, -3)
		B.CreateGF(Tinfobar, 600, 18, "Horizontal", 0, 0, 0, .5, 0)
		local Tinfobar1 = CreateFrame("Frame", nil, Tinfobar)
		Tinfobar1:SetPoint("BOTTOM", Tinfobar, "TOP")
		B.CreateGF(Tinfobar1, 600, 1, "Horizontal", cr, cg, cb, .7, 0)
		local Tinfobar2 = CreateFrame("Frame", nil, Tinfobar)
		Tinfobar2:SetPoint("TOP", Tinfobar, "BOTTOM")
		B.CreateGF(Tinfobar2, 600, 1, "Horizontal", cr, cg, cb, .7, 0)
	end

	-- BOTTOMLEFT
	if NDuiDB["Skins"]["ChatLine"] then
		local Linfobar = CreateFrame("Frame", nil, UIParent)
		Linfobar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 3)
		B.CreateGF(Linfobar, 453, ChatFrame1:GetHeight() + 30, "Horizontal", 0, 0, 0, .5, 0)
		local Linfobar1 = CreateFrame("Frame", nil, Linfobar)
		Linfobar1:SetPoint("BOTTOM", Linfobar, "TOP")
		B.CreateGF(Linfobar1, 453, 1, "Horizontal", cr, cg, cb, .7, 0)
		local Linfobar2 = CreateFrame("Frame", nil, Linfobar)
		Linfobar2:SetPoint("BOTTOM", Linfobar, "BOTTOM", 0, 18)
		B.CreateGF(Linfobar2, 453, 1, "Horizontal", cr, cg, cb, .7, 0)
		local Linfobar3 = CreateFrame("Frame", nil, Linfobar)
		Linfobar3:SetPoint("TOP", Linfobar, "BOTTOM")
		B.CreateGF(Linfobar3, 453, 1, "Horizontal", cr, cg, cb, .7, 0)
		ChatFrame1Tab:HookScript("OnMouseUp", function(_, btn)
			if btn == "LeftButton" then
				Linfobar:SetHeight(ChatFrame1:GetHeight() + 30)
			end
		end)
	end

	-- BOTTOMRIGHT
	if NDuiDB["Skins"]["InfobarLine"] then
		local Rinfobar = CreateFrame("Frame", nil, UIParent)
		Rinfobar:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 3)
		B.CreateGF(Rinfobar, 450, 18, "Horizontal", 0, 0, 0, 0, .5)
		local Rinfobar1 = CreateFrame("Frame", nil, Rinfobar)
		Rinfobar1:SetPoint("BOTTOM", Rinfobar, "TOP")
		B.CreateGF(Rinfobar1, 450, 1, "Horizontal", cr, cg, cb, 0, .7)
		local Rinfobar2 = CreateFrame("Frame", nil, Rinfobar)
		Rinfobar2:SetPoint("TOP", Rinfobar, "BOTTOM")
		B.CreateGF(Rinfobar2, 450, 1, "Horizontal", cr, cg, cb, 0, .7)
	end

	-- MICROMENU
	if NDuiDB["Skins"]["MenuLine"] then
		local mmbottomL = CreateFrame("Frame", nil, UIParent)
		mmbottomL:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", 0, 3)
		B.CreateGF(mmbottomL, 230, 1, "Horizontal", cr, cg, cb, 0, .7)
		local mmbottomR = CreateFrame("Frame", nil, UIParent)
		mmbottomR:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 0, 3)
		B.CreateGF(mmbottomR, 230, 1, "Horizontal", cr, cg, cb, .7, 0)

		local mmtopL = CreateFrame("Frame", nil, UIParent)
		mmtopL:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", 0, 24)
		B.CreateGF(mmtopL, 260, 1, "Horizontal", cr, cg, cb, 0, .7)
		local mmtopR = CreateFrame("Frame", nil, UIParent)
		mmtopR:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 0, 24)
		B.CreateGF(mmtopR, 260, 1, "Horizontal", cr, cg, cb, .7, 0)
	end

	-- ACTIONBAR
	local basic = 94
	if NDuiDB["Actionbar"]["Style"] == 4 then basic = 130 end

	if NDuiDB["Skins"]["BarLine"] then
		local MactionbarL = CreateFrame("Frame", nil, UIParent)
		MactionbarL:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", 0, 4)
		B.CreateGF(MactionbarL, 250, basic, "Horizontal", 0, 0, 0, 0, .5)
		local MactionbarL1 = CreateFrame("Frame", nil, MactionbarL)
		MactionbarL1:SetPoint("BOTTOMRIGHT", MactionbarL, "TOPRIGHT")
		B.CreateGF(MactionbarL1, 230, 1, "Horizontal", cr, cg, cb, 0, .7)
		RegisterStateDriver(MactionbarL, "visibility", "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists] hide; show")

		local MactionbarR = CreateFrame("Frame", nil, UIParent)
		MactionbarR:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 0, 4)
		B.CreateGF(MactionbarR, 250, basic, "Horizontal", 0, 0, 0, .5, 0)
		local MactionbarR1 = CreateFrame("Frame", nil, MactionbarR)
		MactionbarR1:SetPoint("BOTTOMLEFT", MactionbarR, "TOPLEFT")
		B.CreateGF(MactionbarR1, 230, 1, "Horizontal", cr, cg, cb, .7, 0)
		RegisterStateDriver(MactionbarR, "visibility", "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists] hide; show")

		-- OVERRIDEBAR
		local OverbarL = CreateFrame("Frame", nil, UIParent)
		OverbarL:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", 0, 4)
		B.CreateGF(OverbarL, 200, 57, "Horizontal", 0, 0, 0, 0, .5)
		local OverbarL1 = CreateFrame("Frame", nil, OverbarL)
		OverbarL1:SetPoint("BOTTOMRIGHT", OverbarL, "TOPRIGHT")
		B.CreateGF(OverbarL1, 200, 1, "Horizontal", cr, cg, cb, 0, .7)
		RegisterStateDriver(OverbarL, "visibility", "[petbattle]hide; [overridebar][vehicleui][possessbar,@vehicle,exists] show; hide")

		local OverbarR = CreateFrame("Frame", nil, UIParent)
		OverbarR:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 0, 4)
		B.CreateGF(OverbarR, 200, 57, "Horizontal", 0, 0, 0, .5, 0)
		local OverbarR1 = CreateFrame("Frame", nil, OverbarR)
		OverbarR1:SetPoint("BOTTOMLEFT", OverbarR, "TOPLEFT")
		B.CreateGF(OverbarR1, 200, 1, "Horizontal", cr, cg, cb, .7, 0)
		RegisterStateDriver(OverbarR, "visibility", "[petbattle]hide; [overridebar][vehicleui][possessbar,@vehicle,exists] show; hide")
	end

	-- Add Skins
	self:MicroMenu()
	self:CreateRM()
	self:FontStyle()
	self:QuestTracker()
	self:PetBattleUI()

	self:DBMSkin()
	self:ExtraCDSkin()
	self:RCLootCoucil()
	self:SkadaSkin()
	self:BigWigsSkin()
end

function module:LoadWithAddOn(addonName, value, func)
	NDui:EventFrame{"ADDON_LOADED", "PLAYER_ENTERING_WORLD"}:SetScript("OnEvent", function(self, event, addon)
		if not NDuiDB["Skins"][value] then
			self:UnregisterAllEvents()
			return
		end

		if event == "PLAYER_ENTERING_WORLD" then
			self:UnregisterEvent(event)
			if IsAddOnLoaded(addonName) then
				func()
				self:UnregisterAllEvents()
			end
		elseif event == "ADDON_LOADED" and addon == addonName then
			func()
			self:UnregisterAllEvents()
		end
	end)
end