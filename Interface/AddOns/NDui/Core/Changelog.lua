local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"更新支持9.0.5；",
	"更新技能监控及姓名板过滤；",
	"界面美化部分模块更新；",
	"VenturePlan及DBM的美化更新；",
	"更新预设的小队监控；",
	"调整小队监控的按钮的重置逻辑；",
	"修正附魔幻象的已学会染色；",
	"额外任务按钮调整；",
	"任务通报不再重复通告世界任务的交接；",
	"世界任务我们会使你成为候选者的工具优化；",
	"背包装等显示性能优化；",
	"商人页面添加装等显示；",
	"萨满的个人资源条调整；",
	"姓名板的易爆缩放调整至1.5倍；",
	"姓名板添加法术目标显示的功能，默认关闭；",
	"姓名板添加焦点染色功能，默认关闭；",
	"个人资源条添加治疗预估；",
	"添加快速跳过过场动画功能，默认关闭；",
	"添加试衣间卸装预览按钮；",
	"右键点击附魔按钮可直接生效至羊皮纸；",
	"移除插件自动售出垃圾后的通报；",
	"添加选项以修改快速目标标记的修饰键；",
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