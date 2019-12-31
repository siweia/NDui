local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"AuroraClassic更新到3.2.9；",
	"添加选项以关闭背包物品高亮；",
	"添加选项以调整头像相关文本字号缩放；",
	"防止某些插件强制禁用暴雪框体后引起的报错；",
	"背包栏位按钮仅在右键点击时过滤；",
	"修复初始背包为空时的异常显示问题；",
	"修复合并剩余背包时的一处污染；",
	"背包边框调整；",
	"更新姓名板的法术过滤；",
	"背包信息框体尺寸微调；",
	"Details的皮肤更新，不再锁定字号；",
	"更新插件扰屏过滤；",
	"修正好友信息条的邀请功能；",
	"小地图图标回收站更新；",
	"考古信息统计更新；",
	"考古进度条显示当前进度；",
	"战场的顶部信息调整；",
	"垃圾社区邀请屏蔽列表更新；",
	"添加选项以关闭自动填写DELETE；",
	"添加小队的宠物框体，默认关闭；",
	"自动攻击计时条调整；",
	"微型菜单更新；",
	"控制台及本地文本更新；",
	"为8.3进行部分预更新。",
}

local f
local function changelog()
	if f then f:Show() return end

	f = CreateFrame("Frame", "NDuiChangeLog", UIParent)
	f:SetPoint("CENTER")
	f:SetScale(1.2)
	f:SetFrameStrata("HIGH")
	B.CreateMF(f)
	B.CreateBD(f)
	B.CreateSD(f)
	B.CreateTex(f)
	B.CreateFS(f, 30, "NDui", true, "TOPLEFT", 10, 26)
	B.CreateFS(f, 14, DB.Version, true, "TOPLEFT", 90, 14)
	B.CreateFS(f, 16, L["Changelog"], true, "TOP", 0, -10)
	local ll = CreateFrame("Frame", nil, f)
	ll:SetPoint("TOP", -50, -35)
	B.CreateGF(ll, 100, 1, "Horizontal", .7, .7, .7, 0, .7)
	ll:SetFrameStrata("HIGH")
	local lr = CreateFrame("Frame", nil, f)
	lr:SetPoint("TOP", 50, -35)
	B.CreateGF(lr, 100, 1, "Horizontal", .7, .7, .7, .7, 0)
	lr:SetFrameStrata("HIGH")
	local offset = 0
	for n, t in pairs(hx) do
		B.CreateFS(f, 12, n..": "..t, false, "TOPLEFT", 15, -(50 + offset))
		offset = offset + 20
	end
	f:SetSize(400, 60 + offset)
	local close = B.CreateButton(f, 16, 16, "X")
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