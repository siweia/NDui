local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local hx = {
	"AuroraClassic更新至1.8.11；",
	"更新技能及团本法术监控；",
	"添加动作条缩放选项；",
	"优化SHIFT+左键复制名字的功能；",
	"公会信息条的复制及邀请跟随快捷键；",
	"订单及补给需求的世界任务不再通报；",
	"添加选项只播放任务完成的提示音；",
	"萨满，痛苦术及射击猎的职业助手调整；",
	"聊天过滤更新，屏蔽WQT的自动邀请；",
	"在交易窗口上显示目标信息；",
	"界面美化更新，移除ExtraCD插件美化；",
	"姓名板调整；",
	"打断及技能监控触发器等支持宠物来源；",
	"打断提示默认只在非随机的副本中生效；",
	"移除工程移形换影装置通报的功能；",
	"控制台及本地文本更新；",
	"部分潜在的污染修正。",
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