if not isfolder("Nova") then
makefolder("Nova")
end

if not isfile("Nova/Settings.json") then
writefile("Nova/Settings.json", "{}")
end

local SaveManager = {
State = {},
}

local Success, Error = pcall(function()
local FileContent = readfile("Nova/Settings.json")
if FileContent == "" or FileContent == "{}" then
SaveManager.State = {}
return
end
local Decoded = wax.shared.HttpService:JSONDecode(FileContent)
if typeof(Decoded) == "table" then
SaveManager.State = Decoded
else
SaveManager.State = {}
warn("Nova: Settings file contained invalid data type, resetting to defaults")
end
end)

if not Success then
warn("Nova: Failed to load settings - " .. tostring(Error))
SaveManager.State = {}
end

-- Default values for new settings
if SaveManager.State.Theme == nil then SaveManager.State.Theme = "Default" end
if SaveManager.State.CustomNotifications == nil then SaveManager.State.CustomNotifications = true end

function SaveManager:SetState(Idx, Value)
SaveManager.State[Idx] = Value
pcall(writefile, "Nova/Settings.json", wax.shared.HttpService:JSONEncode(SaveManager.State))
end

function SaveManager:GetState(Idx, Default)
if SaveManager.State[Idx] ~= nil then
return SaveManager.State[Idx]
end

return Default
end

return SaveManager
