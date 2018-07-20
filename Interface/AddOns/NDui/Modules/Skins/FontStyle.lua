local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Skins")

function module:FontStyle()
	if not IsAddOnLoaded("AuroraClassic") then return end
	AuroraConfig.enableFont = false

	if not NDuiDB["Skins"]["FontFlag"] then return end

	local function ReskinFont(font, size, white)
		font:SetFont(DB.Font[1], size, white and "" or "OUTLINE")
		font:SetShadowColor(0, 0, 0, 0)
	end

	ReskinFont(RaidWarningFrame.slot1, 20)
	ReskinFont(RaidWarningFrame.slot2, 20)
	ReskinFont(RaidBossEmoteFrame.slot1, 20)
	ReskinFont(RaidBossEmoteFrame.slot2, 20)
	ReskinFont(AchievementFont_Small, 10)
	ReskinFont(CoreAbilityFont, 32)
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
	ReskinFont(NumberFont_GameNormal, 12)
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
	ReskinFont(SystemFont_NamePlate, 12)
	ReskinFont(SystemFont_LargeNamePlate, 12)
	ReskinFont(SystemFont_NamePlateFixed, 12)
	ReskinFont(SystemFont_LargeNamePlateFixed, 12)
	ReskinFont(Tooltip_Med, 13)
	ReskinFont(Tooltip_Small, 12)
	ReskinFont(HelpFrameKnowledgebaseNavBarHomeButtonText, 15)
	ReskinFont(Game12Font, 12)
	ReskinFont(Game16Font, 16)
	ReskinFont(Game18Font, 18)
	ReskinFont(Game20Font, 20)
	ReskinFont(Game24Font, 24)
	ReskinFont(Game27Font, 27)
	ReskinFont(Game32Font, 32)
	ReskinFont(System_IME, 16)
	ReskinFont(Fancy24Font, 24)
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

	-- Achievement ShieldPoints, GuildRoster LevelText
	local styledIndex = 0
	local function updateAchievement(event, addon)
		if addon == "Blizzard_AchievementUI" then
			hooksecurefunc("AchievementObjectives_DisplayProgressiveAchievement", function()
				local index = 1
				local mini = _G["AchievementFrameMiniAchievement"..index]
				while mini do
					if not mini.fontStyled then
						mini.points:SetWidth(22)
						mini.points:ClearAllPoints()
						mini.points:SetPoint("BOTTOMRIGHT", 2, 2)
						mini.fontStyled = true
					end

					index = index + 1
					mini = _G["AchievementFrameMiniAchievement"..index]
				end
			end)

			styledIndex = styledIndex + 1
		elseif addon == "Blizzard_GuildUI" then
			hooksecurefunc("GuildRoster_SetView", function(view)
				if view == "playerStatus" or view == "reputation" or view == "achievement" then
					local buttons = GuildRosterContainer.buttons
					for i = 1, #buttons do
						local str = _G["GuildRosterContainerButton"..i.."String1"]
						str:SetWidth(32)
						str:SetJustifyH("LEFT")
					end

					if view == "achievement" then
						for i = 1, #buttons do
							local str = _G["GuildRosterContainerButton"..i.."BarLabel"]
							str:SetWidth(60)
							str:SetJustifyH("LEFT")
						end
					end
				end
			end)
			GuildRoster_SetView(GetCVar("guildRosterView"))

			styledIndex = styledIndex + 1
		end

		if styledIndex == 2 then B:UnregisterEvent(event, updateAchievement) end
	end
	B:RegisterEvent("ADDON_LOADED", updateAchievement)

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
end