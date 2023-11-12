
-- Function to create the main frame
function CreateMainFrame()
    ---@class Frame
    local frame = CreateFrame("Frame", "RotationRecorder_MainFrame", UIParent)
    frame:SetWidth(200)
    frame:SetHeight(130)
    frame:SetPoint("CENTER")

    local backgroundTexture = frame:CreateTexture(nil, "BACKGROUND")
    backgroundTexture:SetAllPoints(frame)
    backgroundTexture:SetColorTexture(0, 0, 0, 0.7)

    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    local titleText = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    titleText:SetPoint("TOP", 0, -5)
    titleText:SetText("Rotation Recorder")

    -- Create the spell IDs frame and pass the child frame
    frame.spellIDsFrame = CreateSpellIDsFrame(frame)
    return frame
end

-- Function to create a button
function CreateButton(parent, name, x, y, width, height)
    ---@class Button
    local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    button:SetPoint("TOPLEFT", x, y)
    button:SetSize(width, height)

    -- Set initial state based on IsRecording
    if IsRecording then
        button:SetText("Stop Recording")
        button:SetScript("OnClick", function() StopRecordingOnClick(button, parent) end)
    else
        button:SetText("Start Recording")
        button:SetScript("OnClick", function() StartRecordingOnClick(button, parent) end)
    end

    UpdateButtonState(button, parent)
    return button
end

-- Update the button based on the state of IsRecording
---@param parent Frame
---@param button Button
function UpdateButtonState(button, parent)
    if IsRecording then
        button:SetText("Stop Recording")
        button:SetScript("OnClick", function() StopRecordingOnClick(button, parent) end)
    else
        button:SetText("Start Recording")
        button:SetScript("OnClick", function() StartRecordingOnClick(button, parent) end)
    end
end

-- Function to create the spell IDs frame
function CreateSpellIDsFrame(parent)
    --- @class Frame
    local frame = CreateFrame("Frame", "RotationRecorder_SpellIDsFrame", parent)
    frame:SetPoint("TOPLEFT", -20, -150)  -- Adjust the position as needed
    frame:SetWidth(250)
    frame:SetHeight(150)
    local backgroundTexture = frame:CreateTexture(nil, "BACKGROUND")
    backgroundTexture:SetAllPoints(frame)
    backgroundTexture:SetColorTexture(0, 0, 0, 0.7)

    local titleText = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    titleText:SetPoint("TOP", 0, -5)
    titleText:SetText("Spells")

    -- Set the function to update the spell IDs frame
    frame.UpdateSpellIDsFrame = function()
        UpdateSpellIDsFrame(frame)
    end
    frame.UpdateSpellIDsFrame()  -- Initially update the spell IDs frame

    return frame
end


local createdSpells = {}


-- Function to update the spell IDs frame
---@param spellIDsFrame Frame
function UpdateSpellIDsFrame(spellIDsFrame)

    -- Clear previous elements
    for _, element in ipairs(createdSpells) do
        element:Hide()
    end

    -- Reset the table for new elements
    wipe(createdSpells)

    -- Display spell 
    local yPos = -20
    if openers and openers[SelectedClass] and openers[SelectedClass][SelectedSpecializtion] then
        for i, id in ipairs(openers[SelectedClass][SelectedSpecializtion]) do
            local spellName, _, spellIcon = GetSpellInfo(id)
            local spellIconTexture = spellIDsFrame:CreateTexture(nil, "ARTWORK")
            spellIconTexture:SetTexture(spellIcon)
            spellIconTexture:SetSize(30, 30)  -- Adjust the size as needed
            spellIconTexture:SetPoint("TOPLEFT", 10, yPos)
            table.insert(createdSpells, spellIconTexture)


            local spellNameText = spellIDsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            spellNameText:SetPoint("LEFT", spellIconTexture, "RIGHT", 5, 0)
            spellNameText:SetText(spellName)
            table.insert(createdSpells, spellNameText)


            if i == CurrentIndex then
                spellNameText:SetTextColor(1, 1, 0) -- Yellow color for the current spell name
            elseif i < CurrentIndex then
                spellNameText:SetTextColor(0, 1, 0) -- Green color for correctly cast spell names
            end

            yPos = yPos - 35  -- Adjust the spacing as needed
        end
    end

    -- Update the height of the child frame based on the content
    spellIDsFrame:SetHeight(math.max(1, -yPos + 10))
end

-- Function to handle the "Start Recording" button click
---@param mainFrame Frame
function StartRecordingOnClick(button, mainFrame)
    print("Started Recording!")
    Reset()
    IsRecording = true
    mainFrame.spellIDsFrame.UpdateSpellIDsFrame()
    UpdateButtonState(button, mainFrame)
end

-- Function to handle the "Stop Recording" button click
---@param mainFrame Frame
function StopRecordingOnClick(button, mainFrame)
    print("Stopped Recording!")
    Reset()
    IsRecording = false
    mainFrame.spellIDsFrame.UpdateSpellIDsFrame()
    UpdateButtonState(button, mainFrame)
end


-- Function to create the class and specialization selection frame
function CreateSelectionFrame(parent)
    local classDropdown = CreateFrame("Frame", "RotationRecorder_ClassDropdown", parent, "UIDropDownMenuTemplate")
    classDropdown:SetPoint("BOTTOMLEFT", -70, -10)
    UIDropDownMenu_SetWidth(classDropdown, 120)
    UIDropDownMenu_SetText(classDropdown, "Select Class")

    local specializationDropdown = CreateFrame("Frame", "RotationRecorder_SpecializationDropdown", parent, "UIDropDownMenuTemplate")
    specializationDropdown:SetPoint("TOPLEFT", classDropdown, "TOPRIGHT", 0, 0)
    UIDropDownMenu_SetWidth(specializationDropdown, 120)
    UIDropDownMenu_SetText(specializationDropdown, "Select Specialization")

    -- Function to populate the class dropdown
    function InitializeClassDropdown(self, level)
        for class in pairs(openers) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = class
            info.value = class
            info.func = function()
                SelectedClass = class
                UIDropDownMenu_SetText(classDropdown, class)
                UIDropDownMenu_SetText(specializationDropdown, "Select Specialization")
                -- InitializeSpecializationDropdown()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end

    -- Function to populate the specialization dropdown
    function InitializeSpecializationDropdown(self, level)
        local specializations = openers[SelectedClass]

        if specializations then
            for specialization, _ in pairs(specializations) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = specialization
                info.value = specialization
                info.func = function()
                    UIDropDownMenu_SetText(specializationDropdown, specialization)
                    -- load the dict 
                    SelectedSpecializtion = specialization
                    parent.spellIDsFrame.UpdateSpellIDsFrame()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end

    UIDropDownMenu_Initialize(classDropdown,InitializeClassDropdown)
    UIDropDownMenu_Initialize(specializationDropdown,InitializeSpecializationDropdown)


     -- Add OnShow script to class dropdown to initialize the specialization dropdown


    return frame
end