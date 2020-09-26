local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end
if DB.isNewPatch then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"部分材质调整；",
	"单位框体的团队标记调整；",
	"界面美化调整；",
	"姓名板友方模式过滤调整；",
	"WA美化调整；",
	"提高施法条的层级；",
	"控制台及本地文本更新；",
	"个人资源条淡出时调整；",
	"个人资源条添加GCD指示器；",
	"个人资源条满能量时会红色，移除高亮；",
	"打开拍卖行或者交易时自动开关背包；",
	"动作条的冷却计时调整；",
	"添加选项以关闭BOSS表情框体；",
	"聊天栏中的物品宝石信息调整；",
	"信息条金币统计调整；",
	"聊天窗口的美化调整。",
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