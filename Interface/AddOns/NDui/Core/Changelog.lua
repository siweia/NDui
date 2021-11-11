local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"修正信息条的金币统计显示；",
	"界面美化部分模块更新；",
	"隐藏信息条后自动出售及修理依旧生效；",
	"信息条公会模块更新；",
	"移除信息条的征服点数统计；",
	"修正初始背包为空时显示错位的问题；",
	"修正初始银行栏位存放装备时装等异常的问题；",
	"移除背包分组排序，添加每列背包及银行数量选项；",
	"修正背包状态栏开关状态无法保存的问题；",
	"优化各背包之间的排序；",
	"添加部分帮助信息提示；",
	"按住ALT双击预创建队伍为填写备注；",
	"姓名板的稀有指示器的位置调整；",
	"优化姓名板的相关选项，支持更多自定义；",
	"动作条的相关选项调整；",
	"动作条支持自定义，可与他人分享布局；",
	"暂时禁用藏品手册的移动功能；",
	"稀有通报在聊天框的信息调整为坐标超链接；",
	"按住shift指向目标时显示与你的声望状态；",
	"优化聊天窗口tab切换标签功能；",
	"添加选项以关闭背景线条；",
	"更新部分法术监控；",
	"控制台及本地文本更新。"
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