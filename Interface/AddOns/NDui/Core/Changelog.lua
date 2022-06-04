local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"技能使用通报更新；",
	"界面美化更新；",
	"添加对ProtoformSynthesisFieldJournal的美化；",
	"ATT及WA的美化更新；",
	"背包物品计数调整；",
	"修正对宠物动作条发送冷却时的报错；",
	"小地图回收站更新；",
	"背包偏好过滤调整，支持最高5个分组；",
	"设置导入导出调整，仅接受6.23.2及以上的数据；",
	"技能监控更新；",
	"确保超链接的配方名字不再显示两行；",
	"修正副本中石头汤锅引起的鼠标提示报错；",
	"聊天窗口的消息上限增加到2048行；",
	"姓名板添加始终显示可驱散法术的选项；",
	"姓名板过滤及相关选项优化；",
	"移除对旧版本的兼容；",
	"预创建队伍的列表显示其阵营限制；",
	"好友列表同时显示对立阵营的职业颜色；",
	"优化信息条好友模块；",
	"部分反馈的问题调整；",
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