local PartyInstanceAbandonFormatter = CreateFromMixins(SecondsFormatterMixin);
PartyInstanceAbandonFormatter:Init(0, SecondsFormatter.Abbreviation.None, false, true);

AbandonMixin = {}

function AbandonMixin:Reset(status)
    self.VoteIcons:Hide()
    self.VoteIcons.Player:SetAtlas("UI-LFG-RoleIcon-Generic-Disabled")
    self.VoteIcons.Party1:SetAtlas("UI-LFG-RoleIcon-Generic-Disabled")
    self.VoteIcons.Party2:SetAtlas("UI-LFG-RoleIcon-Generic-Disabled")
    self.VoteIcons.Party3:SetAtlas("UI-LFG-RoleIcon-Generic-Disabled")
    self.VoteIcons.Party4:SetAtlas("UI-LFG-RoleIcon-Generic-Disabled")

    self.Title:SetText(VOTE_TO_ABANDON_PROMPT)
    self.Status:SetText(status or "You can't abandon this run yet.")
    self.Status:Show()
end

function AbandonMixin:StartVote()
    self.Status:Hide()

	local duration, timeLeft = C_PartyInfo.GetInstanceAbandonVoteTime();
	local cooldownTimeLeftText = PartyInstanceAbandonFormatter:Format(timeLeft);

    C_Timer.NewTicker(1, function()
        self.Title:SetText(VOTE_TO_ABANDON_PROMPT .. " " .. cooldownTimeLeftText)
    end)
end

function AbandonMixin:UpdateStatus()
    local votesRequired, keystoneOwnerVoteWeight = C_PartyInfo.GetInstanceAbandonVoteRequirements();

    if(votesRequired ~= 0) then
        if C_PartyInfo.IsChallengeModeKeystoneOwner() then
            self.Status:SetFormattedText(VOTE_TO_ABANDON_VOTES_NEEDED_KEYHOLDER, votesRequired, keystoneOwnerVoteWeight)

        else
            self.Status:SetFormattedText(VOTE_TO_ABANDON_VOTES_NEEDED, votesRequired)

        end
    else
        self.Status:SetText(VOTE_TO_ABANDON)

    end
end

function AbandonMixin:UpdateIcons()
    local ownVote = C_PartyInfo.GetInstanceAbandonVoteResponse()
    local numVoted = C_PartyInfo.GetNumInstanceAbandonGroupVoteResponses()
    
    self.VoteIcons.Player:SetAtlas(ownVote and "UI-LFG-RoleIcon-Ready" or ownVote == false and "UI-LFG-RoleIcon-Decline" or "UI-LFG-RoleIcon-Generic-Disabled")

    for i = 1, numVoted, 1 do
        self.VoteIcons["Party" .. i]:SetAtlas("UI-LFG-RoleIcon-Generic")

    end
end

function AbandonMixin:RefreshDisplay()
    local canAbandon = C_PartyInfo.CanStartInstanceAbandonVote()

    self.StartVote:SetEnabled(canAbandon)

    if(canAbandon) then
        self:UpdateStatus()
        self:UpdateIcons()

    else
        self:Reset()

    end
end

function AbandonMixin:OnShow()
    if(C_PartyInfo.GetInstanceAbandonVoteCooldownTime) then
        
    else
        self:RefreshDisplay()
        
    end
end

function AbandonMixin:OnEvent(selfSelf, event, ...)
	if(event == "INSTANCE_ABANDON_VOTE_STARTED") then
        self:StartVote()

	elseif(event == "INSTANCE_ABANDON_VOTE_UPDATED") then
        self:UpdateIcons()

	elseif(event == "INSTANCE_ABANDON_VOTE_FINISHED") then
        self:UpdateIcons()

        C_Timer.After(5, function()
            self:Reset(C_PartyInfo.GetInstanceAbandonVoteResponse())
        
        end)
    end
end

function AbandonMixin:OnLoad()
    --[[self:RegisterEvent("INSTANCE_ABANDON_VOTE_STARTED")
    self:RegisterEvent("INSTANCE_ABANDON_VOTE_UPDATED")
    self:RegisterEvent("INSTANCE_ABANDON_VOTE_FINISHED")
    self:SetScript("OnEvent", self.OnEvent)]]
end