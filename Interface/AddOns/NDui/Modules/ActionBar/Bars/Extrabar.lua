local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local _G = _G
local tinsert = tinsert
local padding = C.Bars.padding

function Bar:CreateExtrabar()
	local buttonList = {}
	local size = 52

	-- ExtraActionButton
	local frame = CreateFrame("Frame", "NDui_ActionBarExtra", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(size + 2*padding)
	frame:SetHeight(size + 2*padding)
	frame.mover = B.Mover(frame, L["Extrabar"], "Extrabar", {"BOTTOM", UIParent, "BOTTOM", 250, 100})

	ExtraActionBarFrame:EnableMouse(false)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint("CENTER", frame)
	ExtraActionBarFrame.ignoreFramePositionManager = true

	hooksecurefunc(ExtraActionBarFrame, "SetParent", function(self, parent)
		if parent == ExtraAbilityContainer then
			self:SetParent(frame)
		end
	end)

	local button = ExtraActionButton1
	tinsert(buttonList, button)
	tinsert(Bar.buttons, button)
	button:SetSize(size, size)

	frame.frameVisibility = "[extrabar] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- ZoneAbility
	local zoneFrame = CreateFrame("Frame", "NDui_ActionBarZone", UIParent)
	zoneFrame:SetWidth(size + 2*padding)
	zoneFrame:SetHeight(size + 2*padding)
	zoneFrame.mover = B.Mover(zoneFrame, L["Zone Ability"], "ZoneAbility", {"BOTTOM", UIParent, "BOTTOM", -250, 100})

	ZoneAbilityFrame:SetParent(zoneFrame)
	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame:SetPoint("CENTER", zoneFrame)
	ZoneAbilityFrame.ignoreFramePositionManager = true
	ZoneAbilityFrame.Style:SetAlpha(0)

	hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", function(self)
		for spellButton in self.SpellButtonContainer:EnumerateActive() do
			if spellButton and not spellButton.styled then
				spellButton.NormalTexture:SetAlpha(0)
				spellButton:SetPushedTexture(DB.pushedTex) --force it to gain a texture
				spellButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				spellButton:GetHighlightTexture():SetInside()
				spellButton.Icon:SetInside()
				B.ReskinIcon(spellButton.Icon, true)
				spellButton.styled = true
			end
		end
	end)

	-- Fix button visibility
	hooksecurefunc(ZoneAbilityFrame, "SetParent", function(self, parent)
		if parent == ExtraAbilityContainer then
			self:SetParent(zoneFrame)
		end
	end)
end