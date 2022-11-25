local baseAddonFrame = CreateFrame("FRAME");
baseAddonFrame:RegisterEvent("ADDON_LOADED");
baseAddonFrame:RegisterEvent("FIRST_FRAME_RENDERED");

local function isAlchemy(spellTabId)
    local alchemyName = GetSpellInfo(2259)
    local professionName = GetProfessionInfo(spellTabId)
    if alchemyName == professionName then
        return true
    end
    return false
end

local function isAlchemyAvailable()
    local p1, p2 = GetProfessions()
    return isAlchemy(p1) or isAlchemy(p2)
end

local function isSacInInventory()
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemId = C_Container.GetContainerItemID(bag, slot)
            if itemId == 160325 then
                return true
            end
        end
    end
    return false
end

function baseAddonFrame:Main()
    -- search for 160325 sac. if it's not here, show craft button.
    if isAlchemyAvailable() and not isSacInInventory() then
        local sizeX = 150;
        local sizeY = 150;

        local baseCircleCenterFrame = CreateFrame("Frame", "ZitternderSack1", UIParent)
        baseCircleCenterFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
        baseCircleCenterFrame:SetSize(sizeX, sizeY);
        baseCircleCenterFrame:SetMovable(true)
        baseCircleCenterFrame:EnableMouse(true)
        baseCircleCenterFrame:SetScript("OnMouseDown", function(self, button)
            if button == "RightButton" and not self.isMoving then
                self:StartMoving();
                self.isMoving = true;
            end
            if button == "LeftButton" then
            end
        end)
        baseCircleCenterFrame:SetScript("OnMouseUp", function(self, button)
            if button == "RightButton" and self.isMoving then
                self:StopMovingOrSizing();
                self.isMoving = false;
                point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
                ZitternderSack_CirclePosition = { x = xOfs, y = yOfs, point = point, relativePoint = relativePoint }
            end
        end)
        baseCircleCenterFrame:SetScript("OnHide", function(self)
            if (self.isMoving) then
                self:StopMovingOrSizing();
                self.isMoving = false;
            end
        end)

        baseCircleCenterFrame.texture = baseCircleCenterFrame:CreateTexture()
        baseCircleCenterFrame.texture:SetAllPoints(baseCircleCenterFrame)
        baseCircleCenterFrame.texture:SetTexture("Interface/AddOns/WeakAuras/Media/Textures/Ring_40px")
        baseCircleCenterFrame.texture:SetVertexColor(0, 0, 0, 0.5)

        if ZitternderSack_CirclePosition ~= nil then
            baseCircleCenterFrame:ClearAllPoints()
            baseCircleCenterFrame:SetPoint(ZitternderSack_CirclePosition.point, UIParent,
                ZitternderSack_CirclePosition.relativePoint, ZitternderSack_CirclePosition.x,
                ZitternderSack_CirclePosition.y)
        end

        local btn = CreateFrame("Button", "CraftButton", baseCircleCenterFrame, "SharedButtonTemplate")
        btn:SetPoint("CENTER", baseCircleCenterFrame, "CENTER")
        btn:SetSize(100, 40)
        btn:SetText("Craft")
        btn:SetScript("OnClick", function()
            -- local alchemyName = GetSpellInfo(2259)
            if ProfessionsFrame:IsVisible() then
                C_TradeSkillUI.CraftRecipe(251808)
                baseCircleCenterFrame:Hide()
            else
                local alchemyName = GetSpellInfo(2259)
                CastSpellByName(alchemyName)
            end
        end)
        btn:Show()
    end

end

function baseAddonFrame:OnEvent(event, arg1, ...)
    if event == "ADDON_LOADED" and arg1 == "ZitternderSack" then
    end
    if event == "FIRST_FRAME_RENDERED" then
        baseAddonFrame:Main()
    end
end

baseAddonFrame:SetScript("OnEvent", baseAddonFrame.OnEvent)
