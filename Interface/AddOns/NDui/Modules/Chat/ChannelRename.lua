local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

function module:ChannelRename()
	for i = 1, NUM_CHAT_WINDOWS do
		if i ~= 2 then
			local f = _G["ChatFrame"..i]
			local am = f.AddMessage
			f.AddMessage = function(frame, text, ...)
				if text:find(INTERFACE_ACTION_BLOCKED) and not DB.isDeveloper then return end
				text = text:gsub(CHAT_FLAG_AFK, DB.AFKTex)
				text = text:gsub(CHAT_FLAG_DND, DB.DNDTex)

				local r, g, b = ...
				if NDuiDB["Chat"]["WhisperColor"] and text:find(L["Tell"].." |H[BN]*player.+%]") then r, g, b = r*.7, g*.7, b*.7 end
				if NDuiDB["Chat"]["Oldname"] then
					text = text:gsub("|h%[(%d+)%. 大脚世界频道%]|h", "|h%[%1%. 世界%]|h")
					text = text:gsub("|h%[(%d+)%. 大腳世界頻道%]|h", "|h%[%1%. 世界%]|h")
					return am(frame, text, r, g, b)
				else
					return am(frame, text:gsub("|h%[(%d+)%..-%]|h", "|h[%1]|h"), r, g, b)
				end
			end
		end
	end

	--online/offline info
	ERR_FRIEND_ONLINE_SS = ERR_FRIEND_ONLINE_SS:gsub("%]%|h", "]|h|cff00c957")
	ERR_FRIEND_OFFLINE_S = ERR_FRIEND_OFFLINE_S:gsub("%%s", "%%s|cffff7f50")

	--whisper
	CHAT_WHISPER_INFORM_GET = L["Tell"].." %s "
	CHAT_WHISPER_GET = L["From"].." %s "
	CHAT_BN_WHISPER_INFORM_GET = L["Tell"].." %s "
	CHAT_BN_WHISPER_GET = L["From"].." %s "

	--say / yell
	CHAT_SAY_GET = "%s "
	CHAT_YELL_GET = "%s "

	if NDuiDB["Chat"]["Oldname"] then return end
	--guild
	CHAT_GUILD_GET = "|Hchannel:GUILD|h[G]|h %s "
	CHAT_OFFICER_GET = "|Hchannel:OFFICER|h[O]|h %s "

	--raid
	CHAT_RAID_GET = "|Hchannel:RAID|h[R]|h %s "
	CHAT_RAID_WARNING_GET = "[RW] %s "
	CHAT_RAID_LEADER_GET = "|Hchannel:RAID|h[RL]|h %s "

	--party
	CHAT_PARTY_GET = "|Hchannel:PARTY|h[P]|h %s "
	CHAT_PARTY_LEADER_GET =  "|Hchannel:PARTY|h[PL]|h %s "
	CHAT_PARTY_GUIDE_GET =  "|Hchannel:PARTY|h[PG]|h %s "

	--instance
	CHAT_INSTANCE_CHAT_GET = "|Hchannel:INSTANCE|h[I]|h %s "
	CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:INSTANCE|h[IL]|h %s "
end