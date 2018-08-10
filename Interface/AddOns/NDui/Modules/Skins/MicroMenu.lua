local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Skins")

local buttonList = {}
local r, g, b = DB.cc.r, DB.cc.g, DB.cc.b
local function CreateMicroButton(parent, data)
	local texture, texcoord, tip, func = unpack(data)
	if not NDuiDB["Skins"]["ClassLine"] then r, g, b = 0, 0, 0 end

	local bu = CreateFrame("Button", nil, parent)
	tinsert(buttonList, bu)
	bu:SetSize(22, 22)
	bu:SetFrameStrata("BACKGROUND")
	bu:SetScript("OnClick", func)
	B.AddTooltip(bu, "ANCHOR_TOP", tip)

	local icon = bu:CreateTexture(nil, "ARTWORK")
	if texture == "encounter" then
		icon:SetPoint("TOPLEFT", 2, -2)
		icon:SetPoint("BOTTOMRIGHT", -2, 3)
	else
		icon:SetAllPoints()
	end
	icon:SetTexture(DB.MicroTex..texture)
	icon:SetTexCoord(unpack(texcoord))
	icon:SetVertexColor(r, g, b)

	bu:SetHighlightTexture(DB.MicroTex..texture)
	local highlight = bu:GetHighlightTexture()
	highlight:SetAllPoints(icon)
	highlight:SetTexCoord(unpack(texcoord))
	if NDuiDB["Skins"]["ClassLine"] then
		highlight:SetVertexColor(r, g, b)
	else
		highlight:SetVertexColor(1, 1, 1)
	end
end

local function ReanchorAlert()
	if TalentMicroButtonAlert then
		TalentMicroButtonAlert:ClearAllPoints()
		TalentMicroButtonAlert:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -220, 40)
		TalentMicroButtonAlert:SetScript("OnMouseUp", function()
			if not PlayerTalentFrame then LoadAddOn("Blizzard_TalentUI") end
			ToggleFrame(PlayerTalentFrame)
		end)
	end

	if EJMicroButtonAlert then
		EJMicroButtonAlert:ClearAllPoints()
		EJMicroButtonAlert:SetPoint("BOTTOM", UIParent, "BOTTOM", 40, 40)
		EJMicroButtonAlert:SetScript("OnMouseUp", function()
			if not EncounterJournal then LoadAddOn("Blizzard_EncounterJournal") end
			ToggleFrame(EncounterJournal)
		end)
	end

	if CollectionsMicroButtonAlert then
		CollectionsMicroButtonAlert:ClearAllPoints()
		CollectionsMicroButtonAlert:SetPoint("BOTTOM", UIParent, "BOTTOM", 65, 40)
		CollectionsMicroButtonAlert:SetScript("OnMouseUp", function()
			if not CollectionsJournal then LoadAddOn("Blizzard_Collections") end
			ToggleFrame(CollectionsJournal)
			CollectionsJournal_SetTab(CollectionsJournal, 2)
		end)
	end

	if CharacterMicroButtonAlert then
		hooksecurefunc(CharacterMicroButtonAlert, "SetPoint", function(self, _, parent)
			if parent ~= UIParent then
				self:ClearAllPoints()
				self:SetPoint("BOTTOM", UIParent, "BOTTOM", -175, 40)
			end
		end)
	end
end

function module:MicroMenu()
	-- Taint Fix
	ToggleFrame(SpellBookFrame)
	ToggleFrame(SpellBookFrame)

	ReanchorAlert()

	if not NDuiDB["Skins"]["MicroMenu"] then return end

	local faction = UnitFactionGroup("player")
	local menubar = CreateFrame("Frame", nil, UIParent)
	menubar:SetSize(373, 22)
	B.Mover(menubar, L["Menubar"], "Menubar", C.Skins.MicroMenuPos)

	-- Generate Buttons
	local buttonInfo = {
		{"player", {51/256, 141/256, 86/256, 173/256}, MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0"), function() ToggleFrame(CharacterFrame) end},
		{"spellbook", {83/256, 173/256, 86/256, 173/256}, MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK"), function() ToggleFrame(SpellBookFrame) end},
		{"talents", {83/256, 173/256, 86/256, 173/256}, MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS"), function()
			if not PlayerTalentFrame then LoadAddOn("Blizzard_TalentUI") end
			if UnitLevel("player") < SHOW_SPEC_LEVEL then
				UIErrorsFrame:AddMessage(DB.InfoColor..format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_SPEC_LEVEL))
			else
				ToggleFrame(PlayerTalentFrame)
			end
		end},
		{"achievements", {83/256, 173/256, 83/256, 173/256}, MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT"), function() ToggleAchievementFrame() end},
		{"quests", {83/256, 173/256, 80/256, 167/256}, MicroButtonTooltipText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG"), function() ToggleQuestLog() end},
		{"guild", {83/256, 173/256, 80/256, 167/256}, MicroButtonTooltipText(GUILD_AND_COMMUNITIES, "TOGGLEGUILDTAB"), function()
			if IsTrialAccount() then
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_RESTRICTED_ACCOUNT_TRIAL)
			elseif faction == "Neutral" then
				UIErrorsFrame:AddMessage(DB.InfoColor..FEATURE_NOT_AVAILBLE_PANDAREN)
			else
				ToggleGuildFrame()
			end
		end},
		{"pvp", {83/256, 173/256, 83/256, 173/256}, MicroButtonTooltipText(PLAYER_V_PLAYER, "TOGGLECHARACTER4"), function()
			if faction == "Neutral" then
				UIErrorsFrame:AddMessage(DB.InfoColor..FEATURE_NOT_AVAILBLE_PANDAREN)
			elseif UnitLevel("player") < LFDMicroButton.minLevel then
				UIErrorsFrame:AddMessage(DB.InfoColor..format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, LFDMicroButton.minLevel))
			else
				TogglePVPUI()
			end
		end},
		{"LFD", {83/256, 173/256, 83/256, 173/256}, MicroButtonTooltipText(DUNGEONS_BUTTON, "TOGGLEGROUPFINDER"), function()
			if faction == "Neutral" then
				UIErrorsFrame:AddMessage(DB.InfoColor..FEATURE_NOT_AVAILBLE_PANDAREN)
			elseif UnitLevel("player") < LFDMicroButton.minLevel then
				UIErrorsFrame:AddMessage(DB.InfoColor..format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, LFDMicroButton.minLevel))
			else
				PVEFrame_ToggleFrame()
			end
		end},
		{"encounter", {83/256, 173/256, 83/256, 173/256}, MicroButtonTooltipText(ADVENTURE_JOURNAL, "TOGGLEENCOUNTERJOURNAL"), function() ToggleEncounterJournal() end},
		{"pets", {83/256, 173/256, 83/256, 173/256}, MicroButtonTooltipText(COLLECTIONS, "TOGGLECOLLECTIONS"), function()
			if InCombatLockdown() and not IsAddOnLoaded("Blizzard_Collections") then
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_POTION_COOLDOWN)
			else
				ToggleCollectionsJournal()
			end
		end},
		{"store", {83/256, 173/256, 83/256, 173/256}, BLIZZARD_STORE, function()
			if IsTrialAccount() then
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_GUILD_TRIAL_ACCOUNT)
			elseif C_StorePublic.IsDisabledByParentalControls() then
				UIErrorsFrame:AddMessage(DB.InfoColor..BLIZZARD_STORE_ERROR_PARENTAL_CONTROLS)
			else
				ToggleStoreUI()
			end
		end},
		{"gm", {83/256, 173/256, 80/256, 170/256}, HELP_BUTTON, function() ToggleFrame(HelpFrame) end},
		{"settings", {83/256, 173/256, 83/256, 173/256}, MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU"), function() ToggleFrame(GameMenuFrame) PlaySound(SOUNDKIT.IG_MINIMAP_OPEN) end},
		{"bags", {47/256, 137/256, 83/256, 173/256}, MicroButtonTooltipText(BAGSLOT, "OPENALLBAGS"), function() ToggleAllBags() end},
	}
	for _, info in pairs(buttonInfo) do CreateMicroButton(menubar, info) end

	-- Order Positions
	for i = 1, #buttonList do
		if i == 1 then
			buttonList[i]:SetPoint("LEFT")
		else
			buttonList[i]:SetPoint("LEFT", buttonList[i-1], "RIGHT", 5, 0)
		end
	end
end