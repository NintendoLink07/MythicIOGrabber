local PartyInstanceAbandonFormatter = CreateFromMixins(SecondsFormatterMixin);
PartyInstanceAbandonFormatter:Init(0, SecondsFormatter.Abbreviation.None, false, true);

AbandonMixin = {}

function AbandonMixin:Reset()
    self.Title:SetText(VOTE_TO_ABANDON_PROMPT)
    self.Status:SetText("You can't abandon this run yet.")
    
    self.VoteIcons:Hide()
    self.VoteIcons.Player:SetAtlas("UI-LFG-RoleIcon-Generic-Disabled")
    self.VoteIcons.Party1:SetAtlas("UI-LFG-RoleIcon-Generic-Disabled")
    self.VoteIcons.Party2:SetAtlas("UI-LFG-RoleIcon-Generic-Disabled")
    self.VoteIcons.Party3:SetAtlas("UI-LFG-RoleIcon-Generic-Disabled")
    self.VoteIcons.Party4:SetAtlas("UI-LFG-RoleIcon-Generic-Disabled")
end

function AbandonMixin:StartTimer()
	local duration, timeLeft = C_PartyInfo.GetInstanceAbandonVoteTime();
	local cooldownTimeLeftText = PartyInstanceAbandonFormatter:Format(timeLeft);

    C_Timer.NewTicker(1, function()
        self.Title:SetText(VOTE_TO_ABANDON_PROMPT .. " " .. cooldownTimeLeftText)
    end)
end

function AbandonMixin:OnShow()
    --print(C_PartyInfo.GetInstanceAbandonShutdownTime())

    -- StartInstanceAbandonVote
    -- SetInstanceAbandonVoteResponse

    if(C_PartyInfo.GetInstanceAbandonVoteCooldownTime) then
        
    else
        local canAbandon = C_PartyInfo.CanStartInstanceAbandonVote()

        self.StartVote:SetEnabled(canAbandon)

        if(canAbandon) then
            local votesRequired, keystoneOwnerVoteWeight = C_PartyInfo.GetInstanceAbandonVoteRequirements();

            if C_PartyInfo.IsChallengeModeKeystoneOwner() then
                self.Status:SetFormattedText(VOTE_TO_ABANDON_VOTES_NEEDED_KEYHOLDER, votesRequired, keystoneOwnerVoteWeight);
            else
                self.Status:SetFormattedText(VOTE_TO_ABANDON_VOTES_NEEDED, votesRequired);
            end

            local ownVote = C_PartyInfo.GetInstanceAbandonVoteResponse();
            local numVoted = C_PartyInfo.GetNumInstanceAbandonGroupVoteResponses();
            
            self.VoteIcons.Player:SetAtlas(ownVote and "UI-LFG-RoleIcon-Ready" or ownVote == false and "UI-LFG-RoleIcon-Decline" or "UI-LFG-RoleIcon-Generic-Disabled")

            for i = 1, numVoted, 1 do
                self.VoteIcons["Party" .. i]:SetAtlas("UI-LFG-RoleIcon-Generic")

            end
        else
            self:Reset()

        end
    end

    

	--self:Refresh();
end

function AbandonMixin:OnEvent(selfSelf, event, ...)


end

function AbandonMixin:OnLoad()
    self:RegisterEvent("INSTANCE_ABANDON_VOTE_STARTED")
    self:RegisterEvent("INSTANCE_ABANDON_VOTE_UPDATED")
    self:RegisterEvent("INSTANCE_ABANDON_VOTE_FINISHED")
    self:SetScript("OnEvent", self.OnEvent)
end