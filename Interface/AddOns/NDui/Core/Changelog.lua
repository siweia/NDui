local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"更新部分技能监控；",
	"更新技能缺失提示；",
	"界面美化更新；",
	"任务自动交接优化；",
	"修正动作条的预设方案；",
	"动作条更新，未锁定时拖动不再点击；",
	"鼠标提示更新，部分场景下不再显示双图标；",
	"修复鼠标提示的法术ID部分场景失效的问题；",
	"鼠标提示移除导灵器学习状态；",
	"背包过滤更新；",
	"更新鼠标中键的快速战复功能；",
	"鼠标提示的套装计数修改为T29；",
	"更新预创建的副本过滤列表；",
	"修复声望追踪条的一个错误；",
	"恩护绑定自然平衡时自动切换至净除；",
	"信息条移除爬塔信息；",
	"姓名板支持交互目标的显示；",
	"优化姓名板的激励合并和dot染色；",
	"技能监控饰品栏位忽略红玉雏龙蛋壳；",
	"重做了施法条的充能效果。",
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