local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"AuroraClassic更新到2.6.7；",
	"更新oUF核心；",
	"更正鼠标提示中法术图标的裁剪；",
	"小地图图标回收站更新；",
	"背包支持拆解机的物品匹配；",
	"移除收割怪的染色，因为仇恨值可以获取了；",
	"更新部分法术监控；",
	"更新小队监控的法术；",
	"背包调整，在拆解机和商人处过滤装备方案的装备；",
	"公会信息条调整，组队时区域信息显示为蓝色；",
	"信息条的金币重置只针对本服务器角色；",
	"更正其他服务器的入侵时间；",
	"初始设置的cvar整理；",
	"技能监控优化，移除对档案库的支持；",
	"聊天相关功能更新，世界频道按钮不限制语系；",
	"修复载具上动作条的刷新异常的问题；",
	"账号钥石信息显示调整",
	"现在装等精确到十分位；",
	"经验条调整；",
	"添加选项，默认只在团本中启用聊天气泡；",
	"姓名板任务标记添加对部分异常任务的支持；",
	"姓名板目标高亮箭头调整，可以选择其方向；",
	"UI缩放调整，以应对某些奇怪的操作；",
	"部分美化调整。",
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
	if HelloWorld then return end

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