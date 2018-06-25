local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Misc")

--[[
	QuickJoin 优化系统自带的预创建功能
	1.鼠标中键点击所追踪的任务进行搜索
	2.双击搜索结果，快速申请
	3.目标为稀有精英或世界BOSS时，右键点击框体可寻找队伍
	4.自动隐藏部分窗口
]]

function module:QuickJoin()
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
			end
			info.notCheckable = true
			UIDropDownMenu_AddButton(info)
		end
	end)

	hooksecurefunc("LFGListInviteDialog_Accept", function()
		if PVEFrame:IsShown() then ToggleFrame(PVEFrame) end
	end)

	local function hideInSecond(frame)
		C_Timer.After(1, function()
			if frame.informational then
				StaticPopupSpecial_Hide(frame)
			elseif frame == "LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS" then
				StaticPopup_Hide(frame)
			end
		end)
	end
	hooksecurefunc("StaticPopup_Show", hideInSecond)
	hooksecurefunc("LFGListInviteDialog_Show", hideInSecond)
end