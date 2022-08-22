local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"LibHealComm更新；",
	"小地图调整；",
	"头像相关调整，添加透明样式；",
	"支持将头像及团队框体的能量条设置为0；",
	"姓名板的精英图标材质更新；",
	"WLK: 修正任务追踪的移动控制；",
	"WLK: 添加货币ID显示；",
	"WLK: 背包添加装备配置方案分类；",
	"WLK: 修正繁体客户端下暴雪的部分报错；",
	"WLK: 系统UI美化更新；",
	"WLK: 支持萨满图腾动作条，右键点击移除；",
	"WLK: 添加获得成就自动截图的选项；",
	"WLK: DK符文系统相关更新；",
	"WLK：禁用回能回蓝指示器；",
	"WLK：猎人自动攻击计时条调整；",
	"WLK：玩家属性面板调整；",
	"WLK: 信息条货币模块调整；",
	"WLK: 姓名板添加副坦仇恨调整；",
	"WLK: 地图迷雾数据更新。",
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