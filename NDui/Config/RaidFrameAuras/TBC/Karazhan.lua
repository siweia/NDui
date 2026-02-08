local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

local TIER = 2
local INSTANCE = 532 -- 卡拉赞

-- 猎手阿图门
module:RegisterDebuff(TIER, INSTANCE, 0, 29833) -- 无形
module:RegisterDebuff(TIER, INSTANCE, 0, 29711) -- 击倒
-- 莫罗斯
module:RegisterDebuff(TIER, INSTANCE, 0, 29425) -- 凿击
module:RegisterDebuff(TIER, INSTANCE, 0, 34694) -- 致盲
module:RegisterDebuff(TIER, INSTANCE, 0, 37066) -- 锁喉
-- 歌剧院
module:RegisterDebuff(TIER, INSTANCE, 0, 30822) -- 浸毒之刺
module:RegisterDebuff(TIER, INSTANCE, 0, 30889) -- 强力吸附
module:RegisterDebuff(TIER, INSTANCE, 0, 30890) -- 盲目激情
-- 贞节圣女
module:RegisterDebuff(TIER, INSTANCE, 0, 29511) -- 悔改
module:RegisterDebuff(TIER, INSTANCE, 0, 29522) -- 神圣之火
module:RegisterDebuff(TIER, INSTANCE, 0, 29512) -- 神圣之地
-- 馆长
-- 特雷斯坦·邪蹄
module:RegisterDebuff(TIER, INSTANCE, 0, 30053) -- 火焰增效
module:RegisterDebuff(TIER, INSTANCE, 0, 30115) -- 牺牲
-- 埃兰之影
module:RegisterDebuff(TIER, INSTANCE, 0, 29946) -- 烈焰花环
module:RegisterDebuff(TIER, INSTANCE, 0, 29947) -- 烈焰花环
module:RegisterDebuff(TIER, INSTANCE, 0, 29990) -- 减速
module:RegisterDebuff(TIER, INSTANCE, 0, 29991) -- 冰链术
module:RegisterDebuff(TIER, INSTANCE, 0, 29954) -- 寒冰箭
module:RegisterDebuff(TIER, INSTANCE, 0, 29951) -- 暴风雪
-- 虚空幽龙
module:RegisterDebuff(TIER, INSTANCE, 0, 38637) -- 虚空疲倦
module:RegisterDebuff(TIER, INSTANCE, 0, 38638) -- 虚空疲倦
module:RegisterDebuff(TIER, INSTANCE, 0, 38639) -- 虚空疲倦
module:RegisterDebuff(TIER, INSTANCE, 0, 30400) -- 虚空光柱 - 坚韧
module:RegisterDebuff(TIER, INSTANCE, 0, 30401) -- 虚空光柱 - 平静
module:RegisterDebuff(TIER, INSTANCE, 0, 30402) -- 虚空光柱 - 统御
module:RegisterDebuff(TIER, INSTANCE, 0, 30421) -- 虚空之门 - 坚韧
module:RegisterDebuff(TIER, INSTANCE, 0, 30422) -- 虚空之门 - 平静
module:RegisterDebuff(TIER, INSTANCE, 0, 30423) -- 虚空之门 - 统御
-- 象棋
module:RegisterDebuff(TIER, INSTANCE, 0, 30529) -- 刚刚控制过棋子
-- 玛克扎尔王子
module:RegisterDebuff(TIER, INSTANCE, 0, 39095) -- 伤害增效
module:RegisterDebuff(TIER, INSTANCE, 0, 30898) -- 暗言术：痛
module:RegisterDebuff(TIER, INSTANCE, 0, 30854) -- 暗言术：痛
-- 夜之魇
module:RegisterDebuff(TIER, INSTANCE, 0, 37091) -- 白骨之雨
module:RegisterDebuff(TIER, INSTANCE, 0, 30210) -- 浓烟吐息
module:RegisterDebuff(TIER, INSTANCE, 0, 30129) -- 灼烧土地
module:RegisterDebuff(TIER, INSTANCE, 0, 30127) -- 灼热灰烬
module:RegisterDebuff(TIER, INSTANCE, 0, 36922) -- 低沉咆哮