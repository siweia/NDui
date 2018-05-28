local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	-- PvP score frame

	select(2, WorldStateScoreScrollFrame:GetRegions()):Hide()
	select(3, WorldStateScoreScrollFrame:GetRegions()):Hide()

	WorldStateScoreFrameTab1:ClearAllPoints()
	WorldStateScoreFrameTab1:SetPoint("TOPLEFT", WorldStateScoreFrame, "BOTTOMLEFT", 5, 2)
	WorldStateScoreFrameTab2:SetPoint("LEFT", WorldStateScoreFrameTab1, "RIGHT", -15, 0)
	WorldStateScoreFrameTab3:SetPoint("LEFT", WorldStateScoreFrameTab2, "RIGHT", -15, 0)
	WorldStateScoreFrame.XPBar.Frame:Hide()

	for i = 1, 3 do
		F.ReskinTab(_G["WorldStateScoreFrameTab"..i])
	end

	F.ReskinPortraitFrame(WorldStateScoreFrame, true)
	F.Reskin(WorldStateScoreFrameQueueButton)
	F.Reskin(WorldStateScoreFrameLeaveButton)
	F.ReskinScroll(WorldStateScoreScrollFrameScrollBar)

	-- Capture bar

	hooksecurefunc("UIParent_ManageFramePositions", function()
		if not NUM_EXTENDED_UI_FRAMES then return end
		for i = 1, NUM_EXTENDED_UI_FRAMES do
			local bar = _G["WorldStateCaptureBar"..i]
			if bar and bar:IsVisible() then
				bar:ClearAllPoints()
				bar:SetPoint("TOP", UIParent, "TOP", 0, -120)

				if not bar.skinned then
					bar.BarBackground:Hide()

					local bg = F.CreateBDFrame(bar)
					bg:SetPoint("TOPLEFT", 25, -7)
					bg:SetPoint("BOTTOMRIGHT", -25, 7)

					local left = bar:CreateTexture()
					left:SetTexture("Interface\\WorldStateFrame\\AllianceFlag")
					left:SetPoint("LEFT", -5, 0)
					left:SetSize(32, 32)
					bar.newLeftFaction = left

					local right = bar:CreateTexture()
					right:SetTexture("Interface\\WorldStateFrame\\HordeFlag")
					right:SetPoint("RIGHT", 5, 0)
					right:SetSize(32, 32)
					bar.newRightFaction = right

					bar.RightLine:SetColorTexture(0, 0, 0)
					bar.RightLine:SetSize(2, 9)
					bar.LeftLine:SetColorTexture(0, 0, 0)
					bar.LeftLine:SetSize(2, 9)

					bar.LeftIconHighlight:SetTexture("Interface\\WorldStateFrame\\HordeFlagFlash")
					bar.LeftIconHighlight:SetAllPoints(left)
					bar.RightIconHighlight:SetTexture("Interface\\WorldStateFrame\\HordeFlagFlash")
					bar.RightIconHighlight:SetAllPoints(right)

					bar.skinned = true
				end
			end
		end
	end)
--[[
	hooksecurefunc(ExtendedUI["CAPTUREPOINT"], "update", function(id)
		local bar = _G["WorldStateCaptureBar"..id]
		if not (bar.newLeftFaction and bar.newRightFaction) then return end

		if bar.style == "LFD_BATTLEFIELD" then
			bar.newLeftFaction:SetTexture("Interface\\WorldStateFrame\\ColumnIcon-FlagCapture2")
			bar.newRightFaction:SetTexture("Interface\\WorldStateFrame\\ColumnIcon-FlagCapture2")
			bar.newRightFaction:SetDesaturated(true)
			bar.newRightFaction:SetVertexColor(.75, .5, 1)
		else
			bar.newLeftFaction:SetTexture("Interface\\WorldStateFrame\\AllianceFlag")
			bar.newRightFaction:SetTexture("Interface\\WorldStateFrame\\HordeFlag")
			bar.newRightFaction:SetDesaturated(false)
			bar.newRightFaction:SetVertexColor(1, 1, 1)
		end
	end)]]
end)