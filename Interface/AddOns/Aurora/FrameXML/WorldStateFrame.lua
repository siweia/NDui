local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	-- PvP score frame

	select(2, WorldStateScoreScrollFrame:GetRegions()):Hide()
	select(3, WorldStateScoreScrollFrame:GetRegions()):Hide()

	WorldStateScoreFrameTab1:ClearAllPoints()
	WorldStateScoreFrameTab1:SetPoint("TOPLEFT", WorldStateScoreFrame, "BOTTOMLEFT", 5, 2)
	WorldStateScoreFrameTab2:SetPoint("LEFT", WorldStateScoreFrameTab1, "RIGHT", -15, 0)
	WorldStateScoreFrameTab3:SetPoint("LEFT", WorldStateScoreFrameTab2, "RIGHT", -15, 0)

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
			local barname = "WorldStateCaptureBar"..i
			local bar = _G[barname]

			if bar and bar:IsVisible() then
				bar:ClearAllPoints()
				bar:SetPoint("TOP", UIParent, "TOP", 0, -120)
				if not bar.skinned then
					local left = _G[barname.."LeftBar"]
					local right = _G[barname.."RightBar"]
					local middle = _G[barname.."MiddleBar"]

					left:SetTexture(C.media.backdrop)
					right:SetTexture(C.media.backdrop)
					middle:SetTexture(C.media.backdrop)
					left:SetDrawLayer("BORDER")
					middle:SetDrawLayer("ARTWORK")
					right:SetDrawLayer("BORDER")

					left:SetGradient("VERTICAL", .1, .4, .9, .2, .6, 1)
					right:SetGradient("VERTICAL", .7, .1, .1, .9, .2, .2)
					middle:SetGradient("VERTICAL", .8, .8, .8, 1, 1, 1)

					_G[barname.."RightLine"]:SetAlpha(0)
					_G[barname.."LeftLine"]:SetAlpha(0)
					select(4, bar:GetRegions()):Hide()
					_G[barname.."LeftIconHighlight"]:SetAlpha(0)
					_G[barname.."RightIconHighlight"]:SetAlpha(0)

					bar.bg = bar:CreateTexture(nil, "BACKGROUND")
					bar.bg:SetPoint("TOPLEFT", left, -1, 1)
					bar.bg:SetPoint("BOTTOMRIGHT", right, 1, -1)
					bar.bg:SetTexture(C.media.backdrop)
					bar.bg:SetVertexColor(0, 0, 0)

					bar.bgmiddle = CreateFrame("Frame", nil, bar)
					bar.bgmiddle:SetPoint("TOPLEFT", middle, -1, 1)
					bar.bgmiddle:SetPoint("BOTTOMRIGHT", middle, 1, -1)
					F.CreateBD(bar.bgmiddle, 0)

					bar.skinned = true
				end
			end
		end
	end)
end)