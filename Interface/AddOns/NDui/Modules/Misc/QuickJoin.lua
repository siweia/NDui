local B, C, L, DB = unpack(select(2, ...))
local module = NDui:GetModule("Misc")

--[[
	QuickJoin 优化系统自带的预创建功能
	1.鼠标中键点击所追踪的任务进行搜索
	2.双击搜索结果，快速申请
	3.目标为稀有精英或世界BOSS时，右键点击框体可寻找队伍
	4.点击创建队伍时自动填写上次在搜索框的内容
	5.高亮由NDui创建的队伍
	6.自动隐藏部分窗口
]]

function module:QuickJoin()
	local englishName = {	-- list from world quest trakcer
		[126338] = "wrath-lord yarez",
		[126852] = "wrangler kravos",
		[122958] = "blistermaw",
		[127288] = "houndmaster kerrax",
		[126912] = "skreeg the devourer",
		[126867] = "venomtail skyfin",
		[126862] = "baruut the bloodthirsty",
		[127703] = "doomcaster suprax",
		[126900] = "instructor tarahna",
		[126860] = "kaara the pale",
		[126419] = "naroua",
		[126898] = "sabuul",
		[126208] = "varga",
		[127705] = "mother rosula",
		[127706] = "rezira the seer",
		[123464] = "sister subversia",
		[127700] = "squadron commander vishax",
		[127581] = "the many faced devourer",
		[126887] = "ataxon",
		[120393] = "siegemaster voraan",
		[127096] = "all-seer xanarian",
		[126199] = "vrax'thul",
		[127376] = "chief alchemist munculus",
		[127300] = "void warden valsuran",
		[125820] = "imp mother laglath",
		[125388] = "vagath the betrayed",
		[123689] = "talestra the vile",
		[127118] = "worldsplitter skuul",
		[124804] = "tereck the selector",
		[125479] = "tar spitter",
		[122911] = "commander vecaya",
		[125824] = "khazaduum",
		[122912] = "commander sathrenael",
		[124775] = "commander endaxis",
		[127704] = "soultender videx",
		[126040] = "puscilla",
		[127291] = "watcher aival",
		[127090] = "admiral relvar",
		[122999] = "gar'zoth",
		[122947] = "mistress il'thendra",
		[126115] = "ven'orn",
		[126254] = "lieutenant xakaar",
		[127084] = "commander texlaz",
		[126946] = "inquisitor vethroz",
		[126865] = "vigilant thanos",
		[126869] = "captain faruq",
		[126896] = "herald of chaos",
		[126899] = "jed'hin champion vorusk",
		[125497] = "overseer y'sorna",
		[126910] = "commander xethgar",
		[126913] = "slithon the last",
		[122838] = "shadowcaster voruun",
		[126815] = "soultwisted monstrosity",
		[126864] = "feasel the muffin thief",
		[126866] = "vigilant kuro",
		[126868] = "turek the lucid",
		[126885] = "umbraliss",
		[126889] = "sorolis the ill-fated",
		[124440] = "overseer y'beda",
		[125498] = "overseer y'morna",
		[126908] = "zul'tan the numerous",
		--world bosses
		[124625] = "mistress alluradel",
		[124514] = "matron folnuna",
		[124555] = "sotanathor",
		[124492] = "occularus",
		[124592] = "inquisitor meto",
		[124719] = "pit lord vilemus",
	}

	if DB.Client == "zhCN" then
		StaticPopupDialogs["LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS"] = {
			text = "针对此项活动，你的队伍人数已满，将被移出列表。",
			button1 = OKAY,
			timeout = 0,
			whileDead = 1,
		}
	end

	hooksecurefunc("BonusObjectiveTracker_OnBlockClick", function(self, button)
		if self.module.ShowWorldQuests then
			if button == "MiddleButton" then
				LFGListUtil_FindQuestGroup(self.TrackedQuest.questID)
			end
		end
	end)

	for i = 1, 10 do
		local bu = _G["LFGListSearchPanelScrollFrameButton"..i]
		if bu then
			bu:HookScript("OnDoubleClick", function()
				if LFGListFrame.SearchPanel.SignUpButton:IsEnabled() then
					LFGListFrame.SearchPanel.SignUpButton:Click()
				end
				if LFGListApplicationDialog:IsShown() and LFGListApplicationDialog.SignUpButton:IsEnabled() then
					LFGListApplicationDialog.SignUpButton:Click()
				end
			end)
		end
	end

	local npcID
	hooksecurefunc("UnitPopup_ShowMenu", function(_, _, unit)
		if UIDROPDOWNMENU_MENU_LEVEL > 1 then return end
		if unit and unit == "target" and (UnitLevel(unit) < 0 and UnitClassification(unit) == "elite" or UnitClassification(unit) == "rareelite") then
			local info = UIDropDownMenu_CreateInfo()
			info.text = FIND_A_GROUP
			info.arg1 = {value = "RARE_SEARCH", unit = unit}
			info.func = function()
				PVEFrame_ShowFrame("GroupFinderFrame", LFGListPVEStub)
				LFGListCategorySelection_SelectCategory(LFGListFrame.CategorySelection, 6, 0)
				LFGListCategorySelection_StartFindGroup(LFGListFrame.CategorySelection, UnitName(unit))

				local guid = UnitGUID(unit)
				if guid then
					npcID = select(6, strsplit("-", guid))
				end
			end
			info.notCheckable = true
			UIDropDownMenu_AddButton(info)
		end
	end)

	hooksecurefunc("LFGListEntryCreation_Show", function(self)
		local searchBox = LFGListFrame.SearchPanel.SearchBox
		local searchText = searchBox:GetText()
		if searchText ~= "" then
			local mapName = GetMapInfo()
			local invaName = C_Scenario.GetInfo()
			local description
			if mapName and mapName:match("InvasionPoint") and invaName then
				local name = mapName:gsub("InvasionPoint", "")
				description = "NDui"..(name and " #Invasion Point: "..name or "")
			else
				local name = englishName[tonumber(npcID)]
				description = npcID and "NDui #NPCID"..npcID..(name and " #"..name or "") or "NDui"
			end

			C_LFGList.CreateListing(self.selectedActivity, searchText, 0, 0, "", description, true)
			searchBox:SetText("")
			npcID = nil
		end
	end)

	local old_LFGListEntryCreation_GetAutoCreateDataQuest = LFGListEntryCreation_GetAutoCreateDataQuest
	function LFGListEntryCreation_GetAutoCreateDataQuest(self)
		local activityID, name, itemLevel, honorLevel, voiceChatInfo, description, autoAccept, privateGroup, questID = old_LFGListEntryCreation_GetAutoCreateDataQuest(self)
		description = "NDui #ID"..questID.." #"..description
		return activityID, name, itemLevel, honorLevel, voiceChatInfo, description, autoAccept, privateGroup, questID
	end

	hooksecurefunc("LFGListSearchEntry_Update", function(self)
		local _, _, _, comment = C_LFGList.GetSearchResultInfo(self.resultID)
		if comment and comment:match("NDui") then
			self.Name:SetTextColor(0, 1, 0)
		end
	end)

	hooksecurefunc("LFGListInviteDialog_Accept", function()
		if PVEFrame:IsShown() then ToggleFrame(PVEFrame) end
	end)

	hooksecurefunc("StaticPopup_Show", function(which)
		if which == "LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS" then
			C_Timer.After(1, function()
				StaticPopup_Hide(which)
			end)
		end
	end)
end