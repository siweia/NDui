local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

local function ReskinTMW()
	TMW.Classes.Icon:PostHookMethod("OnNewInstance", function(self)
		if not self.bg then
			self.bg = B.SetBD(self)
		end
	end)

	TMW.Classes.IconModule_Texture:PostHookMethod("OnNewInstance", function(self)
		self.texture:SetTexCoord(unpack(DB.TexCoord))
	end)
end

S:LoadWithAddOn("TellMeWhen", "TMW", ReskinTMW)