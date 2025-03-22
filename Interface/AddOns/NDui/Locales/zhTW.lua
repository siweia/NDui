local _, ns = ...
local _, _, L = unpack(ns)
if GetLocale() ~= "zhTW" then return end

L["From"] = "來自"
L["Tell"] = "告訴"
L["Ghost"] = "靈魂"
L["Skip"] = "跳過"
L["Sort"] = "整理"
L["Chat Copy"] = "%s複製|n%s選單"
L["Attach List"] = "附件清單:"
L["Rare"] = "稀有"
L["Stack Cap"] = "堆疊上限"
L["Lack"] = "缺少"
L["Flask"] = "精鍊藥劑"
L["Food"] = "食物"
L["World Channel"] = "世界頻道"
L["Raid Tool"] = "團隊工具"
L["Disband Info"] = "確定|cffff0000解散|r當前隊伍/團隊?"
L["Disband Process"] = "NDui團隊解散中"
L["Raid Buff Check"] = "NDui食物精煉檢查:"
L["Count Down"] = "開始/取消倒計時"
L["Check Status"] = "食物精煉檢查"
L["Buffs Ready"] = "食物精煉檢查: 已齊全。"
L["DBM Required"] = "你尚未使用DBM或者BigWigs。"
L["ReloadUI Required"] = "需要重載插件使設定生效"
L["Default Settings Check"] = "已經加載預設設定。"
L["Tutorial Complete"] = "已經載入相關設定，重載插件後生效。"
L["Tips"] = "小提示"
L["Version Info1"] = "版本已經載入，"
L["Version Info2"] = "你可以輸入"
L["Version Info3"] = "以獲取更多幫助。"
L["Tutorial Page1"] = "此處將載入一些諸如|cffffcc00快捷列、技能監控、團隊框架、名條|r等系統設定來改善插件的易用性。|n|n|cffff0000此頁設定無法跳過。|r"
L["Tutorial Page2"] = "|cffff0000注意: 本頁的設定為帳號共享。|r|n|n此處將導入Skada、DBM、BigWigs的預設設定（不會鎖定），以使其更符合NDui的整體風格。|n|n你也可以在|cffffcc00控制面板-介面美化|r裏取消它們的皮膚，一切都取決於自己。"
L["Tutorial Page3"] = "設定完畢，點擊|cffffcc00套用|r後重載生效。|n|n|cffff0000注意:|r|n|n角落的訊息條包含諸多額外的功能，請自行查看；|n|n大部分的設定在控制面板中都可以修改。|r"
L["Help Title"] = "幫助說明"
L["Help Intro"] = "歡迎使用NDui，以下列舉了一些常用指令。|n|n如果你首次使用NDui，請務必進行一次設定嚮導。"
L["Cmd bb intro"] = "快速進行按鍵設定"
L["Cmd mm intro"] = "移動介面元素"
L["Cmd rl intro"] = "重新載入所有插件"
L["Cmd ncl intro"] = "喚出更新日誌面板"
L["Cmd ww intro"] = "添加自定義技能監視"
L["Tutorial"] = "設定嚮導"
L["Default Settings"] = "系統設定"
L["Changelog"] = "更新日誌"
L["AutoQuest"] = "自動交接任務"
L["AutoQuestTip"] = "|n啟用自動交接任務後，對於只有一個選項的對話，也會進行自動交互。|n|n按住Shift鍵可以停止本次交互。|n|n按住ALT並點擊對話視窗的NPC名字，可以屏蔽並不再進行交互。"
L["AutoQuestIgnoreTip"] = "|n你不再與該NPC自動交接任務，可以按住ALT並點擊上方名字取消忽略。"
L["StanceBar"] = "姿態快捷列"
L["ShowStanceBar"] = "啟用姿態快捷列"
L["LeaveVehicle"] = "離開載具按鈕"
L["Pet Actionbar"] = "寵物快捷列"
L["Actionbar"] = "快捷列"
L["Unitframes"] = "頭像及施法條"
L["Auras"] = "技能與法術"
L["Raid Tools"] = "組隊與通知"
L["ChatFrame"] = "聊天視窗"
L["Maps"] = "地圖框架"
L["Nameplate"] = "名條"
L["Skins"] = "介面美化"
L["Tooltip"] = "滑鼠提示框"
L["Misc"] = "易用性"
L["UI Settings"] = "通用設定"
L["Enable Actionbar"] = "啟用快捷列"
L["ActionBarTip"] = "|n關閉後，微型選單也將一同被禁用。"
L["Actionbar Hotkey"] = "顯示快捷鍵"
L["Actionbar Macro"] = "顯示巨集名稱"
L["Actionbar Grid"] = "显示快捷列背景"
L["ClassColor BG"] = "按鍵背景職業染色"
L["Show Cooldown"] = "顯示冷卻計時"
L["Enable AuraWatch"] = "啟用技能監控"
L["AuraWatch ClickThrough"] = "禁用技能監控的提示訊息（點擊穿越）"
L["Enable Reminder"] = "技能缺失提示"
L["ReminderTip"] = "|n根據自身職業，缺少特定Buff時進行提示。|n支持耐力/智力/戰鬥怒吼/野性印記/心靈之火/荊棘術/雄鷹守護/强擊光環/術士護甲/法師護甲/寒冬號角/正義之怒。"
L["Enable Totembar"] = "啟用圖騰欄"
L["Totembar"] = "圖騰欄"
L["VerticalTotems"] = "竪直排列圖騰"
L["TotemSize"] = "圖騰圖示大小"
L["Enable UFs"] = "啟用頭像框架"
L["UFs Portrait"] = "顯示頭像3D模型"
L["Arena Frame"] = "顯示競技場框架"
L["UFs Castbar"] = "啟用施法條"
L["UFs CombatText"] = "顯示簡易戰鬥訊息"
L["CombatText HotsDots"] = "顯示持續性治療和傷害"
L["CombatText ShowPets"] = "顯示寵物造成的治療和傷害"
L["CombatText AutoAttack"] = "顯示自動攻擊的傷害"
L["CombatText OverHealing"] = "顯示完全過量的治療量"
L["CombatText"] = "簡易戰鬥訊息"
L["UFs SwingBar"] = "自動攻擊計時條"
L["UFs SwingTimer"] = "顯示計時條時間"
L["UFs ClassPower"] = "職業特殊資源條"
L["PlayerUF"] = "玩家框架"
L["TargetUF"] = "目標框架"
L["TotUF"] = "目標的目標框架"
L["PetUF"] = "寵物框架"
L["FocusUF"] = "焦點框架"
L["FotUF"] = "焦點目標框架"
L["BossFrame"] = "首領/競技場框架"
L["UFs RaidFrame"] = "啟用團隊框架"
L["RaidFrameTip"] = "|n禁用後，簡易模式、小隊和寵物框架也會同時禁用。"
L["RaidFrame"] = "團隊框架"
L["Num Groups"] = "顯示隊伍數量"
L["RaidFrame TeamIndex"] = "顯示隊伍編號"
L["SimpleRaidFrame"] = "簡易模式框架"
L["SimpleRaidFrameTip"] = "|n簡易模式刪繁就簡，僅保留血量等主要訊息。"
L["Instance Auras"] = "顯示副本的重要減益效果"
L["RaidAuras ClickThrough"] = "禁用法術的提示訊息（點擊穿越）"
L["SimpleMode Scale"] = "簡易模式框架縮放"
L["Spec RaidPos"] = "主副天賦獨立位置"
L["SpecRaidPosTip"] = "|n勾選後，小隊及團隊框架的位置，會按照你的主副天賦進行存儲。"
L["Lock Chat"] = "鎖定聊天視窗設定"
L["Chat Sticky"] = "密語時鎖定該頻道"
L["Whisper Invite"] = "啟用密語自動邀請"
L["Whisper Keyword"] = "密語關鍵詞"
L["WhisperKeywordTip"] = "|n為密語自動邀請設定關鍵詞。對於多個關鍵詞，以空格隔開。"
L["Default Channel"] = "取消頻道名稱簡寫"
L["Guild Invite Only"] = "只邀請公會成員"
L["EasyMark"] = "目標標記助手"
L["EasyMarkTip"] = "|n按住你偏好的修飾鍵，然後左鍵點選目標，即可設置目標標記。"
L["Enable Chatfilter"] = "啟用聊天訊息過濾"
L["Block Addon Alert"] = "過濾部分插件的刷屏"
L["Keyword Match"] = "過濾詞匹配數量"
L["Filter List"] = "過濾詞列表"
L["Minimap Clock"] = "小地圖顯示時鐘"
L["Map Scale"] = "視窗化地圖縮放"
L["Maximize Map Scale"] = "全屏化地圖縮放"
L["Minimap Scale"] = "小地圖縮放"
L["Minimap Size"] = "小地圖尺寸"
L["Minimap Pulse"] = "小地圖邊框脈動"
L["Minimap RecycleBin"] = "圖示回收站"
L["Show RecycleBin"] = "啟用小地圖圖示回收站"
L["Show WhoPings"] = "顯示誰點擊了小地圖"
L["Enable Nameplate"] = "啟用名條"
L["Tank Mode"] = "以仇恨染色名條"
L["TankModeTip"] = "|n勾選後，目標仇恨將以名條血量顏色來展現，而不是邊框。|n对于特殊單位染色的目標，依然保留仇恨染色邊框。"
L["Friendly CC"] = "友方玩家職業染色"
L["Hostile CC"] = "敵對玩家職業染色"
L["NP VerticalSpacing"] = "名條堆叠的縱向間距"
L["Max Auras"] = "法術圖示最大數量"
L["Auras Size"] = "法術圖示大小"
L["ShowCustomUnits"] = "啟用特殊單位染色"
L["CustomUnitsTip"] = "|n啟用後，部分目標的名條將以特殊顏色顯示。|n你可以自定義這個顏色和需要染色的目標列表。"
L["UnitColor List"] = "特殊單位染色列表"
L["ShowPowerList"] = "顯示法力值的目標"
L["DBM Skin"] = "啟用DBM皮膚"
L["Micromenu"] = "啟用微型選單"
L["Menubar"] = "微型選單欄"
L["Infobar Line"] = "啟用訊息條背景線條"
L["Chat Line"] = "啟用聊天頻道背景線條"
L["Menu Line"] = "啟用選單欄背景線條"
L["ClassColor Line"] = "使用職業顏色線條"
L["Skada Skin"] = "啟用Skada皮膚"
L["Bigwigs Skin"] = "啟用BigWigs皮膚"
L["TMW Skin"] = "啟用TellMeWhen皮膚"
L["WeakAuras Skin"] = "啟用WeakAuras皮膚"
L["Bags"] = "背包"
L["Enable Bags"] = "啟用背包整合"
L["Bags IconSize"] = "背包格子大小"
L["Bags FontSize"] = "背包文本大小"
L["Bags Width"] = "背包每行格數"
L["Bank Width"] = "銀行每行格數"
L["Bags Itemlevel"] = "顯示背包裝備物品等級"
L["Bags ItemFilter"] = "背包物品分類存放"
L["Raid Manger"] = "啟用團隊工具"
L["Runes Check"] = "檢查通報符文情況"
L["Lock UIScale"] = "自動設定UI縮放"
L["DBMCount"] = "倒數計時秒數"
L["DBMCountTip"] = "|n為組隊工具的倒計時功能設定倒計時時間。|n需要安裝DBM或者Bigwigs插件。"
L["Setup UIScale"] = "調整UI縮放"
L["Follow Cursor"] = "提示框跟隨滑鼠"
L["ShowItemQuality"] = "顯示物品品質染色"
L["Hide Rank"] = "隱藏公會會階"
L["Hide Title"] = "隱藏頭銜"
L["Hide Realm"] = "僅按住Shift時顯示伺服器"
L["FactionIcon"] = "顯示陣營圖示"
L["Show TargetedBy"] = "顯示隊友關注目標"
L["Mail Tool"] = "啟用郵件增強"
L["Show ItemLevel"] = "角色面板顯示裝備品質"
L["Hide Error"] = "啟用紅字錯誤過濾"
L["Language Filter"] = "關閉語言過濾器"
L["Easy Focus"] = "啟用Shift+左鍵快速焦點"
L["Show Expbar"] = "小地圖經驗/聲望條"
L["Auto ScreenShot"] = "獲得成就時自動截圖"
L["InterruptAlert"] = "組隊時通報技能打斷"
L["OwnInterrupt"] = "只通報自身及寵物的打斷"
L["DispellAlert"] = "組隊時通報法術驅散"
L["OwnDispell"] = "只通報自身及寵物的驅散"
L["BrokenAlert"] = "控制技能打破通報"
L["BrokenAlertTip"] = "|n當有人打破控制技能時，進行通報。|n例如致盲、冰凍陷阱、變形術等。"
L["LoCAlert"] = "當你失去控制時通報"
L["LoCAlertTip"] = "|n勾选後，當你因致盲、悶棍等技能而失去控制時，進行通報。"
L["InstAlertOnly"] = "只在副本中通報"
L["InstAlertOnlyTip"] = "|n勾選後，只在副本中進行上述通報，在野外環境中不進行通報。"
L["Interrupt"] = "打斷 - %s > %s"
L["Steal"] = "偷取 - %s > %s"
L["Dispel"] = "驅散 - %s > %s"
L["BrokenSpell"] = "破控 - %s > %s"
L["LossControl"] = "受控 - %s > %s (%s秒 %s)"
L["QuestNotification"] = "啟用任務通報"
L["QuestProgress"] = "通報任務的詳盡進度"
L["AcceptQuest"] = "接受任務"
L["Faster Loot"] = "自動拾取加速"
L["Numberize"] = "數字顯示方式"
L["Number Type1"] = "標準模式: b/m/k"
L["Number Type2"] = "中式: 億/萬"
L["Number Type3"] = "顯示具體數值"
L["NDui Reset"] = "初始化設定"
L["Reset NDui Check"] = "你確定初始化插件|cffff0000所有|r的設定嗎？"
L["NDui Console"] = "NDui 控制面板"
L["Player Castbar"] = "玩家施法條"
L["Target Castbar"] = "目標施法條"
L["Focus Castbar"] = "焦點施法條"
L["Get Out"] = "離開人群"
L["Get Close"] = "貼近Boss"
L["Stack Buying Check"] = "你確定購買|cffff0000一組|r下列物品嗎？"
L["Invite"] = "邀請"
L["Copy Name"] = "複製"
L["Whisper"] = "密語"
L["Targeted By"] = "關注: "
L["NumberCap1"] = "萬"
L["NumberCap2"] = "億"
L["NumberCap3"] = "兆"
L["Get Naked"] = "右鍵雙擊卸下所有裝備。"
L["Mover Console"] = "NDui框架移動"
L["Grids"] = "網格"
L["Reset Mover Confirm"] = "你確定重置所有框架的位置嗎？"
L["AWConfig Title"] = "NDui技能監控設定"
L["AWConfigTips"] = "|n你可以在每個設定的標題查看幫助信息。|n添加新監控後需要重載插件以生效設定。"
L["Groups"] = "分組"
L["Player Aura"] = "玩家光環"
L["Target Aura"] = "目標光環"
L["Special Aura"] = "玩家重要光環"
L["Focus Aura"] = "焦點光環"
L["Spell Cooldown"] = "冷卻計時"
L["Enchant Aura"] = "附魔及飾品"
L["Raid Buff"] = "團隊增益"
L["Raid Debuff"] = "團隊減益"
L["Warning"] = "目標重要光環"
L["InternalCD"] = "自定義監控"
L["Type*"] = "類型*"
L["Unit*"] = "單位*"
L["Caster"] = "施法者"
L["Stack"] = "層數"
L["Value"] = "光環數值"
L["Timeless"] = "隱藏計時"
L["Combat"] = "戰鬥時顯示"
L["Text"] = "文本提示"
L["Slot*"] = "裝備欄位"
L["Totem*"] = "圖騰欄位"
L["AuraWatch List"] = "自定義列表"
L["Choose a Type"] = "請選擇一種監控類型。"
L["Incomplete Input"] = "你需要完成所有帶*的選項。"
L["Incorrect SpellID"] = "你輸入的法術ID不存在。"
L["Existing ID"] = "你已經添加過該法術。"
L["TotemSlot"] = "圖騰欄"
L["Reset your AuraWatch List?"] = "你想要清空所有分組的自定義列表？"
L["Type Intro"] = "|nAuraID: 監控Buff/Debuff的狀態；|n|nSpellID: 監控技能法術的冷卻時間；|n|nSlotID: 監控裝備欄位的冷卻時間；|n|nTotemID: 監控對應圖騰的冷卻時間。"
L["ID Intro"] = "|n法術的編號，必須為數字。|n|n你可以在法術的滑鼠提示框中看到ID。|n|n不支持直接輸入法術名稱。"
L["Unit Intro"] = "|n監視法術所來自的單位。|n|nplayer: 玩家單位的法術；|n|ntarget: 目標單位的法術；|n|nfocus: 焦點單位的法術；|n|npet: 寵物單位的法術。"
L["Caster Intro"] = "|n用於過濾法術的來源。|n|nplayer: 施法者是玩家；|n|ntarget: 施法者是目標；|n|npet: 施法者是寵物。|n|n留空則任何人施放的都會顯示。"
L["Stack Intro"] = "|n過濾法術的層數，必須為數字。|n|n當法術的層數達到你所設定的數值後顯示。|n|n留空則無視層數，直接顯示。"
L["Value Intro"] = "|n勾選後，顯示法術所包含的數值訊息。|n|n例如牧師的真言術盾將顯示其具體吸收數值。|n|n優先級高於文本提示。"
L["Timeless Intro"] = "|n勾選後，該法術的冷卻時間會被隱藏。"
L["Combat Intro"] = "|n勾選後，該法術將僅在戰鬥中顯示。"
L["Text Intro"] = "|n法術的文本提示。|n|n法術激活時，將同時顯示你所設定的文本。|n|n若啟用Value或者留空，則不顯示文本提示。"
L["Slot Intro"] = "|n顯示所選擇裝備欄的冷卻時間。|n|n例如工程腰帶、披風等。|n|n飾品欄位僅支持主動飾品。"
L["Totem Intro"] = "|n顯示所選擇圖騰欄位的持續時間。"
L["IntID*"] = "法術*"
L["IntID Intro"] = "|n用於觸發冷卻計時器的法術編號，必須為數字。|n|n你可以在法術的滑鼠提示框中看到ID。|n|n不支持直接輸入法術名稱。"
L["Duration*"] = "時長*"
L["Duration Intro"] = "|n所觸發冷卻計時器的持續時間。"
L["ItemID"] = "名稱"
L["ItemID Intro"] = "|n冷卻計時器的名稱所屬的物品編號。|n|n留空則使用觸發冷卻的法術編號。"
L["EditBox Tip"] = "|n輸入完畢後，按一下Enter鍵。"
L["RaidFrame Debuffs"] = "添加團隊框架減益"
L["Priority"] = "優先級"
L["Priority Intro"] = "|n法術監控圖示的顯示優先級。|n|n同一時間存在多個法術時，僅顯示優先級最高的那一個。|n|n最高為6，同時高亮該優先級的光環。|n|n留空則預設為2。"
L["Existing ClickSet"] = "該按鍵組合已綁定技能。"
L["Invalid Input"] = "你所輸入的按鍵行為無效。"
L["Action*"] = "行為*"
L["Action Intro"] = "|n為團隊框架設定按鍵行為。|n|n輸入target，設定目標；|n|n輸入focus，設定焦點；|n|n輸入follow，設定跟隨；|n|n輸入數字，設定施法的法術ID，對應等級；|n|n你也可以直接輸入巨集。|n對於存在多行内容的巨集，用符號~表示換行。"
L["Key*"] = "按鍵*"
L["Key Intro"] = "|n為該法術綁定一個滑鼠按鍵。|n|n為防止衝突，不建議設定單獨的左鍵或者中鍵。"
L["Modified Key"] = "功能键"
L["ModKey Intro"] = "|n為該法術設定組合鍵。"
L["Enable ClickSets"] = "啟用團隊框架點擊施法"
L["Add ClickSets"] = "添加快速施法組合"
L["Reset your click sets?"] = "你想要初始化快速施法方案嗎？"
L["Version Check"] = "NDui版本過期提示"
L["Outdated NDui"] = "  你的|cff0080ffNDui|rClassic已經過期，最新正式版為 |cff70C0F5%s|r"
L["Minimap"] = "小地圖"
L["Equipement Set"] = "裝備配置方案"
L["NFG"] = "不使用公修"
L["AutoSell Junk"] = "自動販賣雜物"
L["Selljunk Calculate"] = "你剛才出售垃圾獲得了"
L["D"] = "耐久"
L["Low Durability"] = "你的裝備耐久度過低！"
L["Hands"] = "手部"
L["Feet"] = "腳部"
L["Player Panel"] = "角色面板"
L["Auto Repair"] = "自動修理"
L["Guild repair"] = "修理使用了公會銀行"
L["Repair cost"] = "修理花費"
L["Repair error"] = "你沒錢還想修裝嗎？"
L["Earned"] = "獲得"
L["Spent"] = "花費"
L["Deficit"] = "虧損"
L["Profit"] = "盈利"
L["Session"] = "本次登錄:"
L["RealmCharacter"] = "伺服器角色:"
L["Hidden"] = "隱藏"
L["Hold Shift"] = "按住<Shift>展開"
L["Collect Memory"] = "回收資源"
L["My Position"] = "我的位置"
L["System"] = "系統"
L["FPS"] = "幀數"
L["Latency"] = "延遲"
L["Home Latency"] = "本機延遲"
L["World Latency"] = "世界延遲"
L["CPU Usage"] = "顯示CPU占用"
L["Are you sure to reset the gold count?"] = "你確定要重置金幣統計嗎？"
L["WoW"] = "魔獸世界"
L["BN"] = "戰網好友"
L["SpecPanel"] = "天賦面板"
L["Change Spec"] = "切換天賦"
L["Reset Gold"] = "重置數據"
L["Toggle Calendar"] = "打開行事曆"
L["Toggle Clock"] = "打開時鐘"
L["WorldMap"] = "打開地圖"
L["Send My Pos"] = "發送我的位置"
L["No Online"] = "當前沒有好友在綫"
L["Local Time"] = "當地時間:"
L["Realm Time"] = "伺服器時間:"
L["AW Switcher"] = "屏蔽預設分組"
L["Trigger"] = "觸發器"
L["Trigger Intro"] = "|n為該法術設定觸發器。|n|nOnAuraGain: 當你獲得該法術光環時觸發計時器；|n|nOnCastSuccess: 當你施放該技能法術時觸發計時器，需要記錄在戰鬥日志中的法術；|n|nUnitCastSucceed: 當你施放該技能法術時觸發計時器，需要記錄在UNIT_SPELLCAST_SUCCEEDED中的法術。"
L["Trigger Unit Intro"] = "|n為觸發器設定監控的目標單位。|n|nPlayer: 只監控玩家自身的技能法術；|n|nAll: 監控所有處於團隊/隊伍中玩家的技能法術。"
L["Mouse"] = "滑鼠"
L["PlayerPlate"] = "個人資源條"
L["Enable PlayerPlate"] = "顯示個人資源條"
L["Tooltip Scale"] = "滑鼠提示框縮放"
L["Differ WhisperColor"] = "為密語雙方使用不同顏色"
L["Map Reveal"] = "去除地圖迷霧"
L["Enable ClassAuras"] = "資源條添加職業監控"
L["PlayerPlate CPHeight"] = "連擊點高度"
L["PlayerPlate HPHeight"] = "血量高度"
L["PlayerPlate MPHeight"] = "能量高度"
L["AuraWatch IconScale"] = "技能監控圖示縮放"
L["PlayerPlate PowerText"] = "顯示能量條數值"
L["OnlyCompleteRing"] = "只播放完成提示音"
L["OnlyCompleteRingTip"] = "|n啟用後，不進行任何通報，只在任務完成時播放提示音。"
L["Stranger"] = "陌生人"
L["WheelUp"] = "滾輪上"
L["WheelDown"] = "滾輪下"
L["DPS Revert Threat"] = "非坦克时反轉染色邏輯"
L["Secure Color"] = "仇恨穩固"
L["Trans Color"] = "仇恨不穩"
L["Insecure Color"] = "仇恨丟失"
L["WhiteList"] = "法術白名單"
L["BlackList"] = "法術黑名單"
L["Details Skin"] = "啟用Details皮膚"
L["Reset to default list"] = "確定還原為預設的列表？"
L["Flash"] = "高亮"
L["Flash Intro"] = "|n勾選後，觸發時將高亮該法術圖示。"
L["Show SpecLevelByShift"] = "僅按住SHIFT時顯示裝等"
L["Instance Type"] = "|n選擇你要添加的ID所屬副本類型。|n|n舊版本及副本外數據在團隊-其他選項中。"
L["Dungeons Intro"] = "|n選擇你要添加的ID所屬地城。"
L["Raid Intro"] = "|n選擇你要添加的ID所屬團隊。"
L["Castbar LagString"] = "施法條延遲數值"
L["Crit"] = "致命"
L["Haste"] = "加速"
L["Mastery"] = "精通"
L["Versa"] = "應變"
L["Option* Tips"] = "|n帶有*號的選項即時生效，無需重載插件。|n|n雙擊滑塊選項的標題和顏色選擇的色塊，即可恢復初始設定。|n|n點擊部分選項的右側齒輪，可進行拓展設定。|n|n聊天欄輸入/ndui查看命令列表。"
L["Place item"] = "%s 放置了 %s"
L["Placed Item Alert"] = "通報隊伍中大餐等物品的放置"
L["MRT Potioncheck"] = "ExRT藥水使用報告"
L["Prio Editbox"] = "|n優先級僅限1-6。|n|n輸入完畢後，按Enter鍵生效。"
L["Player Count"] = "%s名玩家"
L["UFs RuneTimer"] = "顯示DK符文條的計時"
L["RaidBuffIndicator"] = "啟用邊角指示器"
L["RaidBuffIndicatorTip"] = "|n在團隊框架的邊緣添加自己想要的法術監控，可同時顯示增益和減益。"
L["BuffIndicatorType"] = "邊角指示器模式"
L["BuffIndicatorScale"] = "邊角指示器縮放"
L["BI_Blocks"] = "色塊模式"
L["BI_Icons"] = "圖示模式"
L["BI_Numbers"] = "數字模式"
L["TOPLEFT"] = "左上"
L["TOP"] = "頂部"
L["TOPRIGHT"] = "右上"
L["LEFT"] = "左側"
L["RIGHT"] = "右側"
L["BOTTOMLEFT"] = "左下"
L["BOTTOM"] = "底部"
L["BOTTOMRIGHT"] = "右下"
L["RaidBuffWatch"] = "重要法術監控"
L["BuffIndicator"] = "邊角增益設定"
L["HideJunkGuild"] = "縮略過長的公會名"
L["Freeze"] = "別動"
L["Move"] = "移動"
L["Texture Style"] = "選擇材質風格"
L["Highlight"] = "高亮"
L["Gradient"] = "漸變"
L["Flat"] = "扁平"
L["Combo"] = "連擊"
L["AttackSpeed"] = "攻速"
L["CD"] = "冷卻"
L["Strike"] = "影襲"
L["Power"] = "能量"
L["PartyFrame"] = "小隊框架"
L["PartyFrameTip"] = "|n使用獨立設定的小隊框架。如果關閉，則根據你當前設定，使用團隊框架或者簡易模式框架。"
L["HideCooldownOnWA"] = "在WA圖示上禁用冷卻計時"
L["PlayerPlate Fadeout"] = "脫戰後漸隱資源條"
L["PlayerPlate FadeoutAlpha"] = "漸隱後的透明度"
L["AutoBubbles"] = "團本外關閉聊天氣泡"
L["HealthColor"] = "血量顏色顯示方式"
L["Default Dark"] = "預設黑色"
L["ClassColorHP"] = "職業顏色"
L["GradientHP"] = "以百分比漸變"
L["DeleteMode Enabled"] = "|n按住CTRL+ALT鍵，直接點擊摧毀背包中低於藍色精良品質的物品。"
L["ItemDeleteMode"] = "摧毀模式"
L["Trait"] = "特質"
L["Data Info"] = "數據資訊"
L["Version"] = "版本"
L["Character"] = "角色"
L["Import"] = "導入"
L["Import Header"] = "NDui設定導入面板"
L["Import data error"] = "數據異常或過期，導入失敗！"
L["Import data warning"] = "你確定載入設定嗎？"
L["Export"] = "導出"
L["Export Header"] = "NDui設定導出面板"
L["Data Exception"] = "數據異常"
L["QuestTracker"] = "任務追蹤框架"
L["VehicleSeat"] = "載具座位控制"
L["Join or Invite"] = "邀請或加入"
L["AlertFrames"] = "成就/拾取通知框架"
L["UIWidgetFrame"] = "小地圖下方特殊框架|n|n如PVP占點"
L["TargetClassPower"] = "在目標名條顯示職業資源"
L["OffTank Color"] = "副坦仇恨"
L["ShowChatItemLevel"] = "聊天視窗的裝備顯示等級"
L["NameTextSize"] = "名稱字號"
L["HealthTextSize"] = "血量字號"
L["Nameplate MinScale"] = "非目標名條縮放"
L["Nameplate MinAlpha"] = "非目標名條透明度"
L["TargetIndicator"] = "調整目標指示器"
L["TopArrow"] = "頂部箭頭"
L["RightArrow"] = "右側箭頭"
L["TargetGlow"] = "邊框高亮"
L["TopNGlow"] = "頂部箭頭+高亮"
L["RightNGlow"] = "右側箭頭+高亮"
L["QuestIndicator"] = "啟用任務進度指示器"
L["MinimapCalendar"] = "顯示行事曆按鈕"
L["MinimapCalendarTip"] = "|n啟用後，可以在小地圖上顯示行事曆按鈕。|n即使不啟用這個選項，你也可以直接滑鼠中鍵點擊小地圖打開行事曆。"
L["Show ItemLevel"] = "顯示裝備的物品等級"
L["Show ItemQuality"] = "角色面板裝備品質資訊"
L["MapFader"] = "移動時淡化地圖"
L["EnhancedQuestLog"] = "增強任務列表和追蹤"
L["EnhancedQuestLogTips"] = "|n拓寬預設的任務列表，同時美化預設的任務追蹤。|n|n無需再安裝ClassicQuestLog等插件。"
L["Show GemNEnchant"] = "顯示寶石資訊"
L["ShowChatbar"] = "顯示聊天頻道切換按鈕"
L["Chatbar"] = "聊天頻道按鈕"
L["UnitFrame Size"] = "頭像各框架尺寸調整"
L["Power Height"] = "能量條高度"
L["Health Offset"] = "生命值縱向偏移"
L["Power Offset"] = "能量值縱向偏移"
L["Player&Target"] = "玩家和目標框架"
L["Pet&*Target"] = "寵物和副目標框架"
L["LockChatWidth"] = "鎖定的寬度"
L["LockChatHeight"] = "鎖定的高度"
L["QuestIndicatorAddOns"] = "|n支援插件:|n- ClassicCodex|n- Questie"
L["AuraWatch WatchSpellRank"] = "監控法術的不同等級"
L["WatchSpellRankTip"] = "|n啟用後，將同時監控你所設置的同名法術。"
L["FavouriteMode"] = "設定偏好"
L["FavouriteMode Enabled"] = "|n點擊標記你的偏好物品。|n若啟用了物品分類存放，還可以將其添加到偏好選擇分類中。|n此操作對垃圾物品無效。"
L["DisableInfobars"] = "關閉所有資訊條模塊"
L["FreeSlots"] = "空閑背包欄位"
L["Bags GatherEmpty"] = "合併背包空閑欄位"
L["AutoDismount"] = "飛行前自動下馬"
L["AutoDismountTip"] = "|n當你選擇飛行目的地後，自動解散坐騎。"
L["StupidShiftKey"] = "你的Shift鍵可能卡住了。"
L["ChatFilterWhiteList"] = "白名單模式"
L["ChatFilterWhiteListTip"] = "|n只保留列表中出現的聊天内容，留空則關閉此模式。存在多個關鍵詞時，以空格隔開。"
L["FilterListTip"] = "|n對符合列表中出現的聊天内容，達到匹配數量則進行過濾屏蔽。存在多個關鍵詞時，以空格隔開。"
L["HideAllID"] = "關閉所有法術及物品資訊"
L["Recount Skin"] = "啟用Recount皮膚"
L["Reset Details check"] = "你想要重置Details的皮膚美化嗎？"
L["SpecialBagsColor"] = "添加特殊背包的背景色"
L["SpecialBagsColorTip"] = "|n為獵人的箭袋、術士的靈魂袋以及附魔、草藥袋添加背景顏色。"
L["TradeTabs"] = "專業面板快捷標簽"
L["TradeTabsTips"] = "|n在專業面板顯示快捷切換的按鈕。|n|n在懷舊服中，附魔面板不屬於專業面板的一部分。"
L["Castbar Settings"] = "施法條設定"
L["Castbar Colors"] = "施法條顏色"
L["PlayerCastingColor"] = "玩家自身顏色"
L["Interruptible Color"] = "可打斷的顏色"
L["NotInterruptible Color"] = "不可打斷的顏色"
L["Castbar Height"] = "施法條高度"
L["TrackMenu"] = "追蹤選單"
L["SwingTimer Tip"] = "|n在自動攻擊計時條上顯示持續時間。"
L["AuraWatch"] = "技能監控"
L["AuraWatchToggleError"] = "技能監控面板無法這樣關閉。"
L["Reset anchor"] = "還原位置"
L["Hide panel"] = "關閉面板"
L["HideUFWarning"] = "|n關閉後，也將關閉施法條和簡易戰鬥訊息。"
L["UFTextScale"] = "文本字體縮放"
L["Bags ShowNewItem"] = "背包新物品高亮"
L["InstantDelete"] = "摧毀時自動填寫DELETE"
L["PartyPetFrame"] = "小隊寵物框架"
L["PartyPetTip"] = "|n你必須同時啟用小隊框架才可以生效。"
L["ToggleDirection"] = "開關方向"
L["ContactList"] = "聯絡人列表"
L["QuickSplit"] = "快速拆分"
L["SplitCount"] = "拆分個數"
L["SplitMode Enabled"] = "|n點擊拆分背包的堆叠物品。|n可在左側輸入框調整每次點擊的拆分個數。"
L["iLvlToShow"] = "物品等級閾值"
L["iLvlToShowTip"] = "|n只在大於所設閾值時顯示裝備等級。"
L["RaidDebuffScale"] = "副本減益圖示縮放"
L["FlatMode"] = "扁平風格按鍵"
L["Shadow"] = "全局背景陰影邊框"
L["BgTex"] = "顯示背景淺色綫條"
L["SkinAlpha"] = "背景淡化透明度"
L["FontOutline"] = "全局字體描邊"
L["DefaultBags"] = "美化暴雪內建背包"
L["DefaultBagsTips"] = "|n需同時禁用插件內建的背包整合功能。"
L["Loot"] = "美化拾取視窗"
L["BlizzardSkins"] = "美化暴雪內建插件"
L["BlizzardSkinsTips"] = "|n禁用此選項時，主要介面將恢復暴雪原生風格。|n|n同時Rematch等插件的美化也會禁用。"
L["BlockStranger"] = "屏蔽陌生人密語"
L["BlockStrangerTip"] = "|n啟用後，只接受來自隊友、好友以及公會成員的密語。"
L["BlockInvite"] = "屏蔽陌生人組隊邀請"
L["BlockInviteTip"] = "|n啟用後，只接受來自好友以及公會成員的組隊邀請。"
L["BagFilterSetup"] = "背包過濾設定"
L["FilterJunk"] = "過濾垃圾物品"
L["FilterAmmo"] = "過濾彈藥或靈魂碎片"
L["FilterEquipment"] = "過濾裝備"
L["FilterEquipSet"] = "過濾裝備配置方案"
L["FilterConsumable"] = "過濾消耗品"
L["FilterLegendary"] = "過濾傳奇品質物品"
L["FilterCollection"] = "過濾藏品"
L["FilterFavourite"] = "過濾偏好物品"
L["FilterGoods"] = "過濾材料等雜貨"
L["FilterQuest"] = "過濾任務物品"
L["FilterBOE"] = "過濾裝綁物品"
L["EnhancedTradeSkills"] = "拓展專業及附魔介面"
L["SmoothAmount"] = "平滑變化頻率"
L["SmoothAmountTip"] = "|n調節頭像和名條血量等平滑變化的頻率。|n平滑度隨著頻率的提高而降低。"
L["ShowAllTip"] = "|n預設不勾選，只顯示玩家自己施放的Buff。|n|n勾選後，則將顯示所有人施放的Buff。"
L["TototUF"] = "目標的目標的目標"
L["TimestampFormat"] = "聊天時間戳格式"
L["GlobalFontScale"] = "字體縮放"
L["CustomJunkMode"] = "垃圾分類"
L["JunkMode Enabled"] = "|n點擊將可售出的物品歸類為垃圾。|n當你開啟自動出售垃圾時，這些物品也將一同售出。|n這個列表是帳號共享的，同時也不會跟隨你的設置導出。|n按住CTRL+ALT並點擊此按鈕，可以清空這個列表。"
L["Home Protocol"] = "本機協議:"
L["World Protocol"] = "世界協議:"
L["Bandwidth"] = "頻寬占用:"
L["Download"] = "下載進度:"
L["SwitchSystemInfo"] = "切換顯示"
L["ClickThroughTip"] = "|n開啟後，法術圖示不再可供交互，滑鼠無法將其選中。"
L["UnitsPerColumn"] = "每列顯示數量"
L["SimpleMode GroupBy"] = "簡易模式排序方式"
L["FrequentHealth"] = "固定時間頻率刷新"
L["FrequentHealthTip"] = "|n啟用後，框架的血量變化會以固定時間間隔刷新，而不是依靠系統血量刷新的事件。"
L["HealthFrequency"] = "刷新時間間隔"
L["HealthFrequencyTip"] = "|n啟用固定時間刷新後，所設定的時間間隔越短，刷新速度越快。"
L["QuickKeybindMode"] = "快速按鍵設定模式"
L["QuickKeybindDescription"] = "你已進入快速按鍵設定模式。將滑鼠游標移動到快捷鍵圖示上，然後按下鍵盤按鍵，即可將它們綁定。"
L["KeyIndex"] = "序號"
L["KeyBinding"] = "按鍵"
L["KeyBoundTo"] = "綁定按鍵"
L["Save keybinds"] = "按鍵設定已保存。"
L["Discard keybinds"] = "按鍵設定已撤銷。"
L["Clear binds"] = "%s |cff00ff00綁定的所有按鍵已清除。"
L["PressToBind"] = "按下一個按鍵對此快捷列進行綁定。"
L["UnbindTip"] = "按ESC或右鍵清除按鍵設定。"
L["NameplateAuraFilter"] = "名條法術過濾"
L["BlackNWhite"] = "只顯示黑白名單"
L["PlayerOnly"] = "名單+玩家"
L["IncludeCrowdControl"] = "名單+玩家+控場技能"
L["NameOnlyMode"] = "友方名條名字模式"
L["NameOnlyModeTip"] = "|n啟用後，友方名條不再顯示血量等信息，只保留名字。|n同時，法術過濾只顯示白名單列表。"
L["IconsPerRow"] = "每行顯示數量"
L["ButtonSize"] = "快捷列尺寸"
L["MaxButtons"] = "最大顯示數量"
L["ButtonsPerRow"] = "每行按鍵數量"
L["ButtonFontSize"] = "快捷列文本字號"
L["ChatBGType"] = "聊天視窗背景樣式"
L["ShowSolo"] = "單人時顯示"
L["ShowSoloTip"] = "|n勾選後，即使你不在隊伍中，也會顯示小隊或者團隊框架。"
L["BagSortMode"] = "背包整理模式"
L["BagSortDisabled"] = "背包整理已被禁用。"
L["Forward"] = "正向"
L["Backward"] = "反向"
L["ExecuteRatio"] = "斬殺指示器閾值"
L["ExecuteRatioTip"] = "|n當名條單位的血量低於設定閾值時，將其名字顏色調整為紅色。|n當閾值設定為0時，即關閉此項功能。"
L["FCTFontSize"] = "戰鬥訊息字號"
L["DisableMap"] = "關閉世界地圖增強"
L["DisableMapTip"] = "|n關閉後，世界地圖的坐標、縮放、移動，以及去除迷霧的功能，都將一同被禁用。|n啟用Mapster時，將自動關閉地圖增強。"
L["Reset junklist warning"] = "你想要清空自定義垃圾列表嗎？"
L["AddContactTip"] = "|n輸入你想要添加為聯絡人的玩家名字，格式為'玩家名字-伺服器名字'。|n如果不填寫伺服器名字，則默認與你同服。|n你可以自定義名字的顏色來予以分類。"
L["FoundIncompatibleAddon"] = "檢測到不兼容插件:"
L["DisableIncompatibleAddon"] = "禁用列表插件"
L["TakeAll"] = "收件"
L["TotalGold"] = "總計金幣"
L["MailIsCOD"] = "無法自動收取付款取信的郵件"
L["MapRevealGlow"] = "未探索區域陰影"
L["MapRevealGlowTip"] = "|n勾選後，若你打開了去除地圖迷霧，未探索區域將同時蒙上一層陰影。"
L["Reset current profile?"] = "你確定重置當前配置嗎？"
L["Apply selected profile?"] = "你確定載入所選配置嗎？"
L["Download selected profile?"] = "你確定將所選配置替換當前使用的配置嗎？"
L["Upload current profile?"] = "你確定將當前使用的配置覆蓋所選的配置嗎？"
L["DefaultCharacterProfile"] = "角色配置"
L["DefaultSharedProfile"] = "共享配置"
L["ProfileName"] = "配置名稱"
L["ProfileNameTip"] = "|n自定义你的配置名称。若清空了輸入框，則自動載入默認的名字。|n|n輸入完畢後，按一下Enter鍵。"
L["ResetProfile"] = "重置當前配置"
L["ResetProfileTip"] = "|n重置當前配置，並載入默認設定，需要重載插件後生效。"
L["SelectProfile"] = "選擇所選配置"
L["SelectProfileTip"] = "|n切換至所選配置，需要重載插件後生效。"
L["DownloadProfile"] = "替換當前配置"
L["DownloadProfileTip"] = "|n讀取所選配置，並覆蓋你當前使用的配置，需要重載插件後生效。"
L["UploadProfile"] = "覆蓋所選配置"
L["UploadProfileTip"] = "|n將你當前使用的配置，覆蓋到所選的配置位。"
L["Profile"] = "配置管理"
L["Profile Management"] = "配置切換及轉移"
L["Profile Description"] = "你可以在這裏管理你的插件配置，使用前請先備份一次你的數據。默認是基於你的角色進行存儲，不進行同賬號下各角色的共享。你也可以切換到共享配置，這樣多個角色就可以使用同一個設定，無需進行重複的導入和導出。|n數據的導入和導出，只支持當前使用的存檔配置。"
L["SharedCharacters"] = "同配置角色"
L["DeleteUnitProfile"] = "刪除指定角色配置"
L["DeleteUnitProfileTip"] = "|n輸入角色的全名來刪除其配置選擇信息，格式為'玩家名字-伺服器名字'。如果沒有填寫伺服器，則默認該角色與你同服。|n|n此操作也會刪除其金幣記錄。|n|n按ESC鍵清空輸入框，按Enter鍵確認。"
L["Delete unit profile?"] = "你確定刪除角色 %s%s|r 的配置選擇信息嗎？"
L["Incorrect unit name"] = "你輸入的角色名稱不存在。"
L["CooldownRemaining"] = "%s 冷卻剩餘%s"
L["CooldownCompleted"] = "%s 冷卻完畢"
L["SendActionCD"] = "發送快捷列冷卻狀態"
L["SendActionCDTip"] = "|n啟用後，當你指向任意快捷列時，可以滾動滑鼠滾輪發送其冷卻狀態。|n|n只對NDui的快捷列生效。"
L["Contact"] = "聯係方式"
L["UnlockUI"] = "介面移動"
L["GotIt"] = "懂了"
L["ChatScrollHelp"] = "滾輪時按住Ctrl鍵可一次滾動多行，按住Shift鍵快速滾動置頂或置底。"
L["MinimapHelp"] = "滑鼠滾輪可以縮放區域，滑鼠中鍵點擊打開行事曆。"
L["Reset Help"] = "重置幫助提示"
L["Reset NDui Helpinfo"] = "你想要重置所有幫助提示嗎？"
L["ColoredTarget"] = "染色目標名條"
L["ColoredTargetTip"] = "|n啟用後，染色你當前的目標名條，優先級高於自定義及仇恨染色。|n你可以在下面的選項中自定義這個顏色。"
L["TargetNP Color"] = "目標名條顏色"
L["InstanceAurasTip"] = "|n顯示副本相關的自定義法術監控。"
L["CustomTex"] = "自定義材質路徑"
L["CustomTexTip"] = "|n將你的自定義材質放置在Interface目錄下，然後輸入其名字，即可替換默認材質風格。|n如若替換後是純綠色，説明你的材質有誤，或尚未重新啟動客戶端。|n清空輸入框則關閉自定義功能。需要重載插件後生效。"
L["PlateCastbarGlow"] = "重要施法條高亮"
L["PlateCastbarGlowTip"] = "|n當目標施放你覺得重要的法術時，高亮其法術圖示。|n點擊齒輪可以自定義這個列表。"
L["PlateCastTarget"] = "顯示法術目標"
L["PlateCastTargetTip"] = "|n啟用後，顯示名條單位施法時的當前目標。"
L["ColoredFocus"] = "染色焦點名條"
L["ColoredFocusTip"] = "|n啟用後，染色你的焦點名條，優先級高於自定義及仇恨染色。|n你可以在下面的選項中自定義這個顏色。"
L["FocusNP Color"] = "焦點名條顏色"
L["Switch Mode"] = "切換模式"
L["GreyBackdrop"] = "灰色面板邊框"
L["GreyBackdropTip"] = "|n當背景顏色調整為全黑時，如若看不清面板邊框，可以啟用這個選項。"
L["ShowRaidBuff"] = "顯示增益指示器"
L["ShowRaidBuffTip"] = "|n點擊右側齒輪設置團隊框架的法術白名單，最多同時顯示3個。"
L["ShowRaidDebuff"] = "顯示減益指示器"
L["ShowRaidDebuffTip"] = "|n以暴雪團隊框架的邏輯來顯示負面效果，最多同時顯示3個。"
L["RaidBuffSize"] = "增益圖示大小"
L["RaidDebuffSize"] = "減益圖示大小"
L["SmartRaid"] = "僅超員後顯示團隊"
L["SmartRaidTip"] = "|n啟用後，只有隊伍人數超過5人時，才顯示團隊框架。|n若未啟用，則處於團隊時顯示團隊框架，不在團隊時顯示小隊框架。|n|n只在啟用小隊框架時生效。"
L["PlateRange"] = "名條顯示距離"
L["LanguageFilterTip"] = "需要在控制台取消關閉語言過濾器，並重載插件後才能正常連接國服戰網支持。"
L["EquipColor"] = "已裝備物品染色邊框"
L["UIScaleTip"] = "|n當UI縮放低於0.64時，部分暴雪插件和第三方插件可能會出現奇怪的問題。"
L["PetHappiness"] = "獵人寵物狀態提示"
L["PetUnhappy"] = "%s你的寵物 [%s] 快要跑了。"
L["PetBadMood"] = "%s你的寵物 [%s] 有點小情緒。"
L["PetHappy"] = "%s你的寵物 [%s] 感到很開心。"
L["MenuButton"] = "便捷右鍵選單按鈕"
L["MenuButtonTip"] = "|n在右鍵選單上方添加彩色按鈕，以快速添加好友、邀請公會以及複製名字。"
L["SaveMailTarget"] = "保存上次的收件人"
L["AspectBar"] = "獵人守護條"
L["AspectSize"] = "守護圖示大小"
L["VerticleAspect"] = "豎直排列守護"
L["TradeSearchTip"] = "|n輸入你要搜索的配方名稱，按Esc清空輸入框。|n"
L["InvalidName"] = "你輸入的内容不存在。"
L["NoMatchReult"] = "沒有更多匹配選項。"
L["BlockSpammer"] = "阻止刷屏者的訊息"
L["BlockSpammerTip"] = "|n啟用後，在聊天中重複廣告刷屏的玩家會被屏蔽，你不再接收他的任何訊息。"
L["ToggleCastbarTip"] = "|n施法條開關，無需重載插件。"
L["ChatSwitchHelp"] = "按Tab鍵能直接在可用的頻道之間切換，一直按頻道按鈕有點笨。"
L["WhisperSound"] = "私聊訊息提示音"
L["WhisperSoundTip"] = "|n啟用後，當距離上一條私聊訊息超過5秒時，播放訊息提示音。"
L["BagSearchTip"] = "|n點擊對背包進行搜索。|n你可以搜索物品的名字或者裝備的部位。|n輸入boe可以直接搜索裝綁，輸入任務則搜索任務道具。"
L["ClampTargetPlate"] = "鎖定目標名條"
L["ClampTargetPlateTip"] = "|n勾選後，當前選中的目標名條將始終停留在屏幕範圍内。"
L["FriendPlate"] = "友方名條獨立尺寸"
L["FriendPlateTip"] = "|n啟用後，你可以為友方名條設置單獨的尺寸，以區分敵方名條。|n不啟用，則全部使用敵方名條的設定。|n|n你必須關閉友方名條名字模式才能生效友方獨立尺寸。"
L["NameplateSize"] = "名條尺寸設置"
L["HostileNameplate"] = "敵方名條"
L["FriendlyNameplate"] = "友方名條"
L["SysMaxAddOns"] = "系統訊息插件數量"
L["SysMaxAddOnsTip"] = "|n在系統訊息條的滑鼠提示中顯示的最大插件數量。"
L["InfobarFontSize"] = "訊息條字體大小"
L["LeftInfobar"] = "左側訊息條"
L["RightInfobar"] = "右側訊息條"
L["InfobarStrTip"] = "|n根據你輸入的字符組合對訊息條進行排序:|n[guild] 公會|n[friend] 好友|n[ping] 延遲|n[fps] 幀數|n[zone] 地點|n[spec] 專精|n[dura] 耐久度|n[gold] 金幣|n[time] 時間|n|n你可以自行調整順序，但是一個訊息條只能被使用一次。|n注意拼寫及大小寫格式，清空輸入框將重置設定。"
L["BagsPerRow"] = "每列背包數量"
L["BagsPerRowTip"] = "|n开启背包物品分类存放后，每一列允许堆叠的最大背包數量。"
L["BankPerRow"] = "每列銀行背包數量"
L["BankPerRowTip"] = "|n開啟背包物品分類存放後，每一列允許堆叠的最大銀行背包數量。"
L["PlateAuras"] = "名條法術監控"
L["ActionbarSetup"] = "快捷列設定"
L["BaudErrorTip"] = "你的插件報錯了，點擊下方數字查看並反饋。"
L["ApplyBarStyle"] = "按住Ctrl鍵並點擊以載入該快捷列佈局。"
L["CastbarTextSize"] = "施法條文本字號"
L["CastbarTextOffset"] = "施法條文本縱向偏移"
L["StyleStringError"] = "你輸入的快捷列佈局存在錯誤。"
L["ExportActionbarStyle"] = "導出當前使用的快捷列佈局。"
L["ImportActionbarStyle"] = "導入他人分享的快捷列佈局。"
L["Friendly ClickThru"] = "友方名條點擊穿越"
L["Enemy ClickThru"] = "敵方名條點擊穿越"
L["MicroMenuTip"] = "|n微型選單設計之初就是與NDui内設快捷列共同生效，單獨啟用可能會導致一些潛在的污染問題。"
L["TipAnchor"] = "滑鼠提示框錨點"
L["TipAnchorTip"] = "|n調整滑鼠提示框的初始錨點，將按照錨點的反方向延展。"
L["HealthValueType"] = "血量數值顯示方式"
L["PowerValueType"] = "能量數值顯示方式"
L["ShowHealthDefault"] = "當前數值 | 百分比"
L["ShowHealthCurMax"] = "當前數值 | 總上限"
L["ShowHealthCurrent"] = "當前數值"
L["ShowHealthPercent"] = "當前百分比"
L["ShowHealthLoss"] = "損耗數值"
L["ShowHealthLossPercent"] = "損耗百分比"
L["DesaturateIcon"] = "降低他人減益飽和度"
L["DesaturateIconTip"] = "|n勾選後，僅染色來自玩家自身的減益，降低他人所施加的減益飽和度。"
L["NameTextType"] = "名字顯示方式"
L["Tag:name"] = "顯示名字"
L["Tag:rarename"] = "稀有 名字"
L["Tag:levelname"] = "等級 名字"
L["Tag:rarelevelname"] = "稀有 等級 名字"
L["PlateLevelTagTip"] = "|n啟用名條等級顯示時，如果其等級與你一致，則不顯示。|n|n友方名字模式的名條，不受此項影響。"
L["Width"] = "寬度"
L["Height"] = "高度"
L["xOffset"] = "橫向偏移"
L["yOffset"] = "縱向偏移"
L["ShowAuras"] = "顯示框架的增減益"
L["BuffType"] = "增益顯示方式"
L["DebuffType"] = "減益顯示方式"
L["MaxBuffs"] = "最大增益數量"
L["MaxDebuffs"] = "最大減益數量"
L["ShowAll"] = "顯示全部"
L["ShowDispell"] = "顯示可驅散"
L["BlockOthers"] = "屏蔽他人"
L["DebuffColor"] = "減益法術邊框染色"
L["DebuffColorTip"] = "|n根據減益法術的類型，染色其圖示邊框。"
L["ClassColor Name"] = "名字使用職業顏色"
L["BuffFrame"] = "NDui Buff框架"
L["BuffFrameTip"] = "|n替換顯示默認處於畫面右上角的Buff及Debuff框架。"
L["HideBlizUI"] = "隱藏暴雪框架"
L["HideBlizBuffTip"] = "|n隱藏暴雪Buff框架。|n當你啟用NDui的Buff框架時，自動禁用暴雪自帶的Buff框架。"
L["ReverseGrow"] = "反方向增長排列"
L["100PercentTip"] = "|n啟用百分比顯示時，如果百分比為100%則不顯示。"
L["MaxColumns"] = "最大顯示列數"
L["Visibility"] = "可見性"
L["ShowInParty"] = "僅在隊伍顯示"
L["ShowInRaid"] = "僅在團隊顯示"
L["ShowInGroup"] = "組隊即顯示"
L["HideTooltip"] = "禁用滑鼠提示訊息"
L["HideTooltipTip"] = "|n勾選後，當你指向框架時，不再顯示提示訊息。"
L["GrowthDirection"] = "增長方向"
L["RaidDirectionTip"] = "|n調整團隊框架的增長方向。|n左邊的方向代表小隊内成員的增長方向，右邊的方向代表各小隊間的增長方向。"
L["DOWN_RIGHT"] = "向下 向右"
L["DOWN_LEFT"] = "向下 向左"
L["UP_RIGHT"] = "向上 向右"
L["UP_LEFT"] = "向上 向左"
L["RIGHT_DOWN"] = "向右 向下"
L["RIGHT_UP"] = "向右 向上"
L["LEFT_DOWN"] = "向左 向下"
L["LEFT_UP"] = "向左 向上"
L["GO_DOWN"] = "向下"
L["GO_UP"] = "向上"
L["GO_RIGHT"] = "向右"
L["GO_LEFT"] = "向左"
L["SMRDirectionTip"] = "|n調整簡易模式團隊框架的增長方向，需要重載插件後生效。"
L["RaidRows"] = "每組隊伍數量"
L["BottomBox"] = "輸入框置於下方"
L["BlockDBM"] = "屏蔽DBM法術圖示"
L["BlockDBMTip"] = "|n啟用後，關閉DBM在部分戰鬥中對名條添加的法術圖示監控，該法術會自動添加到白名單中並顯示。"
L["AutoHide"] = "自動關閉"
L["OffhandOnTop"] = "副手計時條在上"
L["ShowNPCTitle"] = "顯示NPC頭銜訊息"
L["ShowUnitGuild"] = "顯示公會訊息"
L["TitleTextSize"] = "訊息文本字號"
L["CVarOnlyNames"] = "暴雪名條只顯示名字"
L["CVarOnlyNamesTip"] = "|n勾選後，對於暴雪自帶的名條將只保留名字。|n需要重載插件後生效。"
L["CVarShowNPCs"] = "總是顯示NPC名條"
L["CVarShowNPCsTip"] = "|n勾選後，將總是顯示NPC名條。否則只在選中NPC時顯示。"
L["Dispellable"] = "顯示可驅散法術"
L["DispellableTip"] = "|n過濾：顯示並高亮你能驅散的魔法或激怒效果。|n|n總是：始終顯示目標身上所有魔法及激怒效果，無論你是否可以驅散。"
L["Filter"] = "過濾"
L["Always"] = "總是"
L["ShowInterruptor"] = "施法條顯示打斷者"
L["MmssThreshold"] = "显示分秒的阈值"
L["MmssThresholdTip"] = "|n当冷却时间小于所设阈值时，精确显示分秒。|n例如2分半显示为2:30。"
L["TenthThreshold"] = "显示小数点阈值"
L["TenthThresholdTip"] = "|n当冷却时间小于所设阈值时，精确显示到小数十分位。|n例如3秒显示为3.0。"
L["TargetedByTip"] = "|n在名條右側顯示隊友關注的統計，只在副本中生效。"
L["IgnoredButtons"] = "回收站忽略列表"
L["IgnoredButtonsTip"] = "|n輸入你不想收納進回收站的按鈕名字。你可以輸入/fstack後指向圖示來查看，只需輸入名字的一部分即可。|n對於多個按鈕名字，以空格隔開。需要重載插件後生效。"
L["MaxZoom"] = "最大視距等級"
L["BuffClickThru"] = "禁用增益法術提示訊息"
L["DebuffClickThru"] = "禁用減益法術提示訊息"
L["SysFont"] = "使用系統字體路徑"
L["SysFontTip"] = "|n啟用後，聊天窗口將使用系統的字體路徑，不再與其他UI元素統一。"
L["PlateClickThruTip"] = "|n啟用後，名條不再可供交互，滑鼠無法選中它。"
L["ScrollingCT"] = "卷軸滾動模式"
L["EasyVolume"] = "快速音量調節"
L["EasyVolumeTip"] = "|n啟用後，你可以按住CTRL鍵滾動小地圖來調整音量大小。|n按住CTRL+ALT鍵並滾輪，可以使音量在0和100切換。"
L["ColorByDot"] = "特定法術染色名條"
L["ColorByDotTip"] = "|n啟用後，當目標身上含有來自你的特定法術時，染色名條。"
L["ColorDotsList"] = "法術染色列表"
L["NPCID or Name"] = "|n輸入NPCID或者名字。|n|n你可以按住SHIFT鍵觀察目標來獲取NPCID。"
L["ShowPowerUnits"] = "顯示特定單位法力值"
L["PowerUnitsTip"] = "|n啟用後，在特定單位的名條下方顯示其當前法力值。"
L["Name Offset"] = "名字縱向偏移"
L["LeftButon"] = "左鍵"
L["RightButton"] = "右鍵"
L["MiddleButton"] = "中鍵"
L["Button4"] = "側鍵1"
L["Button5"] = "側鍵2"
L["AutoEquip"] = "自動切換裝備方案"
L["AutoEquipTip"] = "|n啟用後，當你切換天賦時，若存在與該天賦同名的裝備方案，則自動使用這個方案。"
L["TotemBar"] = "圖騰快捷列"
L["ClearHealth"] = "透明"
L["ClearClass"] = "漸變職業色"
L["PetCastbar"] = "寵物施法條"
L["OffTankThreat"] = "啟用副坦仇恨"
L["OffTankThreatTip"] = "|n根據隊伍成員的職責，當目標仇恨在其他坦克身上時，使用自定義顏色。|n|n注意，確保你的隊友們選擇了正確的職責。"
L["HealPrediction"] = "顯示hot治療預估值"
L["DemonPage"] = "術士惡魔形態翻頁"
L["DispellTypeTip"] = "|n總是：始終顯示魔法、詛咒、疾病及中毒效果。|n|n過濾：只顯示你可以驅散的負面效果，對於你可以驅散的法術，圖示邊框是帶有顏色的。"
L["GearManagerTip"] = "雙擊圖示即可裝備該方案。"
L["AutoBuffsTip"] = "|n勾選後，不再使用白名單過濾，而使用暴雪自帶邏輯顯示增益，上限3個。"
L["AutoRepairInfo"] = "訊息條的耐久及貨幣模塊，可以調整自動修理和自動出售垃圾。"
L["AuraFontSize"] = "法術文本大小"
L["SizeRatio"] = "圖示高寬比率"
L["DisableMinimap"] = "禁用小地圖增强"
L["DisableMinimapTip"] = "|n關閉後，下方小地圖的所有模塊都將一同被禁用。|n啟用SexyMap時，將自動關閉小地圖增强。"
L["ChargesRemaining"] = "%s %s/%s 下層充能剩餘%s"
L["ChargesCompleted"] = "%s %s/%s 充能完畢"
L["ToggleActionbarTip"] = "|n快捷列開關，無需重載插件。"
L["BlizzMover"] = "保存角色面板位置"
L["BlizzMoverTip"] = "|n啟用後，將對角色面板移動後的位置進行保存。按CTRL+左鍵可以還原其初始位置。|n|n同時支持任務面板。"
L["TarName"] = "顯示目標名字"
L["Spacing"] = "間距"
L["AuraWatch MinCD"] = "冷卻時間最小值"
L["MinCDTip"] = "|n法術的冷卻時間必須大於設定數值，才會進行監控。"
L["HideInCombat"] = "戰鬥中隱藏滑鼠提示"
L["HideInCombatTip"] = "|n選擇戰鬥中隱藏滑鼠提示的方式。|n當切換為修飾鍵時，只有按住它才可以在戰鬥中顯示。"
L["HideDPSRole"] = "隱藏DPS職責"
L["ShowRoleMode"] = "職責圖標顯示方式"
L["MoreFontSize"] = "更多字體大小"
L["EditFont"] = "輸入框字體大小"
L["KeyDown"] = "按下快捷列施法"
L["ButtonLock"] = "鎖定快捷列"
L["KeyDownTip"] = OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN
L["ButtonLockTip"] = OPTION_TOOLTIP_LOCK_ACTIONBAR
L["CPU Usage Warning"] = "你打開了CPU使用記錄，這會導致性能下降，你想禁用它還是繼續？"
L["SortByRole"] = "按職責排序"
L["SortByRoleTip"] = "|n勾選後，按職責對小隊成員進行排序。否則按小隊成員編號排序。"
L["SortAscending"] = "升序排序"
L["SortAscendingTip"] = "|n勾選後，按升序對小隊成員進行排序。否則按降序排序。"