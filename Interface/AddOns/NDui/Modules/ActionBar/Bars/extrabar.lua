local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")
local cfg = C.bars.extrabar

function Bar:CreateExtrabar()
	local padding, margin = 10, 5
	local num = 1
	local buttonList = {}

	--create the frame to hold the buttons
	local frame = CreateFrame("Frame", "NDui_ActionBarExtra", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num*cfg.size + (num-1)*margin + 2*padding)
	frame:SetHeight(cfg.size + 2*padding)
	frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 250, 100}

	--move the buttons into position and reparent them
	ExtraActionBarFrame:SetParent(frame)
	ExtraActionBarFrame:EnableMouse(false)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint("CENTER", 0, 0)
	ExtraActionBarFrame.ignoreFramePositionManager = true

	--the extra button
	local button = ExtraActionButton1
	table.insert(buttonList, button) --add the button object to the list
	button:SetSize(cfg.size, cfg.size)

	--show/hide the frame on a given state driver
	frame.frameVisibility = "[extrabar] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	--create drag frame and drag functionality
	if C.bars.userplaced then
		frame.mover = B.Mover(frame, L["Extrabar"], "Extrabar", frame.Pos)
	end

	--create the mouseover functionality
	if cfg.fader then
		Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end

	--zone ability
	local zoneFrame = CreateFrame("Frame", "NDui_ActionBarZone", UIParent)
	zoneFrame:SetWidth(cfg.size + 2*padding)
	zoneFrame:SetHeight(cfg.size + 2*padding)
	zoneFrame.Pos = {"BOTTOM", UIParent, "BOTTOM", -250, 100}

	ZoneAbilityFrame:SetParent(zoneFrame)
	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame:SetPoint("CENTER", 0, 0)
	ZoneAbilityFrame.ignoreFramePositionManager = true
	ZoneAbilityFrameNormalTexture:SetAlpha(0)
	zoneFrame.mover = B.Mover(ZoneAbilityFrame, L["Zone Ability"], "ZoneAbility", zoneFrame.Pos)

	local spellButton = ZoneAbilityFrame.SpellButton
	spellButton.Style:SetAlpha(0)
	spellButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	B.ReskinIcon(spellButton.Icon, true)
end