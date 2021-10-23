local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"更新9.1.5新增UI元素的美化；",
	"更新部分技能监控；",
	"目标死亡后不再隐藏鼠标提示的状态条；",
	"调整档案员等个人声望的巅峰在声望条上的显示；",
	"修正动作条1在灰烬王庭的翻页；",
	"按住ALT点击对话窗口的NPC名字可屏蔽不再自动交接任务；",
	"优化额外任务按钮在法夜突袭时的显示；",
	"VenturePlan的美化更新，现在每行5个随从；",
	"BaudErrorFrame更新，支持捕捉中文WA的报错；",
	"更新记录面板调整，显示正确的版本号；",
	"添加独立设置友方姓名板尺寸的选项；",
	"添加姓名板血量垂直偏移的选项；",
	"目标稀有指示图标位置调整；",
	"单位框体的数值标签更新；",
	"账号角色钥石统计调整；",
	"给信息条添加部分选项，并使其可以游戏内移动；",
	"优化背包调整的选项；",
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