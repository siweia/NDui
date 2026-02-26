local _, ns = ...
local B, C, L, DB = unpack(ns)

local function reskinTab(tab)
	if not tab then return end
	B.StripTextures(tab, 0)
	B.ReskinTab(tab)
	tab.bg:SetInside()
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end
	if not CompactRaidFrameManager then return end

	local buttonForward = CompactRaidFrameManagerToggleButtonForward
	local buttonBack = CompactRaidFrameManagerToggleButtonBack

	buttonForward:GetNormalTexture():SetAlpha(0)
	B.ReskinArrow(buttonForward, "right")
	buttonBack:GetNormalTexture():SetAlpha(0)
	B.ReskinArrow(buttonBack, "left")

	B.ReskinDropDown(CompactRaidFrameManagerDisplayFrameModeControlDropdown)
	B.ReskinDropDown(CompactRaidFrameManagerDisplayFrameRestrictPingsDropdown)
	B.Reskin(CompactRaidFrameManagerLeavePartyButton)
	B.Reskin(CompactRaidFrameManagerLeaveInstanceGroupButton)
	CompactRaidFrameManagerDisplayFrameRaidMarkers.BG:SetAlpha(0)

	reskinTab(CompactRaidFrameManagerDisplayFrameRaidMarkersRaidMarkerUnitTab)
	reskinTab(CompactRaidFrameManagerDisplayFrameRaidMarkersRaidMarkerGroundTab)

	for _, button in pairs({CompactRaidFrameManagerDisplayFrameRaidMarkers:GetChildren()}) do
		if button:IsObjectType("Button") and button:GetHeight() > 20 then
			B.Reskin(button)
			button.__bg:SetInside(button, 2, 2)
			if button.backgroundTexture then button.backgroundTexture:SetAlpha(0) end
		end
	end

	B.StripTextures(CompactRaidFrameManager, 0)
	select(1, CompactRaidFrameManagerDisplayFrame:GetRegions()):SetAlpha(0)

	local bd = B.SetBD(CompactRaidFrameManager)
	bd:SetPoint("TOPLEFT")
	bd:SetPoint("BOTTOMRIGHT", -9, 9)
	B.ReskinCheck(CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton)
end)