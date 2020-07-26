local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_GMSurveyUI"] = function()
	B.SetBD(GMSurveyFrame, nil, 0, 0, -32, 4)
	B.StripTextures(GMSurveyCommentFrame)
	local bg = B.CreateBDFrame(GMSurveyCommentFrame, .25)
	bg:SetInside()

	for i = 1, 15 do
		local button = _G["GMSurveyQuestion"..i]
		if button then
			B.StripTextures(button)
			local bg  = B.CreateBDFrame(button, .25)
			bg:SetInside()
			for _, radio in next, button.radioButtons do
				B.ReskinRadio(radio)
				radio:SetSize(20, 20)
			end
		end
	end

	B.StripTextures(GMSurveyFrame)
	B.StripTextures(GMSurveyFrame.Header)
	GMSurveyScrollFrameTop:SetAlpha(0)
	GMSurveyScrollFrameMiddle:SetAlpha(0)
	GMSurveyScrollFrameBottom:SetAlpha(0)
	B.Reskin(GMSurveySubmitButton)
	B.Reskin(GMSurveyCancelButton)
	B.ReskinClose(GMSurveyCloseButton, "TOPRIGHT", GMSurveyFrame, "TOPRIGHT", -36, -4)
	B.ReskinScroll(GMSurveyScrollFrameScrollBar)
end

-- /run LoadAddOn'Blizzard_GMSurveyUI' GMSurveyFrame:Show()