local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"小地图回收站图标层级调整；",
	"密语提醒调整，添加选项以关闭；",
	"重构了姓名板任务指示器；",
	"界面美化部分模块更新；",
	"WA美化调整；",
	"额外任务按钮数据更新；",
	"修正打断通报等开关异常的问题；",
	"添加统御碎片的快速抽插功能；",
	"添加选项以调整世界标记助手的尺寸；",
	"优化垃圾自动出售功能；",
	"背包过滤更新，添加刻希亚圣物分类；",
	"背包添加分组排序的功能，默认关闭；",
	"背包工具栏调整；",
	"优化背包的搜索功能；",
	"聊天时间戳支持显示本地或服务器时间；",
	"更新部分法术监控及姓名板过滤；",
	"优化技能监控的性能；",
	"添加焦点为传送门时的指示器；",
	"连击点支持使用格里恩橙的盗贼。",
}

local f
local function changelog()
	if f then f:Show() return end

	f = CreateFrame("Frame", "NDuiChangeLog", UIParent)
	f:SetPoint("CENTER")
	f:SetFrameStrata("HIGH")
	B.CreateMF(f)
	B.SetBD(f)
	B.CreateFS(f, 18, DB.Version.." "..L["Changelog"], true, "TOP", 0, -10)
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