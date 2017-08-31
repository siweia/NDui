local B, C, L, DB = unpack(select(2, ...))
local module = NDui:GetModule("Skins")
local cr, cg, cb = DB.cc.r, DB.cc.g, DB.cc.b

local buttonList = {}
function module:CreateMMB(parent, data)
	local texture, onside, tip, func = unpack(data)
	local width, offset = 24, 0
	if onside then width, offset = 35, 6 end

	local bu = CreateFrame("Button", nil, parent)
	tinsert(buttonList, bu)
	bu:SetSize(width, 20)
	bu:SetFrameStrata("BACKGROUND")
	B.CreateBD(bu, 0)
	bu:SetBackdropBorderColor(0, 0, 0, 0)
	local icon = bu:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("CENTER", offset, 0)
	icon:SetSize(50, 50)
	icon:SetTexture(DB.Micro..texture)
	icon:SetVertexColor(cr, cg, cb)
	B.CreateGT(bu, "ANCHOR_TOP", tip)
	bu:HookScript("OnEnter", function(self)
		self:SetBackdropColor(0, 0, 0, 1)
		self:SetBackdropBorderColor(0, 0, 0, 1)
	end)
	bu:HookScript("OnLeave", function(self)
		self:SetBackdropColor(0, 0, 0, 0)
		self:SetBackdropBorderColor(0, 0, 0, 0)
	end)
	bu:SetScript("OnClick", func)
end

function module:MicroMenu()
	-- Taint Fix
	ToggleAllBags()
	ToggleAllBags()
	ToggleFrame(SpellBookFrame)
	ToggleFrame(SpellBookFrame)

	if not NDuiDB["Skins"]["MicroMenu"] then return end

	local faction = UnitFactionGroup("player")
	local menubar = CreateFrame("Frame", nil, UIParent)
	menubar:SetSize(384, 20)
	B.Mover(menubar, L["Menubar"], "Menubar", C.Skins.MicroMenuPos)

	-- Retrieve Keybind
	local function key(text, action)
		if GetBindingKey(action) then
			return text.." ("..GetBindingText(GetBindingKey(action))..")"
		else
			return text
		end
	end

	-- Generate Buttons
	local buttonInfo = {
		{"micro_player", true, key(CHARACTER_BUTTON, "TOGGLECHARACTER0"), function() ToggleFrame(CharacterFrame) end},
		{"micro_spellbook", false, key(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK"), function() ToggleFrame(SpellBookFrame) end},
		{"micro_talents", false, key(TALENTS_BUTTON, "TOGGLETALENTS"), function()
			if not PlayerTalentFrame then LoadAddOn("Blizzard_TalentUI") end
			if UnitLevel("player") < SHOW_SPEC_LEVEL then
				UIErrorsFrame:AddMessage(DB.InfoColor..format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_SPEC_LEVEL))
			else
				ToggleFrame(PlayerTalentFrame)
			end
		end},
		{"micro_achievements", false, key(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT"), function() ToggleAchievementFrame() end},
		{"micro_quests", false, key(QUESTLOG_BUTTON, "TOGGLEQUESTLOG"), function() ToggleFrame(WorldMapFrame) end},
		{"micro_guild", false, IsInGuild() and key(GUILD, "TOGGLEGUILDTAB") or key(LOOKINGFORGUILD, "TOGGLEGUILDTAB"), function()
			if IsTrialAccount() then
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_GUILD_TRIAL_ACCOUNT_TRIAL)
			elseif faction == "Neutral" then
				UIErrorsFrame:AddMessage(DB.InfoColor..FEATURE_NOT_AVAILBLE_PANDAREN)
			elseif IsInGuild() then
				if not GuildFrame then LoadAddOn("Blizzard_GuildUI") end
				ToggleFrame(GuildFrame)
			else
				ToggleGuildFinder()
			end
		end},
		{"micro_pvp", false, key(PLAYER_V_PLAYER, "TOGGLECHARACTER4"), function()
			if faction == "Neutral" then
				UIErrorsFrame:AddMessage(DB.InfoColor..FEATURE_NOT_AVAILBLE_PANDAREN)
			elseif UnitLevel("player") < LFDMicroButton.minLevel then
				UIErrorsFrame:AddMessage(DB.InfoColor..format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, LFDMicroButton.minLevel))
			else
				TogglePVPUI()
			end
		end},
		{"micro_LFD", false, key(DUNGEONS_BUTTON, "TOGGLEGROUPFINDER"), function()
			if faction == "Neutral" then
				UIErrorsFrame:AddMessage(DB.InfoColor..FEATURE_NOT_AVAILBLE_PANDAREN)
			elseif UnitLevel("player") < LFDMicroButton.minLevel then
				UIErrorsFrame:AddMessage(DB.InfoColor..format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, LFDMicroButton.minLevel))
			else
				PVEFrame_ToggleFrame()
			end
		end},
		{"micro_encounter", false, key(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL"), function() ToggleEncounterJournal() end},
		{"micro_pets", false, key(COLLECTIONS, "TOGGLECOLLECTIONS"), function()
			if InCombatLockdown() and not IsAddOnLoaded("Blizzard_Collections") then
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_POTION_COOLDOWN)
				return
			end
			ToggleCollectionsJournal()
		end},
		{"micro_store", false, BLIZZARD_STORE, function()
			if IsTrialAccount() then
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_GUILD_TRIAL_ACCOUNT)
			elseif C_StorePublic.IsDisabledByParentalControls() then
				UIErrorsFrame:AddMessage(DB.InfoColor..BLIZZARD_STORE_ERROR_PARENTAL_CONTROLS)
			else
				ToggleStoreUI()
			end
		end},
		{"micro_gm", false, HELP_BUTTON, function() ToggleFrame(HelpFrame) end},
		{"micro_settings", false, MAIN_MENU, function() ToggleFrame(GameMenuFrame) PlaySound(SOUNDKIT.IG_MINIMAP_OPEN) end},
		{"micro_bags", true, key(BAGSLOT, "OPENALLBAGS"), function() ToggleAllBags() end},
	}
	for _, info in pairs(buttonInfo) do self:CreateMMB(menubar, info) end

	-- Order Positions
	for i = 1, #buttonList do
		if i == 1 then
			buttonList[i]:SetPoint("LEFT")
		else
			buttonList[i]:SetPoint("LEFT", buttonList[i-1], "RIGHT", 2, 0)
		end
	end
end