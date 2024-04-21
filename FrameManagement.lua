local addonName, miog = ...

local function resetFrame(pool, childFrame)
    childFrame:Hide()
	childFrame:SetFrameStrata("LOW")

	childFrame.layoutIndex = nil
	childFrame.fixedHeight = nil
	childFrame.fixedWidth = nil
	childFrame.minimumHeight = nil
	childFrame.minimumWidth = nil
	childFrame.maximumHeight = nil
	childFrame.maximumWidth = nil
	childFrame.bottomPadding = nil
	childFrame.leftPadding = nil
	childFrame.topPadding = nil
	childFrame.rightPadding = nil
	
	childFrame.encounterInfo = nil

	local typeOfFrame = childFrame:GetObjectType()

	if(typeOfFrame == "Button") then
		childFrame:Enable()
		childFrame.icon = nil
		childFrame.iconSize = nil
		childFrame.iconAtlas = nil

	elseif(typeOfFrame == "CheckButton") then
		childFrame:Enable()
		childFrame:SetChecked(false)

	elseif(typeOfFrame == "EditBox") then
		childFrame:ClearFocus()
		childFrame:SetScript("OnKeyDown", nil)

	elseif(typeOfFrame == "Frame") then
		if(string.find(pool:GetTemplate(), "BackdropTemplate") and childFrame:GetBackdrop() ~= nil) then
			childFrame:SetBackdrop()

		end

		childFrame.background = nil

		childFrame:SetMouseClickEnabled(false)
		childFrame:SetScript("OnEnter", nil)
		childFrame:SetScript("OnLeave", nil)
		childFrame:SetScript("OnMouseDown", nil)
		childFrame:SetScript("OnLoad", nil)

		childFrame.Texture = nil
		childFrame.FontString = nil

		childFrame.declineButton = nil
		childFrame.inviteButton = nil
		childFrame.expandFrameButton = nil
		childFrame.linkBox = nil
		childFrame.titleString = nil
	end

	childFrame:ClearAllPoints()
	childFrame:SetParent()
end

local function resetFontString(_, childFontString)
    childFontString:Hide()
	childFontString.layoutIndex = nil

	childFontString:SetDrawLayer("OVERLAY", -8)
	childFontString:SetText("")
	childFontString:SetJustifyH("LEFT")
	childFontString:SetJustifyV("MIDDLE")
	childFontString:SetWordWrap(false)
	childFontString:SetSpacing(0)

	childFontString:ClearAllPoints()
	childFontString:SetParent()

	childFontString:SetScript("OnMouseDown", nil)
	childFontString:SetScript("OnEnter", nil)
	childFontString:SetScript("OnLeave", nil)
end

local function resetTexture(_, childTexture)
	childTexture:Hide()
	childTexture.layoutIndex = nil

	childTexture:SetDrawLayer("BACKGROUND", -8)
	childTexture:SetTexture(nil)
	childTexture:SetTexCoord(0, 1, 0, 1)
	childTexture:SetDesaturated(false)

	childTexture:SetMouseClickEnabled(false)
	childTexture:SetScript("OnMouseDown", nil)
	childTexture:SetScript("OnEnter", nil)
	childTexture:SetScript("OnLeave", nil)

	childTexture:ClearAllPoints()
	childTexture:SetParent()
end

miog.resetFrame = resetFrame
miog.resetFontString = resetFontString
miog.resetTexture = resetTexture

miog.persistentFramePool = CreateFramePoolCollection()
miog.persistentFramePool:GetOrCreatePool("Frame", nil, "BackdropTemplate", resetFrame)
miog.persistentFramePool:GetOrCreatePool("Frame", nil, "UIDropDownMenuTemplate", resetFrame)
miog.persistentFramePool:GetOrCreatePool("Frame", nil, "ResizeLayoutFrame, BackdropTemplate", resetFrame)
miog.persistentFramePool:GetOrCreatePool("Frame", nil, "VerticalLayoutFrame, BackdropTemplate", resetFrame)
miog.persistentFramePool:GetOrCreatePool("Frame", nil, "HorizontalLayoutFrame, BackdropTemplate", resetFrame)
miog.persistentFramePool:GetOrCreatePool("Frame", nil, "GridLayoutFrame, BackdropTemplate", resetFrame)
miog.persistentFramePool:GetOrCreatePool("ScrollFrame", nil, "ScrollFrameTemplate", resetFrame)
miog.persistentFramePool:GetOrCreatePool("Button", nil, "IconButtonTemplate", resetFrame)
miog.persistentFramePool:GetOrCreatePool("Button", nil, "IconButtonTemplate, BackdropTemplate", resetFrame)
miog.persistentFramePool:GetOrCreatePool("Button", nil, "UIButtonTemplate", resetFrame)
miog.persistentFramePool:GetOrCreatePool("Button", nil, "UIButtonTemplate, BackdropTemplate", resetFrame)
miog.persistentFramePool:GetOrCreatePool("Button", nil, "UIPanelDynamicResizeButtonTemplate", resetFrame)
miog.persistentFramePool:GetOrCreatePool("CheckButton", nil, "UICheckButtonTemplate", resetFrame)
miog.persistentFramePool:GetOrCreatePool("EditBox", nil, "InputBoxTemplate", resetFrame)
miog.persistentFramePool:GetOrCreatePool("Frame", nil, "LoadingSpinnerTemplate", resetFrame)

miog.persistentFontStringPool = CreateFontStringPool(miog.persistentFramePool:Acquire("BackdropTemplate"), "OVERLAY", nil, "GameTooltipText", resetFontString)
miog.persistentTexturePool = CreateTexturePool(miog.persistentFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, nil, resetTexture)

miog.applicantFramePool = CreateFramePool("Frame", nil, "MIOG_ApplicantFrameTemplate", resetFrame)
miog.searchResultFramePool = CreateFramePool("Frame", nil, "MIOG_ResultFrameTemplate", resetFrame)

miog.raidRosterFramePool = CreateFramePool("Frame", nil, "BackdropTemplate", resetFrame)
miog.raidRosterFontStringPool = CreateFontStringPool(miog.raidRosterFramePool:Acquire("BackdropTemplate"), "OVERLAY", nil, "GameTooltipText", resetFontString)
miog.raidRosterTexturePool = CreateTexturePool(miog.raidRosterFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, nil, resetTexture)

miog.releaseRaidRosterPool = function()
	miog.raidRosterFramePool:ReleaseAll()
	miog.raidRosterFontStringPool:ReleaseAll()
	miog.raidRosterTexturePool:ReleaseAll()
end


local createBasicFontString = function(poolType, fontSize, parent, width, height, text)
	local fontString

	if(type(poolType) == "string") then
		fontString = miog[poolType.."FontStringPool"]:Acquire()

	else
		fontString = poolType:Acquire()

	end

	fontString:SetFont(miog.FONTS["libMono"], fontSize or 16, "OUTLINE")
	fontString:SetJustifyH("LEFT")
	fontString:SetText(text or "")
	fontString:SetSize(width or fontString:GetStringWidth() or 0, height or fontString:GetStringHeight() or 0)

	fontString:SetParent(parent)
	fontString:Show()

	return fontString
end

miog.createBasicFontString = createBasicFontString


local createBasicTexture = function(poolType, texturePath, parent, width, height, layer)
	local texture

	if(type(poolType) == "string") then
		texture = miog[poolType.."TexturePool"]:Acquire()
	else
		texture = poolType:Acquire()

	end

	texture:SetParent(parent)

	if(width == nil and height == nil) then
		texture:SetPoint("TOPLEFT", parent, "TOPLEFT", 1, -1)
		texture:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -1, 1)

	else
		texture:SetPoint("CENTER", parent, "CENTER")
		texture:SetSize(width or 0, height or 0)

	end

	if(layer) then
		texture:SetDrawLayer(layer)
	end

	if(texturePath) then
		texture:SetTexture(texturePath)
	end

	texture:Show()

	return texture
end

miog.createBasicTexture = createBasicTexture


local function createBasicFrame(poolType, template, parent, width, height, addOn, addOnInfo, addOnInfo2)
	local frame = miog[poolType.."FramePool"]:Acquire(template)

	frame:SetParent(parent)
	frame:SetSize(width or 0, height or 0)
	frame:Show()

	if(addOn == "FontString") then

		local fontString = createBasicFontString(poolType, addOnInfo, frame, width, height, addOnInfo2)
		fontString:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -1)
		fontString:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")

		frame.FontString = fontString

	elseif(addOn == "Texture") then

		local texture = createBasicTexture(poolType, addOnInfo, frame, width, height)

		frame.Texture = texture
	end

	return frame
end

miog.createBasicFrame = createBasicFrame

if(Settings) then
	local interfaceOptionsPanel = miog.createBasicFrame("persistent", "BackdropTemplate", nil)
	local category, layout = Settings.RegisterCanvasLayoutCategory(interfaceOptionsPanel, "MythicIOGrabber")
	category.ID = "MythicIOGrabber"
	layout:AddAnchorPoint("TOPLEFT", 10, -10);
	layout:AddAnchorPoint("BOTTOMRIGHT", -10, 10);
	
	Settings.RegisterAddOnCategory(category)

	miog.interfaceOptionsPanel = interfaceOptionsPanel
end














local function createFleetingFontString(pool, fontSize, parent, width, height)
	local fontString = pool:Acquire()
	fontString:SetFont(miog.FONTS["libMono"], fontSize or 16, "OUTLINE")
	fontString:SetJustifyH("LEFT")
	fontString:SetSize(width or fontString:GetStringWidth() or 0, height or fontString:GetStringHeight() or 0)
	fontString:SetParent(parent)
	fontString:Show()

	return fontString
end

miog.createFleetingFontString = createFleetingFontString


local function createFleetingTexture(pool, texturePath, parent, width, height, layer)
	local texture = pool:Acquire()

	texture:SetParent(parent)

	if(width == nil and height == nil) then
		texture:SetPoint("TOPLEFT", parent, "TOPLEFT", 1, -1)
		texture:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -1, 1)

	else
		texture:SetPoint("CENTER", parent, "CENTER")
		texture:SetSize(width or 0, height or 0)

	end

	if(layer) then
		texture:SetDrawLayer(layer)

	end

	if(texturePath) then
		texture:SetTexture(texturePath)

	end

	texture:Show()

	return texture
end

miog.createFleetingTexture = createFleetingTexture


local function createFleetingFrame(pool, template, parent, width, height, addOn, addOnPool, addOnInfo)
	local frame = pool:Acquire(template)

	frame:SetParent(parent)
	frame:SetSize(width or 0, height or 0)
	frame:Show()

	if(addOn == "FontString") then
		local fontString = createBasicFontString(addOnPool, addOnInfo, frame, width, height)
		fontString:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -1)
		fontString:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
		frame.FontString = fontString

	elseif(addOn == "Texture") then
		local texture = createBasicTexture(addOnPool, addOnInfo, frame, width, height)
		frame.Texture = texture

	end

	return frame

end

miog.createFleetingFrame = createFleetingFrame