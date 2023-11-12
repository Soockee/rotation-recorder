-- Create the main frame
---@class Frame
local mainFrame = CreateMainFrame()

local recordingButton = CreateButton(mainFrame, "RotationRecorder_RecordingButton", 20, -30, 150, 30)

local selectionFrame = CreateSelectionFrame(mainFrame)


local function OnEvent(self, event, ...)
    if event == "UNIT_SPELLCAST_SENT" and IsRecording then
        local unit, target, castGUID, spellID = ...
        -- print("Spell Cast Sent:", spellID, "on", unit, "targeting", target)

        if not (openers and openers[SelectedClass] and openers[SelectedClass][SelectedSpecializtion]) then
            return
        end

        local castSpellID = spellID
        if castSpellID == ExpectedSpellID then
            -- print("Correct spell in the sequence!")
            CurrentIndex = CurrentIndex + 1
            ExpectedSpellID = openers[SelectedClass][SelectedSpecializtion][CurrentIndex]
            -- Check if the sequence is complete
            if not ExpectedSpellID then
                -- print("Sequence complete! Resetting to the beginning.")
                CurrentIndex = 1
                ExpectedSpellID = openers[SelectedClass][SelectedSpecializtion][CurrentIndex]
            end
            mainFrame.spellIDsFrame.UpdateSpellIDsFrame()
        else
            local spellName, _, _ = GetSpellInfo(castSpellID)
            local expectedSpellName, _, _ = GetSpellInfo(ExpectedSpellID)
            print("Incorrect spell: ", spellName, " instead of ", expectedSpellName)
            CurrentIndex = 1
            ExpectedSpellID = openers[SelectedClass][SelectedSpecializtion][CurrentIndex]
            mainFrame.spellIDsFrame.UpdateSpellIDsFrame()
        end
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("UNIT_SPELLCAST_SENT")
f:SetScript("OnEvent", OnEvent)


