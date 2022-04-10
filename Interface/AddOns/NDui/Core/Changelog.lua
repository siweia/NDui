local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"优化buff框体的性能；",
	"修正聊天复制有时候错位的问题；",
	"Details美化更新；",
	"小地图回收站添加自动收藏功能；",
	"添加选项以设置小地图回收站黑名单；",
	"自动攻击计时条不再依附施法条，并添加更多选项；",
	"设置导入导出更新；",
	"姓名板名字模式过滤更新，并添加更多选项；",
	"姓名板添加部分cvar选项；",
	"更正姓名板最大显示范围选项；",
	"姓名板目标指示器添加动画效果；",
	"重做去除地图迷雾功能；",
	"重做任务列表拓展功能；",
	"界面美化更新，并支持1.14.3；",
	"修正鼠标提示框中玩家的标记信息；",
	"oUF及LHC更新；",
	"姓名板添加选项以开关可驱散法术及法术打断来源；",
	"姓名板添加队友关注统计功能；",
	"动作条冷却格式调整；",
	"添加选项以调整动作条冷却格式阈值；",
	"修正动作条布局分享功能；",
	"团队减益添加其他分组，用于监控非副本场景；",
	"添加选项以设置最大视距等级；",
	"未启用全局描边时保留聊天窗口字体阴影；",
	"添加选项以调整团队框体增减益指示器的点击穿越；",
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