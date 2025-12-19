QueueManagerMixin = {}

local updateAfterCombat = false

function QueueManagerMixin:UpdateFakeApplications()


end

function QueueManagerMixin:UpdatePVEQueues()
    for categoryID = 1, NUM_LE_LFG_CATEGORYS do
		local mode, submode = GetLFGMode(categoryID);
		local isRF = categoryID == LE_LFG_CATEGORY_RF

		if(mode and submode ~= "noteleport") then
			queuedList = GetLFGQueuedList(categoryID, queuedList) or {}
			
			local length = 0
			for _ in pairs(queuedList) do
				length = length + 1
			end
		
			local activeID = select(18, GetLFGQueueStats(categoryID));
			local isMultiDungeon = categoryID == LE_LFG_CATEGORY_LFD and length > 1

			for queueID, queued in pairs(queuedList) do
				mode, submode = GetLFGMode(categoryID, queueID)
				
				if(activeID == queueID or isRF) then
					self.dataProvider:Insert({
						template = "MIOG_QueueLFGFrameTemplate",
						mode = mode,
						submode = submode,
						categoryID = categoryID,
						queueID = queueID,
						activeID = activeID,
						isCurrentlyActive = queueID == activeID,
						isMultiDungeon = isMultiDungeon,
					})
				end
			end
		end
	end
end

function QueueManagerMixin:CheckQueues()
    self.dataProvider:Flush()

    self:UpdateFakeApplications()
    self:UpdatePVEQueues()
end

function QueueManagerMixin:OnEvent(event, ...)
	if(event == "PLAYER_REGEN_ENABLED") then
		if(updateAfterCombat) then
			updateAfterCombat = false

			self:CheckQueues()
		end

    elseif(event == "PLAYER_REGEN_DISABLED")
		updateAfterCombat = true

	end
end

function QueueManagerMixin:OnLoad()
    self.dataProvider = CreateDataProvider()

    local view = CreateScrollBoxListLinearView(0, 0, 0, 0, 3);

	local function Initializer(frame, data)

    end

    local function CustomFactory(factory, data)
		local template = data.template
		factory(template, Initializer)

	end
	
	view:SetElementFactory(CustomFactory)

	ScrollUtil.InitScrollBoxListWithScrollBar(scrollbox, scrollbar, view);
	
	local scrollBoxAnchorsWithBar = {
		CreateAnchor("TOPLEFT", 3, -4),
		CreateAnchor("BOTTOMRIGHT", -18, 3);
	}

	local scrollBoxAnchorsWithoutBar = {
		scrollBoxAnchorsWithBar[1],
		CreateAnchor("BOTTOMRIGHT", -3, 3);
	}

	ScrollUtil.AddManagedScrollBarVisibilityBehavior(scrollbox, scrollbar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar)

	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
end