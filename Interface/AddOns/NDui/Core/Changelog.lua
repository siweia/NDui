local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"修复好友列表无法邀请的问题；",
	"优化系统预创建，添加自动邀请等功能；",
	"右键预创建刷新按钮，可以指定地下城；",
	"优化插件PGF的功能，添加快捷排序功能；",
	"oUF核心更新；",
	"更正Boss等框体施法条不随尺寸变化的问题；",
	"Boss框体理论上支持8个目标；",
	"更正温西尔战士的个人资源条；",
	"更新技能监控及副本技能列表；",
	"猎人4件套监控更新；",
	"噬渊进度条功能移除；",
	"界面美化更新，添加新的材质图标；",
	"更新破空通报的技能黑名单；",
	"修正部分UI缩放下动作条缩放异常的问题；",
	"更正Buff框体的尺寸范围；",
	"坐骑收集状态只针对聊天窗口的超链接；",
	"插件数据转移调整；",
	"更新姓名板法术过滤；",
	"姓名板新增部分选项；",
	"姓名板名字模式的过滤及选项更新；",
	"姓名板目标指示器添加动效；",
	"在鼠标提示的装等旁显示套装数量；",
	"鼠标提示的职责信息调整；",
	"修复宏图秘术饰品缺失提示失效的问题；",
	"添加对9.2.5的预更新；",
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