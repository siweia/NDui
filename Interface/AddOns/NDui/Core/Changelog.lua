local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"界面美化更新；",
	"Rematch及PGF美化更新；",
	"添加对WarPlan的简单美化；",
	"WA美化更新对异形图标的裁剪；",
	"技能缺失提示更新；",
	"技能监控及施法条跳数更新；",
	"骑士、盗贼及武僧的个人资源条更新；",
	"版本对比修正；",
	"额外任务按钮及任务通报功能修正；",
	"聊天框密语提示高亮更新；",
	"oUF核心更新，并修正酒仙酒池条的刷新；",
	"施法条的字号现在跟随头像字号的整体缩放；",
	"添加选项以调整简易战斗信息字号；",
	"姓名板添加斩杀指示器；",
	"背包过滤及搜索修正；",
	"背包材料银行存放按钮支持自动存放；",
	"可以快速清空背包的垃圾分类列表；",
	"邮箱联系人列表现在没有上限；",
	"修正拍卖行物品的已学会染色；",
	"动作条及快速按键模式调整；",
	"小地图忽略来自玩家自身的点击提示；",
	"右键点击要塞按钮可以切换不同的要塞系统；",
	"鼠标提示更新，添加对第三方插件的支持；",
	"账号钥石信息按钮调整；",
	"添加选项以关闭世界地图增强模块；",
	"控制台及本地文本更新。",
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