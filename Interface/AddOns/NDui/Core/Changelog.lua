local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"版本检测调整；",
	"修正Buff框体尺寸范围；",
	"更新技能监控列表；",
	"重新添加海岛中艾泽里特获取信息过滤；",
	"动作条冷却及预设布局更新；",
	"修正禁用头像后武僧酒池条的可见性；",
	"语言过滤器选项调整；",
	"姓名板过滤更新；",
	"自动交互列表更新；",
	"更正头像的标签刷新；",
	"添加扎雷殁提斯的地图数据；",
	"界面美化更新；",
	"添加MRT计时条的美化；",
	"添加对SoulshapeJournal的美化；",
	"震荡计时条和易爆统计支持军团及比赛服；",
	"信息条时间模块更新；",
	"修正其他语系客户端的背包搜索功能；",
	"装备方案的装备不会被自动售出；",
	"团队框体添加选项以关闭鼠标提示；",
	"团队等框体添加增长方向的选项；",
	"修正鼠标提示框状态条的颜色刷新；",
	"优化颜色选择器；",
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