local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local r, g, b = DB.r, DB.g, DB.b

	local LootHistoryFrame = GroupLootHistoryFrame or LootHistoryFrame
	if not LootHistoryFrame then return end

	if not DB.isPatch10_1 then
		LootHistoryFrame.Label:ClearAllPoints()
		LootHistoryFrame.Label:SetPoint("TOP", LootHistoryFrame, "TOP", 0, -8)
		B.ReskinClose(LootHistoryFrame.CloseButton)
	end

	B.StripTextures(LootHistoryFrame)
	B.SetBD(LootHistoryFrame)
	if DB.isPatch10_1 then
		B.ReskinClose(LootHistoryFrame.ClosePanelButton)
		B.ReskinTrimScroll(LootHistoryFrame.ScrollBar)
	else
		B.ReskinScroll(LootHistoryFrameScrollFrameScrollBar)
	end

	-- [[ Resize button ]]

	B.StripTextures(LootHistoryFrame.ResizeButton)
	LootHistoryFrame.ResizeButton:SetHeight(8)

	do
		local line1 = LootHistoryFrame.ResizeButton:CreateTexture()
		line1:SetTexture(DB.bdTex)
		line1:SetVertexColor(.7, .7, .7)
		line1:SetSize(30, C.mult)
		line1:SetPoint("TOP", 0, -2)

		local line2 = LootHistoryFrame.ResizeButton:CreateTexture()
		line2:SetTexture(DB.bdTex)
		line2:SetVertexColor(.7, .7, .7)
		line2:SetSize(30, C.mult)
		line2:SetPoint("TOP", 0, -5)

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

	if DB.isPatch10_1 then
	else
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
	
		hooksecurefunc("LootHistoryFrame_UpdatePlayerFrame", function(_, playerFrame)
			if not playerFrame.styled then
				playerFrame.PlayerName:SetWordWrap(false)
				playerFrame.PlayerName:SetFontObject(Game13Font)
				playerFrame.RollText:SetTextColor(.9, .9, .9)
				playerFrame.RollText:SetWidth(28)
				playerFrame.RollText:SetFontObject(Game13Font)
				playerFrame.WinMark:SetDesaturated(true)
				playerFrame.WinMark:SetAtlas("checkmark-minimal")
	
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

		-- [[ Dropdown ]]
	
		LootHistoryDropDown.initialize = function(self)
			local info = UIDropDownMenu_CreateInfo();
			info.isTitle = 1;
			info.text = MASTER_LOOTER;
			info.fontObject = GameFontNormalLeft;
			info.notCheckable = 1;
			UIDropDownMenu_AddButton(info);
	
			info = UIDropDownMenu_CreateInfo();
			info.notCheckable = 1;
			local name, class = C_LootHistory.GetPlayerInfo(self.itemIdx, self.playerIdx);
			local classColor = DB.ClassColors[class];
			local colorCode = classColor.colorStr
			info.text = string.format(MASTER_LOOTER_GIVE_TO, colorCode..name.."|r");
			info.func = LootHistoryDropDown_OnClick;
			UIDropDownMenu_AddButton(info);
		end
	end
end)