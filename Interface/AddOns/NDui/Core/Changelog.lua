local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"优化任务交接对战团完成情况的支持；",
	"部分库文件更新；",
	"界面美化更新；",
	"修正目标装备神器时观察报错的问题；",
	"姓名板稀有图标层级调整；",
	"修复部分失效API的报错；",
	"战团银行标签需要禁用背包才可以解锁；",
	"修正姿态动作条的移动模块尺寸；",
	"修正鼠标提示中的物品银行计数；",
	"鼠标提示的套装计数更新；",
	"游戏菜单尺寸调整；",
	"修正考古计数条的错误；",
	"修正Tomtom和WIM插件被错误收纳的问题；",
	"更新物品使用通报的列表；",
	"修正系统背包及银行的装等显示；",
	"姓名板软目标的支持更新；",
	"部分技能监控更新；",
	"修正施放充能技能时的报错；",
	"优化动作条快捷键对Mac的支持；",
	"优化动作条快捷键的快速绑定功能；",
	"修正进入地下堡时错误提示；",
	"战团银行调整支持为合并+分类；",
	"修正宠物对战页面双方的品质着色；",
	"修正使用PitBull4时可能引起的报错；",
	"任务额外按钮支持奖励任务；",
	"修正技能监控控制台的一处报错；",
	"部分反馈的问题修正。",
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