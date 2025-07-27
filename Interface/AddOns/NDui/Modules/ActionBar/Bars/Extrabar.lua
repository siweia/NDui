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
	ExtraActionBarFrame:SetParent(frame)

	hooksecurefunc(ExtraActionBarFrame, "SetParent", function(self, parent)
		if parent == MainMenuBar then
			self:SetParent(frame)
		end
	end)

	local button = ExtraActionButton1
	tinsert(buttonList, button)
	tinsert(Bar.buttons, button)
	button:SetSize(size, size)

	frame.frameVisibility = "[extrabar] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- Extra button range, needs review
	hooksecurefunc("ActionButton_UpdateRangeIndicator", function(self, checksRange, inRange)
		if not self.action then return end
		if checksRange and not inRange then
			self.icon:SetVertexColor(.8, .1, .1)
		else
			local isUsable, notEnoughMana = IsUsableAction(self.action)
			if isUsable then
				self.icon:SetVertexColor(1, 1, 1)
			elseif notEnoughMana then
				self.icon:SetVertexColor(.5, .5, 1)
			else
				self.icon:SetVertexColor(.4, .4, .4)
			end
		end
	end)
end