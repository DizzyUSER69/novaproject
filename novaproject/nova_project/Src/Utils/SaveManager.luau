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
	SaveManager.State = wax.shared.HttpService:JSONDecode(readfile("Nova/Settings.json"))
end)

if not Success then
	warn("Failed to load settings: " .. Error)
end

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
