local _, ns = ...
local B, C, L, DB = unpack(ns)
local A = B:GetModule("Auras")

if DB.MyClass ~= "EVOKER" then return end

local function GetUnitAura(unit, spell, filter)
	return A:GetUnitAura(unit, spell, filter)
end


local function UpdateCooldown(button, spellID, texture)
	return A:UpdateCooldown(button, spellID, texture)
end

local function UpdateBuff(button, spellID, auraID, cooldown, glow)
	return A:UpdateAura(button, "player", auraID, "HELPFUL", spellID, cooldown, glow)
end

local function UpdateDebuff(button, spellID, auraID, cooldown, glow)
	return A:UpdateAura(button, "target", auraID, "HARMFUL", spellID, cooldown, glow)
end

local function UpdateSpellStatus(button, spellID)
	button.Icon:SetTexture(GetSpellTexture(spellID))
	if IsUsableSpell(spellID) then
		button.Icon:SetDesaturated(false)
	else
		button.Icon:SetDesaturated(true)
	end
end

function A:ChantLumos(self)
	local spec = GetSpecialization()
	if spec == 1 then --湮灭
		UpdateCooldown(self.lumos[1], 370553, true)--扭转天平
				do
			local button = self.lumos[2]
				if IsUsableSpell(357208) then
					button.Icon:SetDesaturated(false)
				else
					UpdateCooldown(button, 357208, true)
					button.Icon:SetDesaturated(true)
				end
				button.Icon:SetTexture(GetSpellTexture(357208))
				local name = GetUnitAura("player", 370553, "HELPFUL") --扭转天平高亮
				if name then
					N.ShowOverlayGlow(button)
				else
					N.HideOverlayGlow(button)
				end    
		end

		do
			local button = self.lumos[3]
				if IsUsableSpell(356995) then
					button.Icon:SetDesaturated(false)
				else
					button.Icon:SetDesaturated(true)
					UpdateCooldown(button, 356995, true)
				end
				button.Icon:SetTexture(GetSpellTexture(356995))
				local name = GetUnitAura("player", 359618, "HELPFUL") --高亮精华迸发
				if name then
					N.ShowOverlayGlow(button)
				else
					N.HideOverlayGlow(button)
				end    
		end

		do
		local button = self.lumos[4]
		button.Icon:SetTexture(GetSpellTexture(357211))
		       if IsUsableSpell(357211) then
					button.Icon:SetDesaturated(false)
				else
					button.Icon:SetDesaturated(true)
			end
			local name = GetUnitAura("player", 359618, "HELPFUL") -- 高亮精华迸发
			if name then
				N.ShowOverlayGlow(button)
			else
				N.HideOverlayGlow(button)
			end
		end
		UpdateCooldown(self.lumos[5], 357210, true)--深呼吸
	
	elseif spec == 2 then --恩护
		UpdateCooldown(self.lumos[1], 355936, true)--梦境吐息
		do
			local button = self.lumos[2]--翡翠之花
				if IsUsableSpell(355913) then
					button.Icon:SetDesaturated(false)
				else
					button.Icon:SetDesaturated(true)
					UpdateCooldown(button, 355913, true)
				end
				button.Icon:SetTexture(GetSpellTexture(355913))
				local name = GetUnitAura("player", 369299, "HELPFUL") --高亮精华迸发
				if name then
					N.ShowOverlayGlow(button)
				else
					N.HideOverlayGlow(button)
				end    
		end
		do
			local button = self.lumos[3] --回响
				if IsUsableSpell(364343) then
					button.Icon:SetDesaturated(false)
				else
					button.Icon:SetDesaturated(true)
					UpdateCooldown(button, 364343, true)
				end
				button.Icon:SetTexture(GetSpellTexture(364343))
				local name = GetUnitAura("player", 369299, "HELPFUL") --高亮精华迸发
				if name then
					N.ShowOverlayGlow(button)
				else
					N.HideOverlayGlow(button)
				end    
		end
			UpdateCooldown(self.lumos[4], 366155, true)--逆转
			UpdateCooldown(self.lumos[5], 360995, true)--清脆之拥
  end
end