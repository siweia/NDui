------------------
-- Localization
------------------
QN_Title    = "QuestNotifier Options"
QN_Switch   = "Enable Notifier(Disable when OFF)"
QN_InstanceMode = "Instance Mode"
QN_RaidMode = "Raid Mode"
QN_PartyMode= "Party Mode"
QN_SoloMode = "Sole Mode"
QN_Sound    = "Play Sound on Completed"
QN_Debug    = "|CFF00FF00Print Color QuestInfo|r|CFF00FFFF(inactive when in a Party or Raid)|r"
QN_NoDetail = "|CFF00FFFFDon't Notify Detail|r"
QN_CompleteX = "|CFF00F000Auto Remove Completed Quest from quest watch frame|r"
QN_Locale   = {
	["Colon"]       = ":",
	["Quest"]       = "Quest",
	["Progress"]    = "Progress",
	["Complete"]    = "Completed!", 
	["Accept"]      = "AcceptQuest",
}

if GetLocale() == "zhCN" then 
	QN_Title    = "任务通报功能设置"
	QN_Switch   = "|CFF00FF00启用任务通报(关闭后所有功能失效)|r"
	QN_InstanceMode = "|CFFFF7D00在副本中时通报|r"
	QN_RaidMode = "|CFFFF7D00在团队中时通报|r"
	QN_PartyMode= "|CFF30A0C8在小队中时通报|r"
	QN_SoloMode = "单人的时候通报(慎用,老说话BL/LM老远看到来揍你)"
	QN_Sound    = "|CFF00FF00完成时播放提示音|r"
	QN_Debug    = "|CFF00F000任务进度彩色提示|r(|CF000FFF0仅自己可见,组队时此选项自动失效|r)" 
	QN_NoDetail = "|CFF00FFFF不通报详细进度|r"
	QN_CompleteX = "|CFF00F000任务追踪自动移除已完成任务|r"
	QN_Locale = {
		["Colon"]       = "：",
		["Quest"]       = "任务",
		["Progress"]    = "进度",
		["Complete"]    = "已完成!",
		["Accept"]      = "接受任务",
	}

elseif GetLocale() == "zhTW" then 
	QN_Title    = "任務通報功能設置"
	QN_Switch   = "|CFF00FF00啟用任務通告(關閉後所有功能失效)|r"
	QN_InstanceMode = "|CFFFF7D00在副本中時通報|r"
	QN_RaidMode = "|CFFFF7D00在團隊中時通報|r"
	QN_PartyMode= "|CFF30A0C8在小隊中時通報|r"
	QN_SoloMode = "單人的時候通報(慎用,老說話BL/LM老遠看到來揍你)"
	QN_Sound    = "|CFF00FF00完成時播放提示音|r"
	QN_Debug    = "|CFF00F000任務進度彩色提示|r(|CF000FFF0僅自己可見,組隊時此選項自動失效|r)" 
	QN_NoDetail = "|CFF00FFFF不通報詳細進度|r"
	QN_CompleteX = "|CFF00F000任務追蹤自動移除已完成任務|r"
	QN_Locale = {
		["Colon"]       = ":",
		["Quest"]       = "任務",
		["Progress"]    = "進度",
		["Complete"]    = "已完成!",
		["Accept"]      = "接受任務",
	}
end