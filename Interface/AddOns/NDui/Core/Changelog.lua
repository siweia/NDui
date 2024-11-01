local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"背包过滤更新；",
	"更新部分技能监控；",
	"更新S1的相关副本监控；",
	"界面美化更新；",
	"信息条金币模块的显示调整；",
	"信息条时间模块的追踪更新；",
	"移除部分失效的代码；",
	"更新治疗预估模块；",
	"控制台布局调整；",
	"添加选项以调整头像增益的位置；",
	"添加选项显示团队框体的吸收数值；",
	"DBM的屏蔽选项更新；",
	"修正右键菜单公会邀请失效的问题；",
	"修正角色面板缺失属性的显示；",
	"姓名板的进度显示现在改用MDT数据；",
	"更新部分插件刷屏的屏蔽；",
	"通知通报添加仅有权限时通报功能，默认开启；",
	"修正社区公会聊天字体和聊天窗口不同步的问题；",
	"修正预创建自动邀请选项失效的问题；",
	"额外动作条按钮添加距离染色；",
	"部分反馈的问题修正。",
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