local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local hx = {
	"AuroraClassic更新至1.9.4；",
	"更新技能及团本法术监控；",
	"考古统计修正；",
	"信息条印记统计支持新好运币；",
	"更新自动交互的忽略列表；",
	"优化打断驱散等的通报表现；",
	"添加控场技能打破的通报；",
	"取消聊天框中对AFK/DND等的信息调整；",
	"调整大米公会记录对AngryKeystones的支持；",
	"鼠标提示信息调整；",
	"添加艾泽里特护甲特质信息的显示；",
	"更新oUF核心；",
	"调整竞技场准备阶段的目标框体；",
	"聊天窗口的相关元素调整；",
	"修正分辨率调整后聊天框体错位的问题；",
	"BUFF检查添加对卷轴的监控；",
	"团队框体快速施法现在支持鼠标上下滚轮；",
	"法师/DH/术士职业助手调整；",
	"拆解机现在也显示物品装等；",
	"过滤海岛探险中的艾泽里特获取信息；",
	"控制台及本地文本更新；",
	"控制台添加姓名板的颜色调整选项；",
	"姓名板添加指向高亮；",
	"部分反馈的问题修正。",
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
	if not NDuiADB["Changelog"] then NDuiADB["Changelog"] = {} end

	local old1, old2 = string.split(".", NDuiADB["Changelog"].Version or "")
	local cur1, cur2 = string.split(".", DB.Version)
	if old1 ~= cur1 or old2 ~= cur2 then
		changelog()
		NDuiADB["Changelog"].Version = DB.Version
	end

	B:UnregisterEvent(event, compareToShow)
end
B:RegisterEvent("PLAYER_ENTERING_WORLD", compareToShow)

SlashCmdList["NDUICHANGELOG"] = changelog
SLASH_NDUICHANGELOG1 = "/ncl"