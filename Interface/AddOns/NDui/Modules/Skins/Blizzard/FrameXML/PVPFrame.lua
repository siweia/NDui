local _, ns = ...
local B, C, L, DB = unpack(ns)
local r, g, b = DB.r, DB.g, DB.b

tinsert(C.defaultThemes, function()
	local PVPFrame = PVPFrame
	if not PVPFrame then return end

	B.ReskinPortraitFrame(PVPFrame)
	B.Reskin(PVPFrameLeftButton)
	B.Reskin(PVPFrameRightButton)
	PVPHonorFrameBGTex:SetAlpha(0)
	B.CreateBDFrame(PVPHonorFrameInfoScrollFrame, .25)

	for i = 1, 5 do
		local tab = _G["PVPFrameTab"..i]
		if tab then
			B.ReskinTab(tab)
		end
	end

	B.StripTextures(PVPHonorFrame.bgTypeScrollBar) -- skin this would stop from queue
	B.ReskinTrimScroll(PVPHonorFrameInfoScrollFrame.ScrollBar)
	if PVPHonorFrameInfoScrollFrameScrollBar then
		PVPHonorFrameInfoScrollFrameScrollBar:SetAlpha(0)
	end

	-- WarGame
	B.StripTextures(WarGamesFrame)
	WarGamesFrameBGTex:SetAlpha(0)
	B.CreateBDFrame(WarGamesFrameInfoScrollFrame, .25)
	B.Reskin(WarGameStartButton)
	B.ReskinTrimScroll(WarGamesFrame.scrollBar)
	B.ReskinTrimScroll(WarGamesFrameInfoScrollFrame.ScrollBar)
	if WarGamesFrameInfoScrollFrameScrollBar then
		WarGamesFrameInfoScrollFrameScrollBar:SetAlpha(0)
	end

	hooksecurefunc(WarGamesFrame.scrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local button = select(i, self.ScrollTarget:GetChildren())
			if not button.styled then
				if button.NormalTexture then
					B.ReskinCollapse(button)
				end
				if button.Icon then
					button.Bg:Hide()
					button.Border:Hide()
					button:SetNormalTexture(0)
					button:SetHighlightTexture(0)
	
					local bg = B.CreateBDFrame(button, .25)
					bg:SetPoint("TOPLEFT", 2, 0)
					bg:SetPoint("BOTTOMRIGHT", -1, 2)
	
					button.SelectedTexture:SetDrawLayer("BACKGROUND")
					button.SelectedTexture:SetColorTexture(r, g, b, .25)
					button.SelectedTexture:SetInside(bg)
	
					B.ReskinIcon(button.Icon)
					button.Icon:SetPoint("TOPLEFT", 5, -3)
				end

				button.styled = true
			end
		end
	end)

	B.ReskinCheck(PVPFrame.TankIcon.checkButton)
	B.ReskinCheck(PVPFrame.HealerIcon.checkButton)
	B.ReskinCheck(PVPFrame.DPSIcon.checkButton)

	if DB.isNewPatch then
		B.StripTextures(PVPConquestFrame)
		B.StripTextures(PVPTeamManagementFrame)
		B.StripTextures(PVPTeamManagementFrameWeeklyDisplay)
	end
end)