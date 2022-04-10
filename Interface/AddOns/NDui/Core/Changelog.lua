local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"更正姓名板可驱散法术选项无法保存的问题；",
	"更正聊天复制有时候文本错位的问题；",
	"地图迷雾重做；",
	"预设的边角指示器更新；",
	"姓名板法术过滤更新；",
	"修正鼠标提示框不显示玩家标记的问题；",
	"添加选项以显示姓名板队友关注目标；",
	"姓名板箭头动效支持侧边箭头；",
	"oUF核心更新；",
	"动作条冷却的计时格式调整；",
	"动作条冷却添加计时阈值选项；",
	"团队框体的副本减益添加其他分组，以监控非副本情况；",
	"添加选项以调整团队框体增减益的点击穿越；",
	"挑战页面的每周前十记录现在支持显示全部；",
	"技能缺失提示支持永久符文；",
	"配置导入导出调整；",
	"修正未启用姿态条时动作条的配置分享；",
	"小地图回收站支持黑名单；",
	"移除鼠标滚轮相关的任务助手；",
	"射击四件套集中监控在首领战开启时重置；",
	"添加选项以调整最大视距距离；",
	"界面美化更新，添加对9.2.5的相关改动；",
	"未启用全局描边时聊天框字体保留阴影；",
	"右键交互色块按钮支持战网聊天相关；",
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
		B.CreateFS(f, 14, n..". "..t, false, "TOPLEFT", 15, -(50 + offset))
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