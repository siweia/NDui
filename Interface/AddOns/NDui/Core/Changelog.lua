local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"移除血量定时刷新的选项；",
	"更新oUF核心；",
	"添加选项以切换职责显示方式；",
	"界面美化更新；",
	"修正货币转移失效的问题；",
	"修正专业快捷标签的错误；",
	"更正社区盛宴的计时器；",
	"添加选项以调整姓名板的显示距离；",
	"修正去除迷雾功能残留的阴影；",
	"修正姓名板的大米进度显示的报错；",
	"修正玩家搜索面板的职业染色；",
	"优化背包的搜索功能；",
	"战团银行的金币显示调整；",
	"背包过滤添加战团装绑的分类；",
	"盗贼申斥回响的材质更新；",
	"猎人的相关监控调整；",
	"自动交互对话的功能调整；",
	"添加萨满天怒的技能缺失提示；",
	"WA的美化支持修改版WA；",
	"修正声望条的等级显示；",
	"为防止污染调整聊天窗口字号的调整；",
	"添加选项以调整聊天输入框的字号；",
	"稀有缺失提示忽略前夕事件的龙蛋；",
	"部分反馈的问题调整。",
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