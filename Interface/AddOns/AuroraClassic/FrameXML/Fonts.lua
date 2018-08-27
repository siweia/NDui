local _, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	if not AuroraConfig.reskinFont then return end

	local function ReskinFont(font, size, white)
		font:SetFont(C.media.font, size*AuroraConfig.fontScale, white and "" or "OUTLINE")
		font:SetShadowColor(0, 0, 0, 0)
	end

	ReskinFont(RaidWarningFrame.slot1, 20)
	ReskinFont(RaidWarningFrame.slot2, 20)
	ReskinFont(RaidBossEmoteFrame.slot1, 20)
	ReskinFont(RaidBossEmoteFrame.slot2, 20)
	if GetLocale() == "zhTW" then
		ReskinFont(AchievementFont_Small, 14)
	else
		ReskinFont(AchievementFont_Small, 12)
	end
	ReskinFont(CoreAbilityFont, 32)
	ReskinFont(DestinyFontMed, 14)
	ReskinFont(DestinyFontHuge, 32)
	ReskinFont(DestinyFontLarge, 18)
	ReskinFont(FriendsFont_Normal, 15)
	ReskinFont(FriendsFont_Small, 13)
	ReskinFont(FriendsFont_Large, 17)
	ReskinFont(FriendsFont_UserText, 11)
	ReskinFont(GameFont_Gigantic, 38)
	ReskinFont(GameTooltipHeader, 16)
	ReskinFont(InvoiceFont_Small, 10)
	ReskinFont(InvoiceFont_Med, 12)
	ReskinFont(MailFont_Large, 15)
	ReskinFont(NumberFont_Small, 11)
	ReskinFont(NumberFont_GameNormal, 12)
	ReskinFont(NumberFont_Normal_Med, 12)
	ReskinFont(NumberFont_Shadow_Tiny, 10)
	ReskinFont(NumberFont_OutlineThick_Mono_Small, 13)
	ReskinFont(NumberFont_Outline_Med, 13)
	ReskinFont(NumberFont_Outline_Large, 14)
	ReskinFont(NumberFont_Shadow_Med, 16)
	ReskinFont(NumberFont_Shadow_Small, 12)
	ReskinFont(QuestFont_Shadow_Small, 13)
	ReskinFont(QuestFont_Large, 15)
	ReskinFont(QuestFont_Shadow_Huge, 17)
	ReskinFont(QuestFont_Huge, 17)
	ReskinFont(QuestFont_Super_Huge, 22)
	ReskinFont(QuestFont_Enormous, 30)
	ReskinFont(ReputationDetailFont, 12)
	ReskinFont(SpellFont_Small, 12)
	ReskinFont(SystemFont_InverseShadow_Small, 10)
	ReskinFont(SystemFont_Large, 13)
	ReskinFont(SystemFont_Huge1, 20)
	ReskinFont(SystemFont_Huge2, 24)
	ReskinFont(SystemFont_Med1, 13)
	ReskinFont(SystemFont_Med2, 14)
	ReskinFont(SystemFont_Med3, 13)
	ReskinFont(SystemFont_OutlineThick_WTF, 32)
	ReskinFont(SystemFont_OutlineThick_Huge2, 22)
	ReskinFont(SystemFont_OutlineThick_Huge4, 26)
	ReskinFont(SystemFont_Outline_Small, 12)
	ReskinFont(SystemFont_Outline, 15)
	ReskinFont(SystemFont_Shadow_Large, 17)
	ReskinFont(SystemFont_Shadow_Large_Outline, 17)
	ReskinFont(SystemFont_Shadow_Large2, 19)
	ReskinFont(SystemFont_Shadow_Med1, 15)
	ReskinFont(SystemFont_Shadow_Med1_Outline, 14)
	ReskinFont(SystemFont_Shadow_Med2, 16)
	ReskinFont(SystemFont_Shadow_Med3, 14)
	ReskinFont(SystemFont_Shadow_Outline_Huge2, 22)
	ReskinFont(SystemFont_Shadow_Huge1, 20)
	ReskinFont(SystemFont_Shadow_Huge2, 24)
	ReskinFont(SystemFont_Shadow_Huge3, 25)
	ReskinFont(SystemFont_Shadow_Small, 14)
	ReskinFont(SystemFont_Shadow_Small2, 13)
	ReskinFont(SystemFont_Small, 12)
	ReskinFont(SystemFont_Small2, 13)
	ReskinFont(SystemFont_Tiny, 9)
	ReskinFont(SystemFont_Tiny2, 8)
	ReskinFont(SystemFont_NamePlate, 12)
	ReskinFont(SystemFont_LargeNamePlate, 12)
	ReskinFont(SystemFont_NamePlateFixed, 12)
	ReskinFont(SystemFont_LargeNamePlateFixed, 12)
	ReskinFont(SystemFont_World, 64)
	ReskinFont(SystemFont_World_ThickOutline, 64)
	ReskinFont(SystemFont_WTF2, 64)
	ReskinFont(Tooltip_Med, 13)
	ReskinFont(Tooltip_Small, 12)
	ReskinFont(HelpFrameKnowledgebaseNavBarHomeButtonText, 15)
	ReskinFont(Game11Font, 11)
	ReskinFont(Game12Font, 12)
	ReskinFont(Game13Font, 13)
	ReskinFont(Game13FontShadow, 13)
	ReskinFont(Game15Font, 15)
	ReskinFont(Game16Font, 16)
	ReskinFont(Game18Font, 18)
	ReskinFont(Game20Font, 20)
	ReskinFont(Game24Font, 24)
	ReskinFont(Game27Font, 27)
	ReskinFont(Game30Font, 30)
	ReskinFont(Game32Font, 32)
	ReskinFont(Game36Font, 36)
	ReskinFont(Game42Font, 42)
	ReskinFont(Game46Font, 46)
	ReskinFont(Game48Font, 48)
	ReskinFont(Game48FontShadow, 48)
	ReskinFont(Game60Font, 60)
	ReskinFont(Game72Font, 72)
	ReskinFont(Game120Font, 120)
	ReskinFont(System_IME, 16)
	ReskinFont(Fancy12Font, 12)
	ReskinFont(Fancy14Font, 14)
	ReskinFont(Fancy16Font, 16)
	ReskinFont(Fancy18Font, 18)
	ReskinFont(Fancy20Font, 20)
	ReskinFont(Fancy22Font, 22)
	ReskinFont(Fancy24Font, 24)
	ReskinFont(Fancy27Font, 27)
	ReskinFont(Fancy30Font, 30)
	ReskinFont(Fancy32Font, 32)
	ReskinFont(Fancy48Font, 48)
	ReskinFont(SplashHeaderFont, 24)
	ReskinFont(ChatBubbleFont, 13)
	ReskinFont(GameFontNormalHuge2, 24)

	-- Refont RaidFrame Health
	hooksecurefunc("CompactUnitFrame_UpdateStatusText", function(frame)
		if frame:IsForbidden() then return end

		local options = DefaultCompactUnitFrameSetupOptions
		frame.statusText:ClearAllPoints()
		frame.statusText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 3, options.height/3 - 5)
		frame.statusText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -3, options.height/3 - 5)

		if not frame.fontStyled then
			local fontName, fontSize = frame.statusText:GetFont()
			frame.statusText:SetFont(fontName, fontSize, "OUTLINE")
			frame.statusText:SetTextColor(.7, .7, .7)
			frame.statusText:SetShadowColor(0, 0, 0, 0)
			frame.fontStyled = true
		end
	end)

	-- Refont Titles Panel
	hooksecurefunc("PaperDollTitlesPane_UpdateScrollFrame", function()
		local bu = PaperDollTitlesPane.buttons
		for i = 1, #bu do
			if not bu[i].fontStyled then
				ReskinFont(bu[i].text, 14)
				bu[i].fontStyled = true
			end
		end
	end)

	-- WhoFrame LevelText
	hooksecurefunc("WhoList_Update", function()
		for i = 1, WHOS_TO_DISPLAY, 1 do
			local level = _G["WhoFrameButton"..i.."Level"]
			if level and not level.fontStyled then
				level:SetWidth(32)
				level:SetJustifyH("LEFT")
				level.fontStyled = true
			end
		end
	end)

	-- Text color
	GameFontBlackMedium:SetTextColor(1, 1, 1)
	CoreAbilityFont:SetTextColor(1, 1, 1)
end)