GroupCreatorMixin = {}

function GroupCreatorMixin:OnLoad()
	self.ActivityDropdown:SetDefaultText("Select an activity")
	self.DifficultyDropdown:SetDefaultText("Select a difficulty")
	self.PlayStyleDropdown:SetDefaultText("Select a playstyle")

	local name = LFGListFrame.EntryCreation.Name
	name:ClearAllPoints()
	name:SetAutoFocus(false)
	name:SetParent(entryCreation)
	name:SetPoint("TOPLEFT", self.PlayStyleDropdown, "BOTTOMLEFT", 0, -20)
	name:SetPoint("TOPRIGHT", self.PlayStyleDropdown, "BOTTOMRIGHT", 0, -20)

	local description = LFGListFrame.EntryCreation.Description
	description:ClearAllPoints()
	description:SetParent(entryCreation)
	description:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -20)
	description:SetPoint("TOPRIGHT", name, "BOTTOMRIGHT", 0, -20)
end

function GroupCreatorMixin:OnShow()
    LFGListEntryCreation_SetupPlayStyleDropdown(self)

end