local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")
local iconSize = 40

local colorTable = {
	summon                = DB.QualityColors[1],
	[_G.EARTH_TOTEM_SLOT] = DB.QualityColors[2],
	[_G.FIRE_TOTEM_SLOT]  = DB.QualityColors[5],
	[_G.WATER_TOTEM_SLOT] = DB.QualityColors[3],
	[_G.AIR_TOTEM_SLOT]   = DB.QualityColors[4],
}

local function reskinTotemButton(button, nobg, uncut)
	B.StripTextures(button, 1)
	button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

	local icon = button:GetRegions()
	if not button.icon then button.icon = icon end
	if not uncut then
		icon:SetTexCoord(unpack(DB.TexCoord))
	end
	if not nobg then
		button.bg = B.SetBD(icon)
	end
end

local function reskinTotemArrow(button, direction)
	B.Reskin(button)
	button:SetWidth(iconSize + C.mult*2)

	local tex = button:CreateTexture(nil, "ARTWORK")
	tex:SetSize(22, 22)
	tex:SetPoint("CENTER")
	B.SetupArrow(tex, direction)
	button.__texture = tex
	button:HookScript("OnEnter", B.Texture_OnEnter)
	button:HookScript("OnLeave", B.Texture_OnLeave)
end
-- TODO: Add custom options
function Bar:TotemBar()
	if DB.MyClass ~= "SHAMAN" then return end
	if not C.db["Actionbar"]["TotemBar"] then return end

	local margin = 5
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(iconSize*6 + margin*7, iconSize + margin*2)
	frame:SetPoint("CENTER")
	B.Mover(frame, L["TotemBar"], "TotemBar", {"BOTTOM", UIParent, 0, 275})

	MultiCastActionBarFrame:SetParent(frame)
	MultiCastActionBarFrame.SetParent = B.Dummy
	MultiCastActionBarFrame:ClearAllPoints()
	MultiCastActionBarFrame:SetPoint("CENTER")
	MultiCastActionBarFrame.SetPoint = B.Dummy
	MultiCastActionBarFrame:SetScript('OnUpdate', nil)
	MultiCastActionBarFrame:SetScript('OnShow', nil)
	MultiCastActionBarFrame:SetScript('OnHide', nil)

	reskinTotemButton(MultiCastSummonSpellButton)
	MultiCastSummonSpellButton:SetSize(iconSize, iconSize)
	reskinTotemButton(MultiCastRecallSpellButton)
	MultiCastRecallSpellButton:SetSize(iconSize, iconSize)

	for i = 1, 4 do
		local button = _G["MultiCastSlotButton"..i]
		reskinTotemButton(button)
		button:SetSize(iconSize, iconSize)
	end

	for i = 1, 12 do
		reskinTotemButton(_G["MultiCastActionButton"..i], true)
	end

	hooksecurefunc("MultiCastSlotButton_Update", function(button, slot)
		local color = colorTable[slot]
		if color then
			button.bg:SetBackdropBorderColor(color.r, color.g, color.b)
		end
	end)

	hooksecurefunc("MultiCastActionButton_Update", function(button, _, _, slot)
		button:ClearAllPoints()
		button:SetAllPoints(button.slotButton)
	end)

	B.StripTextures(MultiCastFlyoutFrame)
	reskinTotemArrow(MultiCastFlyoutFrameOpenButton, "up")
	reskinTotemArrow(MultiCastFlyoutFrameCloseButton, "down")

	hooksecurefunc(MultiCastFlyoutFrame, "SetHeight", function(frame, height, force)
		if force then return end
		local count = 0
		for i = 1, #frame.buttons do
			if frame.buttons[i]:IsShown() then
				count = count + 1
			end
		end
		frame:SetHeight(count*(iconSize+2) + 22, true)
	end)

	hooksecurefunc("MultiCastFlyoutFrame_ToggleFlyout", function(frame, type, parent)
		for i = 1, #frame.buttons do
			local button = frame.buttons[i]
			if not button.bg then
				reskinTotemButton(button, nil, true)
				button:SetSize(iconSize, iconSize)
			end
			if not (type == "slot" and i == 1) then
				button.icon:SetTexCoord(unpack(DB.TexCoord))
			end
			local color = type == "page" and colorTable.summon or colorTable[parent:GetID()]
			button.bg:SetBackdropBorderColor(color.r, color.g, color.b)
		end
	end)

	local buttonList = {
		MultiCastSummonSpellButton,
		MultiCastSlotButton1,
		MultiCastSlotButton2,
		MultiCastSlotButton3,
		MultiCastSlotButton4,
		MultiCastRecallSpellButton,
	}
	for i, button in pairs(buttonList) do
		button:ClearAllPoints()
		button:SetPoint("LEFT", frame, margin + (iconSize+margin)*(i-1), 0)
		button.SetPoint = B.Dummy
	end
end