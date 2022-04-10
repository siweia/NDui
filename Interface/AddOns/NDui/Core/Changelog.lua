local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"界面美化更新；",
	"重做专业面板的拓展；",
	"烹饪及急救页面的搜索现在和其他专业一致；",
	"修正隐藏伤害统计美化的箭头时出现的黑点；",
	"团队框体减益屏蔽工程传送器失效的debuff；",
	"添加祖阿曼的相关副本减益；",
	"修正聊天复制有时候错位的问题；",
	"重做去除地图迷雾功能；",
	"重做任务面板的拓展；",
	"修正鼠标提示框中玩家目标的标记；",
	"oUF及LHC更新；",
	"姓名板添加可驱散法术及打断目标的开关；",
	"姓名板添加队伍关注统计的选项；",
	"姓名板目标箭头动效支持右侧箭头；",
	"动作条冷却计时调整；",
	"添加动作条冷却格式阈值的选项；",
	"团队减益添加其他分组，用于监控非副本场景；",
	"添加小地图回收站黑名单的选项；",
	"设置导入导出更新；",
	"动作条的配置分享功能修正姿态条的开关问题；",
	"添加最大视距等级选项；",
	"未启用全局描边时聊天框字体保留阴影；",
	"团队框体增减益指示器添加点击穿越选项；",
	"右键菜单交互色块支持战网密语；",
	"控制台及本地文本更新。",
}

local f
local function changelog()
	if f then f:Show() return end

	local majorVersion = gsub(DB.Version, "%.%d+$", ".0")

	f = CreateFrame("Frame", "NDuiChangeLog", UIParent)
	f:SetPoint("CENTER")
	f:SetFrameStrata("HIGH")
	B.CreateMF(f)
	B.SetBD(f)
	B.CreateFS(f, 18, majorVersion.." "..L["Changelog"], true, "TOP", 0, -10)
	B.CreateWatermark(f)

	local ll = B.SetGradient(f, "H", .7, .7, .7, 0, .5, 100, C.mult)
	ll:SetPoint("TOP", -50, -35)
	local lr = B.SetGradient(f, "H", .7, .7, .7, .5, 0, 100, C.mult)
	lr:SetPoint("TOP", 50, -35)

	local offset = 0
	for n, t in pairs(hx) do
		B.CreateFS(f, 14, n..": "..t, false, "TOPLEFT", 15, -(50 + offset))
		offset = offset + 24
	end
	f:SetSize(480, 60 + offset)
	local close = B.CreateButton(f, 16, 16, true, DB.closeTex)
	close:SetPoint("TOPRIGHT", -10, -10)
	close:SetScript("OnClick", function() f:Hide() end)
end

local function compareToShow(event)
	if NDui_Tutorial then return end

	local old1, old2 = strsplit(".", NDuiADB["Changelog"].Version or "")
	local cur1, cur2 = strsplit(".", DB.Version)
	if old1 ~= cur1 or old2 ~= cur2 then
		changelog()
		NDuiADB["Changelog"].Version = DB.Version
	end

	B:UnregisterEvent(event, compareToShow)
end
B:RegisterEvent("PLAYER_ENTERING_WORLD", compareToShow)

SlashCmdList["NDUICHANGELOG"] = changelog
SLASH_NDUICHANGELOG1 = "/ncl"