local B, C, L, DB = unpack(select(2, ...))
if DB.Client ~= "zhCN" then return end

local hx = {
	"Aurora部分模块调整；",
	"更新部分法术；",
	"更新NPC过滤列表；",
	"聊天过滤更新；",
	"优化信息条低耐久提醒；",
	"头像及团队框体调整；",
	"BOSS/竞技场框体及其施法条调整；",
	"控制台调整；",
	"插件面板移动控制调整；",
	"附加控制台简化，现在会预输入部分选项；",
	"团队工具的就位确认指示器调整，只监视在线的玩家；",
	"默认关闭简易战斗信息的过量治疗；",
	"Buff栏调整，debuff会比buff略大；",
	"团队工具的倒数按钮现在是按下即响应；",
	"更新姓名板的相关过滤列表；",
	"修复部分潜在的内存泄露。",
}

local function changelog()
	local f = CreateFrame("Frame", "NDuiChangeLog", UIParent)
	f:SetPoint("CENTER")
	f:SetScale(1.2)
	f:SetFrameStrata("HIGH")
	B.CreateMF(f)
	B.CreateBD(f)
	B.CreateTex(f)
	B.CreateFS(f, 30, "NDui", true, "TOPLEFT", 10, 25)
	B.CreateFS(f, 14, DB.Version, true, "TOPLEFT", 90, 12)
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
	local close = B.CreateButton(f, 20, 20, "X")
	close:SetPoint("TOPRIGHT", -10, -10)
	close:SetScript("OnClick", function() f:Hide() end)
end

NDui:EventFrame{"PLAYER_ENTERING_WORLD"}:SetScript("OnEvent", function(self)
	self:UnregisterAllEvents()
	if HelloWorld then return end
	if not NDuiADB["Changelog"] then NDuiADB["Changelog"] = {} end

	local old1, old2 = string.split(".", NDuiADB["Changelog"].Version or "")
	local cur1, cur2 = string.split(".", DB.Version)
	if old1 ~= cur1 or old2 ~= cur2 then
		changelog()
		NDuiADB["Changelog"].Version = DB.Version
	end
end)

SlashCmdList["NDUICHANGELOG"] = function()
	if not NDuiChangeLog then changelog() else NDuiChangeLog:Show() end
end
SLASH_NDUICHANGELOG1 = '/ncl'