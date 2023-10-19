local addonName, miog = ...

local function resetFrame(_, childFrame)
    childFrame:Hide()
	childFrame:SetFrameStrata("LOW")

	childFrame.fixedHeight = nil
	childFrame.fixedWidth = nil
	childFrame.minimumHeight = nil
	childFrame.minimumWidth = nil
	childFrame.maximumHeight = nil
	childFrame.maximumWidth = nil
	childFrame.icon = nil
	childFrame.iconSize = nil
	childFrame.iconAtlas = nil

	local typeOfFrame = childFrame:GetObjectType()

	if(typeOfFrame == "Button") then
		childFrame:Enable()

	elseif(typeOfFrame == "CheckButton") then
		childFrame:Enable()
		childFrame:SetChecked(false)

	elseif(typeOfFrame == "EditBox") then
		childFrame:ClearFocus()
		childFrame:SetScript("OnKeyDown", nil)

	elseif(typeOfFrame == "Frame") then
		childFrame:ClearBackdrop()
		childFrame:SetScript("OnEnter", nil)
		childFrame:SetScript("OnLeave", nil)
		childFrame.Texture = nil
		childFrame.FontString = nil

		childFrame.declineButton = nil
		childFrame.inviteButton = nil
		childFrame.linkBox = nil

		childFrame.textRows = nil
		childFrame.mythicPlusTabButton = nil
		childFrame.raidTabButton = nil
		childFrame.rows = nil
		childFrame.memberFrames = nil
		childFrame.textureRows = nil
		childFrame:SetMouseClickEnabled(false)
		childFrame:SetScript("OnEnter", nil)
		childFrame:SetScript("OnLeave", nil)
		childFrame:SetScript("OnMouseDown", nil)
	end
	
	childFrame:ClearAllPoints()
	childFrame:SetParent()
end

local function resetFontString(_, childFontString)
    childFontString:Hide()
	childFontString:SetDrawLayer("OVERLAY", -8)
	childFontString:SetText("")
	childFontString:SetJustifyH("LEFT")
	childFontString:SetJustifyV("MIDDLE")
	childFontString:SetWordWrap(false)
	childFontString:SetSpacing(0)
	childFontString:ClearAllPoints()
	childFontString:SetParent()
end

local function resetTexture(_, childTexture)
	childTexture:Hide()
	childTexture:SetDrawLayer("BACKGROUND", -8)
	childTexture:SetTexture(nil)
	childTexture:SetTexCoord(0, 1, 0, 1)
	childTexture:SetDesaturated(false)
	childTexture:ClearAllPoints()
	childTexture:SetParent()
end

miog.persistentFramePool = CreateFramePoolCollection()
miog.persistentFramePool:CreatePoolIfNeeded("Frame", nil, "BackdropTemplate", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("Frame", nil, "ResizeLayoutFrame, BackdropTemplate", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("ScrollFrame", nil, "ScrollFrameTemplate", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("Button", nil, "IconButtonTemplate", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("Button", nil, "UIButtonTemplate", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("Button", nil, "UIPanelDynamicResizeButtonTemplate", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("CheckButton", nil, "UICheckButtonTemplate", resetFrame)


miog.persistentFontStringPool = CreateFontStringPool(miog.persistentFramePool:Acquire("BackdropTemplate"), "OVERLAY", nil, "GameTooltipText", resetFontString)

miog.persistentTexturePool = CreateTexturePool(miog.persistentFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, nil, resetTexture)


miog.fleetingFramePool = CreateFramePoolCollection()
miog.fleetingFramePool:CreatePoolIfNeeded("Frame", nil, "BackdropTemplate", resetFrame)
miog.fleetingFramePool:CreatePoolIfNeeded("Frame", nil, "ResizeLayoutFrame, BackdropTemplate", resetFrame)
miog.fleetingFramePool:CreatePoolIfNeeded("EditBox", nil, "InputBoxTemplate", resetFrame)
miog.fleetingFramePool:CreatePoolIfNeeded("Button", nil, "IconButtonTemplate", resetFrame)
miog.fleetingFramePool:CreatePoolIfNeeded("Button", nil, "UIButtonTemplate", resetFrame)
miog.fleetingFramePool:CreatePoolIfNeeded("Button", nil, "UIPanelButtonTemplate", resetFrame)

miog.fleetingFontStringPool = CreateFontStringPool(miog.fleetingFramePool:Acquire("BackdropTemplate"), "OVERLAY", nil, "GameTooltipText", resetFontString)
miog.fleetingTexturePool = CreateTexturePool(miog.fleetingFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, nil, resetTexture)

miog.releaseAllFleetingWidgets = function()
	miog.fleetingFramePool:ReleaseAll()
	miog.fleetingFontStringPool:ReleaseAll()
	miog.fleetingTexturePool:ReleaseAll()
end

miog.raidRosterFramePool = CreateFramePool("Frame", nil, "BackdropTemplate", resetFrame)
miog.raidRosterFontStringPool = CreateFontStringPool(miog.raidRosterFramePool:Acquire("BackdropTemplate"), "OVERLAY", nil, "GameTooltipText", resetFontString)
miog.raidRosterTexturePool = CreateTexturePool(miog.raidRosterFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, nil, resetTexture)

miog.releaseRaidRosterPool = function()
	miog.raidRosterFramePool:ReleaseAll()
	miog.raidRosterFontStringPool:ReleaseAll()
	miog.raidRosterTexturePool:ReleaseAll()
end

local createBasicFontString = function(type, fontSize, parent, width, height, text)
	local fontString = miog[type.."FontStringPool"]:Acquire()

	fontString:SetFont(miog.FONTS["libMono"], fontSize or 16, "OUTLINE")
	fontString:SetJustifyH("LEFT")
	fontString:SetText(text or "")
	fontString:SetSize(width or fontString:GetStringWidth() or 0, height or fontString:GetStringHeight() or 0)

	fontString:SetParent(parent)
	fontString:Show()

	return fontString
end

miog.createBasicFontString = createBasicFontString

local createBasicTexture = function(type, texturePath, parent, width, height, layer)
	local texture = miog[type.."TexturePool"]:Acquire()

	texture:SetParent(parent)
	
	if(width == nil and height == nil) then
		texture:SetPoint("TOPLEFT", parent, "TOPLEFT", 1, -1)
		texture:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -1, 1)

	else
		texture:SetPoint("LEFT", parent, "LEFT", 0, 0)
		texture:SetSize(width or 0, height or 0)

	end

	texture:SetTexture(texturePath)

	texture:Show()

	return texture
end

miog.createBasicTexture = createBasicTexture

miog.createBasicFrame = function (type, template, parent, width, height, addOn, addOnInfo, addOnInfo2)
	local frame = miog[type.."FramePool"]:Acquire(template)

	frame:SetParent(parent)
	frame:SetSize(width or 0, height or 0)
	frame:Show()

	if(addOn == "FontString") then

		local fontString = createBasicFontString(type, addOnInfo, frame, width, height, addOnInfo2)
		fontString:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -1)
		fontString:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")

		frame.FontString = fontString

	elseif(addOn == "Texture") then

		local texture = createBasicTexture(type, addOnInfo, frame, width, height, addOnInfo2)

		frame.Texture = texture
	end

	return frame
end