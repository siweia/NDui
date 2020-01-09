local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_GMSurveyUI"] = function()
	B.SetBD(GMSurveyFrame, 0, 0, -32, 4)
	B.CreateBD(GMSurveyCommentFrame, .25)
	for i = 1, 11 do
		B.CreateBD(_G["GMSurveyQuestion"..i], .25)
		for j = 0, 5 do
			B.ReskinRadio(_G["GMSurveyQuestion"..i.."RadioButton"..j])
		end
	end

	for i = 1, 12 do
		select(i, GMSurveyFrame:GetRegions()):Hide()
	end
	GMSurveyHeaderLeft:Hide()
	GMSurveyHeaderRight:Hide()
	GMSurveyHeaderCenter:Hide()
	GMSurveyScrollFrameTop:SetAlpha(0)
	GMSurveyScrollFrameMiddle:SetAlpha(0)
	GMSurveyScrollFrameBottom:SetAlpha(0)
	B.Reskin(GMSurveySubmitButton)
	B.Reskin(GMSurveyCancelButton)
	B.ReskinClose(GMSurveyCloseButton, "TOPRIGHT", GMSurveyFrame, "TOPRIGHT", -36, -4)
	B.ReskinScroll(GMSurveyScrollFrameScrollBar)
end