CurrentIndex = 1
ExpectedSpellID = 0
IsRecording = false
SelectedClass = nil
SelectedSpecializtion = nil

function Reset()
    CurrentIndex = 1

    if openers and openers[SelectedClass] and openers[SelectedClass][SelectedSpecializtion] then
        ExpectedSpellID = openers[SelectedClass][SelectedSpecializtion][CurrentIndex]
    end
end