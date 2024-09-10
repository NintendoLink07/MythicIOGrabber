local addonName, miog = ...

SortingMixin = {}

function SortingMixin:OnLoad()
    self.sortingParameters = {}
    self.sortingData = {}
end

function SortingMixin:AddSingleSortingParameter(parameter)
    table.insert(self.sortingParameters, parameter)
end

function SortingMixin:UpdateSortingData(table)
    self.sortingData = table
end

function SortingMixin:SetSortingFunction(func)
    self.sortingFunction = func
end

function SortingMixin:SortBy()
    
end

function SortingMixin:Sort()
    if(self.sortingFunction) then
        table.sort(self.sortingData, function(k1, k2)
            self.sortingFunction(k1, k2)
        end)
    else


    end
end