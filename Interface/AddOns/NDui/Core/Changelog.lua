local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"界面美化更新；",
	"小队及团队框体相关选项调整；",
	"在聊天框发送的坐骑链接显示是否已学会；",
	"Details美化更新，不再总是打开的状态；",
	"姓名板的稀有指示器材质调整；",
	"调整状态条平滑度的范围，为1则关闭；",
	"更新物品使用通报列表；",
	"更新集市及初诞者圣墓的相关法术监控；",
	"替换大米解密词缀的相关法术图标；",
	"技能监控更新；",
	"优化buff框体的性能；",
	"聊天复制功能更新；",
	"启用语言过滤器不再阻止团队管理的开关；",
	"个人资源条更新，添加射击4T29能量监控；",
	"移除对旧版本的兼容；",
	"小地图点击提示更新；",
	"小地图回收站添加自动关闭的开关；",
	"暴雪自带点击施法面板现在可移动；",
	"更新部分自动交互忽略列表；",
	"自动攻击计时条不再依附于施法条；",
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