-- NDui 关键词监控模块 - 完整版
-- 参考 Pig 插件的关键词提取功能

local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

-- 本地化函数
local gsub, match, upper, strsplit, strlower, gmatch, find, sub = string.gsub, string.match, string.upper, strsplit, string.lower, string.gmatch, string.find, string.sub
local GetServerTime, date, GetTime = GetServerTime, date, GetTime
local InCombatLockdown, PlaySound = InCombatLockdown, PlaySound
local Ambiguate, IsShiftKeyDown, UnitName = Ambiguate, IsShiftKeyDown, UnitName
local C_Timer, C_FriendList, C_BattleNet = C_Timer, C_FriendList, C_BattleNet
local BNGetNumFriends, BNGetFriendInfoByID = BNGetNumFriends, BNGetFriendInfoByID
local tinsert, tremove = table.insert, table.remove
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local FCF_StartAlertFlash, FCF_SetChatWindowFontSize = FCF_StartAlertFlash, FCF_SetChatWindowFontSize
local GeneralDockManager = GeneralDockManager
local GetColoredName, GetPlayerLink = GetColoredName, GetPlayerLink
local ChatFrame_ReplaceIconAndGroupExpressions = C_ChatInfo and C_ChatInfo.ReplaceIconAndGroupExpressions or ChatFrame_ReplaceIconAndGroupExpressions
local ChatFrame_CanChatGroupPerformExpressionExpansion = ChatFrame_CanChatGroupPerformExpressionExpansion
local BNET_CLIENT_WOW = BNET_CLIENT_WOW

-- 配置变量（保存到 NDuiADB）
-- 注意：不使用本地 config 变量，直接引用 NDuiADB["KeywordMonitor"]
-- 这样可以确保配置在 SavedVariables 加载后立即可用

-- 全局变量
local keywordFrame
local keywords = {}
local keywordButton
local configFrame
local lastSoundTime = 0
local repeatMessageCache = {} -- 重复消息缓存

-- 初始化配置（仅在首次使用时创建默认值）
local function EnsureConfig()
	-- 注意：NDuiADB 在 Init.lua 中被重置为 {}，所以我们需要确保子表存在
	if not NDuiADB["KeywordMonitor"] then
		NDuiADB["KeywordMonitor"] = {}
	end
	
	-- 为每个配置项设置默认值（如果不存在）
	local cfg = NDuiADB["KeywordMonitor"]
	if cfg["Enabled"] == nil then cfg["Enabled"] = false end
	if cfg["Keywords"] == nil then cfg["Keywords"] = "" end
	if cfg["AudioEnabled"] == nil then cfg["AudioEnabled"] = true end
	if cfg["OutputMode"] == nil then cfg["OutputMode"] = 2 end
	if cfg["OutputChatFrame"] == nil then cfg["OutputChatFrame"] = 1 end
	if cfg["FlashOnMatch"] == nil then cfg["FlashOnMatch"] = true end
	if cfg["CombatHide"] == nil then cfg["CombatHide"] = false end
	if cfg["InheritFilter"] == nil then cfg["InheritFilter"] = true end
	if cfg["KeywordFrameHeight"] == nil then cfg["KeywordFrameHeight"] = 180 end
	if cfg["BgColor"] == nil then cfg["BgColor"] = {0, 0, 0, 0.4} end
end

-- 检查是否是好友
local function IsFriend(name)
	if not name then return false end
	
	-- 检查 WoW 好友
	local numOnline = C_FriendList.GetNumOnlineFriends()
	for i = 1, numOnline do
		local info = C_FriendList.GetFriendInfoByIndex(i)
		if info and info.name == name then
			return true
		end
	end
	
	-- 检查战网好友
	local _, numBNetOnline = BNGetNumFriends()
	for i = 1, numBNetOnline do
		local numGameAccounts = C_BattleNet.GetFriendNumGameAccounts(i)
		for j = 1, numGameAccounts do
			local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(i, j)
			if gameAccountInfo and gameAccountInfo.clientProgram == BNET_CLIENT_WOW then
				if gameAccountInfo.characterName == name then
					return true
				end
			end
		end
	end
	
	return false
end

-- 检查是否是重复消息
local function IsRepeatMessage(text)
	local currentTime = GetTime()
	
	-- 清理60秒前的缓存
	for i = #repeatMessageCache, 1, -1 do
		if currentTime - repeatMessageCache[i].time > 60 then
			tremove(repeatMessageCache, i)
		end
	end
	
	-- 检查是否重复
	for _, cache in ipairs(repeatMessageCache) do
		if cache.text == text then
			return true
		end
	end
	
	-- 添加到缓存
	tinsert(repeatMessageCache, {text = text, time = currentTime})
	return false
end

-- 工具函数：分割字符串
local function SplitString(str, delimiter)
	local result = {}
	if not str or str == "" then return result end
	
	str = gsub(str, "，", ",")
	for word in gmatch(str, "[^"..delimiter.."]+") do
		word = gsub(word, "^%s*(.-)%s*$", "%1")
		if word ~= "" then
			tinsert(result, word)
		end
	end
	return result
end

-- 清理文本函数
local function CleanText(text)
	if not text then return "" end
	-- 移除链接
	text = gsub(text, "|H.-|h%[.-%]|h", "")
	-- 移除颜色代码
	text = gsub(text, "|c%x%x%x%x%x%x%x%x", "")
	text = gsub(text, "|r", "")
	-- 移除材质标记
	text = gsub(text, "|T[^|]+|t", "")
	text = gsub(text, "|T[^|]+|T", "")
	-- 移除标点符号和空格
	text = gsub(text, "[%p%s]", "")
	-- 转大写
	text = upper(text)
	return text
end

-- 高亮关键词（在消息中标记匹配的关键词）
local function HighlightKeyword(msg, matchedKeyword)
	if not matchedKeyword or not msg then return msg end
	
	-- 获取关键词字符串
	local keyword = type(matchedKeyword) == "table" and matchedKeyword[1] or matchedKeyword
	if not keyword or keyword == "" then return msg end
	
	-- 简单实现：查找关键词并高亮（不区分大小写）
	-- 注意：这个实现会忽略链接和颜色代码内的匹配
	local upperMsg = upper(msg)
	local upperKeyword = upper(keyword)
	
	-- 查找关键词位置
	local startPos = find(upperMsg, upperKeyword, 1, true)
	if not startPos then return msg end
	
	-- 提取原始大小写的关键词
	local endPos = startPos + #keyword - 1
	local originalKeyword = sub(msg, startPos, endPos)
	
	-- 用绿色高亮替换
	local result = sub(msg, 1, startPos - 1) .. "|cff00FF00" .. originalKeyword .. "|r" .. sub(msg, endPos + 1)
	
	return result
end

-- 检查是否匹配关键词（支持 & 和 # 组合）
local function MatchKeywords(text)
	if #keywords == 0 then return false end
	
	local cleanText = CleanText(text)
	
	for i, keyword in ipairs(keywords) do
		if type(keyword) == "string" then
			-- 单个关键词
			if find(cleanText, keyword, 1, true) then
				return true, keyword
			end
		elseif type(keyword) == "table" then
			-- 组合关键词 (AA#BB 或 AA&CC)
			local allMatch = true
			for _, subKey in ipairs(keyword) do
				local isExclude = sub(subKey, 1, 1) == "&"
				local checkKey = isExclude and sub(subKey, 2) or subKey
				
				if isExclude then
					-- & 表示不包含
					if find(cleanText, checkKey, 1, true) then
						allMatch = false
						break
					end
				else
					-- # 表示必须包含
					if not find(cleanText, checkKey, 1, true) then
						allMatch = false
						break
					end
				end
			end
			
			if allMatch then
				return true, keyword[1]
			end
		end
	end
	
	return false
end

-- 更新关键词列表
function module:UpdateKeywordList(keywordStr)
	keywords = {}
	if not keywordStr or keywordStr == "" then return end
	
	keywordStr = gsub(keywordStr, "，", ",")
	local list = SplitString(keywordStr, ",")
	
	for _, word in ipairs(list) do
		if match(word, "&") or match(word, "#") then
			-- 组合关键词
			local subList = {}
			for subWord in gmatch(word, "[^&#]+") do
				subWord = gsub(subWord, "^%s*(.-)%s*$", "%1")
				if subWord ~= "" then
					tinsert(subList, upper(subWord))
				end
			end
			if #subList > 0 then
				tinsert(keywords, subList)
			end
		else
			-- 单个关键词
			local upperWord = upper(word)
			tinsert(keywords, upperWord)
		end
	end
end

-- 创建独立监控窗口
local function CreateKeywordFrame()
	if keywordFrame then return keywordFrame end
	EnsureConfig()
	
	local frame = CreateFrame("ScrollingMessageFrame", "NDui_KeywordMonitor", UIParent)
	frame:SetSize(ChatFrame1:GetWidth(), NDuiADB["KeywordMonitor"]["KeywordFrameHeight"])
	frame:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 30)
	frame:SetFrameStrata("MEDIUM")
	frame:SetFading(false)
	frame:SetMaxLines(100)
	frame:SetHyperlinksEnabled(true)
	frame:EnableMouse(true)
	frame:EnableMouseWheel(true)
	
	-- 设置字体
	local fontPath, fontSize = ChatFrame1:GetFont()
	frame:SetFont(fontPath, fontSize, "OUTLINE")
	frame:SetShadowColor(0, 0, 0, 0)
	frame:SetJustifyH("LEFT")
	
	-- 使用 NDui 的背景样式
	B.SetBD(frame)
	
	-- 滚动到底部按钮
	local scrollBtn = CreateFrame("Button", nil, frame)
	scrollBtn:SetSize(20, 20)
	scrollBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 5)
	scrollBtn:SetAlpha(0.5)
	
	-- 使用 NDui 的图标样式
	local icon = scrollBtn:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints()
	icon:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollEnd-Up")
	scrollBtn.icon = icon
	
	scrollBtn:Hide()
	scrollBtn:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
	scrollBtn:SetScript("OnLeave", function(self) self:SetAlpha(0.5) end)
	scrollBtn:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_CHAT_BOTTOM)
		frame:ScrollToBottom()
		scrollBtn:Hide()
	end)
	frame.ScrollToBottomButton = scrollBtn
	
	-- 鼠标滚轮
	frame:SetScript("OnMouseWheel", function(self, delta)
		if self:GetNumMessages() == 0 then return end
		scrollBtn:Show()
		if delta == 1 then
			self:ScrollUp()
		else
			self:ScrollDown()
			if self:AtBottom() then
				scrollBtn:Hide()
			end
		end
	end)
	
	frame:Hide()
	keywordFrame = frame
	return frame
end

-- 显示关键词消息
local function ShowKeywordMessage(self, event, msg, author, ...)
	EnsureConfig()
	if not NDuiADB["KeywordMonitor"]["Enabled"] then return false end
	
	-- 获取玩家信息
	local guid = select(11, ...)
	local name = Ambiguate(author, "none")
	
	-- 过滤自己的消息
	if name == UnitName("player") then
		return false
	end
	
	-- 过滤好友消息
	if IsFriend(name) then
		return false
	end
	
	-- 检查关键词匹配
	local matched, keyword = MatchKeywords(msg)
	if not matched then return false end
	
	-- 清理文本用于重复检查
	local cleanMsg = CleanText(msg)
	
	-- 过滤重复消息
	if IsRepeatMessage(cleanMsg) then
		return false
	end
	
	local time = GetServerTime()
	local timeStr = date("%H:%M", time)
	
	-- 获取职业颜色的玩家名
	local coloredName = GetColoredName(event, msg, author, ...)
	local playerLink = GetPlayerLink(author, "["..coloredName.."]")
	
	-- 从 coloredName 中提取职业颜色（用于整条消息）
	local r, g, b = 1, 1, 1  -- 默认白色
	-- coloredName 格式: |cffRRGGBB名字|r
	local colorCode = coloredName:match("|cff(%x%x%x%x%x%x)")
	if colorCode then
		-- 将十六进制颜色转换为 RGB (0-1)
		r = tonumber(colorCode:sub(1, 2), 16) / 255
		g = tonumber(colorCode:sub(3, 4), 16) / 255
		b = tonumber(colorCode:sub(5, 6), 16) / 255
	end
	
	-- 处理消息（转换表情和图标）
	local outMsg = msg
	if ChatFrame_ReplaceIconAndGroupExpressions then
		outMsg = ChatFrame_ReplaceIconAndGroupExpressions(msg, select(17, ...), not ChatFrame_CanChatGroupPerformExpressionExpansion("CHANNEL"))
	end
	
	-- 高亮关键词
	outMsg = HighlightKeyword(outMsg, keyword)
	
	-- 构建输出消息
	local output
	if NDuiADB["KeywordMonitor"]["OutputMode"] == 1 then
		-- 系统模式：添加 [关注] 标记
		output = string.format("|cff808080%s|r [|cff00FF00关注|r] %s: %s", timeStr, playerLink, outMsg)
	else
		-- 独立窗口模式
		output = string.format("|cff808080%s|r %s: %s", timeStr, playerLink, outMsg)
	end
	
	-- 根据输出模式显示（使用职业颜色）
	if NDuiADB["KeywordMonitor"]["OutputMode"] == 1 then
		-- 输出到系统聊天窗口
		local chatFrame = _G["ChatFrame"..NDuiADB["KeywordMonitor"]["OutputChatFrame"]]
		if chatFrame then
			chatFrame:AddMessage(output, r, g, b)
			-- 窗口闪动
			if NDuiADB["KeywordMonitor"]["FlashOnMatch"] and GeneralDockManager.selected ~= chatFrame then
				FCF_StartAlertFlash(chatFrame)
			end
		end
	elseif NDuiADB["KeywordMonitor"]["OutputMode"] == 2 then
		-- 输出到独立窗口
		if keywordFrame and keywordFrame:IsShown() then
			keywordFrame:AddMessage(output, r, g, b)
		end
	end
	
	-- 播放声音
	if NDuiADB["KeywordMonitor"]["AudioEnabled"] then
		PlaySoundFile("Interface\\AddOns\\NDui\\Audio\\FollowMsg_1.ogg", "Master")
	end
	
	return false
end

-- 更新按钮状态
local function UpdateButtonStatus()
	if not keywordButton then return end
	EnsureConfig()
	
	if NDuiADB["KeywordMonitor"]["Enabled"] then
		keywordButton.Icon:SetVertexColor(0, 1, 0)
	else
		keywordButton.Icon:SetVertexColor(1, 0, 0)
	end
end

-- 切换关键词监控
function module:ToggleKeywordMonitor(enable)
	EnsureConfig()
	NDuiADB["KeywordMonitor"]["Enabled"] = enable
	
	-- 先移除过滤器
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CHANNEL", ShowKeywordMessage)
	
	if enable then
		if NDuiADB["KeywordMonitor"]["OutputMode"] == 2 then
			-- 独立窗口模式
			if not keywordFrame then
				CreateKeywordFrame()
			end
			
			if keywordFrame then
				if NDuiADB["KeywordMonitor"]["CombatHide"] then
					if not InCombatLockdown() then
						keywordFrame:Show()
					end
				else
					keywordFrame:Show()
				end
			end
		else
			-- 系统聊天窗口模式：销毁独立窗口
			if keywordFrame then
				keywordFrame:Hide()
				keywordFrame:SetParent(nil)
				keywordFrame = nil
			end
		end
		
		-- 注册过滤器
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", ShowKeywordMessage)
	else
		-- 关闭监控时隐藏独立窗口
		if keywordFrame then
			keywordFrame:Hide()
		end
	end
	
	UpdateButtonStatus()
end

-- 战斗隐藏处理
local function HandleCombatVisibility()
	EnsureConfig()
	if not NDuiADB["KeywordMonitor"]["Enabled"] or NDuiADB["KeywordMonitor"]["OutputMode"] ~= 2 or not NDuiADB["KeywordMonitor"]["CombatHide"] then return end
	if not keywordFrame then return end
	
	if InCombatLockdown() then
		keywordFrame:Hide()
	else
		keywordFrame:Show()
	end
end

-- 由于代码太长，我会继续在下一个文件中添加配置界面和按钮创建

-- 创建配置界面
local function CreateConfigFrame()
	if configFrame then return configFrame end
	EnsureConfig()
	
	local frame = CreateFrame("Frame", "NDui_KeywordConfig", UIParent, "BackdropTemplate")
	frame:SetSize(500, 450)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	B.SetBD(frame)
	frame:Hide()
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	
	-- 标题
	local title = B.CreateFS(frame, 16, "关键词监控设置", true)
	title:SetPoint("TOP", 0, -10)
	
	-- 关闭按钮
	local closeBtn = B.CreateButton(frame, 20, 20, "X")
	closeBtn:SetPoint("TOPRIGHT", -5, -5)
	closeBtn:SetScript("OnClick", function() frame:Hide() end)
	
	-- 启用开关
	local enableCheck = B.CreateCheckBox(frame)
	enableCheck:SetPoint("TOPLEFT", 20, -40)
	enableCheck:SetChecked(NDuiADB["KeywordMonitor"]["Enabled"])
	local enableLabel = B.CreateFS(frame, 14, "启用提取关注信息", false, "LEFT")
	enableLabel:SetPoint("LEFT", enableCheck, "RIGHT", 5, 0)
	enableLabel:SetTextColor(0, 1, 0)
	
	-- 关键词输入框
	local keywordLabel = B.CreateFS(frame, 13, "关键词", false, "LEFT")
	keywordLabel:SetPoint("TOPLEFT", 20, -75)
	
	local keywordBox = B.CreateEditBox(frame, 460, 30)
	keywordBox:SetPoint("TOPLEFT", 20, -95)
	keywordBox:SetMaxLetters(500)
	keywordBox:SetText(NDuiADB["KeywordMonitor"]["Keywords"])
	
	-- 延迟设置 OnTextChanged，避免 SetText 时触发
	C_Timer.After(0, function()
		keywordBox:SetScript("OnTextChanged", function(self)
			local text = self:GetText()
			NDuiADB["KeywordMonitor"]["Keywords"] = text
			module:UpdateKeywordList(text)
		end)
	end)
	
	-- 说明文字
	local helpText = B.CreateFS(frame, 11, "关注关键字  用 , 分隔\nAA : 提取包含AA的内容\nAA#BB : 提取同时包含AA和BB的内容\nAA&CC : 提取包含AA但不包含CC的内容", false, "LEFT")
	helpText:SetPoint("TOPLEFT", 20, -130)
	helpText:SetTextColor(0, 1, 0)
	
	-- 提示音设置
	local audioCheck = B.CreateCheckBox(frame)
	audioCheck:SetPoint("TOPLEFT", 20, -190)
	audioCheck:SetChecked(NDuiADB["KeywordMonitor"]["AudioEnabled"])
	local audioLabel = B.CreateFS(frame, 13, "提示音", false, "LEFT")
	audioLabel:SetPoint("LEFT", audioCheck, "RIGHT", 5, 0)
	
	audioCheck:SetScript("OnClick", function(self)
		local checked = self:GetChecked()
		NDuiADB["KeywordMonitor"]["AudioEnabled"] = checked
	end)
	
	local audioText = B.CreateFS(frame, 12, "有关注消息", false, "LEFT")
	audioText:SetPoint("LEFT", audioLabel, "RIGHT", 10, 0)
	audioText:SetTextColor(0.7, 0.7, 0.7)
	
	-- 继承过滤设置
	local inheritCheck = B.CreateCheckBox(frame)
	inheritCheck:SetPoint("TOPLEFT", 20, -225)
	inheritCheck:SetChecked(NDuiADB["KeywordMonitor"]["InheritFilter"])
	local inheritLabel = B.CreateFS(frame, 13, "继承过滤设置再提取", false, "LEFT")
	inheritLabel:SetPoint("LEFT", inheritCheck, "RIGHT", 5, 0)
	
	inheritCheck:SetScript("OnClick", function(self)
		local checked = self:GetChecked()
		NDuiADB["KeywordMonitor"]["InheritFilter"] = checked
	end)
	
	-- 输出方式
	local outputLabel = B.CreateFS(frame, 14, "输出方式:", false, "LEFT")
	outputLabel:SetPoint("TOPLEFT", 20, -260)
	
	-- 系统聊天窗口
	local systemRadio = B.CreateCheckBox(frame)
	systemRadio:SetPoint("TOPLEFT", 40, -285)
	systemRadio:SetChecked(NDuiADB["KeywordMonitor"]["OutputMode"] == 1)
	local systemLabel = B.CreateFS(frame, 13, "系统聊天窗口", false, "LEFT")
	systemLabel:SetPoint("LEFT", systemRadio, "RIGHT", 5, 0)
	
	-- 独立聊天窗口
	local independentRadio = B.CreateCheckBox(frame)
	independentRadio:SetPoint("LEFT", systemLabel, "RIGHT", 30, 0)
	independentRadio:SetChecked(NDuiADB["KeywordMonitor"]["OutputMode"] == 2)
	local independentLabel = B.CreateFS(frame, 13, "独立聊天窗口", false, "LEFT")
	independentLabel:SetPoint("LEFT", independentRadio, "RIGHT", 5, 0)
	
	-- 输出到聊天窗口选择（下拉菜单）
	local chatFrameLabel = B.CreateFS(frame, 13, "输出到聊天窗口", false, "LEFT")
	chatFrameLabel:SetPoint("TOPLEFT", 60, -315)
	
	-- 创建下拉菜单
	local chatFrameDropdown = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	chatFrameDropdown:SetSize(150, 30)
	chatFrameDropdown:SetPoint("LEFT", chatFrameLabel, "RIGHT", 10, 0)
	B.CreateBD(chatFrameDropdown, .3)
	
	-- 下拉菜单文本
	chatFrameDropdown.Text = B.CreateFS(chatFrameDropdown, 12, "", false, "LEFT")
	chatFrameDropdown.Text:SetPoint("LEFT", 10, 0)
	chatFrameDropdown.Text:SetPoint("RIGHT", -25, 0)
	
	-- 下拉箭头
	chatFrameDropdown.Arrow = chatFrameDropdown:CreateTexture(nil, "ARTWORK")
	chatFrameDropdown.Arrow:SetSize(8, 8)
	chatFrameDropdown.Arrow:SetPoint("RIGHT", -10, 0)
	chatFrameDropdown.Arrow:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
	
	-- 下拉列表
	chatFrameDropdown.List = CreateFrame("Frame", nil, chatFrameDropdown, "BackdropTemplate")
	chatFrameDropdown.List:SetPoint("TOP", chatFrameDropdown, "BOTTOM", 0, -2)
	chatFrameDropdown.List:SetWidth(chatFrameDropdown:GetWidth())
	B.CreateBD(chatFrameDropdown.List, .9)
	chatFrameDropdown.List:Hide()
	chatFrameDropdown.List:SetFrameStrata("DIALOG")
	
	-- 更新下拉菜单选项
	local function UpdateChatFrameDropdown()
		local options = {}
		
		-- 获取所有停靠的聊天窗口（有标签页的窗口）
		local dockedFrames = {}
		if GeneralDockManager then
			for _, chatFrame in ipairs(GeneralDockManager.DOCKED_CHAT_FRAMES) do
				if chatFrame then
					local id = chatFrame:GetID()
					dockedFrames[id] = true
				end
			end
		end
		
		-- 遍历所有聊天窗口
		for i = 1, NUM_CHAT_WINDOWS do
			local name = GetChatWindowInfo(i)
			-- 只添加停靠的窗口（有标签页的窗口）
			if name and name ~= "" and dockedFrames[i] then
				tinsert(options, {
					text = name,
					value = i,
				})
			end
		end
		
		chatFrameDropdown.options = options
		
		-- 设置当前选中的值
		local currentFrame = NDuiADB["KeywordMonitor"]["OutputChatFrame"]
		local currentName = GetChatWindowInfo(currentFrame)
		
		-- 检查当前选择的窗口是否在列表中
		local found = false
		for _, option in ipairs(options) do
			if option.value == currentFrame then
				found = true
				break
			end
		end
		
		if found and currentName and currentName ~= "" then
			chatFrameDropdown.Text:SetText(currentName)
		elseif #options > 0 then
			-- 如果当前窗口无效，选择第一个有效窗口
			NDuiADB["KeywordMonitor"]["OutputChatFrame"] = options[1].value
			chatFrameDropdown.Text:SetText(options[1].text)
		else
			-- 没有可用窗口
			chatFrameDropdown.Text:SetText("无可用窗口")
		end
	end
	
	-- 下拉菜单点击事件
	chatFrameDropdown:SetScript("OnMouseDown", function(self)
		if self.List:IsShown() then
			self.List:Hide()
			return
		end
		
		-- 更新选项
		UpdateChatFrameDropdown()
		
		-- 清空旧按钮
		if self.buttons then
			for _, btn in ipairs(self.buttons) do
				btn:Hide()
			end
		else
			self.buttons = {}
		end
		
		-- 创建选项按钮
		for i, option in ipairs(self.options) do
			local btn = self.buttons[i]
			if not btn then
				btn = CreateFrame("Button", nil, self.List, "BackdropTemplate")
				btn:SetSize(self.List:GetWidth() - 2, 20)
				B.CreateBD(btn, .3)
				
				btn.text = B.CreateFS(btn, 12, "", false, "LEFT")
				btn.text:SetPoint("LEFT", 5, 0)
				
				btn:SetScript("OnEnter", function(b)
					b:SetBackdropColor(1, 1, 1, .25)
				end)
				btn:SetScript("OnLeave", function(b)
					b:SetBackdropColor(0, 0, 0, .3)
				end)
				
				self.buttons[i] = btn
			end
			
			btn.text:SetText(option.text)
			btn:Show()
			
			if i == 1 then
				btn:SetPoint("TOPLEFT", self.List, "TOPLEFT", 1, -1)
			else
				btn:SetPoint("TOPLEFT", self.buttons[i-1], "BOTTOMLEFT", 0, -1)
			end
			
			btn:SetScript("OnClick", function()
				NDuiADB["KeywordMonitor"]["OutputChatFrame"] = option.value
				self.Text:SetText(option.text)
				self.List:Hide()
			end)
		end
		
		-- 调整列表高度
		local listHeight = #self.options * 21 + 2
		self.List:SetHeight(listHeight)
		self.List:Show()
	end)
	
	-- 点击其他地方关闭下拉菜单
	chatFrameDropdown.List:SetScript("OnHide", function(self)
		self:GetParent().Arrow:SetRotation(0)
	end)
	chatFrameDropdown.List:SetScript("OnShow", function(self)
		self:GetParent().Arrow:SetRotation(math.pi)
	end)
	
	-- 初始化
	UpdateChatFrameDropdown()
	
	-- 监听聊天窗口变化
	local updateFrame = CreateFrame("Frame")
	updateFrame:RegisterEvent("UPDATE_CHAT_WINDOWS")
	updateFrame:SetScript("OnEvent", function(self, event)
		if event == "UPDATE_CHAT_WINDOWS" and frame:IsShown() then
			UpdateChatFrameDropdown()
		end
	end)
	
	-- 提取成功窗口标签闪动
	local flashCheck = B.CreateCheckBox(frame)
	flashCheck:SetPoint("TOPLEFT", 60, -345)
	flashCheck:SetChecked(NDuiADB["KeywordMonitor"]["FlashOnMatch"])
	local flashLabel = B.CreateFS(frame, 13, "提取成功窗口标签闪动", false, "LEFT")
	flashLabel:SetPoint("LEFT", flashCheck, "RIGHT", 5, 0)
	
	flashCheck:SetScript("OnClick", function(self)
		local checked = self:GetChecked()
		NDuiADB["KeywordMonitor"]["FlashOnMatch"] = checked
	end)
	
	-- 战斗中隐藏独立窗口
	local combatHideCheck = B.CreateCheckBox(frame)
	combatHideCheck:SetPoint("TOPLEFT", 60, -375)
	combatHideCheck:SetChecked(NDuiADB["KeywordMonitor"]["CombatHide"])
	local combatHideLabel = B.CreateFS(frame, 13, "战斗中隐藏独立窗口", false, "LEFT")
	combatHideLabel:SetPoint("LEFT", combatHideCheck, "RIGHT", 5, 0)
	
	combatHideCheck:SetScript("OnClick", function(self)
		local checked = self:GetChecked()
		NDuiADB["KeywordMonitor"]["CombatHide"] = checked
	end)
	
	-- 定义更新UI显示的函数（在所有元素创建后）
	local function UpdateOptionsVisibility()
		local isEnabled = NDuiADB["KeywordMonitor"]["Enabled"]
		local isSystemMode = NDuiADB["KeywordMonitor"]["OutputMode"] == 1
		
		-- 使用 Show/Hide 而不是 SetShown，兼容性更好
		if isEnabled then
			keywordBox:Show()
			keywordLabel:Show()
			helpText:Show()
			audioCheck:Show()
			audioLabel:Show()
			audioText:Show()
			inheritCheck:Show()
			inheritLabel:Show()
			outputLabel:Show()
			systemRadio:Show()
			systemLabel:Show()
			independentRadio:Show()
			independentLabel:Show()
			
			if isSystemMode then
				chatFrameLabel:Show()
				chatFrameDropdown:Show()
				flashCheck:Show()
				flashLabel:Show()
				combatHideCheck:Hide()
				combatHideLabel:Hide()
			else
				chatFrameLabel:Hide()
				chatFrameDropdown:Hide()
				flashCheck:Hide()
				flashLabel:Hide()
				combatHideCheck:Show()
				combatHideLabel:Show()
			end
		else
			keywordBox:Hide()
			keywordLabel:Hide()
			helpText:Hide()
			audioCheck:Hide()
			audioLabel:Hide()
			audioText:Hide()
			inheritCheck:Hide()
			inheritLabel:Hide()
			outputLabel:Hide()
			systemRadio:Hide()
			systemLabel:Hide()
			independentRadio:Hide()
			independentLabel:Hide()
			chatFrameLabel:Hide()
			chatFrameDropdown:Hide()
			flashCheck:Hide()
			flashLabel:Hide()
			combatHideCheck:Hide()
			combatHideLabel:Hide()
		end
	end
	
	-- 现在设置启用开关的事件（所有UI元素都已创建）
	enableCheck:SetScript("OnClick", function(self)
		local checked = self:GetChecked()
		NDuiADB["KeywordMonitor"]["Enabled"] = checked
		module:ToggleKeywordMonitor(NDuiADB["KeywordMonitor"]["Enabled"])
		UpdateOptionsVisibility()
	end)
	
	-- 单选框逻辑（输出方式）
	systemRadio:SetScript("OnClick", function(self)
		if self:GetChecked() then
			NDuiADB["KeywordMonitor"]["OutputMode"] = 1
			independentRadio:SetChecked(false)
			-- 关闭下拉列表
			if chatFrameDropdown.List then
				chatFrameDropdown.List:Hide()
			end
			UpdateOptionsVisibility()
			module:ToggleKeywordMonitor(NDuiADB["KeywordMonitor"]["Enabled"])
		else
			self:SetChecked(true)
		end
	end)
	
	independentRadio:SetScript("OnClick", function(self)
		if self:GetChecked() then
			NDuiADB["KeywordMonitor"]["OutputMode"] = 2
			systemRadio:SetChecked(false)
			-- 关闭下拉列表
			if chatFrameDropdown.List then
				chatFrameDropdown.List:Hide()
			end
			UpdateOptionsVisibility()
			module:ToggleKeywordMonitor(NDuiADB["KeywordMonitor"]["Enabled"])
		else
			self:SetChecked(true)
		end
	end)
	
	-- 初始显示状态
	UpdateOptionsVisibility()
	
	-- 当窗口显示时，刷新状态
	frame:SetScript("OnShow", function(self)
		enableCheck:SetChecked(NDuiADB["KeywordMonitor"]["Enabled"])
		UpdateOptionsVisibility()
	end)
	
	configFrame = frame
	return frame
end

-- 创建聊天栏按钮
function module:CreateKeywordButton()
	local chatbar = _G["NDui_ChatBar"]
	if not chatbar then 
		return
	end
	
	if keywordButton then return keywordButton end
	EnsureConfig()
	
	local width, height = 40, 8
	local bu = CreateFrame("Button", "NDui_KeywordButton", chatbar, "BackdropTemplate")
	bu:SetSize(width, height)
	B.PixelIcon(bu, DB.normTex, true)
	B.CreateSD(bu)
	bu.Icon:SetVertexColor(1, 0, 0)
	bu:SetHitRectInsets(0, 0, -8, -8)
	bu:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	
	-- 提示文本
	B.AddTooltip(bu, "ANCHOR_TOP", 
		"|cff00FFff左键|r - 设置提取过滤\n" ..
		"|cff00FFff右键|r - 启用/关闭提取\n" ..
		"|cff00FFffShift+右键|r - 启用/关闭过滤"
	)
	
	-- 点击事件
	bu:SetScript("OnClick", function(self, button)
		if button == "LeftButton" then
			-- 打开配置界面
			local frame = configFrame
			if not frame then
				frame = CreateConfigFrame()
			end
			
			if frame and frame:IsShown() then
				frame:Hide()
			elseif frame then
				frame:Show()
			end
		elseif button == "RightButton" then
			if IsShiftKeyDown() then
				-- Shift+右键：切换过滤（这里简化处理，只提示）
				print("|cff00FF00[NDui]|r 过滤功能请使用 NDui 自带的聊天过滤")
			else
				-- 右键：切换提取
				NDuiADB["KeywordMonitor"]["Enabled"] = not NDuiADB["KeywordMonitor"]["Enabled"]
				module:ToggleKeywordMonitor(NDuiADB["KeywordMonitor"]["Enabled"])
				print("|cff00FF00[NDui]|r 关键词监控: " .. (NDuiADB["KeywordMonitor"]["Enabled"] and "|cff00FF00已开启|r" or "|cffFF0000已关闭|r"))
			end
		end
	end)
	
	-- 定位按钮
	local children = {chatbar:GetChildren()}
	local lastButton
	for i = #children, 1, -1 do
		if children[i]:IsObjectType("Button") and children[i] ~= bu then
			lastButton = children[i]
			break
		end
	end
	
	if lastButton then
		bu:SetPoint("LEFT", lastButton, "RIGHT", 5, 0)
	else
		bu:SetPoint("LEFT", chatbar, "LEFT", 0, 0)
	end
	
	keywordButton = bu
	UpdateButtonStatus()
	return bu
end

-- 初始化
function module:InitKeywordMonitor()
	-- 确保配置存在
	EnsureConfig()
	
	-- 延迟创建按钮和加载配置（等待聊天栏创建）
	C_Timer.After(2, function()
		-- 加载保存的关键词
		if NDuiADB["KeywordMonitor"]["Keywords"] and NDuiADB["KeywordMonitor"]["Keywords"] ~= "" then
			module:UpdateKeywordList(NDuiADB["KeywordMonitor"]["Keywords"])
		end
		
		-- 创建按钮
		module:CreateKeywordButton()
		
		-- 如果启用了，立即开始监控
		if NDuiADB["KeywordMonitor"]["Enabled"] then
			module:ToggleKeywordMonitor(true)
		end
	end)
	
	-- 注册战斗事件
	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	eventFrame:SetScript("OnEvent", function(self, event)
		HandleCombatVisibility()
	end)
	
	-- 添加斜杠命令
	SlashCmdList["NDUIKEYWORD"] = function(msg)
		local cmd, args = strsplit(" ", msg, 2)
		cmd = strlower(cmd or "")
		
		if cmd == "on" or cmd == "开启" then
			NDuiADB["KeywordMonitor"]["Enabled"] = true
			module:ToggleKeywordMonitor(true)
			print("|cff00FF00[NDui]|r 关键词监控已开启")
		elseif cmd == "off" or cmd == "关闭" then
			NDuiADB["KeywordMonitor"]["Enabled"] = false
			module:ToggleKeywordMonitor(false)
			print("|cff00FF00[NDui]|r 关键词监控已关闭")
		elseif cmd == "set" or cmd == "设置" then
			if args and args ~= "" then
				NDuiADB["KeywordMonitor"]["Keywords"] = args
				module:UpdateKeywordList(args)
				print("|cff00FF00[NDui]|r 关键词已设置为: " .. args)
			else
				print("|cff00FF00[NDui]|r 用法: /keyword set 关键词1,关键词2")
			end
		elseif cmd == "config" or cmd == "配置" or cmd == "" then
			if not configFrame then
				CreateConfigFrame()
			end
			if configFrame:IsShown() then
				configFrame:Hide()
			else
				configFrame:Show()
			end
		else
			print("|cff00FF00[NDui 关键词监控]|r")
			print("  /keyword on - 开启监控")
			print("  /keyword off - 关闭监控")
			print("  /keyword set 关键词1,关键词2 - 设置关键词")
			print("  /keyword config - 打开配置界面")
		end
	end
	SLASH_NDUIKEYWORD1 = "/keyword"
	SLASH_NDUIKEYWORD2 = "/关键词"
end
