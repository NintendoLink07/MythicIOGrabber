local addonName, miog = ...
local wticc = WrapTextInColorCode

miog.inviteFrames = {}

hooksecurefunc("LFGListInviteDialog_Show", function(blizzDialog, resultID, kstringGroupName)
    if(miog.InviteFrame and C_LFGList.HasSearchResultInfo(resultID)) then
        blizzDialog:Hide()

        local apps = C_LFGList.GetApplications();

        if(apps) then
            for i=1, #apps do
                local id, status, pendingStatus = C_LFGList.GetApplicationInfo(apps[i]);

                if ( status == "invited" and not pendingStatus and not miog.inviteFrames[id]) then
                    local resultFrame = miog.createPersistentResultFrame(resultID, true)
                    miog.updatePersistentResultFrame(resultID, true)

                    resultFrame.BasicInformation.Age:Hide()

                    if(resultFrame.BasicInformation.Age.ageTicker) then
                        resultFrame.BasicInformation.Age.ageTicker:Cancel()

                    end

                    resultFrame.InviteBackground:Show()
                    resultFrame.CancelApplication:Show()
                    resultFrame.AcceptInvite:Show()

                    miog.setResultFrameColors(resultID, true)

                    resultFrame.CancelApplication:SetScript("OnClick", function(self, button)
                        if(button == "LeftButton") then
                            if(status == "invited") then
                                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                                C_LFGList.DeclineInvite(resultID)
        
                                self:GetParent().framePool:ReleaseAll()

                                miog.searchResultFramePool:Release(self:GetParent())

                                miog.inviteFrames[resultID] = nil

                                for _, _ in pairs(miog.inviteFrames) do
                                    return
                                end

                                miog.InviteFrame:Hide()
                            end
                        end
                    end)

                    resultFrame.AcceptInvite:SetScript("OnClick", function(_, button)
                        if(button == "LeftButton") then
                            if(status == "invited") then
                                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                                C_LFGList.AcceptInvite(resultID)
        
                                for index, v in pairs(miog.inviteFrames) do
                                    v.framePool:ReleaseAll()

                                    miog.searchResultFramePool:Release(v)

                                    miog.inviteFrames[index] = nil
                        
                                end

                                miog.InviteFrame:Hide()
                            end
                        end
                    end)

                    local index = i

                    resultFrame.layoutIndex = index
                    resultFrame:Show()
                end
            end

            miog.InviteFrame.Container:MarkDirty()
            miog.InviteFrame:MarkDirty()
            miog.InviteFrame:Show()
        end
    end
end)