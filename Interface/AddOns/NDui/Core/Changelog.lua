local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"移除对旧版本的兼容部分；",
	"修正邮箱收取暴雪邮件可能卡住的问题；",
	"修正关闭能量条后头像buff框体不可见的问题；",
	"Buff框体添加合并增益的功能；",
	"头像及团队框体添加渐变职业色的风格；",
	"更新LibHealComm及萨满诅咒驱散的判断；",
	"小地图追踪按钮调整；",
	"微型菜单调整；",
	"修正团队框体点击施法滚轮失效的问题；",
	"更新部分法术监控；",
	"施法条更新，添加宠物施法条以应对部分任务；",
	"拾取框的移动也影响成就通知框体；",
	"更新部分缺失的美化；",
	"可以跟正式服一样按住ALT展开装备的可选切换；",
	"添加选项以关闭队伍职责显示；",
	"添加选项以关闭副坦仇恨显示；",
	"添加术士恶魔变形的动作条切换；",
	"添加提示给不更新Questie又不知道发报错只知道报怨插件的傻子。",
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