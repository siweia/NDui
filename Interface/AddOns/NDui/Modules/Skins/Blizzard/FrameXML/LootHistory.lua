local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	local r, g, b = DB.r, DB.g, DB.b

	local LootHistoryFrame = LootHistoryFrame

	LootHistoryFrame.Label:ClearAllPoints()
	LootHistoryFrame.Label:SetPoint("TOP", LootHistoryFrame, "TOP", 0, -8)

	B.StripTextures(LootHistoryFrame)
	B.SetBD(LootHistoryFrame)
	B.ReskinClose(LootHistoryFrame.CloseButton)
	B.ReskinScroll(LootHistoryFrameScrollFrameScrollBar)

	-- [[ Resize button ]]

	LootHistoryFrame.ResizeButton:SetNormalTexture(0)
	LootHistoryFrame.ResizeButton:SetHeight(8)

	do
		local line1 = LootHistoryFrame.ResizeButton:CreateTexture()
		line1:SetTexture(DB.bdTex)
		line1:SetVertexColor(.7, .7, .7)
		line1:SetSize(30, 1)
		line1:SetPoint("TOP")

		local line2 = LootHistoryFrame.ResizeButton:CreateTexture()
		line2:SetTexture(DB.bdTex)
		line2:SetVertexColor(.7, .7, .7)
		line2:SetSize(30, 1)
		line2:SetPoint("TOP", 0, -3)

		LootHistoryFrame.ResizeButton:HookScript("OnEnter", function()
			line1:SetVertexColor(r, g, b)
			line2:SetVertexColor(r, g, b)
		end)

		LootHistoryFrame.ResizeButton:HookScript("OnLeave", function()
			line1:SetVertexColor(.7, .7, .7)
			line2:SetVertexColor(.7, .7, .7)
		end)
	end

	-- [[ Item frame ]]

	hooksecurefunc("LootHistoryFrame_UpdateItemFrame", function(self, frame)
		local rollID, _, _, isDone, winnerIdx = C_LootHistory.GetItem(frame.itemIdx)
		local expanded = self.expandedRolls[rollID]

		if not frame.styled then
			frame.Divider:Hide()
			frame.NameBorderLeft:Hide()
			frame.NameBorderRight:Hide()
			frame.NameBorderMid:Hide()
			frame.WinnerRoll:SetTextColor(.9, .9, .9)

			frame.bg = B.ReskinIcon(frame.Icon)
			B.ReskinIconBorder(frame.IconBorder)

			B.ReskinCollapse(frame.ToggleButton)
			frame.ToggleButton:GetNormalTexture():SetAlpha(0)
			frame.ToggleButton:GetPushedTexture():SetAlpha(0)
			frame.ToggleButton:GetDisabledTexture():SetAlpha(0)

			frame.WinnerName:SetFontObject(Game13Font)
			frame.WinnerRoll:SetWidth(28)
			frame.WinnerRoll:SetFontObject(Game13Font)

			frame.styled = true
		end

		if isDone and not expanded and winnerIdx then
			local name, class = C_LootHistory.GetPlayerInfo(frame.itemIdx, winnerIdx)
			if name then
				local color = DB.ClassColors[class]
				frame.WinnerName:SetVertexColor(color.r, color.g, color.b)
			end
		end
	end)

	-- [[ Player frame ]]

	hooksecurefunc("LootHistoryFrame_UpdatePlayerFrame", function(_, playerFrame)
		if not playerFrame.styled then
			playerFrame.PlayerName:SetWordWrap(false)
			playerFrame.PlayerName:SetFontObject(Game13Font)
			playerFrame.RollText:SetTextColor(.9, .9, .9)
			playerFrame.RollText:SetWidth(28)
			playerFrame.RollText:SetFontObject(Game13Font)
			playerFrame.WinMark:SetDesaturated(true)

			playerFrame.styled = true
		end

		if playerFrame.playerIdx then
			local name, class, _, _, isWinner = C_LootHistory.GetPlayerInfo(playerFrame.itemIdx, playerFrame.playerIdx)

			if name then
				local color = DB.ClassColors[class]
				playerFrame.PlayerName:SetTextColor(color.r, color.g, color.b)

				if isWinner then
					playerFrame.WinMark:SetVertexColor(color.r, color.g, color.b)
				end
			end
		end
	end)
end)