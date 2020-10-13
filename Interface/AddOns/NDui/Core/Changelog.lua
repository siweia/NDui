local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"API更新；",
	"界面美化更新；",
	"聊天背景选项更新；",
	"动作条更新，添加额外动作条选项；",
	"快速按键绑定功能调整；",
	"更新部分技能监控；",
	"更新全职业个人资源条；",
	"技能缺失提示更新，支持萨满的武器附魔；",
	"Buff框体及其选项更新；",
	"更新oUF核心及相关框架；",
	"团队工具更新；",
	"图腾助手调整为全职业可用；",
	"移除武僧雕像助手；",
	"添加世界标记工具条选项，默认关闭；",
	"任务助手相关更新；",
	"地图去迷雾数据更新；",
	"稀有警报现在只包括稀有相关事件；",
	"移除腐蚀信息相关；",
	"信息条公会及好友模块更新；",
	"邮箱助手更新；",
	"添加导灵器的收集状态提示；",
	"控制台及本地文本更新；",
	"其他大量修正及更新以适配9.0。",
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
		B.CreateFS(f, 14, n..": "..t, false, "TOPLEFT", 15, -(50 + offset))
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