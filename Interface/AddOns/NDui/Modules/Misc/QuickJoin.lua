local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Misc")

--[[
	QuickJoin 优化系统自带的预创建功能
	1.修复简中语系的一个报错
	2.双击搜索结果，快速申请
	3.自动隐藏部分窗口
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