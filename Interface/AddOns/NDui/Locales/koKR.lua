local _, ns = ...
local _, _, L = unpack(ns)
if GetLocale() ~= "koKR" then return end

L["From"] = "출처"
L["Tell"] = "알림"
L["Ghost"] = "영혼"
L["Skip"] = "스킵"
L["Sort"] = "정리"
L["Chat Copy"] = "%s복제|n%s메뉴"
L["Attach List"] = "첨부파일:"
L["Rare"] = "희귀"
L["Stack Cap"] = "중첩상한"
L["Lack"] = "부족"
L["Flask"] = "영약"
L["Food"] = "음식"
L["World Channel"] = "월드채널"
L["Raid Tool"] = "레이드툴"
L["Disband Info"] = "확인|cffff0000해산|r파티 또는 공대?"
L["Disband Process"] = "NDui공대해체 중"
L["Raid Buff Check"] = "NDui도핑체크:"
L["Count Down"] = "시작/최소 카운트"
L["Check Status"] = "도핑체크"
L["Buffs Ready"] = "도핑체크: 준비완료."
L["DBM Required"] = "사용중인 DBM 또는 BigWigs가 없습니다."
L["ReloadUI Required"] = "애드온 재로딩 후 적용됩니다"
L["Default Settings Check"] = "기본설정으로 로딩하였습니다."
L["Tutorial Complete"] = "튜토리얼 로딩 완료."
L["Tips"] = "팁"
L["Version Info1"] = "버전 로딩 완료，"
L["Version Info2"] = "입력 가능"
L["Version Info3"] = "더 많은 정보를 획득하십시오."
L["Tutorial Page1"] = "해당 페이지에서 설정 가능:|cffffcc00액션바, 스킬모니터링, 레이드툴, 네임플레이트|r등 유용한 설정을 할 수 있습니다|n|n|cffff0000해당 페이지는 스킵불가입니다.|r"
L["Tutorial Page2"] = "|cffff0000주의: 본 페이지의 설정은 계정 내 공유됩니다.|r|n|n해당 페이지는 Skada、DBM、BigWigs설정 페이지이고(잠금아님)，NDui스트일에 맞게 설정되였습니다.|n|n필요하면|cffffcc00콘솔-스킨에서|r취소할 수 있습니다."
L["Tutorial Page3"] = "설정완료!|cffffcc00적용|r을 클릭 시 활성화됩니다.|n|n|cffff0000주의:|r|n|n각 모듈마다 추가기능이 있습니다.|n|n대부분의 설정은 콘솔에서 모두 수정할 수 있습니다.|r"
L["Help Title"] = "설명"
L["Help Intro"] = "Welcome NDui，아래는 자주 사용하는 명령어입니다.|n|n처음 사용하는 유저라면 튜토리얼의 진행을 추천드립니다."
L["Cmd bb intro"] = "단축키 설정"
L["Cmd mm intro"] = "UI 이동"
L["Cmd rl intro"] = "애드온 재로딩"
L["Cmd ncl intro"] = "패치 로그"
L["Cmd ww intro"] = "스킬 커스텀"
L["Tutorial"] = "튜토리얼"
L["Default Settings"] = "기본설정"
L["Changelog"] = "업데이트 로그"
L["AutoQuest"] = "임무 자동수락/완료"
L["AutoQuestTip"] = "|n자동임무 완료 사용 시, 1개의 완료 퀘스트가 있어도 자동으로 반납합니다.|nShift키를 누르고 있으면 이번 상호작용은 취소됩니다.|n|nAlt키를 누르고 NPC와 대화 시, 차단하고 더이상 상호작용을 하지 않습니다. "
L["AutoQuestIgnoreTip"] = "|n더이상 대상 NPC와 자동 임무 수락/완료를 하지 않습니다. ALT를 누른상태에서 NPC클릭시 차단을 해제할 수 있습니다."
L["StanceBar"] = "추가 액션바"
L["ShowStanceBar"] = "추가 액션바 사용"
L["LeaveVehicle"] = "취소"
L["Pet Actionbar"] = "팻 액션바"
L["Actionbar"] = "액션바"
L["Unitframes"] = "유닛프레임과 캐스팅바"
L["Auras"] = "스킬과 효과"
L["Raid Tools"] = "레이드툴"
L["ChatFrame"] = "채팅창"
L["Maps"] = "맵"
L["Nameplate"] = "네임플레이트"
L["Skins"] = "스킨"
L["Tooltip"] = "툴팁"
L["Misc"] = "편의성"
L["UI Settings"] = "UI세팅"
L["Enable Actionbar"] = "액션바 사용"
L["ActionBarTip"] = "|n해제 시, 하단 메인메뉴바도 함께 사용금지 됩니다."
L["Actionbar Hotkey"] = "단축키 표시"
L["Actionbar Macro"] = "매크로 표시"
L["Actionbar Grid"] = "Show Grid" -- need translation
L["ClassColor BG"] = "직업컬러 배경"
L["Show Cooldown"] = "쿨타임표시"
L["Enable AuraWatch"] = "스킬감시 사용"
L["AuraWatch ClickThrough"] = "스킬감시 툴팁중지"
L["Enable Reminder"] = "효과상실 알림"
L["ReminderTip"] = "|n특정직업 자체버즈 부족 시 알림.|n인내/지능/전투외침/발바닥/가시/수호/오라/흑마와 법사 마갑."
L["Enable Totembar"] = "토템바 사용"
L["Totembar"] = "토템바"
L["VerticalTotems"] = "토템 수직배열"
L["TotemSize"] = "토템아이콘사이즈"
L["Enable UFs"] = "유닛프레임 사용"
L["UFs Portrait"] = "3D프레임사용"
L["Arena Frame"] = "투기장 프레임 사용"
L["UFs Castbar"] = "캐스팅바 사용"
L["UFs CombatText"] = "전투정보 표시"
L["CombatText HotsDots"] = "Hot/Dot등 지속효과 표시"
L["CombatText ShowPets"] = "팻으로 인한 치유와 피해"
L["CombatText AutoAttack"] = "자동공격피해"
L["CombatText OverHealing"] = "오버힐량표시"
L["CombatText"] = "전투정보"
L["UFs SwingBar"] = "자동공격 스윙바"
L["UFs SwingTimer"] = "시간표시"
L["UFs ClassPower"] = "직업 특수 파워"
L["PlayerUF"] = "유저 유닛프레임"
L["TargetUF"] = "타겟 유닛프레임"
L["TotUF"] = "타겟의타겟 유닛프레임"
L["PetUF"] = "팻 프레임"
L["FocusUF"] = "주시대상프레임"
L["FotUF"] = "주시대상의 타겟프레임"
L["BossFrame"] = "투기장 프레임"
L["UFs RaidFrame"] = "레이트프레임 사용"
L["RaidFrameTip"] = "|n사용금지 시 간이모드,파티,팻프레임도 모두 금지됩니다."
L["RaidFrame"] = "레이드프레임"
L["Num Groups"] = "파티넘버 표시"
L["RaidFrame TeamIndex"] = "파티번호표시"
L["SimpleRaidFrame"] = "간이 프레임"
L["SimpleRaidFrameTip"] = "|n간이 레이드프레임은 오직 체력등 주요정보만 표시합니다."
L["Instance Auras"] = "던전의 중요Debuff표시"
L["RaidAuras ClickThrough"] = "금지스킬의 알림"
L["SimpleMode Scale"] = "간이모드 사이즈"
L["Spec RaidPos"] = "주/부특성 별도 포지션"
L["SpecRaidPosTip"] = "|n체크 시, 파티와 레이드 프레임은 나의 주/부특성에 따라 저장됩니다. "
L["Lock Chat"] = "채팅창 설정잠금"
L["Chat Sticky"] = "귓말 시 채널잠금"
L["Whisper Invite"] = "귓말자동 초대사용"
L["Whisper Keyword"] = "귓말키워드"
L["WhisperKeywordTip"] = "|n귓말은 빈칸으로 여러개를 설정할 수 있습니다."
L["Default Channel"] = "채팅창 간이명칭 취소"
L["Guild Invite Only"] = "길드원만 초대"
L["EasyMark"] = "손쉬운 징표표시"
L["EasyMarkTip"] = "|n설정한 단축키를 누른상태에서 좌클릭 후 징표표시를 진행합니다."
L["Enable Chatfilter"] = "채팅필터사용"
L["Block Addon Alert"] = "애드온에러필터"
L["Keyword Match"] = "필터링 단어수량"
L["Filter List"] = "필터링 단어"
L["Minimap Clock"] = "미니맵에 시간표시"
L["Map Scale"] = "Window map scale" -- need translation
L["Maximize Map Scale"] = "Fullscreen map scale" -- need translation
L["Minimap Scale"] = "미니맵 사이즈"
L["Minimap Size"] = "미니맵 사이즈"
L["Minimap Pulse"] = "미니맵 테두리"
L["Minimap RecycleBin"] = "애드온 아이콘 통합"
L["Show RecycleBin"] = "애드온 아이콘 취합"
L["Show WhoPings"] = "미니맵 클릭자 이름표시"
L["Enable Nameplate"] = "네임플레이트 사용"
L["Tank Mode"] = "직업별 컬러로 표시"
L["TankModeTip"] = "|n선택 시, 타겟의 어그로는 체력형태로 표현됩니다.|n커스터마이즈 컬러를 선택한 타겟은 여전히 테두리컬러로 어그로량이 표시됩니다."
L["Friendly CC"] = "아군 직업 컬러"
L["Hostile CC"] = "적군 직업 컬러"
L["NP VerticalSpacing"] = "중첩간격"
L["Max Auras"] = "스킬아이콘 표시수량"
L["Auras Size"] = "스킬아이콘 사이즈"
L["ShowCustomUnits"] = "특정유닛의 컬러커스터마이징"
L["CustomUnitsTip"] = "|n특정 타겟의 네임플레이트가 설정한 컬러로 표시됩니다.|n특정타겟리스트와 컬러를 자체적으로 설정가능합니다."
L["UnitColor List"] = "특정유닛의 컬러리스트"
L["ShowPowerList"] = "파워바 표시타겟"
L["DBM Skin"] = "DBM 스킨사용"
L["Micromenu"] = "미니 메뉴 사용"
L["Menubar"] = "미니 메뉴"
L["Infobar Line"] = "배경 테두리사용"
L["Chat Line"] = "채팅창 테두리사용"
L["Menu Line"] = "미니메뉴 테두리사용"
L["ClassColor Line"] = "직업컬러 테두리사용"
L["Skada Skin"] = "Skada스킨사용"
L["Bigwigs Skin"] = "BigWigs스킨사용"
L["TMW Skin"] = "TellMeWhen스킨사용"
L["WeakAuras Skin"] = "WeakAuras스킨사용"
L["Bags"] = "가방"
L["Enable Bags"] = "통합가방 사용"
L["Bags IconSize"] = "가방 슬롯사이즈"
L["Bags FontSize"] = "Bags FontSize"
L["Bags Width"] = "가방 가로수량"
L["Bank Width"] = "은행 가로수량"
L["Bags Itemlevel"] = "아이템 레벨표시"
L["Bags ItemFilter"] = "아이템 분류"
L["Raid Manger"] = "레이드툴 사용"
L["Runes Check"] = "룬 체크"
L["Lock UIScale"] = "UI사이즈 자동적용"
L["DBMCount"] = "카운트다운"
L["DBMCountTip"] = "|n공대 전투준비 카운트다운 시간.|n필요한 애드온: DBM 또는 Bigwigs."
L["Setup UIScale"] = "UI사이즈 조절"
L["Follow Cursor"] = "마우스커서 위치에 표시"
L["ShowItemQuality"] = "아이템 퀄리티 표현"
L["Hide Rank"] = "길드내 직급 숨김"
L["Hide Title"] = "칭호 숨김"
L["Hide Realm"] = "서버명표시(Shift누를시)"
L["FactionIcon"] = "진영 아이콘 표시"
L["Show TargetedBy"] = "타겟팅한 파티원"
L["Mail Tool"] = "메일툴 사용"
L["Show ItemLevel"] = "캐릭터창 장비품질 표시"
L["Hide Error"] = "전투 중 에러필터링"
L["Language Filter"] = "채팅 필터링 금지"
L["Easy Focus"] = "Shift+좌클릭으로 주시대상 설정"
L["Show Expbar"] = "미니맵에 경험치/평판표시"
L["Auto ScreenShot"] = "업적 획득 시 자동 스샷"
L["InterruptAlert"] = "파티채널 스킬차단 알림"
L["OwnInterrupt"] = "본인과 팻의 차단만 알림"
L["DispellAlert"] = "파티채널에 마법해제 알림"
L["OwnDispell"] = "본인과 팻의 마법해제만 알림"
L["BrokenAlert"] = "매즈스킬 풀림 알림"
L["BrokenAlertTip"] = "|n누군가 매즈를 풀리게 하면 알림.|n실명, 얼덫, 양변등"
L["LoCAlert"] = "내가 매즈당했을때 알림"
L["LoCAlertTip"] = "|n체크 시, 내가 실명, 절, 양변등 매즈스킬을 당했을때에만 알림"
L["InstAlertOnly"] = "던전에서만 알림"
L["InstAlertOnlyTip"] = "|n체크 시, 던전에서 매즈당했을때만 알림, 필드에서는 알림 안함."
L["Interrupt"] = "차단 - %s > %s"
L["Steal"] = "스틸 - %s > %s"
L["Dispel"] = "해제 - %s > %s"
L["BrokenSpell"] = "풀림 - %s > %s"
L["LossControl"] = "매즈당함 - %s > %s (%ss %s)"
L["QuestNotification"] = "퀘스트 알림"
L["QuestProgress"] = "퀘스트 상세현황 알림"
L["AcceptQuest"] = "퀘스트 수락 알림"
L["Faster Loot"] = "자동루팅 가속"
L["Numberize"] = "숫자 표시방식"
L["Number Type1"] = "표준방식: b/m/k"
L["Number Type2"] = "글자방식: 억/만"
L["Number Type3"] = "상세수치표시"
L["NDui Reset"] = "NDui Reset"
L["Reset NDui Check"] = "본 애드온의 모든 설정을|cffff0000초기화를|r진행하시겠습니까？"
L["NDui Console"] = "NDui 설정"
L["Player Castbar"] = "유저 캐스팅바"
L["Target Castbar"] = "타겟 캐스팅바"
L["Focus Castbar"] = "주시대상 캐스팅바"
L["Get Out"] = "산개하세요!"
L["Get Close"] = "Boss 옆으로 모이세요!"
L["Stack Buying Check"] = "해당 리스트의 아이템을 |cffff0000한 세트|r구매하시겠습니까？"
L["Invite"] = "초대"
L["Copy Name"] = "복제"
L["Whisper"] = "귓말"
L["Targeted By"] = "주시: "
L["NumberCap1"] = "만"
L["NumberCap2"] = "억"
L["NumberCap3"] = "조"
L["Get Naked"] = "우클릭으로 모든 장비 해제"
L["Mover Console"] = "NDui콘솔이동"
L["Grids"] = "통신"
L["Reset Mover Confirm"] = "모든 UI위치를 초기화 하시겠습니까?"
L["AWConfig Title"] = "NDui스킬감시 설정"
L["AWConfigTips"] = "|n각 항목에 마우스를 올려 가이드를 확인하십시오.|n설정 후 재로딩이 필요합니다."
L["Groups"] = "그룹"
L["Player Aura"] = "유저 오라"
L["Target Aura"] = "타겟 오라"
L["Special Aura"] = "유저 중요 오라"
L["Focus Aura"] = "주시대상 오라"
L["Spell Cooldown"] = "쿨타임"
L["Enchant Aura"] = "마부와 장신구"
L["Raid Buff"] = "공대Buff"
L["Raid Debuff"] = "공대Debuff"
L["Warning"] = "타겟의 중요Buff"
L["InternalCD"] = "커스터마이징"
L["Type*"] = "타입*"
L["Unit*"] = "유닛*"
L["Caster"] = "시전자"
L["Stack"] = "중첩수"
L["Value"] = "Buff값"
L["Timeless"] = "시간감추기"
L["Combat"] = "전투중표시"
L["Text"] = "텍스트 알림"
L["Slot*"] = "장비슬롯 위치"
L["Totem*"] = "토템슬롯위치"
L["AuraWatch List"] = "커스터마이징 리스트"
L["Choose a Type"] = "한가지 Buff의 유형을 선택하세요."
L["Incomplete Input"] = "모든 별표가 있는 항목은 필수입력입니다."
L["Incorrect SpellID"] = "입력한 스킬ID가 유효하지 않습니다."
L["Existing ID"] = "이미 추가된 마법입니다."
L["TotemSlot"] = "토템슬롯"
L["Reset your AuraWatch List?"] = "모든 그룹의 커스터마이징 리스트를 초기화 하시겠습니까?"
L["Type Intro"] = "|nAuraID: 감시Buff/Debuff의 상태；|n|nSpellID: 감시스킬의 쿨타임；|n|nSlotID: 감시 장비슬롯의 쿨타임；|n|nTotemID: 감시한 토템의 지속시간."
L["ID Intro"] = "|n마법의 ID, 숫자로 입력.|n|n스킬에 마우스를 올려 ID를 확인하세요.|n|n텍스트로 스킬명을 입력 시 식별할 수 없습니다."
L["Unit Intro"] = "|n스킬의 시전자를 감시.|n|nplayer: 타 유저가 시전한 스킬；|n|ntarget: 타겟이 시전한 스킬；|n|nfocus: 주시대상가 시전한 스킬；|n|npet: 팻이 시전한 스킬."
L["Caster Intro"] = "|n스킬의 시전자를 필터링.|n|nplayer: 시전자가 본인일때；|n|ntarget: 시전자가 타겟일때；|n|npet: 시전자가 팻일때.|n|n빈칸으로 남길 시 아무나 시전하는 모든 스킬을 표시합니다."
L["Stack Intro"] = "|n스킬 중첩수의 필터링, 숫자여야 함.|n|n입력한 숫자만큼 중첩되어야 표시.|n|n빈칸으로 남길 시 중첩에 상관없이 모두 표시."
L["Value Intro"] = "|n선택 시, 스킬의 구체적인 값을 표시.|n|n예를들자면 사제의 보호막의 흡수가능한 피해량을 표시.|n|n텍스트 툴팁보다 우선순위가 높음."
L["Timeless Intro"] = "|n선택 시, 해당 스킬의 쿨타임이 숨김처리 됩니다."
L["Combat Intro"] = "|n선택 시, 해당 스킬은 전투중에만 표시됩니다."
L["Text Intro"] = "|n스킬의 텍스트 툴팁.|n|n스킬 활성화 시 설정한 테스트가 표시됩니다.|n|n값 또는 빈칸으로 남길 시 텍스트 알림이 표시되지 않습니다."
L["Slot Intro"] = "|n설정한 장비슬롯의 쿨타임을 표시합니다.|n|n예를들면 기공허리띠, 망토등등.|n|n장신구는 오직 직접 사용할 수 있는 장신구만 지원합니다."
L["Totem Intro"] = "|n선택한 토템슬롯의 지속시간을 표시합니다."
L["IntID*"] = "스킬*"
L["IntID Intro"] = "|n쿨타임의 확인을 위한 스킬ID를 입력, 숫자로만 입력.|n|n스킬에 마우스를 올려 ID를 확인하세요.|n|n텍스트로 스킬명을 입력 시 인식하지 않습니다."
L["Duration*"] = "지속시간*"
L["Duration Intro"] = "|n활성화된 쿨타임의 지속시간."
L["ItemID"] = "아이템ID"
L["ItemID Intro"] = "|n쿨타임이 발생한 아이템의 ID.|n|n빈칸으로 남길 시 쿨타임이 발생한 스킬ID를 사용합니다."
L["EditBox Tip"] = "|n입력 후 Enter를 눌러주세요."
L["RaidFrame Debuffs"] = "공대프레임의 Debuff표시추가"
L["Priority"] = "우선순위"
L["Priority Intro"] = "|n스킬아이콘의 표시순위.|n|n동시에 다수의 Debuff가 걸릴 시 우선순위에 따라 1개를 표시합니다.|n|n최고순위는 6이고 밝은색으로 해당 아이콘을 표시합니다.|n|n빈칸으로 남길 시 우선순위은 2로 됩니다."
L["Existing ClickSet"] = "해당 단축키는 이미 사용중인 스킬이 있습니다."
L["Invalid Input"] = "입력한 단축키가 유요하지 않습니다."
L["Action*"] = "액션*"
L["Action Intro"] = "|n레이드 프레임을 위한 단축키 설정.|n|n- target': 타겟 설정|n|n- 'focus': 주시대상 설정|n|n- 'follow': 따라가기|n|n- numbers: 스킬ID|n|n- macro: 매크로 입력도 가능|n매크로가 여러항일때는 ~ 부호가 다음항을 의미합니다."
L["Key*"] = "단축키*"
L["Key Intro"] = "|n스킬에 특정 단축키를 설정합니다.|n|n충돌발생 방지를 위하여 좌클릭,우클릭,쿨림버튼클릭등의 사용은 지양하기 바랍니다."
L["Modified Key"] = "기능키"
L["ModKey Intro"] = "|n특정 스킬을 조합단축키로 설정합니다."
L["Enable ClickSets"] = "공대프레임 클릭시전 사용"
L["Add ClickSets"] = "클릭시전 설정"
L["Reset your click sets?"] = "기존 클릭시전설정을 초기화하시겠습니까?"
L["Version Check"] = "NDui버전체크"
L["Outdated NDui"] = "  고객님의 |cff0080ffNDui|rClassic은 업데이트가 필요합니다.최신버전은: |cff70C0F5%s|r"
L["Minimap"] = "미니맵"
L["Equipement Set"] = "장비세팅 방안"
L["NFG"] = "No guild fund"
L["AutoSell Junk"] = "잡템 자동판매"
L["Selljunk Calculate"] = "잡템판매 대금: "
L["D"] = "내구도"
L["Low Durability"] = "내구도가 부족합니다!"
L["Hands"] = "장갑"
L["Feet"] = "신발"
L["Player Panel"] = "캐릭터창"
L["Auto Repair"] = "자동수리"
L["Guild repair"] = "길드대금으로 수리하였습니다."
L["Repair cost"] = "수리비용"
L["Repair error"] = "수리비용이 부족하다니..이럴수가!"
L["Earned"] = "수입"
L["Spent"] = "지출"
L["Deficit"] = "손실"
L["Profit"] = "이윤"
L["Session"] = "이번 접속:"
L["RealmCharacter"] = "캐릭터:"
L["Hidden"] = "숨김"
L["Hold Shift"] = "<Shift+클릭>으로 펼침"
L["Collect Memory"] = "메모리 회수"
L["My Position"] = "나의위치"
L["System"] = "시스템"
L["FPS"] = "FPS"
L["Latency"] = "지연"
L["Home Latency"] = "로컬 지연:"
L["World Latency"] = "월드 지연:"
L["CPU Usage"] = "CPU점유율 표시"
L["Are you sure to reset the gold count?"] = "누적된 골드의 통계를 초기화 하시겠습니까?"
L["WoW"] = "WoW"
L["BN"] = "배틀넷 친구"
L["SpecPanel"] = "특성창"
L["Change Spec"] = "특성 교체"
L["Reset Gold"] = "골드정보 리셋"
L["Toggle Calendar"] = "달력"
L["Toggle Clock"] = "월드시간"
L["WorldMap"] = "월드맵"
L["Send My Pos"] = "좌표 공유"
L["No Online"] = "접속중인 친구가 없음"
L["Local Time"] = "로컬시간:"
L["Realm Time"] = "서버시간:"
L["AW Switcher"] = "예약그룹설정 잠금(AW Switcher)"
L["Trigger"] = "트리거"
L["Trigger Intro"] = "|nAdd trigger on cooldown timer.|n|nOnAuraGain: Trigger timer once you gain this aura.|n|nOnCastSuccess: Trigger timer once you cast this spell successfully, the spell must be recorded in combat log.|n|nUnitCastSucceed: Trigger timer once you cast this spell successfully，the spell must be recorded in event UNIT_SPELLCAST_SUCCEEDED."
L["Trigger Unit Intro"] = "|n타겟유닛의 감시 트리거 설정.|n|nPlayer: 타겟자신의 스킬의 시전을 감시；|n|nAll: 모든 공대/파티원의 스킬 감시."
L["Mouse"] = "마우스"
L["PlayerPlate"] = "개인 자원바"
L["Enable PlayerPlate"] = "나의 HP/MP 별도표시"
L["Tooltip Scale"] = "툴팁창 사이즈"
L["Differ WhisperColor"] = "귓말대상과 다른컬러사용"
L["Map Reveal"] = "월드맵 미오픈지역 보이기"
L["Enable ClassAuras"] = "개인자원바에 직업감시 추가"
L["PlayerPlate CPHeight"] = "연계포인트바 높이"
L["PlayerPlate HPHeight"] = "체력바 높이"
L["PlayerPlate MPHeight"] = "에너지바 높이"
L["AuraWatch IconScale"] = "감시스킬 아이콘 사이즈"
L["PlayerPlate PowerText"] = "에너지바 수치표시"
L["OnlyCompleteRing"] = "완료 시 음성알림"
L["OnlyCompleteRingTip"] = "|n체크 시, 임무 완료 시에만 알림음 재생."
L["Stranger"] = "낯선이"
L["WheelUp"] = "휠을 위로굴림"
L["WheelDown"] = "휠을 아래로굴림"
L["DPS Revert Threat"] = "탱커가 아닐 시 몹 체력컬리를 반대로 표시"
L["Secure Color"] = "어그로 확고 시 "
L["Trans Color"] = "어그로 불안 시"
L["Insecure Color"] = "어그로 상실 시"
L["WhiteList"] = "네임플레이트 스킬 화이트리스트"
L["BlackList"] = "네임플레이트 스킬 블랙리스트"
L["Details Skin"] = "Details스킨 사용"
L["Reset to default list"] = "기본리스트를 로딩하시겠습니까?"
L["Flash"] = "밝음"
L["Flash Intro"] = "|n스킬이 활성화 시 아니콘이 밝음으로 표시."
L["Instance Type"] = "|n추가하려는 ID가 속한 던전유형을 선택.|n|n오리지널 버전과 던전외 데이타는 공대-기타 사항에 있음."
L["Dungeons Intro"] = "|n추가하려는 ID가 속한 던전을 선택하세요."
L["Raid Intro"] = "|n추가하려는 ID가 속한 레이드던전을 선택하세요."
L["Castbar LagString"] = "시전지연 수치표시"
L["Crit"] = "크리"
L["Haste"] = "가속"
L["Mastery"] = "숙련"
L["Versa"] = "능력"
L["Option* Tips"] = "|n별표*가 있는 항복은 즉시유효임으로 재로딩을 안하셔도 됩니다.|n|n더블클릭으로 제복과 컬르를 선택 시 원래의 기본설정으로 돌아갈 수 있습니다.|n|n일부 항복의 우측톱니바퀴를 클릭 시 상세한 설정을 할 수 있습니다.|n|n채팅창에 /ndui를 입력하여 명령어를 확인할 수 있습니다."
L["Place item"] = "멋진 %s 님께서 %s으로 밥상을 푸짐하게 차렸습니다."
L["Placed Item Alert"] = "파티에 밥상 설치 알림"
L["MRT Potioncheck"] = "ExRT약물의 사용을 알림"
L["Prio Editbox"] = "|n우선순위는 1-6.|n|n입력 후 Enter를 누르십시오."
L["Player Count"] = "%s명 유저"
L["UFs RuneTimer"] = "죽기 룬 타이머 표시"
L["RaidBuffIndicator"] = "레이드프레임 버프표시 사용"
L["RaidBuffIndicatorTip"] = "|n공대프로임위에 감시하려는 스킬을 추가하여 Buff/Debuff를 표시."
L["BuffIndicatorType"] = "버프 알림모드"
L["BuffIndicatorScale"] = "버프 사이즈"
L["BI_Blocks"] = "컬러로 표시"
L["BI_Icons"] = "아이콘으로 표시"
L["BI_Numbers"] = "숫자로 표시"
L["TOPLEFT"] = "좌측상단"
L["TOP"] = "상단"
L["TOPRIGHT"] = "우측상단"
L["LEFT"] = "좌측"
L["RIGHT"] = "우측"
L["BOTTOMLEFT"] = "좌측하단"
L["BOTTOM"] = "하단"
L["BOTTOMRIGHT"] = "우측하단"
L["RaidBuffWatch"] = "중요스킬 감시"
L["BuffIndicator"] = "레이드프레임 Buff설정"
L["HideJunkGuild"] = "길드명 줄임표시"
L["Freeze"] = "움직이지마세요"
L["Move"] = "이동"
L["Texture Style"] = "스킨 선택"
L["Highlight"] = "밝기"
L["Gradient"] = "차츰"
L["Flat"] = "편평"
L["Combo"] = "연계"
L["AttackSpeed"] = "공속"
L["CD"] = "쿨타임"
L["Strike"] = "기습"
L["Power"] = "에너지"
L["PartyFrame"] = "파티 프레임"
L["PartyFrameTip"] = "|n단독 파티프레임 사용. 해제 시, 설정에 따라 레이드프레임 또는 간소화 프레임을 사용."
L["HideCooldownOnWA"] = "WA아이콘의 쿨타임 사용금지"
L["PlayerPlate Fadeout"] = "전투이탈 후 희미하게"
L["PlayerPlate FadeoutAlpha"] = "투명도"
L["AutoBubbles"] = "레이드던전 밖에서 채팅버블 닫기"
L["HealthColor"] = "생명력 컬러"
L["Default Dark"] = "검정색"
L["ClassColorHP"] = "직업컬러"
L["GradientHP"] = "차츰 변하는"
L["DeleteMode Enabled"] = "|n버튼(CTRL+ALT키)누른 상태로 바로 가방내의 레어품질 미만 아이템을 파괴."
L["ItemDeleteMode"] = "파괴모드"
L["Trait"] = "특성"
L["Data Info"] = "정보"
L["Version"] = "버전"
L["Character"] = "캐릭터"
L["Import"] = "가져오기"
L["Import Header"] = "NDui설정 가져오기"
L["Import data error"] = "데이타 이상으로 불러오기 실패하였습니다!"
L["Import data warning"] = "가져오기를 진행하시겠습니까?"
L["Export"] = "내보내기"
L["Export Header"] = "NDui설정 내보내기"
L["Data Exception"] = "데이타가 이상합니다."
L["QuestTracker"] = "퀘스트 추적창"
L["VehicleSeat"] = "탈것 설정"
L["Join or Invite"] = "초대or 가입"
L["AlertFrames"] = "업적/룻 알림창"
L["UIWidgetFrame"] = "미니맵 하단에 특수창 표시|n|n예: PVP점령"
L["TargetClassPower"] = "네임플레이트에 에너지바 사용"
L["OffTank Color"] = "부탱 어그로"
L["ShowChatItemLevel"] = "채팅창에 템렙표시"
L["NameTextSize"] = "이름 폰트 사이즈"
L["HealthTextSize"] = "체력치 폰트 사이즈"
L["Nameplate MinScale"] = "비타겟 네임플레이트 사이즈"
L["Nameplate MinAlpha"] = "비타겟 네임플레이트 투명도"
L["TargetIndicator"] = "타겟 인디케이터"
L["TopArrow"] = "상단 화살표"
L["RightArrow"] = "우측 화살표"
L["TargetGlow"] = "변두리 밝음"
L["TopNGlow"] = "상단화살표+밝음"
L["RightNGlow"] = "우측화살표+밞음"
L["QuestIndicator"] = "퀘스트 현황 알림"
L["MinimapCalendar"] = "미니맵 달력 표시"
L["MinimapCalendarTip"] = "|n미니맵에 달력버튼 표시.|n해당 기능을 사용하지 않더라도 미니맵위로 마우스 휠클릭으로 달력을 불러옵니다."
L["Show ItemLevel"] = "아이템레벨 표시"
L["Show ItemQuality"] = "캐릭창 장비품질 정보"
L["MapFader"] = "이동시 맵 투명화"
L["EnhancedQuestLog"] = "퀘스트 추적과 강화"
L["EnhancedQuestLogTips"] = "|n기본 퀘스트리스트를 확장함과 동시에 퀘스트 추적 스킨미화.|n|n기타 ClassicQuestLog등 애드온설치할 필요가 없습니다."
L["Show GemNEnchant"] = "보석정보 표시"
L["ShowChatbar"] = "채팅바 버튼표시"
L["Chatbar"] = "채팅바 버튼"
L["UnitFrame Size"] = "유닛프레임 사이즈"
L["Power Height"] = "에너지바 높이"
L["Health Offset"] = "체력바 Y-Offset"
L["Power Offset"] = "에너지바 Y-Offset"
L["Player&Target"] = "나와 타겟의 프레임"
L["Pet&*Target"] = "팻과 팻타겟 프레임"
L["LockChatWidth"] = "너비 고정"
L["LockChatHeight"] = "높이 고정"
L["QuestIndicatorAddOns"] = "|n지원 애드온:|n- ClassicCodex|n- Questie"
L["AuraWatch WatchSpellRank"] = "여러 레벨스킬 감시"
L["WatchSpellRankTip"] = "|n선택 시, 여러 레벨의 동일한 스킬을 모두 감시합니다."
L["FavouriteMode"] = "나의 설정"
L["FavouriteMode Enabled"] = "|n나의 즐겨찾기 아이템을 표기.|n아이템 분류별 저장을 사용하면 기타 즐겨찾기설정도 추가해 놓을 수 있습니다.|n해당 기능은 잡템에는 효과가 없습니다."
L["DisableInfobars"] = "Info Bar 사용중지"
L["FreeSlots"] = "배낭 빈칸"
L["Bags GatherEmpty"] = "배낭 빈칸 합병"
L["AutoDismount"] = "와이번 타기 전 탈것해제"
L["AutoDismountTip"] = "|n와이번 목표지점 선택 후 자동으로 탈것해제"
L["StupidShiftKey"] = "Shift키가 눌려져 있습니다."
L["ChatFilterWhiteList"] = "화이트리스트 모드"
L["ChatFilterWhiteListTip"] = "|n리스트에 포함된 채팅내용만 표시, 빈칸으로 남기면 닫음으로 됩니다. 여러 단어는 빈칸으로 띄어쓰기 하기 바랍니다."
L["FilterListTip"] = "|n리스트에 부합되는 채팅내용이 일정한 수량에 달성 시 필터링을 하게 됩니다."
L["HideAllID"] = "모든 마법과 아이템정보를 닫기"
L["Recount Skin"] = "Recount스킨 사용"
L["Reset Details check"] = "Details의 스킨을 초기화 하시겠습니까?"
L["SpecialBagsColor"] = "특수배낭에 배경색 추가"
L["SpecialBagsColorTip"] = "|n냥꾼의 화살통, 흑마의 영석가방, 마부/약초가방등등."
L["TradeTabs"] = "전문스킬 단축탭"
L["TradeTabsTips"] = "|n전문기술창 옆에 탭을 추가.|n|n클래식에서 마부는 제외됩니다."
L["Castbar Settings"] = "캐스팅바 설정"
L["Castbar Colors"] = "캐스팅바 컬러"
L["PlayerCastingColor"] = "Player casting color" -- need translation
L["Interruptible Color"] = "차단가능한 컬러"
L["NotInterruptible Color"] = "차단불가 컬러"
L["Castbar Height"] = "캐스팅바 높이"
L["TrackMenu"] = "추적메뉴"
L["SwingTimer Tip"] = "|n자동공격 사이클에 지속시간 표시."
L["AuraWatch"] = "스킬감시"
L["AuraWatchToggleError"] = "스킬감시창의 닫기를 다른방식으로 해야 합니다."
L["Reset anchor"] = "기본으로 리셋"
L["Hide panel"] = "닫기"
L["HideUFWarning"] = "|n닫은 후 캐스팅바와 간편전투정보도 닫게 됩니다."
L["UFTextScale"] = "텍스트 사이즈"
L["Bags ShowNewItem"] = "신규 아이템 밝음처리"
L["InstantDelete"] = "템 파괴 시 DELETE 자동입력"
L["PartyPetFrame"] = "파티원 팻프레임"
L["PartyPetTip"] = "|n파티프레임을 사용해야만 유효한 기능입니다."
L["ToggleDirection"] = "온오프 방향"
L["ContactList"] = "연락 리스트"
L["QuickSplit"] = "분할"
L["SplitCount"] = "분할단위"
L["SplitMode Enabled"] = "|n가방내의 중첩된 템을 간편하게 분할하기.|n클릭하면 자동으로 입력한 숫자만큼 분할."
L["iLvlToShow"] = "템레벨 역치"
L["iLvlToShowTip"] = "|n설정한 레벨보다 높을 시 템렙표시."
L["RaidDebuffScale"] = "레이드 Debuff 아이콘 사이즈"
L["FlatMode"] = "편평한 재질"
L["Shadow"] = "쉐도우 표현"
L["BgTex"] = "배경 텍스쳐라인 표현"
L["SkinAlpha"] = "배경 투명도"
L["FontOutline"] = "폰트 테두리"
L["DefaultBags"] = "기본배낭"
L["DefaultBagsTips"] = "|n동시에 애드온내의 가방통합 기능을 사용금지 해야합니다."
L["Loot"] = "루팅창"
L["BlizzardSkins"] = "블리자드 스킨"
L["BlizzardSkinsTips"] = "|n해당 기능 닫을 시, 메인 UI는 블리자드 기본풍으로 변합니다.|n|n동시에 Rematch등 애드온의 스킨도 사용할 수 없게 됩니다."
L["BlockStranger"] = "낯선이의 귓말을 차단"
L["BlockStrangerTip"] = "|n사용 시 오직 파티원,친구,길드원의 귓말만 받습니다."
L["BlockInvite"] = "낯선이의 초대를 차단"
L["BlockInviteTip"] = "|n체크 시, 친구와 길드원으로부터 오는 초대만 받습니다."
L["BagFilterSetup"] = "배낭필터링 세팅"
L["FilterJunk"] = "잡템 필터링"
L["FilterAmmo"] = "탄약과 영석 필터링"
L["FilterEquipment"] = "장비 필터링"
L["FilterEquipSet"] = "Filter equipment sets"
L["FilterConsumable"] = "소모품 필터링"
L["FilterLegendary"] = "전설급템 필터링"
L["FilterCollection"] = "Filter collections"
L["FilterFavourite"] = "나의 필터링"
L["FilterGoods"] = "재료등 잡템 필터링"
L["FilterQuest"] = "퀘템 필터링"
L["EnhancedTradeSkills"] = "전문스킬과 마부창 확장"
L["SmoothAmount"] = "부드러운 프레임 변화"
L["SmoothAmountTip"] = "|n유닛프레임과 네임플레이트의 체력등의 프레임 변화를 조절합니다.|n프레임이 높을 수록 부드러움이 감소합니다."
L["ShowAllTip"] = "|n선택하지 않음이 기본설정입니다. 오직 유저가 시전한 Buff만 표시합니다.|n|n선택 시 타인이 시전한 Buff도 모두 표시합니다."
L["TototUF"] = "타겟의 타겟의 타겟"
L["TimestampFormat"] = "채팅창 시간표시"
L["GlobalFontScale"] = "폰트 사이즈"
L["CustomJunkMode"] = "정크 분류"
L["JunkMode Enabled"] = "|n판매가능한 아이템을 클릭하여 잡템으로 분류.|n자동판매를 선택 시 해당 아이템들도 함께 판매되게 됩니다.|n해당 기능은 계정내 모든 캐릭터 공용설정입니다. 또한 내보내기할때 해당 설정은 포함되지 않습니다.|n버튼 CTRL+ALT를 누른뒤 버튼을 클릭 시 해당 리스트를 리셋시킵니다."
L["Home Protocol"] = "로컬통신:"
L["World Protocol"] = "월드통신:"
L["Bandwidth"] = "트래픽:"
L["Download"] = "다운로드:"
L["SwitchSystemInfo"] = "표시 변경"
L["ClickThroughTip"] = "|n사용 시 스킬 아이콘으로 상호작용할 수 없고 마우스로도 선택할 수 없게 됩니다."
L["UnitsPerColumn"] = "열 표시수량"
L["SimpleMode GroupBy"] = "심플모드 나열"
L["FrequentHealth"] = "프레임 갱신 고정주기"
L["FrequentHealthTip"] = "|n사용 시 프레임의 체력변화는 고정된 시간주기로 갱신되고 시스템의 갱신주기에 따라하기 않습니다."
L["HealthFrequency"] = "갱신 시간간격"
L["HealthFrequencyTip"] = "|n고정 시간간격을 사용 시 설정한 시간간격보이 짧을 수록 갱신이 빠릅니다."
L["QuickKeybindMode"] = "단축키 설정모드"
L["QuickKeybindDescription"] = "단축키 간편설정 모드입니다. 마우스를 특정 스킬슬롯으로 이동한뒤 사용하려는 단축키를 누르십시오."
L["KeyIndex"] = "번호"
L["KeyBinding"] = "단축키"
L["KeyBoundTo"] = "단축키 설정"
L["Save keybinds"] = "단축키 저장 완료."
L["Discard keybinds"] = "단축키 설정 취소."
L["Clear binds"] = "%s |cff00ff00 설정한 모든 단축키를 삭제했습니다."
L["PressToBind"] = "원하는 키를 눌러 설정을 완성하십시오."
L["UnbindTip"] = "ESC또는 우클릭으로 설정을 취소할 수 있습니다."
L["NameplateAuraFilter"] = "네임플레이트 스킬필터링"
L["BlackNWhite"] = "블랙리스트만 표시"
L["PlayerOnly"] = "리스트+유저"
L["IncludeCrowdControl"] = "리스트+유저+매즈스킬"
L["NameOnlyMode"] = "아군 네임플레이트 모드"
L["NameOnlyModeTip"] = "|n사용 시 아군 네임플레이트에 더이상 체력등 정보가 없어지고 이름만 표시됩니다.|n동시에 스킬필터링은 단지 화이트 리스트내의 것만 표시됩니다."
L["IconsPerRow"] = "항 표시수량"
L["ButtonSize"] = "사이즈"
L["MaxButtons"] = "최대 표시 슬롯"
L["ButtonsPerRow"] = "항 슬롯수량"
L["ButtonFontSize"] = "슬롯 사이즈"
L["ChatBGType"] = "채팅창 배경양식"
L["ShowSolo"] = "싱글 시 표시"
L["ShowSoloTip"] = "|n선택 시 파티중이 아니여도 파티또는 공대프레임이 표시됩니다."
L["BagSortMode"] = "가방정리"
L["BagSortDisabled"] = "가방정리 기능이 해제되였습니다."
L["Forward"] = "정방향"
L["Backward"] = "역방향"
L["ExecuteRatio"] = "마격알림"
L["ExecuteRatioTip"] = "|n네임플레이트의 체력이 해당 역치보다 낮을 시, 폰트가 붉은색으로 변하게됩니다.|n역치가 0일때 해당 기능은 닫히게 됩니다."
L["FCTFontSize"] = "전투정보 폰트"
L["DisableMap"] = "월드맵 강화 종료"
L["DisableMapTip"] = "|n닫을 시 월드맵의 좌표,줌인,이동,가림등 효과가 사용금지됩니다.|n그리고 Mapster또는 시, 해당 기능은 자동으로 닫히게 됩니다."
L["Reset junklist warning"] = "잡템 리스트를 리셋하시겠습니까?"
L["AddContactTip"] = "|n추가하고 싶은 유저의 이름을 유저이름-서버명 방식으로 입력합니다.|n서버를 입력하지 않으면 기본으로 현재 서버로 설정됩니다.|n이름의 컬러와 분류를 자체적으로 설정할 수 있습니다."
L["FoundIncompatibleAddon"] = "충돌되는 애드온이 검색되지 않음:"
L["DisableIncompatibleAddon"] = "사용금지 할 애드온"
L["TakeAll"] = "일괄 받기"
L["TotalGold"] = "총 골드"
L["MailIsCOD"] = "대금청구 메일은 자동으로 받을 수 없습니다."
L["MapRevealGlow"] = "미탐사구역 or 쉐도우"
L["MapRevealGlowTip"] = "|n선택 후 맵의 가림을 취소하면 미탐사지역은 그림자층이 생기게 됩니다."
L["Reset current profile?"] = "현재 세팅을 초기화 하시겠습니까?"
L["Apply selected profile?"] = "입력한 세팅을 로딩하시겠습니까?"
L["Download selected profile?"] = "모든 설정을 선택한 세팅으로 교체하시겠습니까?"
L["Upload current profile?"] = "현재의 프로필로 모든 세팅을 덮어씌우시겠습니까?"
L["DefaultCharacterProfile"] = "캐릭터 프로필"
L["DefaultSharedProfile"] = "프로필 공유"
L["ProfileName"] = "프로필 명칭"
L["ProfileNameTip"] = "|n나의 프로필 명칭 설정. 입력창이 비었을 시 자동으로 기본으롬으로 넣게 됩니다.|n|n입력 후 Enter를 눌러야 합니다."
L["ResetProfile"] = "현재 프로필 초기화"
L["ResetProfileTip"] = "|n현재 프로필을 초기화하여 기본 세팅을 로딩합니다. 애드온 재로딩이 필요합니다."
L["SelectProfile"] = "프로필 선택"
L["SelectProfileTip"] = "|n선택한 세팅으로 교체, 애드온 재로딩 후 적용됩니다."
L["DownloadProfile"] = "현재 세팅 교체"
L["DownloadProfileTip"] = "|n선택한 프로필을 읽어와서 현재의 세팅을 덮어씁니다. 애드온 재로딩 후 적용 됩니다."
L["UploadProfile"] = "선택한 세팅으로 덮어쓰기"
L["UploadProfileTip"] = "|n선택한 프로필을 지정한 세팅에 덮어씌우기."
L["Profile"] = "프로필 관리"
L["Profile Management"] = "가져오기/내보내기"
L["Profile Description"] = "여기서 애드온 세팅을 관리할 수 있습니다. 사용하기전에 백업을 하기 바랍니다. 기본으로 캐릭터별로 저장되며 같은 계정내 다른 캐릭터에 적용되지 않습니다. 공용세팅으로 설정해야 다수의 캐릭터가 한가지 세팅을 공유할 수 있습니다.|n내보내기와 가져오기는 동일한 버전에서만 지원합니다."
L["SharedCharacters"] = "같은 세팅 캐릭터"
L["DeleteUnitProfile"] = "삭제할 캐릭터프로필"
L["DeleteUnitProfileTip"] = "|n캐릭명을 입력하여 해당 캐릭터의 모든 정보를 삭제합니다. 양식은 이름-서버명 입니다.서버명을 입력하지 않을 시 현재서버로 인식합니다.|n|n삭제 시 골드 현황 기록도 삭제됩니다.|n|n버튼ESC키로 입력창 비울 수 있고 Enter를 눌러야 합니다."
L["Delete unit profile?"] = "해당 캐릭터 %s%s|r 의 세팅을 삭제하시겠습니까？"
L["Incorrect unit name"] = "입력한 캐릭터가 존재하지 않습니다."
L["CooldownRemaining"] = "%s 쿨타임 잔여 %s"
L["CooldownCompleted"] = "%s 쿨타임 완료"
L["SendActionCD"] = "쿨타임 상태를 발송"
L["SendActionCDTip"] = "|n임의의 액션바에 마우스커서를 올려놓고 휠을 굴려서 쿨타임 상태를 발송할 수 있습니다.|n|n오직 NDui의 액션바에만 작용합니다."
L["Contact"] = "연락방식"
L["UnlockUI"] = "UI이동"
L["GotIt"] = "알겠습니다"
L["ChatScrollHelp"] = "마우스휠 쿨림 시 Ctrl버튼을 누르면 여러항을 굴릴 수 있고 Shift를 누를 시 맨위/맨아래로 이동합니다."
L["MinimapHelp"] = "Scroll minimap to zoom in or out, middle click to toggle calendar."
L["Reset Help"] = "Reset Help"
L["Reset NDui Helpinfo"] = "모든 Hep정보를 초기화 하시겠습니까?"
L["ColoredTarget"] = "타겟 네임플레이트 컬러"
L["ColoredTargetTip"] = "|n사용 시, 현재 타겟의 네임플레이트 컬러를 설정합니다. 우선순위는 나의설정 및 어그로컬러보다 높습니다.|n아래창에서 컬러를 선택할 수 있습니다."
L["TargetNP Color"] = "타겟 네임플레이트 컬러"
L["InstanceAurasTip"] = "|n던전 관련 자체설정 스킬감시를 표시합니다."
L["CustomTex"] = "커스텀 재질출처"
L["CustomTexTip"] = "|n사용하려는 재료를 Interface폴더아래에 넣고 임의로 이름을 설정하여 재질을 교체하십시오.|n교체 후 초록색으로 표시된다면 설정에 오류가 있음을 의미하거나 클라이언트 재실행이 필요합니다.|n입력창이 비엇을 시 해당 기능이 닫히게 되고 재로딩이 필요합니다."
L["PlateCastbarGlow"] = "중요한 캐스팅을 밝게"
L["PlateCastbarGlowTip"] = "|n타겟이 특정 스킬을 캐스팅 시 밞음으로 표시됩니다.|n톱니바퀴를 클릭하여 해당 리스트를 설정가능합니다.|n|n감시 스킬의 기타 레벨은 고려하지 않습니다."
L["PlateCastTarget"] = "타겟을 표시"
L["PlateCastTargetTip"] = "|n사용 시, 네임플레이트에 캐스팅 타겟을 표시합니다."
L["ColoredFocus"] = "주시대상 네임플레이트 컬러"
L["ColoredFocusTip"] = "|n사용 시, 포서크 타겟 네임플레이트 컬러 설정. 우선순위는 자체정의 또는 어그로컬러보다 높습니다.|n아래 리스트에서 컬러를 설정합니다."
L["FocusNP Color"] = "주시대상 네임플레이트 컬러"
L["Switch Mode"] = "모드 교체"
L["DispellableOnly"] = "해제가능한 Debuff만 표시"
L["DispellableOnlyTip"] = "|n해제 가능한 Debuff만 표시. 내가 해제 가능한 Debuff의 아이콘 테루리는 특별한 컬러가 표시됩니다.|n닫을 시 상시 마법, 저주, 질병, 중독등 효과가 표시됩니다."
L["GreyBackdrop"] = "회색 테두리"
L["GreyBackdropTip"] = "|n배경컬러를 모두 검은색으로 할 시 잘 보이지 않는다면 해당 기능을 켜는게 좋습니다."
L["ShowRaidBuff"] = "Buff알림"
L["ShowRaidBuffTip"] = "|n블리자드 레이드프레임의 로직으로 Buff효과를 표시합니다. 최대로 3개가 표시됩니다.|n|n테두리 알림과 같이 사용하는것을 추천드리지 않습니다."
L["ShowRaidDebuff"] = "Debuff알림"
L["ShowRaidDebuffTip"] = "|n블리자드 레이드프레임의 로직으로 Debuff를 표시합니다. 최대로 3개가 표시됩니다."
L["RaidBuffSize"] = "Buff아이콘 사이즈"
L["RaidDebuffSize"] = "Debuff아이콘 사이즈"
L["SmartRaid"] = "인원초과 시 레이드프레임표시"
L["SmartRaidTip"] = "|n유저가 5인이상 파티맺을 시에만 레이드 공대가 표시됩니다.|n미 사용 시, 공대에 있을대에만 표시되고 공대가 아닐 시 파티로 표시됩니다.|n|n파티창을 사용 할 시 유효합니다."
L["PlateRange"] = "네임플레이트 거리표시"
L["LanguageFilterTip"] = "설정창에서 채팅필터를 해제하고 Reload 후에야 정상적으로 배틀넷 사용 가능.(중국서버 전용)"
L["EquipColor"] = "장착한 템의 테두리컬러"
L["UIScaleTip"] = "|nUI사이즈가 0.64보다 낮을 시 일부 블리자드 애드온과 제3자 애드온에 문제가 생길 수 있습니다."
L["PetHappiness"] = "냥꾼 팻 상태 알림"
L["PetUnhappy"] = "%s 당신의 팻 [%s] 이 곧 도망가려고 합니다."
L["PetBadMood"] = "%s 당신의 팻 [%s] 이 좀 삐졌습니다."
L["PetHappy"] = "%s 당신의 팻 [%s] 이 상당히 즐겁다고 합니다."
L["MenuButton"] = "간편 우클릭 메뉴"
L["MenuButtonTip"] = "|n우클릭 메뉴 위에 친추, 길드초대, 이름복사 기능추가."
L["SaveMailTarget"] = "메일 수신자 저장"
L["AspectBar"] = "냥꾼 상 바"
L["AspectSize"] = "상 아이콘 사이즈"
L["VerticleAspect"] = "세로로 표시"
L["TradeSearchTip"] = "|n검색하려는 도안 명칭 입력, Esc로 초기화.|n"
L["InvalidName"] = "입력한 내용이 없습니다."
L["NoMatchReult"] = "적합한 선택사항이 없습니다."
L["BlockSpammer"] = "채팅난사자 차단"
L["BlockSpammerTip"] = "|n체크 시, 해당 유저는 차단됩니다."
L["ToggleCastbarTip"] = "|n캐스팅바 OnOff기능, Reload필요 없음."
L["ChatSwitchHelp"] = "Tab버튼으로 채널지간의 교체를 진행"
L["WhisperSound"] = "귓말 알림음"
L["WhisperSoundTip"] = "|n체크 시, 귓말대응 5초이상 하지 않았을때 알림음 재생."
L["BagSearchTip"] = "|n배낭속 아이템을 검색.|n아이템명칭 또는 부위로 검색 가능.|n'boe'를 입력하면 귀속템 검색, 'quest'를 입력하면 퀘템 검색."
L["ClampTargetPlate"] = "타겟 네임플레이트 고정잠금"
L["ClampTargetPlateTip"] = "|n체크 시, 타겟 네임플레이는 나의 스크린범위를 벗어나지 않습니다."
L["FriendPlate"] = "아군 네임플레이트 사이즈"
L["FriendPlateTip"] = "|n체크 시, 아군의 네임플레이를 별도로 세팅하여 적군과 구분할 수 있습니다.|n체크 해제 시, 적군과 아군은 동일한 설정을 사용합니다. |n|n반드시 아군이름모드를 해제해야 아군네임플레이트의 별도 사이즈를 사용할 수 있습니다."
L["NameplateSize"] = "네임플레이트 사이즈"
L["HostileNameplate"] = "적군 네임플레이트"
L["FriendlyNameplate"] = "아군 네임플레이트"
L["SysMaxAddOns"] = "애드온 수량"
L["SysMaxAddOnsTip"] = "|nInforBar에 마우스 올릴 시 최대 애드온 수량을 표시합니다."
L["InfobarFontSize"] = "Infobar 폰트 사이즈"
L["LeftInfobar"] = "좌측 Infobar"
L["RightInfobar"] = "우측 Infobar"
L["InfobarStrTip"] = "|n입력한 Text조합으로 InfoBar배열 설정.|n[friend] 친구정보|n[ping] 통신상태|n[fps] FPS|n[zone] 위치|n[spec] 전문기술|n[dura] 내구도|n[gold] 골드|n[time] 시간|n|n유저 자체적으로 순서를 설정가능하지만 1개 정보는 1번만 사용가능합니다.|n스펠링과 대소문자에 유의하세요."
L["BagsPerRow"] = "배낭 열당 수량"
L["BagsPerRowTip"] = "|n배낭 매열에 최대 허용하는 슬롯수량"
L["BankPerRow"] = "은행배낭 열당 수량"
L["BankPerRowTip"] = "|n은행배낭 매열 최대 허용하는 슬롯수량"
L["PlateAuras"] = "네임플레이트 스킬감지"
L["ActionbarSetup"] = "액션바 설정"
L["BaudErrorTip"] = "UI에러 발생, 우측하단의 빨간색 숫라를 클릭하고 개발자에게 피드백을 보내주세요."
L["ApplyBarStyle"] = "Ctrl키를 누른 상태에서 클릭하여 해당 액션바 설정을 로딩하세요."
L["CastbarTextSize"] = "캐스팅바 폰트 사이즈"
L["CastbarTextOffset"] = "캐스팅바 폰트 Y-Offset"
L["StyleStringError"] = "입력하신 액션바 세팅이 에러가 있습니다."
L["ExportActionbarStyle"] = "나의 액션바 세팅을 내보내기."
L["ImportActionbarStyle"] = "다른이의 액션바 세팅을 가져오기."
L["Friendly ClickThru"] = "아군 네임플레이트 ClickThru"
L["Enemy ClickThru"] = "적군 네임플레이트 ClickThru"
L["MicroMenuTip"] = "|n미니메뉴의 개발목적은 NDui와 액션바의 공생이였습니다. 단독으로 사용 시 일부 미지의 문제가 있을 수 있습니다."
L["TipAnchor"] = "툴팁창 위치"
L["TipAnchorTip"] = "|n툴팁창의 초기 위치, 설정한 위치의 반대방향으로 확장하게 됩니다."
L["HealthValueType"] = "체력수치 표시방식"
L["PowerValueType"] = "에너지바수치 표시방식"
L["ShowHealthDefault"] = "현재수치 | 퍼센트"
L["ShowHealthCurMax"] = "현재수치 | 최대치"
L["ShowHealthCurrent"] = "현재수치"
L["ShowHealthPercent"] = "퍼센트"
L["ShowHealthLoss"] = "감소한 체력"
L["ShowHealthLossPercent"] = "감소한 체력%"
L["DesaturateIcon"] = "타인의 Debuff표시수량을 감소"
L["DesaturateIconTip"] = "|n체크 시, 내가 보낸 Buff만 표시"
L["NameTextType"] = "이름 표시방식"
L["Tag:name"] = "이름표시"
L["Tag:rarename"] = "희귀 이름"
L["Tag:levelname"] = "레벨 이름"
L["Tag:rarelevelname"] = "희귀 레벨 이름"
L["PlateLevelTagTip"] = "|n나의 레벨과 같을때에는 표시하지 않습니다.|n|n아군 네임플레이트 이름은 영향을 받지 않습니다."
L["Width"] = "너비"
L["Height"] = "높이"
L["xOffset"] = "X Offset"
L["yOffset"] = "Y Offset"
L["ShowAuras"] = "유닛 오라 표시"
L["BuffType"] = "Buff표시"
L["DebuffType"] = "Debuff표시"
L["MaxBuffs"] = "Buffs최대수량"
L["MaxDebuffs"] = "Debuffs최대수량"
L["ShowAll"] = "모두표시"
L["ShowDispell"] = "해제가능한 스킬만 표시"
L["BlockOthers"] = "차단하기"
L["DebuffColor"] = "Debuff 아이콘 테두리 컬러"
L["DebuffColorTip"] = "|nDebuff유형에 따라 아이콘 테두리 컬러를 설정."
L["ClassColor Name"] = "이름을 직업컬러로 설정"
L["BuffFrame"] = "NDui Buff 프레임"
L["BuffFrameTip"] = "|n우측상단에 위치한 Buff, Debuff를 교체"
L["HideBlizUI"] = "블리자드UI 숨김"
L["HideBlizBuffTip"] = "|n블리자드 Buff창 숨김.|nNdui의 Buff창을 사용 시, 자동으로 블리자드의 기본Buff창을 사용금지 합니다."
L["ReverseGrow"] = "역방향으로 나열"
L["100PercentTip"] = "|n퍼센트로 표시를 사용 시, 100%로 설정하면 표시하지 않게 됩니다."
L["MaxColumns"] = "최대 열 수량"
L["Visibility"] = "가시성"
L["ShowInParty"] = "파티 시 표시"
L["ShowInRaid"] = "공대 시 표시"
L["ShowInGroup"] = "파티나 공대 시 표시"
L["HideTooltip"] = "마우스툴팁 사용금지"
L["HideTooltipTip"] = "|n체크 시, 더이상 툴팁창을 사용하지 않습니다."
L["GrowthDirection"] = "확장 방향"
L["RaidDirectionTip"] = "|n레이드 프레임의 확장 방향을 조절합니다.|n좌측방향은 파티원이 추가될때의 방향이고, 우측방향은 신규파티가 추가될 방향입니다."
L["DOWN_RIGHT"] = "Down and Right"
L["DOWN_LEFT"] = "Down and Left"
L["UP_RIGHT"] = "Up and Right"
L["UP_LEFT"] = "Up and Left"
L["RIGHT_DOWN"] = "Right and Down"
L["RIGHT_UP"] = "Right and Up"
L["LEFT_DOWN"] = "Left and Down"
L["LEFT_UP"] = "Left and Up"
L["GO_DOWN"] = "Go down"
L["GO_UP"] = "Go up"
L["GO_RIGHT"] = "Go right"
L["GO_LEFT"] = "Go left"
L["SMRDirectionTip"] = "|n간소화 레이드 프레임의 확장 방향설정입니다. Reload후 유효합니다."
L["RaidRows"] = "그룹당 파티수량"
L["BottomBox"] = "입력창이 아래로"
L["BlockDBM"] = "DBM스킬아이콘 끄기"
L["BlockDBMTip"] = "|n체크 시, DBM이 네임플레이트에 추가하는 스킬감지 아이콘을 끕니다. 해당 스킬은 자동으로 화이트리스트에 표기됩니다."
L["AutoHide"] = "자동 끄기"
L["OffhandOnTop"] = "보조무기 스윙바 타이머가 위로"
L["ShowNPCTitle"] = "NPC타이틀 표시"
L["ShowUnitGuild"] = "길드정보 표시"
L["TitleTextSize"] = "정보텍스트 사이즈"
L["CVarOnlyNames"] = "블리자드 네임플레이트 이름만 보류"
L["CVarOnlyNamesTip"] = "|n체크 시, 블리자드 자체 네임플레이는 이름만 남깁니다. Reload가 필요합니다."
L["CVarShowNPCs"] = "NPC네임플레이트 항상표시"
L["CVarShowNPCsTip"] = "|n체크 시, 항상 NPC네임플레이트가 표시됩니다. 체크 해제 시, NPC를 선택해야만 표시됩니다."
L["Dispellable"] = "해제가능 스킬표시"
L["DispellableTip"] = "|n필터: 해제 가능한 마법또는 격노효과를 밝게 표시|n|n항상: 항상 타겟의 모든 마법과 격노효과를 표시. 자신이 해제할 수 없는것도 표시. "
L["Filter"] = "필터"
L["Always"] = "항상"
L["ShowInterruptor"] = "캐스팅 차단자 표시"
L["MmssThreshold"] = "MMSS 설정값"
L["MmssThresholdTip"] = "|n쿨타임이 설정값 이하일때 초단위로 정확히 표시 |n예를들면 2분반을 2:30초로"
L["TenthThreshold"] = "최소 설정값"
L["TenthThresholdTip"] = "|n쿨타임이 설정값 이하일때 소숫점 아래까지 표시|n예를들면 3초를 3.0초로 표시"
L["TargetedByTip"] = "|n네임플레이옆에 타겟팅 중인 팀원 통계, 던전에서만 유효."
L["IgnoredButtons"] = "취합 무시 리스트"
L["IgnoredButtonsTip"] = "|n취합하기 싫은 버튼 이름을 입력. /fstack 입력 후 아이콘 클릭으로 죄회가능, 이름의 일부만 입력해도 가능.|n여러개의 이름일때 쉼표로 구분, Reloading후 적용. "
L["MaxZoom"] = "최대 Zoom"
L["BuffClickThru"] = "Buff정보 알림 금지"
L["DebuffClickThru"] = "Debuff 정보알림 금지"
L["SysFont"] = "시스템 폰트 사용"
L["SysFontTip"] = "|n체크시, 채팅창은 시스템폰트를 사용하게됨. 기타 UI와 차별 "
L["PlateClickThruTip"] = "|n체크시, 네임플레이트는 더이상 상호작용을 제공하지 않음. 마우스로 선택 불가 "
L["ScrollingCT"] = "스크롤 텍스트 모드"
L["EasyVolume"] = "쉬운 음량 설정"
L["EasyVolumeTip"] = "|n체크시, CTRL를 누른상태에서 미니맵에 마우스를 올려놓고 스크롤하여 음량을 조절 가능 |nCTRL+ALT와 마우스휠로 음량 0-100조절 가능"
L["ColorByDot"] = "특정 DOT컬러 - 네임플레이트"
L["ColorByDotTip"] = "|n체크 시, 타겟에 지정한 스킬효과가 발동 시 네임플레이트 컬러 변화"
L["ColorDotsList"] = "DOT컬러 리스트"
L["NPCID or Name"] = "|n NPC ID 또는 Name입력|n|nShift를 누른 상태에서 대상을 관찰하여 NPCID를 획득 가능."
L["ShowPowerUnits"] = "특정 유닛 마력치 표시"
L["PowerUnitsTip"] = "|n체크 시, 특정 유닛의 네임플레이트 아래에 현재 마력치를 표시"
L["Name Offset"] = "이름 Y-Offset"
L["LeftButon"] = "Left Mouse Button"
L["RightButton"] = "Right Mouse Button"
L["MiddleButton"] = "Middle Mouse Button"
L["Button4"] = "Mouse Button 4"
L["Button5"] = "Mouse Button 5"
L["AutoEquip"] = "장비 자동교체"
L["AutoEquipTip"] = "|n체크시, 특성 교환 시 같은 장비예상세팅이 있다면 자동으로 사용하게 됨. "
L["TotemBar"] = "토템바"
L["ClearHealth"] = "투명"
L["ClearClass"] = "차츰 변하는 직업컬러"
L["PetCastbar"] = "팻 캐스트바"
L["OffTankThreat"] = "부탱 어그로 사용"
L["OffTankThreatTip"] = "|n공대원의 열할에 따라 현재 어그로가 기타 탱커에게 있을 시 컬러를 지정 |n|n주의, 공대원들이 정확한 역할을 선택해야함."
L["HealPrediction"] = "Hot 예측힐량 표시"
L["DemonPage"] = "흑마: 악마형상 시 액션바 변화"
L["DispellTypeTip"] = "|n항상: 타겟에 걸려있는 저주, 마법, 질병과 독효과를 표시합니다.|n|n필터링: 나의 Debuff만 표시합니다. 내가 해제가능한 스킬의 아이콘테두리는 컬러로 표시됩니다."
L["AutoBuffsTip"] = "|nIf checked, use blizzard API logic to display buffs, no longer use the white list below, up to 3." -- need translation
L["AutoRepairInfo"] = "You can toggle 'Auto repair' and 'Auto sell junk' on infobar durability and gold module." -- need translation
L["AuraFontSize"] = "Auras FontSize" -- need translation
L["SizeRatio"] = "Icon Size Ratio" -- need translation
L["DisableMinimap"] = "Disable Enhanced Minimap" -- need translation
L["DisableMinimapTip"] = "|nIf checked, all the features below will be disabled as well.|nIf you have addon SexyMap enabled, the enhanced minimap would turn off automatically." -- need translation
L["ChargesRemaining"] = "%s %s/%s next charge remaining %s" -- need translation
L["ChargesCompleted"] = "%s %s/%s all charges ready." -- need translation
L["ToggleActionbarTip"] = "|nOption to toggle actionbar, no need to reload UI." -- need translation
L["BlizzMover"] = "Save CharacterFrame anchor" -- need translation
L["BlizzMoverTip"] = "|nIf enabled, save CharacterFrame anchor after you move it. Hold CTRL and left click to reset its default anchor.|n|nAlso support QuestLogFrame." -- need translation
L["TarName"] = "Show target name" -- need translation
L["AuraWatch MinCD"] = "Min Cooldown" -- need translation
L["MinCDTip"] = "|nThe Spell cooldown only visible when its cooldown greater then the second value." -- need translation
L["HideInCombat"] = "Hide in combat" -- need translation
L["HideInCombatTip"] = "|nSelect the way to hide GameTooltip in combat.|nGameTooltip only visible when you hold the modified key you selected." -- need translation
L["HideDPSRole"] = "Hide DPS roleicon" -- need translation
L["ShowRoleMode"] = "Show roleicons" -- need translation
L["EditFont"] = "Editbox fontsize" -- need translation
L["KeyDown"] = "Cast on keydown" -- need translation
L["ButtonLock"] = "Lock actionbars" -- need translation
L["KeyDownTip"] = OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN
L["ButtonLockTip"] = OPTION_TOOLTIP_LOCK_ACTIONBAR