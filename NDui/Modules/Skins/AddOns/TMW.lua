local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

local function ReskinTMW()
	if not C.db["Skins"]["TMW"] then return end

	TMW.Classes.Icon:PostHookMethod("OnNewInstance", function(self)
		if not self.bg then
			self.bg = B.SetBD(self)
		end
	end)

	TMW.Classes.IconModule_Texture:PostHookMethod("OnNewInstance", function(self)
		self.texture:SetTexCoord(unpack(DB.TexCoord))
	end)
end

S:RegisterSkin("TellMeWhen", ReskinTMW)