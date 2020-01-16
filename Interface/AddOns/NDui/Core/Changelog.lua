local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"更新支持8.3；",
	"更正宠物来源的标签；",
	"添加Skada及Details皮肤开关的移动选项；",
	"Details的皮肤调整；",
	"角色面板显示艾泽里特护甲特质；",
	"邮箱添加联系人列表的功能；",
	"小地图回收站的位置调整；",
	"添加背包堆叠物品快速拆分的功能；",
	"背包选项调整时刷新状态；",
	"背包逆序整理调整；",
	"添加特殊背包染色的功能；",
	"添加背包装等显示阈值选项；",
	"背包背景颜色微调，防止全黑时看不清；",
	"分辨率调整后重新设置聊天窗口尺寸；",
	"更新盗贼的职业助手；",
	"专业标签添加热流铁砧和开锁；",
	"专业面板添加快速过滤的功能；",
	"团队工具的菜单根据位置自动调整方向；",
	"点击施法中现在使用~来进行换行；",
	"团队等框体的尺寸调节添加了独立设置页；",
	"团队减益以及边角指示器可以快速缩放；",
	"禁用边角指示器后，buff监控依然使用其设置过滤；",
	"边角增益指示器的模式切换即时生效；",
	"小队技能监控上限调整为6个；",
	"修复暴雪自带插件列表滚动时的一个报错；",
	"UI缩放调整；",
	"整合AuroraClassc相关功能；",
	"移除Skada和AuroraClassic；",
	"延长副本锁定按钮添加帮助说明；",
	"添加选项以屏蔽陌生人密语，默认关闭；",
	"更新微型菜单的图标材质；",
	"控制台及本地文本更新。",
}

local f
local function changelog()
	if f then f:Show() return end

	f = CreateFrame("Frame", "NDuiChangeLog", UIParent)
	f:SetPoint("CENTER")
	f:SetScale(1.2)
	f:SetFrameStrata("HIGH")
	B.CreateMF(f)
	B.SetBD(f)
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