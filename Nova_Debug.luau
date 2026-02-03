-- ++++++++ WAX BUNDLED DATA BELOW ++++++++ --

-- Will be used later for getting flattened globals
local ImportGlobals

-- Holds direct closure data (defining this before the DOM tree for line debugging etc)
local ClosureBindings = {
    function()local wax,script,require=ImportGlobals(1)local ImportGlobals return (function(...)wax.shared.NovaStartTime = tick()

local FileLogger = require(script.Utils.FileLog)

--[[
    Nova Project
    Created by 04xSkater
]]

-- Environment
for _, Service in pairs({
	"ContentProvider",
	"CoreGui",
	"TweenService",
	"Players",
	"RunService",
	"HttpService",
	"UserInputService",
	"TextService",
	"StarterGui",
}) do
	wax.shared[Service] = cloneref(game:GetService(Service))
end

wax.shared.NovaVerificationToken = wax.shared.HttpService:GenerateGUID()
wax.shared.SaveManager = require(script.Utils.SaveManager)
wax.shared.Settings = {}

wax.shared.Hooks = {}

-- Executor Support
wax.shared.ExecutorName = identifyexecutor()
wax.shared.ExecutorSupport = require(script.ExecutorSupport)

-- Utils
require(script.Utils.Connect)
wax.shared.Hooking = require(script.Utils.Hooking)

-- UI
wax.shared.Sonner = require(script.Utils.UI.Sonner)

-- Code Generation
local LuaEncode = require(script.Utils.Serializer.LuaEncode)
wax.shared.LuaEncode = LuaEncode

local CodeGen = require(script.Utils.CodeGen.Generator)

-- Variables
if not wax.shared.Players.LocalPlayer then
	wax.shared.Players.PlayerAdded:Wait()
end
wax.shared.LocalPlayer = wax.shared.Players.LocalPlayer
wax.shared.PlayerScripts = cloneref(wax.shared.LocalPlayer:WaitForChild("PlayerScripts"))

-- Functions
wax.shared.gethui = gethui or function()
	return wax.shared.CoreGui
end
wax.shared.checkcaller = checkcaller or function()
	return nil
end
wax.shared.restorefunction = function(Function: (...any) -> ...any, Silent: boolean?)
	local Original = wax.shared.Hooks[Function]

	if Silent and not Original then
		return
	end

	assert(Original, "Function not hooked")

	if restorefunction and isfunctionhooked(Function) then
		restorefunction(Function)
	else
		wax.shared.Hooking.HookFunction(Function, Original)
	end

	wax.shared.Hooks[Function] = nil
end
wax.shared.getrawmetatable = wax.shared.ExecutorSupport["getrawmetatable"].IsWorking
		and (getrawmetatable or debug.getmetatable)
	or function()
		return setmetatable({}, {
			__index = function()
				return function() end
			end,
		})
	end

wax.shared.newcclosure = wax.shared.ExecutorName == "AWP"
		and function(f)
			local env = getfenv(f)
			local x = setmetatable({
				__F = f,
			}, {
				__index = env,
				__newindex = env,
			})

					local nf = function(...)
						return x.__F(...)
					end

			setfenv(nf, x) -- set func env (env of nf gets deoptimized)
			return newcclosure(nf)
		end
	or newcclosure
wax.shared.queue_on_teleport = queue_on_teleport or queueonteleport or function(...) end

wax.shared.IsPlayerModule = function(Origin: LocalScript | ModuleScript, Instance: Instance): boolean
	if Instance and Instance.ClassName ~= "BindableEvent" then
		return false
	end

	if not Origin or typeof(Origin) ~= "Instance" or not Origin.IsA(Origin, "LuaSourceContainer") then
		return false
	end

	local PlayerModule = Origin and Origin.FindFirstAncestor(Origin, "PlayerModule") or nil
	if not PlayerModule then
		return false
	end

	if PlayerModule.Parent == nil then
		return true
	end

	return compareinstances(PlayerModule.Parent, wax.shared.PlayerScripts)
end
wax.shared.ShouldIgnore = function(Instance, Origin)
	return wax.shared.Settings.IgnoredRemotesDropdown.Value[Instance.ClassName] == true
		or (wax.shared.Settings.IgnorePlayerModule.Value and wax.shared.IsPlayerModule(Origin, Instance))
end

wax.shared.GetTableLength = function(Table)
	if Table["n"] then
		return Table.n
	end

	local Length = 0
	for _, _ in pairs(Table) do
		Length += 1
	end
	return Length
end
wax.shared.JoinTable = function(Table, Prefix, Suffix)
	local FinalString = ""
	for _, Value in pairs(Table) do
		FinalString ..= Prefix .. tostring(Value) .. Suffix
	end

	FinalString = string.sub(FinalString, 1, string.len(FinalString) - string.len(Suffix))

	return FinalString
end
wax.shared.GetTextBounds = function(Text: string, Font: Font, Size: number, Width: number?): (number, number)
	local Params = Instance.new("GetTextBoundsParams")
	Params.Text = Text
	Params.RichText = true
	Params.Font = Font
	Params.Size = Size
	Params.Width = Width or workspace.CurrentCamera.ViewportSize.X - 32

	local Bounds = wax.shared.TextService:GetTextBoundsAsync(Params)
	Params:Destroy()
	
	return Bounds.X, Bounds.Y
end

wax.shared.Unloaded = false
wax.shared.Unload = function()
	for _, Connection in pairs(wax.shared.Connections) do
		wax.shared.Disconnect(Connection)
	end

	local gameMetatable = wax.shared.getrawmetatable(game)

	if wax.shared.ExecutorSupport["oth"].IsWorking then
		pcall(oth.unhook, gameMetatable.__namecall)
		pcall(oth.unhook, gameMetatable.__newindex)
	else
		if wax.shared.ExecutorSupport["restorefunction"].IsWorking and not wax.shared.AlternativeEnabled then
			pcall(restorefunction, gameMetatable.__namecall)
			pcall(restorefunction, gameMetatable.__newindex)
		else
			wax.shared.Hooking.HookMetaMethod(game, "__namecall", wax.shared.NamecallHook)
			wax.shared.Hooking.HookMetaMethod(game, "__newindex", wax.shared.NewIndexHook)
		end
	end

	for Function, Original in pairs(wax.shared.Hooks) do
		if wax.shared.ExecutorSupport["oth"].IsWorking then
			task.spawn(pcall, oth.unhook, Function)
		elseif wax.shared.ExecutorSupport["restorefunction"].IsWorking then
			task.spawn(pcall, wax.shared.restorefunction, Function)
		else
			pcall(wax.shared.Hooking.HookFunction, Function, Original)
		end
	end

	if wax.shared.ActorCommunicator then
		pcall(function()
			wax.shared.ActorCommunicator:Fire("Unload")
		end)
	end

	getgenv().NovaInitialized = false

	wax.shared.Communicator:Destroy()
	wax.shared.ScreenGui:Destroy()

	wax.shared.Unloaded = true
end

local AnticheatData = require(script.Utils.Anticheats.Main)

-- Load Script
wax.shared.Communicator = Instance.new("BindableEvent")

wax.shared.SetupLoggingConnection = function()
	if wax.shared.LogConnection then
		wax.shared.LogConnection:Disconnect()
	end

	wax.shared.LogFileName = `Nova/Logs/{DateTime.now():ToIsoDate():gsub(":", "_")}.log`
	local FileLog = FileLogger.new(wax.shared.LogFileName, FileLogger.LOG_LEVELS.INFO, true)

	return function(RemoteInstance, Type, CallOrderInLog)
		local LogEntry = wax.shared.Logs[Type][RemoteInstance]
		if not LogEntry then
			return
		end

		local CallDataFromHook = LogEntry.Calls[CallOrderInLog]

		local success, err = pcall(function()
			local generatedCode = CodeGen:BuildCallCode(setmetatable({
				Instance = RemoteInstance,
				Type = Type,
			}, {
				__index = CallDataFromHook,
			}) :: any)

			local comprehensiveDataToSerialize = {
				RemoteInstanceInfo = {
					Name = RemoteInstance and RemoteInstance.Name,
					ClassName = RemoteInstance and RemoteInstance.ClassName,
					Path = RemoteInstance and CodeGen.GetFullPath(RemoteInstance, {
						DisableNilParentHandler = true,
					}),
				},
				EventType = Type,
				CallOrderInLog = CallOrderInLog,
				DataFromHook = CallDataFromHook,
			}

			local serializedEventData = LuaEncode(
				comprehensiveDataToSerialize,
				{ Prettify = true, InsertCycles = true, UseInstancePaths = true }
			)

			local instanceName = RemoteInstance and RemoteInstance.Name or "UnknownInstance"
			local instanceClassName = RemoteInstance and RemoteInstance.ClassName or "UnknownClass"
			local instancePath = RemoteInstance and CodeGen.GetFullPath(RemoteInstance, {
				DisableNilParentHandler = true
			}) or "UnknownPath"

			local logParts = {
				("Instance: %s (%s)"):format(instanceName, instanceClassName),
				("Path: %s"):format(instancePath),
				("Call Order In Log: %s"):format(CallOrderInLog or "N/A"),
				"-------------------- Event Data --------------------",
				serializedEventData,
				"-------------------- Generated Code --------------------",
				generatedCode,
			}
			local logMessage = table.concat(logParts, "\n\t")
			local threadId = ("%s:%s"):format(Type or "S", instanceName)

			FileLog:Info(threadId, logMessage)
		end)

		if not success then
			local instanceNameForError = RemoteInstance and RemoteInstance.Name or "Unknown"
			FileLog:Error(
				"Logger",
				("Failed to log remote communication for %s:%s - %s"):format(
					Type or "UnknownType",
					instanceNameForError,
					tostring(err)
				)
			)

			warn(
				("Nova: Failed to log remote communication for %s:%s - %s"):format(
					Type or "UnknownType",
					instanceNameForError,
					tostring(err)
				)
			)
		end
	end
end

if wax.shared.SaveManager:GetState("EnableLogging", false) then
	local LogConnection = wax.shared.SetupLoggingConnection()
	wax.shared.LogConnection = wax.shared.Connect(wax.shared.Communicator.Event:Connect(LogConnection))
end

wax.shared.Log = require(script.Utils.Log)
wax.shared.Logs = {
	Outgoing = {},
	Incoming = {},
}

wax.shared.NewLog = function(Instance, Type, Method, CallingScript)
	local Log =
		wax.shared.Log.new(Instance, Type, Method, wax.shared.GetTableLength(wax.shared.Logs[Type]) + 1, CallingScript)
	wax.shared.Logs[Type][Instance] = Log
	return Log
end

require(script.Window)
require(script.Spy.Init)

wax.shared.Connect(wax.shared.LocalPlayer.OnTeleport:Connect(function()
	if not wax.shared.SaveManager:GetState("ExecuteOnTeleport", false) then
		return
	end

	-- getgenv().NOVA_LATEST_URL for dev environments
	local NovaURL = getgenv().NOVA_LATEST_URL
		or "https://github.com/DizzyUSER69/novaproject/releases/latest/download/Nova.luau"
	wax.shared.queue_on_teleport(string.format(
		[[
		if getgenv().NovaAutoExecuted then
			return
		end

		getgenv().NovaAutoExecuted = true
		loadstring(game:HttpGet("%s"))()
	]],
		NovaURL
	))
end))

task.wait(1)
if AnticheatData.Disabled then
	wax.shared.Sonner.success(`Nova has bypassed {AnticheatData.Name} (anticheat detected)`)
end

end)() end,
    function()local wax,script,require=ImportGlobals(2)local ImportGlobals return (function(...)--[[

	Very lightweight checks for various executor functions and reports whether they are working or not.
	Some checks also verify that the function works as intended, not just that it exists.

]]

local ExecutorSupport = {
	FailedChecks = {
		Essential = {},
		NonEssential = {},
	},
}

local BrokenFeatures = {
	["Volcano"] = { "oth", "run_on_actor" },
	["Seliware"] = { "run_on_actor" },
}

local function CheckFFlagValue(Name: string, Value: any)
	local Success, Result = pcall(getfflag, Name)
	if not Success then
		return false
	end

	if typeof(Result) == "boolean" then
		return Result
	end

	if typeof(Result) == "string" then
		return Result == tostring(Value)
	end

	return false
end

local function test(name, Callback, CheckType, Essential)
	local TestFunction = not CheckType and Callback or function()
		assert(typeof(Callback) == "function", string.format("%s is not a function.", name))
		return "Passed nil check."
	end

	if Essential == nil then
		Essential = true
	end

	local Success, Result
	if BrokenFeatures[wax.shared.ExecutorName] and table.find(BrokenFeatures[wax.shared.ExecutorName], name) then
		Success = false
		Result = "This function/library is broken or can crash your game on this executor."
	else
		Success, Result = pcall(TestFunction)
	end

	ExecutorSupport[name] = {
		IsWorking = Success,
		Details = Result,
		Essential = Essential,
	}

	if not Success then
		if Essential then
			table.insert(ExecutorSupport.FailedChecks.Essential, name)
		else
			table.insert(ExecutorSupport.FailedChecks.NonEssential, name)
		end
	end
end

-- FFlag Library
test("getfflag", getfflag, true)
test("setfflag", setfflag, true)

-- Actor Library
test("getactors", getactors, true)
test("run_on_actor", run_on_actor, true)
test("create_comm_channel", create_comm_channel, true)

-- Closure Library
test("newcclosure", function()
	assert(typeof(newcclosure) == "function", "newcclosure is not a function")
	local CClosure = newcclosure(function()
		return true
	end)

	assert(typeof(CClosure) == "function", "newcclosure did not return a function")
	assert(CClosure() == true, "Failed to create a new closure")

	assert(debug.info(CClosure, "s") == "[C]", "newcclosure did not create a C closure")
end, true)

test("checkcaller", checkcaller, true)
test("getcallingscript", getcallingscript, true)

test("hookfunction", function()
	assert(typeof(hookfunction) == "function", "hookfunction is not a function")

	local function Original(a, b)
		return a + b
	end

	local ref = hookfunction(Original, function(a, b)
		return a * b
	end)

	assert(Original(2, 3) == 6, "Failed to hook a function and change the return value")
	assert(ref(2, 3) == 5, "Did not return the original function")
end)
test("isfunctionhooked", function()
	assert(typeof(isfunctionhooked) == "function", "isfunctionhooked is not a function")
	assert(typeof(hookfunction) == "function", "hookfunction is required for this test")

	local function Original(a, b)
		return a + b
	end

	assert(isfunctionhooked(Original) == false, "isfunctionhooked returned true for an unhooked function")

	hookfunction(Original, function(a, b)
		return a * b
	end)

	assert(isfunctionhooked(Original) == true, "isfunctionhooked returned false for a hooked function")
end)
test("restorefunction", function()
	assert(typeof(restorefunction) == "function", "restorefunction is not a function")
	assert(typeof(hookfunction) == "function", "hookfunction is required for this test")

	local function Original(a, b)
		return a + b
	end

	hookfunction(Original, function(a, b)
		return a * b
	end)

	assert(Original(2, 3) == 6, "Failed to hook a function and change the return value")

	restorefunction(Original)

	assert(Original(2, 3) == 5, "restorefunction did not restore the original function")
end)

test("setstackhidden", function()
	assert(typeof(setstackhidden) == "function", "setstackhidden is not a function")

	local StackCheck = {}

	local CallerFunctionSource = [[
		local StackCheck = ...
		local function CallerFunction()
			return StackCheck[1]()
		end
		return CallerFunction
	]]

	local CallerFunction = (loadstring(CallerFunctionSource, "=CallerFunction") :: (...any) -> ...any)(StackCheck)

	setstackhidden(CallerFunction, true)

	StackCheck[1] = function()
		return debug.info(2, "f") ~= CallerFunction
	end

	local IsHidden = CallerFunction()
	assert(IsHidden == true, "setstackhidden did not hide the function from the stack (debug.info)")

	StackCheck[1] = function()
		return not debug.traceback():find("CallerFunction")
	end

	IsHidden = CallerFunction()
	assert(IsHidden == true, "setstackhidden did not hide the function from the stack (debug.traceback)")

	local TestTable = { math.huge, 0 / 0, 123, 58913 } :: { any }
	setfenv(CallerFunction, TestTable)

	StackCheck[1] = function()
		return getfenv(2) ~= TestTable
	end

	IsHidden = CallerFunction()
	assert(IsHidden == true, "setstackhidden did not hide the function from the stack (getfenv)")

	StackCheck[1] = function()
		return not select(2, pcall(error, "", 3)):find("CallerFunction")
	end

	IsHidden = CallerFunction()
	assert(IsHidden == true, "setstackhidden did not hide the function from the stack (error with level traceback)")
end, false, false)

-- Oth Library
test("oth", function()
	assert(oth ~= nil, "oth library not found")

	assert(typeof(oth.hook) == "function", "oth.hook is not a function")
	assert(hookfunction ~= oth.hook, "oth.hook is an alias of hookfunction")

	assert(typeof(oth.unhook) == "function", "oth.unhook is not a function")
	assert(restorefunction ~= oth.unhook, "oth.unhook is an alias of restorefunction")

	assert(typeof(oth.is_hook_thread) == "function", "oth.is_hook_thread is not a function")
	assert(typeof(oth.get_original_thread) == "function", "oth.get_original_thread is not a function")

	local VIM = Instance.new("VirtualInputManager")
	local Origin = coroutine.running()

	local Working = nil

	local Old
	Old = oth.hook(VIM.SendGravityEvent, function(...)
		if Working == nil then
			Working = (Origin ~= coroutine.running() and oth.is_hook_thread() and oth.get_original_thread() == Origin)
			return
		end

		return Old(...)
	end)

	pcall(VIM.SendGravityEvent, VIM, 0, 0, 0)

	repeat
		task.wait()
	until Working ~= nil
	local Success, Error = pcall(oth.unhook, VIM.SendGravityEvent, Old)

	VIM:Destroy()

	assert(Working, "oth.hook is not running on a seperate thread")
	assert(Success, "oth.unhook failed: " .. tostring(Error))
end, false, false)

-- Metamethod
test("hookmetamethod", function()
	assert(typeof(hookmetamethod) == "function", "hookmetamethod is not a function")

	local object = setmetatable({}, {
		__index = newcclosure(function()
			return false
		end),
		__metatable = "Locked!",
	})

	local ref = hookmetamethod(object, "__index", function()
		return true
	end)

	assert(object.test == true, "Failed to hook a metamethod and change the return value")
	assert(ref() == false, "Did not return the original function")
end)
test("getnamecallmethod", function()
	assert(typeof(getnamecallmethod) == "function", "getnamecallmethod is not a function")

	pcall(function()
		game:TEST_NAMECALL_METHOD()
	end)

	assert(getnamecallmethod() == "TEST_NAMECALL_METHOD", "getnamecallmethod did not return the real namecall method")
end)
test("getrawmetatable", function()
	assert(typeof(getrawmetatable) == "function", "getrawmetatable is not a function")

	local BaseLockedMetatable = {
		__index = function()
			return false
		end,
		__metatable = "Locked!",
	}

	local TestMetatable = setmetatable({}, BaseLockedMetatable)

	local FetchedMetatable = getrawmetatable(TestMetatable)
	assert(typeof(FetchedMetatable) == "table", "getrawmetatable did not return a table")

	assert(FetchedMetatable.__index() == false, "getrawmetatable did not return the correct metatable [__index()]")
	assert(
		FetchedMetatable.__metatable == "Locked!",
		"getrawmetatable did not return the correct metatable [locked mt check]"
	)

	assert(
		FetchedMetatable == BaseLockedMetatable,
		"getrawmetatable did not return the correct metatable [mt eq check]"
	)
end)

-- Instance Library
test("getcallbackvalue", function()
	assert(typeof(getcallbackvalue) == "function", "getcallbackvalue is not a function")

	local bindable = Instance.new("BindableFunction")
	local InvokeFunction = function(value)
		return value * 2
	end
	bindable.OnInvoke = InvokeFunction

	local FetchedInvoke = getcallbackvalue(bindable, "OnInvoke")
	bindable:Destroy()

	assert(typeof(FetchedInvoke) == "function", "getcallbackvalue did not return a function")

	assert(FetchedInvoke(5) == 10, "getcallbackvalue's function return did not match expected value")
	assert(FetchedInvoke == InvokeFunction, "getcallbackvalue did not return the original function")

	local success, didNoValueReturnNil = pcall(function() 
		local remoteFunction = Instance.new("RemoteFunction")
		task.delay(1, remoteFunction.Destroy, remoteFunction)
		return getcallbackvalue(remoteFunction, "OnClientInvoke") == nil
	end)

	assert(success and didNoValueReturnNil, "getcallbackvalue raised an error instead of returning nil, the function is not supposed to raise an error when there is no callback.")
end)
test("getnilinstances", function()
	assert(typeof(getnilinstances) == "function", "getnilinstances is not a function")

	local NilInstances = getnilinstances()
	assert(typeof(NilInstances) == "table", "getnilinstances did not return a table")
end)
test("getconnections", function()
	assert(typeof(getconnections) == "function", "getconnections is not a function")

	local Event = Instance.new("BindableEvent")
	local ConnectionFunction = function() end
	local OnceFunction = function() end

	Event.Event:Connect(ConnectionFunction)
	Event.Event:Once(OnceFunction)
	task.spawn(function()
		Event.Event:Wait()
	end)

	local Connections = getconnections(Event.Event)

	assert(typeof(Connections) == "table", "getconnections did not return a table")
	assert(#Connections == 3, "getconnections did not return the correct number of connections")

	local FoundFunctions = {}
	for _, Connection in Connections do
		local _, ConnFunc = pcall(function()
			return Connection.Function
		end)

		if typeof(ConnFunc) == "function" then
			table.insert(FoundFunctions, ConnFunc)
		end
	end

	assert(
		table.find(FoundFunctions, ConnectionFunction) ~= nil,
		"getconnections did not return the correct connection [:Connect()]"
	)
	assert(
		table.find(FoundFunctions, OnceFunction) ~= nil,
		"getconnections did not return the correct connection [:Once()]"
	)

	Event:Destroy()
end)
test("firesignal", function()
	assert(typeof(firesignal) == "function", "firesignal is not a function")

	local event = Instance.new("BindableEvent")
	local fired = false

	event.Event:Once(function(value)
		fired = value
	end)

	firesignal(event.Event, true)
	task.wait(0.1)
	event:Destroy()

	assert(fired, "Failed to fire a BindableEvent")
end)
test("cloneref", function()
	assert(typeof(cloneref) == "function", "cloneref is not a function")

	local ref = cloneref(game)
	assert(ref ~= game, "cloneref did not create a ref to instance")
	assert(typeof(ref) == "Instance", "cloneref did not return an instance")
end)
test("compareinstances", function()
	assert(typeof(compareinstances) == "function", "compareinstances is not a function")
	assert(typeof(cloneref) == "function", "cloneref is required for this test")

	assert(compareinstances(game, cloneref(game)) == true, "compareinstances did not return true for the same instance")
	assert(compareinstances(game, workspace) == false, "compareinstances did not return false for different instances")
end)

if CheckFFlagValue("DebugRunParallelLuaOnMainThread", false) and not ExecutorSupport["run_on_actor"].IsWorking then
	task.spawn(function()
		if not game:IsLoaded() then
			game.Loaded:Wait()
		end

		local GameUsesActors = false

		local CategoryToSearch = { game:QueryDescendants("Actor") }
		if ExecutorSupport["getnilinstances"].IsWorking then
			table.insert(CategoryToSearch, getnilinstances())
		end

		for _, Category in CategoryToSearch do
			if GameUsesActors then
				break
			end

			for _, Instance in Category do
				if not Instance:IsA("Actor") then
					continue
				end

				GameUsesActors = true
				break
			end
		end

		if not GameUsesActors then
			return
		end

		local bindable = Instance.new("BindableFunction")

		function bindable.OnInvoke(response)
			if response == "Enable Fix" then
				setfflag("DebugRunParallelLuaOnMainThread", "true")
				wax.shared.StarterGui:SetCore("SendNotification", {
					Title = "Nova",
					Text = "Please rejoin for the fix to take effect!",
					Duration = math.huge,
				})
			end

			bindable:Destroy()
		end

		wax.shared.StarterGui:SetCore("SendNotification", {
			Title = "Nova",
			Text = "This game may use remotes in a way that your executor can't intercept. You can enable the fix and rejoin to detect them.",
			Duration = math.huge,
			Callback = bindable,
			Button1 = "Enable Fix",
			Button2 = "Dismiss",
		})
	end)
end

return ExecutorSupport

end)() end,
    [17] = function()local wax,script,require=ImportGlobals(17)local ImportGlobals return (function(...)--[[
    Bypasses for popular roblox anticheats
]]

local AnticheatData = {
	Disabled = false,
	Name = "N/A",
}

local BypassEnabled = wax.shared.SaveManager:GetState("AnticheatBypass", true)
if not BypassEnabled then
	return AnticheatData
end

type Bypass = {
	Name: string,
	Game: string | number | { number } | { string },
	Detect: () -> boolean,
	Bypass: () -> boolean,
}

local GeneralPurposeBypasses: { Bypass } = {}
local DedicatedPlaceACBypass: Bypass = nil

local AnticheatBypasses = script.Parent.impl
for _, Anticheat in AnticheatBypasses:GetChildren() do
	local Data = require(Anticheat) :: Bypass

	local IsDedicatedACBypass = (
		if typeof(Data.Game) == "table"
			then (table.find(Data.Game, game.PlaceId) or table.find(Data.Game, tostring(game.PlaceId)))
			else (tostring(Data.Game) == tostring(game.PlaceId))
	)

	if IsDedicatedACBypass then
		DedicatedPlaceACBypass = Data
		break
	end

	if Data.Game ~= "*" then
		continue
	end

	table.insert(GeneralPurposeBypasses, Data)
end

if DedicatedPlaceACBypass and DedicatedPlaceACBypass.Detect() then
	DedicatedPlaceACBypass.Bypass()

	AnticheatData.Name = DedicatedPlaceACBypass.Name
	AnticheatData.Disabled = true
	return AnticheatData
end

for _, Data in GeneralPurposeBypasses do
	if not Data.Detect() then
		continue
	end

	if Data.Bypass() then
		AnticheatData.Name = Data.Name
		AnticheatData.Disabled = true
		break
	end
end

return AnticheatData

end)() end,
    [40] = function()local wax,script,require=ImportGlobals(40)local ImportGlobals return (function(...)local ImageFetcher = {
	FallbackMapping = {
		Logo = "rbxassetid://91685317120520",
	},
}

if not isfolder("Nova/Assets") then
	makefolder("Nova/Assets")
end

function SafeFetchCustomContentID(Path: string)
	local Success, Result = pcall(function()
		return getcustomasset(Path)
	end)

	return Success and Result or nil
end

function SafeFetchCustomImgData(url)
	local Success, Response = pcall(request, {
		Url = url,
		Method = "GET",
	})

	if Success and Response.Success or Response.StatusCode >= 200 and Response.StatusCode < 300 then
		return Response.Body
	end

	return nil
end

function ImageFetcher.GetRemoteImages(Images: { [string]: string })
	if not getcustomasset then
		return Images
	end

	local NewImages = {}
	for ClassName, Image in Images do
		if isfile(`Nova/Assets/{ClassName}.png`) then
			NewImages[ClassName] = SafeFetchCustomContentID(`Nova/Assets/{ClassName}.png`) or Image
			continue
		end

		local IconRawData = SafeFetchCustomImgData(`https://robloxapi.github.io/ref/icons/dark/{ClassName}.png`)
		if not IconRawData then
			NewImages[ClassName] = Image
			continue
		end

		writefile(
			`Nova/Assets/{ClassName}.png`,
			IconRawData
		)

		NewImages[ClassName] = SafeFetchCustomContentID(`Nova/Assets/{ClassName}.png`) or Image
	end

	return NewImages
end

function ImageFetcher.GetImage(Image: string)
	if not getcustomasset then
		return ImageFetcher.FallbackMapping[Image] or Image
	end

	if isfile(`Nova/Assets/{Image}.png`) then
		return SafeFetchCustomContentID(`Nova/Assets/{Image}.png`) or ImageFetcher.FallbackMapping[Image] or Image
	end

	local IconRawData = SafeFetchCustomImgData(`https://raw.githubusercontent.com/DizzyUSER69/novaproject/main/nova_project/Assets/{Image}.png`)

	if not IconRawData then
		return ImageFetcher.FallbackMapping[Image] or Image
	end

	writefile(`Nova/Assets/{Image}.png`, IconRawData)
	return SafeFetchCustomContentID(`Nova/Assets/{Image}.png`) or ImageFetcher.FallbackMapping[Image] or Image
end

return ImageFetcher

end)() end,
    [21] = function()error("[AOT COMPILER ERROR] Expected ')' (to close '(' at line 475), got ']'")end,
    [39] = function()local wax,script,require=ImportGlobals(39)local ImportGlobals return (function(...)local Icons = {}

type Icon = {
	Url: string,
	Id: number,
	IconName: string,
	ImageRectOffset: Vector2,
	ImageRectSize: Vector2,
}

local Success, IconsModule = pcall(function()
	local IconFetchSuccess, IconModuleSource = pcall(request, {
		Url = "https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua",
		Method = "GET",
	})

	assert(
		IconFetchSuccess and IconModuleSource.Success or IconModuleSource.StatusCode >= 200 and IconModuleSource.StatusCode < 300,
		"Failed to fetch lucide icons direct module source"
	)
	return (loadstring(IconModuleSource.Body) :: () -> { Icons: { string }, GetAsset: (Name: string) -> Icon? })()
end)

function Icons.GetIcon(iconName: string): Icon?
	if not Success then
		return
	end

	local Success, Icon = pcall(IconsModule.GetAsset, iconName)
	if not Success then
		return
	end

	return Icon
end

function Icons.SetIcon(imageInstance: ImageLabel, iconName: string)
	local Icon: Icon? = Icons.GetIcon(iconName)
	if not Icon then
		return
	end

	imageInstance.Image = Icon.Url
	imageInstance.ImageRectOffset = Icon.ImageRectOffset
	imageInstance.ImageRectSize = Icon.ImageRectSize
end

return Icons

end)() end,
    [36] = function()local wax,script,require=ImportGlobals(36)local ImportGlobals return (function(...)--[[
	Enhanced Modal Component for Nova
	Improved modal with smooth animations and better UX
]]

local Constants = require(script.Parent.Constants)
local Interface = require(script.Parent.Interface)

local EnhancedModal = {}

type ModalConfig = {
	Title: string,
	Icon: string?,
	Size: UDim2?,
	MinSize: UDim2?,
	MaxSize: UDim2?,
	Resizable: boolean?,
	Parent: Instance,
}

function EnhancedModal.Create(config: ModalConfig)
	local modal = {}
	
	-- Background overlay
	local overlay = Interface.New("TextButton", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		Visible = false,
		ZIndex = 1000,
		Parent = config.Parent,
	})
	
	-- Modal container
	local container = Interface.New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Constants.Colors.Background.Secondary,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = config.Size or UDim2.fromScale(0.6, 0.7),
		ZIndex = 1001,
		Visible = false,
		Parent = config.Parent,
		
		["UICorner"] = {
			CornerRadius = Constants.CornerRadius.Medium,
		},
		
		["UIStroke"] = {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Constants.Colors.Border.Primary,
			Thickness = Constants.StrokeThickness.Thin,
		},
	})
	
	-- Title bar
	local titleBar = Interface.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 36),
		Parent = container,
		
		["UIPadding"] = {
			PaddingLeft = Constants.Padding.Medium,
			PaddingRight = Constants.Padding.Medium,
			PaddingTop = Constants.Padding.Medium,
			PaddingBottom = Constants.Padding.Medium,
		},
	})
	
	-- Title text
	local titleText = Interface.New("TextLabel", {
		Text = config.Title,
		TextSize = Constants.TextSize.Large,
		TextColor3 = Constants.Colors.Text.Primary,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -60, 1, 0),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = titleBar,
	})
	
	-- Icon (if provided)
	if config.Icon then
		local Icons = require(script.Parent.Icons)
		if config.Icon:match("rbxasset") then
			Interface.New("ImageLabel", {
				Image = config.Icon,
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromOffset(4, 0),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = 1,
				Parent = titleBar,
			})
		else
			Interface.NewIcon(config.Icon, {
				ImageTransparency = 0.5,
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromOffset(4, 0),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Parent = titleBar,
			})
		end
	end
	
	-- Close button
	local closeButton = Interface.New("ImageButton", {
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		BackgroundTransparency = 1,
		Parent = titleBar,
	})
	
	local closeIcon = Interface.NewIcon("x", {
		ImageTransparency = 0.5,
		Size = UDim2.fromOffset(22, 22),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Parent = closeButton,
	})
	
	-- Close button hover effects
	closeButton.MouseEnter:Connect(function()
		wax.shared.TweenService:Create(
			closeIcon,
			Constants.TweenInfo.Default,
			{ ImageTransparency = 0.25 }
		):Play()
	end)
	
	closeButton.MouseLeave:Connect(function()
		wax.shared.TweenService:Create(
			closeIcon,
			Constants.TweenInfo.Default,
			{ ImageTransparency = 0.5 }
		):Play()
	end)
	
	-- Separator line
	Interface.New("Frame", {
		Parent = container,
		BackgroundColor3 = Constants.Colors.Border.Primary,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.fromOffset(0, 36),
	})
	
	-- Content area
	local content = Interface.New("ScrollingFrame", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 1, -37),
		ClipsDescendants = true,
		ScrollBarThickness = 2,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromScale(0, 0),
		Parent = container,
		
		["UIPadding"] = {
			PaddingLeft = Constants.Padding.Large,
			PaddingRight = Constants.Padding.Large,
			PaddingTop = Constants.Padding.Large,
			PaddingBottom = Constants.Padding.Large,
		},
	})
	
	-- Modal methods
	function modal:Open()
		overlay.Visible = true
		container.Visible = true
		
		-- Fade in overlay
		wax.shared.TweenService:Create(
			overlay,
			Constants.TweenInfo.Default,
			{ BackgroundTransparency = 0.5 }
		):Play()
		
		-- Scale in container
		container.Size = UDim2.fromScale(0, 0)
		wax.shared.TweenService:Create(
			container,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Size = config.Size or UDim2.fromScale(0.6, 0.7) }
		):Play()
	end
	
	function modal:Close()
		-- Fade out overlay
		local overlayTween = wax.shared.TweenService:Create(
			overlay,
			Constants.TweenInfo.Default,
			{ BackgroundTransparency = 1 }
		)
		
		-- Scale out container
		local containerTween = wax.shared.TweenService:Create(
			container,
			TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In),
			{ Size = UDim2.fromScale(0, 0) }
		)
		
		overlayTween:Play()
		containerTween:Play()
		
		containerTween.Completed:Connect(function()
			overlay.Visible = false
			container.Visible = false
		end)
	end
	
	function modal:GetContent()
		return content
	end
	
	function modal:SetTitle(newTitle: string)
		titleText.Text = newTitle
	end
	
	-- Connect close button
	closeButton.MouseButton1Click:Connect(function()
		modal:Close()
	end)
	
	-- Connect overlay click to close
	overlay.MouseButton1Click:Connect(function()
		modal:Close()
	end)
	
	modal.Container = container
	modal.Content = content
	modal.Overlay = overlay
	
	return modal
end

return EnhancedModal

end)() end,
    [28] = function()local wax,script,require=ImportGlobals(28)local ImportGlobals return (function(...)--[[

Pagination Module
made by deivid and turned into module by upio

]]

local Pagination = {}
Pagination.__index = Pagination

function Pagination.new(Options: {
	TotalItems: number,
	ItemsPerPage: number,
	CurrentPage: number?,
	SiblingCount: number?,
})
	return setmetatable({
		TotalItems = Options.TotalItems,
		ItemsPerPage = Options.ItemsPerPage,
		CurrentPage = Options.CurrentPage or 1,
		SiblingCount = Options.SiblingCount or 2,
	}, Pagination)
end

function Pagination:GetInfo()
	local TotalPages = math.ceil(self.TotalItems / self.ItemsPerPage)

	return {
		TotalItems = self.TotalItems,
		ItemsPerPage = self.ItemsPerPage,
		CurrentPage = self.CurrentPage,
		TotalPages = TotalPages,
	}
end

function Pagination:SetItemsPerPage(max: number)
	self.ItemsPerPage = max
end

function Pagination:GetIndexRanges(Page: number?)
	Page = Page or self.CurrentPage

	local TotalPages = math.ceil(self.TotalItems / self.ItemsPerPage)
	if TotalPages == 0 then
		return 1, 0
	end
	assert(
		Page <= TotalPages,
		"Attempted to get invalid page out of range, got " .. Page .. " but max is " .. TotalPages
	)

	local Start = (((Page or self.CurrentPage) - 1) * self.ItemsPerPage) + 1
	local End = Start + (self.ItemsPerPage - 1)

	return Start, End
end

function Pagination:SetPage(Page: number)
	local TotalPages = math.ceil(self.TotalItems / self.ItemsPerPage)
	if TotalPages == 0 then
		self.CurrentPage = 1
		return
	end
	assert(Page <= TotalPages, "Attempted to set page out of range, got " .. Page .. " but max is " .. TotalPages)

	self.CurrentPage = Page
end

function Pagination:Update(TotalItems: number?, ItemsPerPage: number?)
	self.TotalItems = TotalItems or self.TotalItems
	self.ItemsPerPage = ItemsPerPage or self.ItemsPerPage
end

function Pagination:GetVisualInfo(Page: number?)
	Page = Page or self.CurrentPage

	local TotalPages = math.ceil(self.TotalItems / self.ItemsPerPage)
	if TotalPages == 0 then
		return {}
	end

	assert(
		Page <= TotalPages,
		"Attempted to get invalid page out of range, got " .. Page .. " but max is " .. TotalPages
	)

	local MaxButtons = 5 + self.SiblingCount * 2
	local Result = table.create(MaxButtons, "none")
	if TotalPages <= MaxButtons then
		for i = 1, TotalPages do
			Result[i] = i
		end
		return Result
	end

	local LeftSibling = math.max(Page - self.SiblingCount, 1)
	local RightSibling = math.min(Page + self.SiblingCount, TotalPages)

	local FakeLeft = LeftSibling > 2
	local FakeRight = RightSibling < TotalPages - 1

	local TotalPageNumbers = math.min(2 * self.SiblingCount + 5, TotalPages)
	local ItemCount = TotalPageNumbers - 2

	if not FakeLeft and FakeRight then
		for i = 1, ItemCount do
			Result[i] = i
		end
		Result[ItemCount + 1] = "ellipsis"
		Result[ItemCount + 2] = TotalPages
		--return MergeTables(LeftRange, "ellipsis", TotalPages)
		return Result
	elseif FakeLeft and not FakeRight then
		--local RightRange = CreateArray(TotalPages - ItemCount + 1, TotalPages)
		Result[1] = 1
		Result[2] = "ellipsis"

		local Index = 3
		for i = TotalPages - ItemCount + 1, TotalPages do
			Result[Index] = i
			Index += 1
		end

		return Result
	elseif FakeLeft and FakeRight then
		--local MiddleRange = CreateArray(LeftSibling, RightSibling)
		Result[1] = 1
		Result[2] = "ellipsis"
		local Index = 3

		for i = LeftSibling, RightSibling do
			Result[Index] = i
			Index += 1
		end

		Result[Index] = "ellipsis"
		Result[Index + 1] = TotalPages

		return Result
		--return MergeTables(1, "ellipsis", MiddleRange, "ellipsis", TotalPages)
	end

	--return CreateArray(1, TotalPages)
	for i = 1, TotalPages do
		Result[i] = i
	end
	return Result
end

return Pagination

end)() end,
    [44] = function()local wax,script,require=ImportGlobals(44)local ImportGlobals return (function(...)local Resize = {}
Resize.__index = Resize

local Interface = require(script.Parent.Interface)
local Drag = require(script.Parent.Drag)

local HANDLE_SIZE = 6
local CORNER_HANDLE_SIZE = 20

function Resize.new(Options: {
	MainFrame: Frame,
	MinimumSize: Vector2? | UDim2?,
	MaximumSize: UDim2?,
	HandleSize: number?,
	CornerHandleSize: number?,
	Mirrored: boolean?,
	LockedPosition: boolean? | UDim2?,
})
	local MainFrame = Options.MainFrame
	local HandleSize = Options.HandleSize or HANDLE_SIZE
	local CornerHandleSize = Options.CornerHandleSize or CORNER_HANDLE_SIZE
	local Mirrored = Options.Mirrored or false
	local LockedPosition = Options.LockedPosition

	local MinimumSize
	if typeof(Options.MinimumSize) == "Vector2" then
		MinimumSize = UDim2.fromOffset(Options.MinimumSize.X, Options.MinimumSize.Y)
	elseif typeof(Options.MinimumSize) == "UDim2" then
		MinimumSize = Options.MinimumSize
	else
		MinimumSize = UDim2.fromOffset(100, 100)
	end

	local MaximumSize = Options.MaximumSize

	local self = setmetatable({
		MainFrame = MainFrame,
		ScreenGui = MainFrame:FindFirstAncestorOfClass("ScreenGui"),
		Parent = MainFrame.Parent,
	}, Resize)

	local function CalculateResizeProperties(
		initialFramePosition: UDim2,
		initialFrameSize: UDim2,
		mouseDelta: Vector2,
		resizeTypeX: string?,
		resizeTypeY: string?
	)
		if Mirrored then
			local parentAbsSize = self.Parent.AbsoluteSize

			local newSizeOffsetX = initialFrameSize.X.Offset
			local newSizeOffsetY = initialFrameSize.Y.Offset

			if resizeTypeX then
				local deltaX = 0
				if resizeTypeX == "Right" then
					deltaX = 2 * mouseDelta.X
				elseif resizeTypeX == "Left" then
					deltaX = -2 * mouseDelta.X
				end
				newSizeOffsetX = initialFrameSize.X.Offset + deltaX

				local minWidthAbs = MinimumSize.X.Scale * parentAbsSize.X + MinimumSize.X.Offset
				local maxWidthAbs = (MaximumSize and (MaximumSize.X.Scale * parentAbsSize.X + MaximumSize.X.Offset))
					or math.huge
				local scaleContributionX = initialFrameSize.X.Scale * parentAbsSize.X
				local minAllowedTotalOffsetX = minWidthAbs - scaleContributionX
				local maxAllowedTotalOffsetX = maxWidthAbs - scaleContributionX
				newSizeOffsetX = math.clamp(newSizeOffsetX, minAllowedTotalOffsetX, maxAllowedTotalOffsetX)
			end

			if resizeTypeY then
				local deltaY = 0
				if resizeTypeY == "Bottom" then
					deltaY = 2 * mouseDelta.Y
				elseif resizeTypeY == "Top" then
					deltaY = -2 * mouseDelta.Y
				end
				newSizeOffsetY = initialFrameSize.Y.Offset + deltaY

				local minHeightAbs = MinimumSize.Y.Scale * parentAbsSize.Y + MinimumSize.Y.Offset
				local maxHeightAbs = (MaximumSize and (MaximumSize.Y.Scale * parentAbsSize.Y + MaximumSize.Y.Offset))
					or math.huge
				local scaleContributionY = initialFrameSize.Y.Scale * parentAbsSize.Y
				local minAllowedTotalOffsetY = minHeightAbs - scaleContributionY
				local maxAllowedTotalOffsetY = maxHeightAbs - scaleContributionY
				newSizeOffsetY = math.clamp(newSizeOffsetY, minAllowedTotalOffsetY, maxAllowedTotalOffsetY)
			end

			local finalNewSize =
				UDim2.new(initialFrameSize.X.Scale, newSizeOffsetX, initialFrameSize.Y.Scale, newSizeOffsetY)
			local finalNewPosition = initialFramePosition
			if typeof(LockedPosition) == "UDim2" then
				finalNewPosition = LockedPosition
			end
			return finalNewSize, finalNewPosition
		else
			-- Non-mirrored logic
			local currentScreenGuiAbsSize = self.ScreenGui.AbsoluteSize
			local parentAbsSizeForMinMax = currentScreenGuiAbsSize -- As per original non-mirrored logic for min/max context

			-- These will store the final UDim offset values for position and the absolute pixel values for size calculation
			local finalPosOffsetX = initialFramePosition.X.Offset
			local finalPosOffsetY = initialFramePosition.Y.Offset

			-- Initial absolute pixel size of the frame
			local initialAbsWidthPx = initialFrameSize.X.Scale * self.Parent.AbsoluteSize.X + initialFrameSize.X.Offset
			local initialAbsHeightPx = initialFrameSize.Y.Scale * self.Parent.AbsoluteSize.Y + initialFrameSize.Y.Offset

			local newAbsWidthPx = initialAbsWidthPx
			local newAbsHeightPx = initialAbsHeightPx

			-- Min/max pixel dimensions
			local minWidthPx = MinimumSize.X.Scale * parentAbsSizeForMinMax.X + MinimumSize.X.Offset
			local minHeightPx = MinimumSize.Y.Scale * parentAbsSizeForMinMax.Y + MinimumSize.Y.Offset
			local maxWidthPx = MaximumSize and (MaximumSize.X.Scale * parentAbsSizeForMinMax.X + MaximumSize.X.Offset)
				or math.huge
			local maxHeightPx = MaximumSize and (MaximumSize.Y.Scale * parentAbsSizeForMinMax.Y + MaximumSize.Y.Offset)
				or math.huge

			-- Original edge calculation logic (assuming MainFrame.Position is center if AnchorPoint is 0.5,0.5 for these calcs)
			local initialAbsCenterX = currentScreenGuiAbsSize.X * initialFramePosition.X.Scale
				+ initialFramePosition.X.Offset
			local initialAbsSizeX_forEdgeCalc = initialFrameSize.X.Offset -- Original code used offset for this part of edge calculation
			local initialRightEdgeX = initialAbsCenterX + initialAbsSizeX_forEdgeCalc / 2
			local initialLeftEdgeX = initialAbsCenterX - initialAbsSizeX_forEdgeCalc / 2

			local initialAbsCenterY = currentScreenGuiAbsSize.Y * initialFramePosition.Y.Scale
				+ initialFramePosition.Y.Offset
			local initialAbsSizeY_forEdgeCalc = initialFrameSize.Y.Offset -- Original code used offset for this part of edge calculation
			local initialBottomEdgeY = initialAbsCenterY + initialAbsSizeY_forEdgeCalc / 2
			local initialTopEdgeY = initialAbsCenterY - initialAbsSizeY_forEdgeCalc / 2

			if resizeTypeX then
				if resizeTypeX == "Left" then
					local newLeftEdge = initialLeftEdgeX + mouseDelta.X
					newAbsWidthPx = math.clamp(initialRightEdgeX - newLeftEdge, minWidthPx, maxWidthPx)
					if newAbsWidthPx ~= (initialRightEdgeX - newLeftEdge) then -- Readjust edge if clamped
						newLeftEdge = initialRightEdgeX - newAbsWidthPx
					end
					if not LockedPosition then
						local newAbsCenterX = newLeftEdge + newAbsWidthPx / 2 -- Assuming center is halfway for position update
						finalPosOffsetX = newAbsCenterX - currentScreenGuiAbsSize.X * initialFramePosition.X.Scale
					end
				elseif resizeTypeX == "Right" then
					local newRightEdge = initialRightEdgeX + mouseDelta.X
					newAbsWidthPx = math.clamp(newRightEdge - initialLeftEdgeX, minWidthPx, maxWidthPx)
					if not LockedPosition then
						local newAbsCenterX = initialLeftEdgeX + newAbsWidthPx / 2 -- Assuming center is halfway
						finalPosOffsetX = newAbsCenterX - currentScreenGuiAbsSize.X * initialFramePosition.X.Scale
					end
				end
			end

			if resizeTypeY then
				if resizeTypeY == "Top" then
					local newTopEdge = initialTopEdgeY + mouseDelta.Y
					newAbsHeightPx = math.clamp(initialBottomEdgeY - newTopEdge, minHeightPx, maxHeightPx)
					if newAbsHeightPx ~= (initialBottomEdgeY - newTopEdge) then -- Readjust edge if clamped
						newTopEdge = initialBottomEdgeY - newAbsHeightPx
					end
					if not LockedPosition then
						local newAbsCenterY = newTopEdge + newAbsHeightPx / 2 -- Assuming center is halfway
						finalPosOffsetY = newAbsCenterY - currentScreenGuiAbsSize.Y * initialFramePosition.Y.Scale
					end
				elseif resizeTypeY == "Bottom" then
					local newBottomEdge = initialBottomEdgeY + mouseDelta.Y
					newAbsHeightPx = math.clamp(newBottomEdge - initialTopEdgeY, minHeightPx, maxHeightPx)
					if not LockedPosition then
						local newAbsCenterY = initialTopEdgeY + newAbsHeightPx / 2 -- Assuming center is halfway
						finalPosOffsetY = newAbsCenterY - currentScreenGuiAbsSize.Y * initialFramePosition.Y.Scale
					end
				end
			end

			-- Convert final absolute pixel dimensions back to UDim offsets for size
			local finalSizeOffsetX = newAbsWidthPx - (initialFrameSize.X.Scale * self.Parent.AbsoluteSize.X)
			local finalSizeOffsetY = newAbsHeightPx - (initialFrameSize.Y.Scale * self.Parent.AbsoluteSize.Y)

			local finalNewSize =
				UDim2.new(initialFrameSize.X.Scale, finalSizeOffsetX, initialFrameSize.Y.Scale, finalSizeOffsetY)
			local finalNewPosition = initialFramePosition -- Default if LockedPosition is true
			if typeof(LockedPosition) == "UDim2" then
				finalNewPosition = LockedPosition
			elseif not LockedPosition then -- Only update if not locked (boolean false)
				finalNewPosition = UDim2.new(
					initialFramePosition.X.Scale,
					finalPosOffsetX,
					initialFramePosition.Y.Scale,
					finalPosOffsetY
				)
			end
			return finalNewSize, finalNewPosition
		end
	end

	local function createDragHandler(resizeTypeX, resizeTypeY)
		return function(Info, Input: InputObject)
			local mouseDelta = Input.Position - Info.StartPosition
			if wax.shared.GetDPIScale then
				mouseDelta = mouseDelta / wax.shared.GetDPIScale()
			end
			
			local newSize, newPosition =
				CalculateResizeProperties(Info.FramePosition, Info.FrameSize, mouseDelta, resizeTypeX, resizeTypeY)

			MainFrame.Size = newSize
			MainFrame.Position = newPosition
		end
	end

	local LeftSide = Interface.New("Frame", {
		Size = UDim2.new(0, HandleSize, 1, -CornerHandleSize * 2),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		BackgroundTransparency = 1,
		Parent = MainFrame,
		ZIndex = 9e6,
	})
	Drag.Setup(MainFrame, LeftSide, createDragHandler("Left", nil))

	local RightSide = Interface.New("Frame", {
		Size = UDim2.new(0, HandleSize, 1, -CornerHandleSize * 2),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		BackgroundTransparency = 1,
		Parent = MainFrame,
		ZIndex = 9e6,
	})
	Drag.Setup(MainFrame, RightSide, createDragHandler("Right", nil))

	local TopSide = Interface.New("Frame", {
		Size = UDim2.new(1, -CornerHandleSize * 2, 0, HandleSize),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		BackgroundTransparency = 1,
		Parent = MainFrame,
		ZIndex = 9e6,
	})
	Drag.Setup(MainFrame, TopSide, createDragHandler(nil, "Top"))

	local BottomSide = Interface.New("Frame", {
		Size = UDim2.new(1, -CornerHandleSize * 2, 0, HandleSize),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		BackgroundTransparency = 1,
		Parent = MainFrame,
		ZIndex = 9e6,
	})
	Drag.Setup(MainFrame, BottomSide, createDragHandler(nil, "Bottom"))

	local TopLeftCorner = Interface.New("Frame", {
		Size = UDim2.fromOffset(CornerHandleSize, CornerHandleSize),
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromScale(0, 0),
		BackgroundTransparency = 1,
		Parent = MainFrame,
		ZIndex = 9e6 + 1,
	})
	Drag.Setup(MainFrame, TopLeftCorner, createDragHandler("Left", "Top"))

	local TopRightCorner = Interface.New("Frame", {
		Size = UDim2.fromOffset(CornerHandleSize, CornerHandleSize),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		BackgroundTransparency = 1,
		Parent = MainFrame,
		ZIndex = 9e6 + 1,
	})
	Drag.Setup(MainFrame, TopRightCorner, createDragHandler("Right", "Top"))

	local BottomLeftCorner = Interface.New("Frame", {
		Size = UDim2.fromOffset(CornerHandleSize, CornerHandleSize),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		BackgroundTransparency = 1,
		Parent = MainFrame,
		ZIndex = 9e6 + 1,
	})
	Drag.Setup(MainFrame, BottomLeftCorner, createDragHandler("Left", "Bottom"))

	local BottomRightCorner = Interface.New("Frame", {
		Size = UDim2.fromOffset(CornerHandleSize, CornerHandleSize),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = MainFrame,
		ZIndex = 9e6 + 1,
	})
	Drag.Setup(MainFrame, BottomRightCorner, createDragHandler("Right", "Bottom"))

	return self
end

return Resize

end)() end,
    [35] = function()local wax,script,require=ImportGlobals(35)local ImportGlobals return (function(...)local Drag = {
	Dragging = false,
	Frame = nil,
	FramePosition = nil,
	FrameSize = nil, -- Added to store initial frame size
	StartPosition = nil,
	ChangedConnection = nil,
	Callback = nil,
}

local Helper = require(script.Parent.Helper)

local function DefaultCallback(_, Input: InputObject)
	local Delta = Input.Position - Drag.StartPosition
	local FramePosition: UDim2 = Drag.FramePosition

	if wax.shared.GetDPIScale then
		Delta = Delta / wax.shared.GetDPIScale()
	end

	Drag.Frame.Position = UDim2.new(
		FramePosition.X.Scale,
		FramePosition.X.Offset + Delta.X,
		FramePosition.Y.Scale,
		FramePosition.Y.Offset + Delta.Y
	)
end

function Drag.Setup(Frame: GuiObject, DragFrame: GuiObject, Callback: (Info: {}, Input: InputObject) -> () | nil)
	Callback = Callback or DefaultCallback

	DragFrame.InputBegan:Connect(function(Input: InputObject)
		if not Helper.IsClickInput(Input) then
			return
		end

		Drag.Dragging = true
		Drag.Frame = Frame
		Drag.FramePosition = Frame.Position
		Drag.StartPosition = Input.Position
		Drag.FrameSize = Frame.Size
		Drag.Callback = Callback

		Drag.ChangedConnection = Input.Changed:Connect(function()
			if Input.UserInputState ~= Enum.UserInputState.End then
				return
			end

			Drag.Dragging = false
			Drag.Frame = nil
			Drag.Callback = nil

			if Drag.ChangedConnection and Drag.ChangedConnection.Connected then
				Drag.ChangedConnection:Disconnect()
				Drag.ChangedConnection = nil
			end
		end)
	end)
end

wax.shared.Connect(wax.shared.UserInputService.InputChanged:Connect(function(Input: InputObject)
	if Drag.Dragging and Drag.Callback and Helper.IsMoveInput(Input) then
		Drag.Callback(Drag, Input)
	end
end))

return Drag

end)() end,
    [33] = function()local wax,script,require=ImportGlobals(33)local ImportGlobals return (function(...)local Animations = {
	TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Exponential),
	Exclusions = {},
	Expectations = { In = {}, Out = {} },
}

local function GetTransparencyProperty(object)
	if table.find(Animations.Exclusions, object) then
		return nil
	end

	if object:IsA("TextButton") or object:IsA("TextLabel") or object:IsA("TextBox") then
		return { "TextTransparency" }
	elseif object:IsA("CanvasGroup") then
		return { "GroupTransparency" }
	elseif object:IsA("Frame") then
		return { "BackgroundTransparency" }
	elseif object:IsA("ScrollingFrame") then
		return { "ScrollBarImageTransparency" }
	elseif object:IsA("ImageLabel") or object:IsA("ImageButton") then
		return { "ImageTransparency", "BackgroundTransparency" }
	elseif object:IsA("UIStroke") then
		return { "Transparency" }
	end

	return nil
end

local function BuildPropertyTable(properties, type, object)
	if Animations.Expectations[type][object] then
		return Animations.Expectations[type][object]
	end

	local propTable = {}
	for _, prop in properties do
		propTable[prop] = type == "In" and 0 or 1
	end
	return propTable
end

function Animations.FadeOut(object, time)
	local tweenInfo = time and TweenInfo.new(time, Enum.EasingStyle.Exponential) or Animations.TweenInfo
	local properties = GetTransparencyProperty(object)

	if not properties then
		return
	end

	wax.shared.TweenService:Create(object, tweenInfo, BuildPropertyTable(properties, "Out", object)):Play()

	if object:IsA("CanvasGroup") then
		return
	end

	for _, child in object:GetDescendants() do
		local prop = GetTransparencyProperty(child)
		if not prop then
			continue
		end

		wax.shared.TweenService:Create(child, tweenInfo, BuildPropertyTable(prop, "Out", child)):Play()
	end
end

function Animations.FadeIn(object, time)
	local tweenInfo = time and TweenInfo.new(time, Enum.EasingStyle.Exponential) or Animations.TweenInfo
	local property = GetTransparencyProperty(object)

	if property then
		wax.shared.TweenService:Create(object, tweenInfo, BuildPropertyTable(property, "In", object)):Play()
	end

	if object:IsA("CanvasGroup") then
		return
	end

	for _, child in object:GetDescendants() do
		local prop = GetTransparencyProperty(child)
		if not prop then
			continue
		end

		wax.shared.TweenService:Create(child, tweenInfo, BuildPropertyTable(prop, "In", child)):Play()
	end
end

function Animations.AddFadeExclusion(object)
	local prop = GetTransparencyProperty(object)
	if not prop then
		return
	end

	table.insert(Animations.Exclusions, object)
end

function Animations.AddFadeExclusions(objects)
	for _, object in objects do
		local prop = GetTransparencyProperty(object)
		if not prop then
			continue
		end

		table.insert(Animations.Exclusions, object)
	end
end

function Animations.SetFadeExpectation(type: "In" | "Out", object: GuiBase2d, properties: { [string]: any })
	if not Animations.Expectations[type] then
		return
	end

	Animations.Expectations[type][object] = properties
end

return Animations

end)() end,
    [34] = function()local wax,script,require=ImportGlobals(34)local ImportGlobals return (function(...)--[[
	UI Constants for Nova
	Centralized styling values for consistent theming
	Customized for 04xSkater
]]

local Constants = {}

-- Corner Radius
Constants.CornerRadius = {
	Large = UDim.new(0, 10),
	Medium = UDim.new(0, 8),
	Small = UDim.new(0, 6),
	Round = UDim.new(1, 0),
}

-- Theme Definitions
Constants.Themes = {
    Dark = { -- Cobalt Style
        Background = {
            Primary = Color3.fromRGB(15, 15, 15),
            Secondary = Color3.fromRGB(20, 20, 20),
            Tertiary = Color3.fromRGB(10, 10, 10),
        },
        Accent = {
            Primary = Color3.fromRGB(25, 25, 25),
            Hover = Color3.fromRGB(30, 30, 30),
            Active = Color3.fromRGB(50, 50, 50),
            Light = Color3.fromRGB(200, 200, 200),
        },
        Border = {
            Primary = Color3.fromRGB(30, 30, 30),
            Secondary = Color3.fromRGB(40, 40, 40),
        }
    },
    Nova = {
        Background = {
            Primary = Color3.fromRGB(10, 10, 12),
            Secondary = Color3.fromRGB(15, 15, 20),
            Tertiary = Color3.fromRGB(5, 5, 7),
        },
        Accent = {
            Primary = Color3.fromRGB(0, 174, 255), -- Electric Blue from Logo
            Hover = Color3.fromRGB(0, 190, 255),
            Active = Color3.fromRGB(0, 150, 220),
            Light = Color3.fromRGB(255, 255, 255),
        },
        Border = {
            Primary = Color3.fromRGB(30, 30, 40),
            Secondary = Color3.fromRGB(0, 174, 255), -- Blue border for highlights
        }
    }
}

-- Current active colors (will be updated by Window.luau)
Constants.Colors = {}

function Constants.ApplyTheme(themeName)
    local theme = Constants.Themes[themeName] or Constants.Themes.Dark
    
    Constants.Colors.Background = theme.Background
    Constants.Colors.Accent = theme.Accent
    Constants.Colors.Border = theme.Border
    
    -- Static Colors
    Constants.Colors.Status = {
        Success = Color3.fromRGB(52, 199, 89),
        Warning = Color3.fromRGB(255, 153, 0),
        Error = Color3.fromRGB(255, 69, 58),
        Info = theme.Accent.Primary,
    }
    Constants.Colors.Text = {
        Primary = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(180, 190, 200),
        Tertiary = Color3.fromRGB(120, 130, 140),
    }
end

-- Default initialization
Constants.ApplyTheme("Dark")

-- Padding
Constants.Padding = {
	None = UDim.new(0, 0),
	XSmall = UDim.new(0, 2),
	Small = UDim.new(0, 4),
	Medium = UDim.new(0, 6),
	Large = UDim.new(0, 8),
	XLarge = UDim.new(0, 12),
}

-- Spacing
Constants.Spacing = {
	None = UDim.new(0, 0),
	XSmall = UDim.new(0, 2),
	Small = UDim.new(0, 4),
	Medium = UDim.new(0, 6),
	Large = UDim.new(0, 8),
	XLarge = UDim.new(0, 15),
}

-- Text Sizes
Constants.TextSize = {
	Small = 14,
	Medium = 15,
	Regular = 16,
	Large = 17,
	XLarge = 18,
}

-- Tween Info
Constants.TweenInfo = {
	Default = TweenInfo.new(0.2, Enum.EasingStyle.Exponential),
	Fast = TweenInfo.new(0.1, Enum.EasingStyle.Exponential),
	Slow = TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
}

-- Sizes
Constants.Sizes = {
	Button = {
		Small = UDim2.fromOffset(24, 24),
		Medium = UDim2.fromOffset(30, 30),
		Large = UDim2.fromOffset(36, 36),
	},
	Icon = {
		Small = UDim2.fromOffset(16, 16),
		Medium = UDim2.fromOffset(20, 20),
		Large = UDim2.fromOffset(24, 24),
	},
}

-- Transparency
Constants.Transparency = {
	Opaque = 0,
	SemiTransparent = 0.5,
	Transparent = 1,
}

-- Stroke Thickness
Constants.StrokeThickness = {
	Thin = 1,
	Medium = 2,
	Thick = 3,
}

return Constants

end)() end,
    [22] = function()local wax,script,require=ImportGlobals(22)local ImportGlobals return (function(...)local Utils = script.Parent.Parent

local LuaEncode = require(script.Parent.Parent.Serializer.LuaEncode)
local CodeGen = require(script.Parent.Generator)

local SessionExporter = {}
do
    local StringMapper = {}
    StringMapper.__index = StringMapper

    function StringMapper.New()
        return setmetatable({
            StringMap = {},
            StringList = {},
            NextStringId = 1,
        }, StringMapper)
    end

    function StringMapper:GetId(Str)
        if Str == nil then Str = "nil" end
        Str = tostring(Str)
        if not self.StringMap[Str] then
            self.StringMap[Str] = self.NextStringId
            self.StringList[tostring(self.NextStringId)] = Str
            self.NextStringId = self.NextStringId + 1
        end
        return self.StringMap[Str]
    end

    function StringMapper:GetString(Id)
        return self.StringList[Id]
    end

    SessionExporter.StringMapper = StringMapper
end

function SessionExporter:FetchAllLogs()
	local AllCalls = {}

	for _, LogCategory in next, wax.shared.Logs do
		for _, Log in next, LogCategory do
			for Idx, Call in next, Log.Calls do
				table.insert(AllCalls, setmetatable(Call, {
					__index = Log
				}))
			end
		end
	end

	return AllCalls
end

function SessionExporter:SortCalls(AllCalls)
	table.sort(AllCalls, function(a, b)
		local TimeA = a.CreationTime or 0
		local TimeB = b.CreationTime or 0
		return TimeA < TimeB
	end)
end

function SessionExporter:GetSessionData(AllCalls)
	local StartTime = wax.shared.NovaStartTime or tick()
	local EndTime = AllCalls[#AllCalls] and AllCalls[#AllCalls].CreationTime or tick()
	local Duration = math.max(0.1, EndTime - StartTime)
	local SessionId = wax.shared.HttpService:GenerateGUID(false)

	return {
        StartTime = StartTime,
        EndTime = EndTime,
        Duration = Duration,
        SessionId = SessionId,
    }
end

function SessionExporter:EscapeHTML(Str)
	return Str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

function SessionExporter:SerializeLuauTableForHTML(Table)
	local SerializedString = LuaEncode(Table, {
		Prettify = true,
		InsertCycles = true,
		DisableNilParentHandler = true,
	})
	
	return self:EscapeHTML(SerializedString)
end

function SessionExporter:ProcessCalls(AllCalls, SessionData, UpdateProgress)
	local StringMapper = self.StringMapper.New()

    local Events = {}
    local AllCallsNum = #AllCalls
    for Idx, Call in next, AllCalls do
        if Idx % 500 == 0 then
            if UpdateProgress then
                UpdateProgress(`Processing... ({Idx}/{AllCallsNum})`)
            end
            task.wait()
        end

        local ArgsString = self:SerializeLuauTableForHTML(
            { table.unpack(Call.Arguments, 1, Call.Arguments.n) }
        )

        local Method = "Unknown"
        if wax.shared.FunctionForClasses[Call.Type] then
            Method = wax.shared.FunctionForClasses[Call.Type][Call.Instance.ClassName] or Method
        end

        local FunctionName, FunctionLine, FunctionSource, FunctionHash = "Unknown", Call.Line or -1, Call.Source or "Unknown", "N/A"
        local FunctionUpvalues, FunctionProtos, FunctionConstants = "{}", "{}", "{}"
        do
            if type(Call.Function) == "table" and Call.IsActor then
                FunctionName = Call.Function.Name ~= "" and Call.Function.Name or "Anonymous"
                FunctionSource = Call.Function.Source or "N/A"
                FunctionLine = Call.Function.Line or -1
                
                if not Call.Function.IsC then
                    FunctionHash = Call.Function.FunctionHash or "N/A"
                    FunctionUpvalues = self:SerializeLuauTableForHTML(Call.Function.Upvalues)
                    FunctionProtos = self:SerializeLuauTableForHTML(Call.Function.Protos)
                    FunctionConstants = self:SerializeLuauTableForHTML(Call.Function.Constants)
                else
                    FunctionHash = "N/A (C Closure)"
                    FunctionUpvalues = "N/A (C Closure)"
                    FunctionProtos = "N/A (C Closure)"
                    FunctionConstants = "N/A (C Closure)"
                end
            elseif type(Call.Function) == "function" then
                FunctionName = debug.info(Call.Function, "n")
            
                if islclosure(Call.Function) then
                    FunctionHash = getfunctionhash and getfunctionhash(Call.Function) or "N/A"
                    FunctionUpvalues = self:SerializeLuauTableForHTML(debug.getupvalues(Call.Function))
                    FunctionProtos = self:SerializeLuauTableForHTML(debug.getprotos(Call.Function))
                    FunctionConstants = self:SerializeLuauTableForHTML(debug.getconstants(Call.Function))
                else
                    FunctionHash = "N/A (C Closure)"
                    FunctionUpvalues = "N/A (C Closure)"
                    FunctionProtos = "N/A (C Closure)"
                    FunctionConstants = "N/A (C Closure)"
                end
            else
                FunctionName = tostring(Call.Function or "Unknown")
            end

            if FunctionName == "" then FunctionName = "Anonymous" end
        end

        local OriginPath = Call.Origin and CodeGen.GetFullPath(Call.Origin, {
            DisableNilParentHandler = true,
        }) or "Unknown"

        table.insert(Events, {
            StringMapper:GetId(Call.Instance.Name),
            StringMapper:GetId(Call.Instance.ClassName),
            StringMapper:GetId(CodeGen.GetFullPath(Call.Instance, {
                DisableNilParentHandler = true,
            })),

            StringMapper:GetId(Method),
            (Call.CreationTime or SessionData.StartTime),
            StringMapper:GetId(OriginPath),

            StringMapper:GetId(ArgsString),
            StringMapper:GetId(Method),

            StringMapper:GetId(FunctionName),
            FunctionLine,
            StringMapper:GetId(FunctionSource),
            Call.IsExecutor and 1 or 0,
            Call.IsActor and 1 or 0,

            StringMapper:GetId(FunctionHash),
            StringMapper:GetId(FunctionUpvalues),
            StringMapper:GetId(FunctionProtos),
            StringMapper:GetId(FunctionConstants)
        })
    end

    return Events, StringMapper
end

function SessionExporter:ExportSessionToHTML(Events, StringMapper, SessionData)
    local Template = Utils.CodeGen.SessionHTMLView.Value
    local StartDateStr = os.date("%d %b %Y, %H:%M:%S", math.floor(SessionData.StartTime))
    local EndDateStr = os.date("%d %b %Y, %H:%M:%S", math.floor(SessionData.EndTime))

    local HTML = Template
        :gsub("{{EVENTS_JSON}}", function() return wax.shared.HttpService:JSONEncode(Events) end)
        :gsub("{{DICTIONARY_JSON}}", function() return wax.shared.HttpService:JSONEncode(StringMapper.StringList) end)
        :gsub("{{SESSION_ID}}", SessionData.SessionId)
        :gsub("{{START_TIME}}", tostring(SessionData.StartTime))
        :gsub("{{DURATION}}", tostring(SessionData.Duration))
        :gsub("{{EVENT_COUNT}}", tostring(#Events))
        :gsub("{{TOTAL_DURATION}}", string.format("%.2f", SessionData.Duration))
        :gsub("{{PLACE_ID}}", tostring(game.PlaceId))
        :gsub("{{JOB_ID}}", game.JobId)
        :gsub("{{DATE}}", StartDateStr)
        :gsub("{{END_DATE}}", EndDateStr)

    return HTML
end

return SessionExporter
end)() end,
    [14] = function()local wax,script,require=ImportGlobals(14)local ImportGlobals return (function(...)local LuaEncode = require(script.Parent.Parent.Utils.Serializer.LuaEncode)
local CodeGen = require(script.Parent.Parent.Utils.CodeGen.Generator)

local Hooks = script.Parent.Hooks

-- Main Thread Hooks
for _, Hook in Hooks.Default:GetChildren() do
	task.spawn(require, Hook)
end

getgenv().NovaInitialized = true

-- Actors use a different lua vm
-- This means that our main thread metatable hooks dont apply in the actor's vm
-- So we need to set up the hooks again in the actor lua vm in order to log everything
local ActorsUtils = script.Parent.Actors

wax.shared.ActorsEnabled = (
	wax.shared.ExecutorSupport["run_on_actor"].IsWorking
	and wax.shared.ExecutorSupport["getactors"].IsWorking
	and wax.shared.ExecutorSupport["create_comm_channel"].IsWorking
)

if wax.shared.ActorsEnabled then
	local ActorEnvironmentCode = ActorsUtils.Environment.Value

	local CommunicationChannelID, Channel = create_comm_channel()
	wax.shared.ActorCommunicator = Channel

	local AlternativeEnabled = wax.shared.SaveManager:GetState("UseAlternativeHooks", false)

	local IgnorePlayerModule = wax.shared.SaveManager:GetState("IgnorePlayerModule", true)
	local IngoredRemotesDropdown = wax.shared.SaveManager:GetState("IgnoredRemotesDropdown", {
		["BindableEvent"] = true,
		["BindableFunction"] = true,
	})

	local ActorData = LuaEncode({
		Token = wax.shared.NovaVerificationToken,

		IgnorePlayerModule = IgnorePlayerModule,
		IgnoredRemotesDropdown = IngoredRemotesDropdown,
		UseAlternativeHooks = AlternativeEnabled,

		ExecutorSupport = wax.shared.ExecutorSupport,
	})

	ActorEnvironmentCode = ActorEnvironmentCode:gsub("NOVA_ACTOR_DATA", ActorData)

	-- Actor Logs Sync Layer
	local function ReconstructTable(Info, CyclicRefs)
		local Reconstructed = {}

		for Key, Value in Info do
			if type(Value) == "table" then
				if Value["__Function"] and Value["Validation"] == wax.shared.NovaVerificationToken then
					local FunctionData = table.clone(Value)
					FunctionData["__Function"] = nil
					FunctionData["Validation"] = nil

					Reconstructed[Key] = FunctionData
					continue
				end

				-- Check for Nova Created Object
				if not Value["__CyclicRef"] then
					Reconstructed[Key] = ReconstructTable(Value, CyclicRefs)
					continue
				end

				local CyclicId = Value["__Id"]

				if not CyclicRefs[CyclicId] then
					warn("CyclicRef not found: " .. CyclicId)
					continue
				end

				Reconstructed[Key] = CyclicRefs[CyclicId]
				continue
			end

			Reconstructed[Key] = Value
		end

		return Reconstructed
	end

	wax.shared.Connect(Channel.Event:Connect(function(EventType, ...)
		local ShouldLogActors = wax.shared.SaveManager:GetState("LogActors", true)

		if not ShouldLogActors then
			return
		end

		if EventType ~= "ActorCall" then
			return
		end

		local Instance, Type, RawInfo, CyclicRefs = ...
		if Instance == Channel or Instance == wax.shared.Communicator then
			return
		end

		local Method = wax.shared.FunctionForClasses[Type][Instance.ClassName]
		local Log = wax.shared.Logs[Type][Instance]

		if not Log then
			Log = wax.shared.NewLog(Instance, Type, Method, RawInfo.Origin)
		end

		if Log.Blocked then
			return
		elseif not Log.Ignored then
			local ReconstructedInfo = ReconstructTable(RawInfo, CyclicRefs)
			ReconstructedInfo.IsActor = true

			--// Reconstruct Packed Arguments (BindableEvents omit ["n"] for unknown reason) \\--
			local Packed = ReconstructedInfo.Arguments
			local PackedN, PackedData = Packed.n, Packed.Data
			ReconstructedInfo.Arguments = PackedData
			ReconstructedInfo.Arguments.n = PackedN

			Log:Call(ReconstructedInfo)
			wax.shared.Communicator:Fire(Log.Instance, Type, #Log.Calls)
		end
	end))

	-- Actor Hooking Code Generation
	local CodeToRun = ActorEnvironmentCode

	for _, ActorHook in Hooks.Actors:GetChildren() :: { StringValue } do
		CodeToRun ..= table.concat({
			"task.spawn(function()",
			CodeGen:IndentCode(ActorHook.Value, 1),
			"end)",
		}, "\n") .. "\n\n"
	end

	CodeToRun ..= table.concat({
		"task.spawn(function()",
		CodeGen:IndentCode(ActorsUtils.Unload.Value, 1),
		"end)",
	}, "\n")

	-- Actual Hooking Logic
	-- The hooking code wont run again if nova is already initialized in that Actor (to address deleted actors aka LuaStateProxy stuff)
	
	-- `HookActor` is to address Volcano returning non initialized actors inside their `getactors` function.
	-- God this code is so ass 🥹
	local function HookActor(TargetActor: Actor)
		local Hooked = false
		repeat
			Hooked, _ = pcall(run_on_actor, TargetActor, CodeToRun, CommunicationChannelID)
			task.wait(0.25)
		until Hooked
	end

	for _, TargetActor in getactors() do
		task.spawn(HookActor, TargetActor)
	end

	wax.shared.Connect(game.DescendantAdded:Connect(function(actor)
		if not actor:IsA("Actor") then
			return
		end

		HookActor(actor)
	end))
end

return {}

end)() end,
    [12] = function()local wax,script,require=ImportGlobals(12)local ImportGlobals return (function(...)local ClassesToHook = {
	RemoteEvent = "OnClientEvent",
	RemoteFunction = "OnClientInvoke",
	UnreliableRemoteEvent = "OnClientEvent",
	BindableEvent = "Event",
	BindableFunction = "OnInvoke",
}

type InstancesToHook = RemoteEvent | UnreliableRemoteEvent | RemoteFunction | BindableEvent | BindableFunction
type MethodsToHook = "OnClientEvent" | "OnClientInvoke" | "Event" | "OnInvoke"

local LogConnectionFunctions = {}
local SignalMapping = setmetatable({}, { __mode = "kv" })

local function CreateLookupTable(table)
	local LookupTable = {}
	for _, Method in next, table do
		LookupTable[Method] = true
	end
	return LookupTable
end


--[[
	Individually logs an incoming remote call.

	@param Instance The instance that was called.
	@param Method The method that was called (e.g., "OnClientEvent").
	@param Function The function that was called, if applicable.
	@param Info The information about the call, including arguments and origin. Can be nil.
	@param ... The arguments passed from the server to the client.
	@return boolean Returns true if the call was blocked, false otherwise.
]]
local function LogRemote(
	Instance: InstancesToHook,
	Method: MethodsToHook,
	Function: (...any) -> ...any,
	Info: {
		Arguments: { [number]: any, n: number },
		Origin: Instance,
		Function: (...any) -> ...any,
		Line: number,
		IsExecutor: boolean,
	}
)
	if not wax.shared.ShouldIgnore(Instance, getcallingscript()) and not LogConnectionFunctions[Function] then
		local Log = wax.shared.Logs.Incoming[Instance]
		if not Log then
			Log = wax.shared.NewLog(Instance, "Incoming", Method, getcallingscript())
		end

		if Log.Blocked then
			return true
		elseif not Log.Ignored then
			Log:Call(Info)
		end
	end

	return false
end

--[[
	Creates a function that can be used to pass to `Connect` which will log all the incoming calls. It will additonally add the function to a ignore list (`LogConnectionFunctions`) to prevent unneccessary logging.
	
	@param Instance The instance to log.
	@param Method The method to log (e.g., "OnClientEvent").
	@return function Returns a function that logs all calls to the given instance and method.
]]
local function CreateConnectionFunction(Instance: InstancesToHook, Method: MethodsToHook)
	local ConnectionFunction = function(...)
		for _, Connection in pairs(getconnections((Instance :: any)[Method])) do
			if Connection.ForeignState then
				continue
			end

			local Function = typeof(Connection.Function) == "function" and Connection.Function or nil
			local Thread = Connection.Thread

			local Origin = nil

			if Thread and getscriptfromthread then
				Origin = getscriptfromthread(Thread)
			end

			if not Origin and Function then
				-- ts is unreliable because people could js set the script global to nil
				-- if only debug.getinfo(Function).source or debug.info(Function, "s") returned an Instance...

				local Script = rawget(getfenv(Function), "script")
				if typeof(Script) == "Instance" then
					Origin = Script
				end
			end

			LogRemote(Instance, Method, Function, {
				Arguments = table.pack(...),
				Origin = Origin,
				Function = Function,
				Line = nil,
				IsExecutor = Function and isexecutorclosure(Function) or false,
			})
		end
	end

	LogConnectionFunctions[ConnectionFunction] = true
	return ConnectionFunction
end

--[[
	Creates a function that can be used to pass to callbacks (.OnInvoke & .OnClientInvoke) which will log all the incoming calls.
	
	@param Instance The instance to log.
	@param Method The method to log (e.g., "OnClientEvent").
	@param Function The original callback of the RemoteFunction
	@return function Returns a function that logs all function calls to the given instance and method.
]]
local function CreateCallbackDetour(Instance: InstancesToHook, Method: MethodsToHook, Callback: (...any) -> ...any)
	local Detour = function(...)
		local Origin = nil

		-- May not exist in all executors
		if getscriptfromthread then
			Origin = getscriptfromthread(coroutine.running())
		end

		-- Unreliable method to get script.
		if not Origin then
			local Script = rawget(getfenv(Callback), "script")
			if typeof(Script) == "Instance" then
				Origin = Script
			end
		end

		local FunctionCaller = debug.info(2, "f")
		local IsExecutor = if typeof(FunctionCaller) == "function"
			then isexecutorclosure(FunctionCaller)
			else isexecutorclosure(Callback)

		if
			LogRemote(Instance, Method, Callback, {
				Arguments = table.pack(...),
				Origin = Origin,
				Function = Callback,
				Line = nil,
				IsExecutor = IsExecutor,
			})
		then
			return
		end

		return Callback(...)
	end

	if wax.shared.ExecutorSupport["setstackhidden"].IsWorking then
		setstackhidden(Detour, true)
	end

	return Detour
end

--[[
	Handles setting up logging for the appropriate instances.

	@param Instance The instance to handle.
]]
local function HandleInstance(Instance: any)
	if
		not ClassesToHook[Instance.ClassName]
		or Instance == wax.shared.Communicator
		or Instance == wax.shared.ActorCommunicator
	then
		return
	end

	local Method = ClassesToHook[Instance.ClassName]

	if Instance.ClassName == "RemoteEvent" or Instance.ClassName == "UnreliableRemoteEvent" then
		wax.shared.Connect(Instance.OnClientEvent:Connect(CreateConnectionFunction(Instance, Method)))

		SignalMapping[Instance.OnClientEvent] = Instance
	elseif Instance.ClassName == "BindableEvent" then
		wax.shared.Connect(Instance.Event:Connect(CreateConnectionFunction(Instance, Method)))

		SignalMapping[Instance.Event] = Instance
	elseif Instance.ClassName == "RemoteFunction" or Instance.ClassName == "BindableFunction" then
		local Success, Callback = pcall(getcallbackvalue, Instance, Method)
		local IsCallable = (
			typeof(Callback) == "function"
			or wax.shared.getrawmetatable(Callback) ~= nil and typeof(wax.shared.getrawmetatable(Callback)["__call"]) == "function"
			or false
		)

		if not Success or not IsCallable then
			return
		end

		Instance[Method] = CreateCallbackDetour(Instance, Method, Callback)
	end
end

wax.shared.Connect(game.DescendantAdded:Connect(HandleInstance))

local CategoryToSearch = { game:QueryDescendants("RemoteEvent, RemoteFunction, UnreliableRemoteEvent, BindableEvent, BindableFunction") }
if wax.shared.ExecutorSupport["getnilinstances"].IsWorking then
	table.insert(CategoryToSearch, getnilinstances())
end

for _, Category in CategoryToSearch do
	for _, Instance in next, Category do
		HandleInstance(Instance)
	end
end

wax.shared.NewIndexHook = wax.shared.Hooking.HookMetaMethod(game, "__newindex", function(...)
	local self, key, value = ...

	if typeof(self) ~= "Instance" or not ClassesToHook[self.ClassName] then
		return wax.shared.NewIndexHook(...)
	end

	if self.ClassName == "RemoteFunction" or self.ClassName == "BindableFunction" then
		local Method = ClassesToHook[self.ClassName]

		local IsCallable = (
			typeof(value) == "function"
			or wax.shared.getrawmetatable(value) ~= nil and typeof(wax.shared.getrawmetatable(value)["__call"]) == "function"
			or false
		)

		if key == Method and IsCallable then
			return wax.shared.NewIndexHook(self, key, CreateCallbackDetour(self :: InstancesToHook, Method, value))
		end
	end

	return wax.shared.NewIndexHook(...)
end)

local ConnectionKeys = CreateLookupTable({
	"Connect",
	"ConnectParallel",
	"connect",
	"connectParallel",
	"once",
	"Once",
})

local SignalMetatable = wax.shared.getrawmetatable(Instance.new("Part").Touched)
wax.shared.Hooks[SignalMetatable.__index] = wax.shared.Hooking.HookFunction(SignalMetatable.__index, function(...)
	local self, key = ...

	if ConnectionKeys[key] then
		local Instance = SignalMapping[self]
		local Connect = wax.shared.Hooks[SignalMetatable.__index](...)

		if not Instance then
			return Connect
		end

		local Method = ClassesToHook[Instance.ClassName]
		wax.shared.Hooks[Connect] = wax.shared.Hooking.HookFunction(Connect, function(...)
			local _self, callback = ...

			local Result = table.pack(wax.shared.Hooks[Connect](...))
			local Log = wax.shared.Logs.Incoming[Instance]

			if Log and Log.Blocked then
				for _, Connection in pairs(getconnections(Instance[Method])) do
					if not Connection.ForeignState and Connection.Function ~= callback then
						continue
					end

					Connection:Disable()
				end
			end

			return table.unpack(Result, 1, Result.n)
		end)

		return Connect
	end

	return wax.shared.Hooks[SignalMetatable.__index](...)
end)

end)() end,
    [38] = function()local wax,script,require=ImportGlobals(38)local ImportGlobals return (function(...)--[[

Luau syntax highlighter with studio colors
Based on: https://devforum.roblox.com/t/realtime-richtext-lua-syntax-highlighting/2500399

]]

local Highlighter = {
	Colors = {
		Keyword = "#f86d7c",
		String = "#adf195",
		Number = "#ffc600",
		Nil = "#ffc600",
		Boolean = "#ffc600",
		Function = "#f86d7c",
		Self = "#f86d7c",
		Local = "#f86d7c",
		Text = "#ffffff",
		LocalMethod = "#fdfbac",
		LocalProperty = "#61a1f1",
		BuiltIn = "#84d6f7",
		Comment = "#666666",
	},

	Keywords = {
		Lua = {
			"and",
			"break",
			"or",
			"else",
			"elseif",
			"if",
			"then",
			"until",
			"repeat",
			"while",
			"do",
			"for",
			"in",
			"end",
			"local",
			"return",
			"function",
			"export",
		},
		Roblox = {
			"game",
			"workspace",
			"script",
			"math",
			"string",
			"table",
			"task",
			"wait",
			"select",
			"next",
			"Enum",
			"error",
			"warn",
			"tick",
			"assert",
			"shared",
			"loadstring",
			"tonumber",
			"tostring",
			"type",
			"typeof",
			"unpack",
			"print",
			"Instance",
			"CFrame",
			"Vector3",
			"Vector2",
			"Color3",
			"UDim",
			"UDim2",
			"Ray",
			"BrickColor",
			"OverlapParams",
			"RaycastParams",
			"Axes",
			"Random",
			"Region3",
			"Rect",
			"TweenInfo",
			"collectgarbage",
			"not",
			"utf8",
			"pcall",
			"xpcall",
			"_G",
			"setmetatable",
			"getmetatable",
			"os",
			"pairs",
			"ipairs",
		},
	},
}

local function CreateKeywordSet(keywords)
	local keywordSet = {}
	for _, keyword in ipairs(keywords) do
		keywordSet[keyword] = true
	end
	return keywordSet
end

local LuaSet = CreateKeywordSet(Highlighter.Keywords.Lua)
local RobloxSet = CreateKeywordSet(Highlighter.Keywords.Roblox)

local function GetHighlightColor(tokens, index)
	local token = tokens[index]

	if tonumber(token) then
		return Highlighter.Colors.Number
	elseif token == "nil" then
		return Highlighter.Colors.Nil
	elseif token:sub(1, 2) == "--" then
		return Highlighter.Colors.Comment
	elseif LuaSet[token] then
		return Highlighter.Colors.Keyword
	elseif RobloxSet[token] or getgenv()[token] ~= nil then
		return Highlighter.Colors.BuiltIn
	elseif token:sub(1, 1) == '"' or token:sub(1, 1) == "'" then
		return Highlighter.Colors.String
	elseif token == "true" or token == "false" then
		return Highlighter.Colors.Boolean
	end

	if tokens[index + 1] == "(" then
		if tokens[index - 1] == ":" then
			return Highlighter.Colors.LocalMethod
		end
		return Highlighter.Colors.LocalMethod
	end

	if tokens[index - 1] == "." then
		if tokens[index - 2] == "Enum" then
			return Highlighter.Colors.BuiltIn
		end
		return Highlighter.Colors.LocalProperty
	end

	return nil
end

local ArgumentColors = {
	["boolean"] = Highlighter.Colors.Boolean,
	["number"] = Highlighter.Colors.Number,
	["Vector2"] = Highlighter.Colors.Number,
	["Vector3"] = Highlighter.Colors.Number,
	["CFrame"] = Highlighter.Colors.Number,
	["string"] = Highlighter.Colors.String,
	["EnumItem"] = Highlighter.Colors.BuiltIn,
	["nil"] = Highlighter.Colors.Nil,
}
function Highlighter.GetArgumentColor(Argument)
	return ArgumentColors[typeof(Argument)] or Highlighter.Colors.Text
end

function Highlighter.Run(source)
	local tokens = {}
	local currentToken = ""

	local inString = false
	local inComment = false
	local commentPersist = false

	for i = 1, #source do
		local character = source:sub(i, i)

		if inComment then
			if character == "\n" and not commentPersist then
				table.insert(tokens, currentToken)
				table.insert(tokens, character)
				currentToken = ""

				inComment = false
			elseif source:sub(i - 1, i) == "]]" and commentPersist then
				currentToken = currentToken .. "]"

				table.insert(tokens, currentToken)
				currentToken = ""

				inComment = false
				commentPersist = false
			else
				currentToken = currentToken .. character
			end
		elseif inString then
			if character == inString and source:sub(i - 1, i - 1) ~= "\\" or character == "\n" then
				currentToken = currentToken .. character
				table.insert(tokens, currentToken)
				currentToken = ""
				inString = false
			else
				currentToken = currentToken .. character
			end
		else
			if source:sub(i, i + 1) == "--" then
				table.insert(tokens, currentToken)
				currentToken = "--"
				inComment = true
				commentPersist = source:sub(i + 2, i + 3) == "[["
				i = i + 1
			elseif character == '"' or character == "'" then
				table.insert(tokens, currentToken)
				currentToken = character
				inString = character
			elseif character:match("[%p]") and character ~= "_" then
				table.insert(tokens, currentToken)
				table.insert(tokens, character)
				currentToken = ""
			elseif character:match("[%w_]") then
				currentToken = currentToken .. character
			else
				table.insert(tokens, currentToken)
				table.insert(tokens, character)
				currentToken = ""
			end
		end
	end

	if currentToken ~= "" then
		table.insert(tokens, currentToken)
	end

	for i = #tokens, 1, -1 do
		if tokens[i] == "" then
			table.remove(tokens, i)
		end
	end

	local highlighted = {}

	for i, token in ipairs(tokens) do
		local highlightColor = GetHighlightColor(tokens, i)

		if highlightColor then
			local syntax =
				string.format('<font color="%s">%s</font>', highlightColor, token:gsub("<", "&lt;"):gsub(">", "&gt;"))

			table.insert(highlighted, syntax)
		else
			table.insert(highlighted, token)
		end
	end

	return table.concat(highlighted)
end

return Highlighter

end)() end,
    [29] = function()local wax,script,require=ImportGlobals(29)local ImportGlobals return (function(...)if not isfolder("Nova") then
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

end)() end,
    [24] = function()local wax,script,require=ImportGlobals(24)local ImportGlobals return (function(...)wax.shared.Connections = {}

wax.shared.Connect = function(Connection)
	table.insert(wax.shared.Connections, Connection)
	return Connection
end

wax.shared.Disconnect = function(Connection)
	Connection:Disconnect()

	local Index = table.find(wax.shared.Connections, Connection)
	if Index then
		table.remove(wax.shared.Connections, Index)
	end

	return true
end

return {}
end)() end,
    [43] = function()local wax,script,require=ImportGlobals(43)local ImportGlobals return (function(...)local Interface = require(script.Parent.Interface)
local ImageFetcher = require(script.Parent.ImageFetch)

local LoadingScreen = {}

-- Nova Blue Color (from logo)
local NOVA_BLUE = Color3.fromRGB(0, 174, 255)
local BACKGROUND_COLOR = Color3.fromRGB(10, 10, 12)
local SECONDARY_TEXT = Color3.fromRGB(180, 190, 200)

function LoadingScreen.show()
    local NovaLogo = ImageFetcher.GetImage("Logo")
    
    local ScreenGui = Interface.New("ScreenGui", {
        Name = "NovaLoading",
        DisplayOrder = 9999,
        ResetOnSpawn = false,
        Parent = Interface.GetScreenParent(),
    })

    local MainFrame = Interface.New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = BACKGROUND_COLOR,
        Parent = ScreenGui,
    })

    local Container = Interface.New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(300, 300),
        BackgroundTransparency = 1,
        Parent = MainFrame,
    })

    local Logo = Interface.New("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.4),
        Size = UDim2.fromOffset(150, 150),
        Image = NovaLogo,
        BackgroundTransparency = 1,
        ImageTransparency = 1,
        Parent = Container,
    })

    local Title = Interface.New("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.65),
        Size = UDim2.fromOffset(200, 30),
        Text = "NOVA PROJECT",
        TextColor3 = NOVA_BLUE,
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        TextTransparency = 1,
        BackgroundTransparency = 1,
        Parent = Container,
    })

    local Creator = Interface.New("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.72),
        Size = UDim2.fromOffset(200, 20),
        Text = "by 04xSkater",
        TextColor3 = NOVA_BLUE,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextTransparency = 1,
        BackgroundTransparency = 1,
        Parent = Container,
    })

    local ProgressBarBackground = Interface.New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.85),
        Size = UDim2.fromOffset(200, 4),
        BackgroundColor3 = Color3.fromRGB(30, 30, 40),
        BorderSizePixel = 0,
        Parent = Container,
    })

    local ProgressBar = Interface.New("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = NOVA_BLUE,
        BorderSizePixel = 0,
        Parent = ProgressBarBackground,
    })

    Interface.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ProgressBarBackground })
    Interface.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ProgressBar })

    -- Animations
    local ts = game:GetService("TweenService")
    local ti = TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    ts:Create(Logo, ti, { ImageTransparency = 0, Position = UDim2.fromScale(0.5, 0.45) }):Play()
    task.wait(0.5)
    ts:Create(Title, ti, { TextTransparency = 0 }):Play()
    task.wait(0.3)
    ts:Create(Creator, ti, { TextTransparency = 0 }):Play()
    task.wait(0.5)

    -- Fake loading progress
    local steps = 20
    for i = 1, steps do
        ts:Create(ProgressBar, TweenInfo.new(0.2), { Size = UDim2.fromScale(i/steps, 1) }):Play()
        task.wait(0.1)
    end

    task.wait(0.5)

    -- Fade out
    local fadeTi = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    ts:Create(Logo, fadeTi, { ImageTransparency = 1 }):Play()
    ts:Create(Title, fadeTi, { TextTransparency = 1 }):Play()
    ts:Create(Creator, fadeTi, { TextTransparency = 1 }):Play()
    ts:Create(ProgressBarBackground, fadeTi, { BackgroundTransparency = 1 }):Play()
    ts:Create(ProgressBar, fadeTi, { BackgroundTransparency = 1 }):Play()
    ts:Create(MainFrame, fadeTi, { BackgroundTransparency = 1 }):Play()

    task.wait(0.6)
    ScreenGui:Destroy()
end

return LoadingScreen

end)() end,
    [19] = function()local wax,script,require=ImportGlobals(19)local ImportGlobals return (function(...)local Adonis = {
	Name = "Adonis",
	Game = "*",
}

local AdonisAnticheatThreads = {}
function Adonis.Detect()
	if not getreg or not getgc or not isfunctionhooked then
		return false
	end

	local AdonisDetected = false

	for _, thread in getreg() do
		if typeof(thread) ~= "thread" then
			continue
		end

		local Source = debug.info(thread, 1, "s")
		if Source and (Source:match(".Core.Anti") or Source:match(".Plugins.Anti_Cheat")) then
			AdonisDetected = true
			table.insert(AdonisAnticheatThreads, thread)
		end
	end

	return AdonisDetected
end

function Adonis.Bypass()
	for _, thread in AdonisAnticheatThreads do
		pcall(coroutine.close, thread)
	end

	local AdonisTables = {}
	if filtergc then
		local ContendorAdonisTables = filtergc("table", {
			Keys = { "Detected", "RLocked" }
		}, false)

		for _, AdonisTable in ContendorAdonisTables do
			if typeof(rawget(AdonisTable, "Detected")) ~= "function" then continue end
			table.insert(AdonisTables, AdonisTable)
		end
	else
		for _, Table in getgc(true) do
			if typeof(Table) ~= "table" then
				continue
			end
	
			local IsAdonisOrigin = typeof(rawget(Table, "Detected")) == "function" and rawget(Table, "RLocked")
			if not IsAdonisOrigin then continue end

			table.insert(AdonisTables, Table)
		end
	end

	for _, Adonis in AdonisTables do
		for _, DetectionFunc in Adonis do
			-- Just in case they already loaded a custom anticheat bypass for adonis
			if typeof(DetectionFunc) ~= "function" or isfunctionhooked(DetectionFunc) then
				continue
			end

			wax.shared.Hooks[DetectionFunc] = wax.shared.Hooking.HookFunction(
				DetectionFunc,
				function(action, info, nocrash)
					coroutine.yield(coroutine.running())
					return task.wait(9e9)
				end
			)
		end
	end

	return true
end

return Adonis

end)() end,
    [37] = function()local wax,script,require=ImportGlobals(37)local ImportGlobals return (function(...)local UIHelper = {}

local CodeGen = require(script.Parent.Parent.CodeGen.Generator)

function UIHelper.IsMouseOverFrame(Frame: GuiObject, Position: Vector3): boolean
	local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
	return Position.X >= AbsPos.X
		and Position.X <= AbsPos.X + AbsSize.X
		and Position.Y >= AbsPos.Y
		and Position.Y <= AbsPos.Y + AbsSize.Y
end

function UIHelper.IsClickInput(Input: InputObject): boolean
	return Input.UserInputState == Enum.UserInputState.Begin
		and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch)
end

function UIHelper.IsMoveInput(Input: InputObject): boolean
	return Input.UserInputState == Enum.UserInputState.Change
		and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
end

function UIHelper.QuickSerializeNumber(Number: number)
	if Number % 1 ~= 0 then
		return string.format("%.3f", Number)
	elseif Number == 1 / 0 then
		return "math.huge"
	elseif Number == -1 / 0 then
		return "-math.huge"
	end

	return Number
end

function UIHelper.QuickSerializeArgument(Argument)
	if typeof(Argument) == "string" then
		return string.format('"%s"', Argument)
	elseif typeof(Argument) == "number" then
		return UIHelper.QuickSerializeNumber(Argument)
	elseif typeof(Argument) == "Vector2" then
		return string.format(
			"%s, %s",
			UIHelper.QuickSerializeNumber(Argument.X),
			UIHelper.QuickSerializeNumber(Argument.Y)
		)
	elseif typeof(Argument) == "Vector3" then
		return string.format(
			"%s, %s, %s",
			UIHelper.QuickSerializeNumber(Argument.X),
			UIHelper.QuickSerializeNumber(Argument.Y),
			UIHelper.QuickSerializeNumber(Argument.Z)
		)
	elseif typeof(Argument) == "CFrame" then
		local Components = { Argument:GetComponents() }
		for Index, Value in pairs(Components) do
			Components[Index] = UIHelper.QuickSerializeNumber(Value)
		end
		return table.concat(Components, ", ")
	elseif typeof(Argument) == "table" then
		return "{...}"
	elseif typeof(Argument) == "Instance" then
		return CodeGen.GetFullPath(Argument, { DisableNilParentHandler = true })
	elseif typeof(Argument) == "userdata" then
		return "newproxy(" .. getmetatable(Argument) and "true" or "false" .. ")"
	end

	return tostring(Argument)
end

return UIHelper

end)() end,
    [41] = function()local wax,script,require=ImportGlobals(41)local ImportGlobals return (function(...)--[[
	Improved Button Component for Nova
	Enhanced button with better visual feedback and animations
]]

local Constants = require(script.Parent.Constants)
local Interface = require(script.Parent.Interface)

local ImprovedButton = {}

type ButtonConfig = {
	Text: string?,
	Icon: string?,
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	BackgroundColor: Color3?,
	HoverColor: Color3?,
	ActiveColor: Color3?,
	TextSize: number?,
	CornerRadius: UDim?,
	OnClick: (() -> ())?,
	Parent: Instance?,
	LayoutOrder: number?,
}

function ImprovedButton.Create(config: ButtonConfig)
	local button = Interface.New("TextButton", {
		Size = config.Size or UDim2.fromOffset(100, 36),
		Position = config.Position or UDim2.fromScale(0, 0),
		AnchorPoint = config.AnchorPoint or Vector2.new(0, 0),
		BackgroundColor3 = config.BackgroundColor or Constants.Colors.Accent.Primary,
		Text = config.Icon and "" or (config.Text or "Button"),
		TextSize = config.TextSize or Constants.TextSize.Regular,
		TextColor3 = Constants.Colors.Text.Primary,
		AutoButtonColor = false,
		LayoutOrder = config.LayoutOrder or 0,
		Parent = config.Parent,
		
		["UICorner"] = {
			CornerRadius = config.CornerRadius or Constants.CornerRadius.Medium,
		},
		
		["UIStroke"] = {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Constants.Colors.Border.Primary,
			Thickness = Constants.StrokeThickness.Thin,
		},
	})
	
	-- Add padding if text is present
	if not config.Icon or config.Text then
		Interface.New("UIPadding", {
			PaddingLeft = Constants.Padding.Medium,
			PaddingRight = Constants.Padding.Medium,
			PaddingTop = Constants.Padding.Small,
			PaddingBottom = Constants.Padding.Small,
			Parent = button,
		})
	end
	
	-- Add icon if specified
	if config.Icon then
		local Icons = require(script.Parent.Icons)
		local iconImage = Interface.NewIcon(config.Icon, {
			Size = config.Text and Constants.Sizes.Icon.Medium or Constants.Sizes.Icon.Large,
			Position = config.Text and UDim2.fromOffset(8, 0) or UDim2.fromScale(0.5, 0.5),
			AnchorPoint = config.Text and Vector2.new(0, 0.5) or Vector2.new(0.5, 0.5),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Parent = button,
		})
		
		-- If both icon and text, add text label
		if config.Text then
			Interface.New("TextLabel", {
				Text = config.Text,
				TextSize = config.TextSize or Constants.TextSize.Regular,
				TextColor3 = Constants.Colors.Text.Primary,
				Size = UDim2.new(1, -36, 1, 0),
				Position = UDim2.fromOffset(32, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Parent = button,
			})
		end
	end
	
	-- Hover animation
	local originalColor = config.BackgroundColor or Constants.Colors.Accent.Primary
	local hoverColor = config.HoverColor or Constants.Colors.Accent.Hover
	local activeColor = config.ActiveColor or Constants.Colors.Accent.Active
	
	button.MouseEnter:Connect(function()
		wax.shared.TweenService:Create(
			button,
			Constants.TweenInfo.Default,
			{ BackgroundColor3 = hoverColor }
		):Play()
	end)
	
	button.MouseLeave:Connect(function()
		wax.shared.TweenService:Create(
			button,
			Constants.TweenInfo.Default,
			{ BackgroundColor3 = originalColor }
		):Play()
	end)
	
	button.MouseButton1Down:Connect(function()
		wax.shared.TweenService:Create(
			button,
			Constants.TweenInfo.Fast,
			{ BackgroundColor3 = activeColor }
		):Play()
	end)
	
	button.MouseButton1Up:Connect(function()
		wax.shared.TweenService:Create(
			button,
			Constants.TweenInfo.Fast,
			{ BackgroundColor3 = hoverColor }
		):Play()
	end)
	
	-- Click callback
	if config.OnClick then
		button.MouseButton1Click:Connect(config.OnClick)
	end
	
	return button
end

return ImprovedButton

end)() end,
    [45] = function()local wax,script,require=ImportGlobals(45)local ImportGlobals return (function(...)--[[[

Sonner Luau Port by upio
Original Sonner by Emil Kowalski (https://sonner.emilkowal.ski/)

TODO (which will almost probably never be done):
 - Add a way to view the previous notifications (hovering over the notifs but im lazy)
 - Handle too many notifications breaking the UI
 - Fix inconsistant notification positioning
]]

local Sonner = {
	Queue = {},
	TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
	Wrapper = nil,
	PendingQueue = {},
	Processing = false,
}

local Icons = require(script.Parent.Icons)
local Interface = require(script.Parent.Interface)
local Animations = require(script.Parent.Animations)

local function InternalCreateNotificationObject(zindex, image, text)
	local NotificationTemplate = Interface.New("CanvasGroup", {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		AnchorPoint = Vector2.new(0.5, 1),
		Size = UDim2.new(0, 250, 0, 50),
		Position = UDim2.new(0.5, 0, 1, 50),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = zindex,

		["UICorner"] = {
			CornerRadius = UDim.new(0, 4),
		},

		["UIStroke"] = {
			Color = Color3.fromRGB(39, 42, 42),
		},

		["UIScale"] = {},
	})

	local ImageLabel = Interface.New("ImageLabel", {
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.new(0, 20, 0, 20),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 20, 0.5, 0),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		ZIndex = zindex + 1,
		Parent = NotificationTemplate,
	})

	Animations.SetFadeExpectation("In", ImageLabel, {
		BackgroundTransparency = 1,
		ImageTransparency = 0,
	})

	if image then
		if image:find("rbxasset") then
			ImageLabel.Image = image
		else
			Icons.SetIcon(ImageLabel, image)
		end
	else
		ImageLabel.Visible = false
	end

	local Frame = Interface.New("Frame", {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(1, -50, 1, 0),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		ZIndex = zindex + 1,
		Parent = NotificationTemplate,
	})

	Interface.New("TextLabel", {
		BorderSizePixel = 0,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 200, 0, 50),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = text,
		ZIndex = zindex + 1,
		Parent = Frame,
		TextWrapped = true,
	})

	return NotificationTemplate
end

local function InternalToast(image, text, internalTime, removeCallback)
	assert(Sonner.Wrapper, "Sonner has not been initialized")
	assert(typeof(image) == "string" or image == nil, "Image must be a string or nil")
	assert(typeof(text) == "string", "Text is required!")
	assert(typeof(internalTime) == "number" or internalTime == nil, "Time must be a number or nil")

	local time = internalTime or 4.5

	local Notif = InternalCreateNotificationObject(500, image, text)

	Notif.Position = UDim2.new(0.5, 0, 1, 30)
	Notif.Parent = Sonner.Wrapper

	table.insert(Sonner.Queue, Notif)

	local ScaleMultiplier = 0.9
	local RemovalQueue = {}

	for index, object in Sonner.Queue do
		if object == Notif then
			continue
		end

		object.ZIndex = 500 - (#Sonner.Queue - index)

		-- shift them down
		wax.shared.TweenService
			:Create(object.UIScale, Sonner.TweenInfo, {
				Scale = object.UIScale.Scale * ScaleMultiplier,
			})
			:Play()

		wax.shared.TweenService
			:Create(object, Sonner.TweenInfo, {
				Position = object.Position - UDim2.fromOffset(0, object.AbsoluteSize.Y * 0.35),
			})
			:Play()

		if ((#Sonner.Queue - index) + 1) >= 4 then
			Animations.FadeOut(object)
			task.delay(0.5, function()
				object:Destroy()
			end)
			table.insert(RemovalQueue, object)
		end
	end

	for _, obj in RemovalQueue do
		table.remove(Sonner.Queue, table.find(Sonner.Queue, obj))
	end

	wax.shared.TweenService
		:Create(Notif, Sonner.TweenInfo, {
			Position = UDim2.new(0.5, 0, 1, -20),
		})
		:Play()
	Animations.FadeIn(Notif)

	if removeCallback then
		task.spawn(removeCallback, Notif, time)
	else
		task.delay(time, function()
			if not table.find(Sonner.Queue, Notif) then
				return
			end
			table.remove(Sonner.Queue, table.find(Sonner.Queue, Notif))

			Animations.FadeOut(Notif, 0.35)
			wax.shared.TweenService
				:Create(Notif, Sonner.TweenInfo, {
					Position = UDim2.new(0.5, 0, 1, 50),
				})
				:Play()
			task.wait(0.5)
			Notif:Destroy()
		end)
	end
end

local function ProcessQueue()
	if Sonner.Processing then
		return
	end
	Sonner.Processing = true

	while #Sonner.PendingQueue > 0 do
		local Request = table.remove(Sonner.PendingQueue, 1)
		InternalToast(Request.image, Request.text, Request.internalTime, Request.removeCallback)
		task.wait(0.5)
	end

	Sonner.Processing = false
end

local function toast(image, text, internalTime, removeCallback)
		local useNotifications = wax.shared.SaveManager:GetState("CustomNotifications", true)
		if not useNotifications then
			return
		end

		table.insert(Sonner.PendingQueue, {
			image = image,
			text = text,
			internalTime = internalTime,
			removeCallback = removeCallback,
		})
	
		task.spawn(ProcessQueue)
	end

function Sonner.info(text, internalTime)
	toast("info", text, internalTime)
end

function Sonner.success(text, internalTime)
	toast("circle-check", text, internalTime)
end

function Sonner.warning(text, internalTime)
	toast("triangle-alert", text, internalTime)
end

function Sonner.error(text, internalTime)
	toast("circle-alert", text, internalTime)
end

function Sonner.toast(text, internalTime)
	toast(nil, text, internalTime)
end

function Sonner.promise(func, options)
	local loadingText = options.loadingText or "Loading..."
	local successText = options.successText or "Success!"
	local errorText = options.errorText or "Error!"
	local internalTime = options.time or 4.5

	toast("loader-circle", loadingText, internalTime, function(notif, time)
		local success, resultOrError = nil, nil

		local spinnerThread = task.spawn(function()
			repeat
				wax.shared.RunService.RenderStepped:Wait()

				local icon = notif:FindFirstChild("ImageLabel")
				if not icon then
					continue
				end
				icon.Rotation = (icon.Rotation + 1) % 360
			until success == false or resultOrError ~= nil
		end)

		success, resultOrError = pcall(func, function(text)
			notif.Frame.TextLabel.Text = text
		end)

		task.spawn(function()
			setthreadidentity(8)

			-- The thread identity is 8 when setting it on the parent thread (Sonner.promise), but it still lacks capabilities when running another child thread
			-- Capabilities here should pass from a thread to another... Could be an upstream (executor) issue ?

			Animations.FadeOut(notif.ImageLabel, 0.15)
			wax.shared.TweenService
				:Create(notif.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = UDim2.new(0, 0, 0, 0),
				})
				:Play()
			task.wait(0.15)

			if coroutine.status(spinnerThread) ~= "dead" then
				coroutine.close(spinnerThread)
			end
			notif.ImageLabel.Rotation = 0

			if success then
				Icons.SetIcon(notif.ImageLabel, "check")
				local message = (
					typeof(successText) == "string" and successText
					or typeof(successText) == "function" and successText(resultOrError)
					or "Success!"
				)

				if message:match("%s") then
					notif.Frame.TextLabel.Text = string.format(message, tostring(resultOrError))
				else
					notif.Frame.TextLabel.Text = message
				end
			else
				Icons.SetIcon(notif.ImageLabel, "circle-alert")
				notif.Frame.TextLabel.Text = (
					typeof(errorText) == "string" and errorText
					or typeof(errorText) == "function" and errorText(resultOrError)
					or "Error!"
				)
			end

			Animations.FadeIn(notif.ImageLabel)
			wax.shared.TweenService
				:Create(notif.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = UDim2.new(0, 20, 0, 20),
				})
				:Play()

			task.delay(time, function()
				if not table.find(Sonner.Queue, notif) then
					return
				end
				table.remove(Sonner.Queue, table.find(Sonner.Queue, notif))

				Animations.FadeOut(notif, 0.35)
				wax.shared.TweenService
					:Create(notif, Sonner.TweenInfo, {
						Position = UDim2.new(0.5, 0, 1, 50),
					})
					:Play()

				task.wait(0.5)
				notif:Destroy()
			end)
		end)
	end)
end

function Sonner.rawtoast(options)
	local image = options.image
	local text = options.text or "No Text Provided"
	local internalTime = options.time or 4.5

	toast(image, text, internalTime)
end

function Sonner.init(wrapper)
	Sonner.Wrapper = wrapper
end

return Sonner

end)() end,
    [42] = function()local wax,script,require=ImportGlobals(42)local ImportGlobals return (function(...)local Interface = {}
local Icons = require(script.Parent.Icons)

local DefaultFont = Font.fromId(12187365364)
local _DefaultFontBold = Font.fromId(12187365364, Enum.FontWeight.Bold)

local DefaultProperties = {
	["Frame"] = {
		BorderSizePixel = 0,
	},
	["ScrollingFrame"] = {
		BorderSizePixel = 0,
	},
	["ImageLabel"] = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	},
	["ImageButton"] = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	},

	["TextLabel"] = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = DefaultFont,
		RichText = true,
		TextColor3 = Color3.new(1, 1, 1),
	},
	["TextButton"] = {
		AutoButtonColor = false,
		BorderSizePixel = 0,
		FontFace = DefaultFont,
		RichText = true,
		TextColor3 = Color3.new(1, 1, 1),
	},
	["TextBox"] = {
		BorderSizePixel = 0,
		FontFace = DefaultFont,
		ClipsDescendants = true,
		RichText = false,
		TextColor3 = Color3.new(1, 1, 1),
	},

	["UIListLayout"] = {
		SortOrder = Enum.SortOrder.LayoutOrder,
	},
}

function Interface.New(ClassName: string, Properties: { [string | number]: any })
	local Object = Instance.new(ClassName)

	for Key, Value in pairs(DefaultProperties[ClassName] or {}) do
		if Properties and Properties[Key] ~= nil then
			continue
		end

		Object[Key] = Value
	end

	for Key, Value in pairs(Properties or {}) do
		if typeof(Value) == "table" then
			local SubObject = Interface.New(Key, Value)
			SubObject.Parent = Object

			continue
		elseif typeof(Key) ~= "string" and typeof(Value) == "Instance" then
			local SubObject = Value:Clone()
			SubObject.Parent = Object

			continue
		end

		Object[Key] = Value
	end

	
function Interface.AddCorner(Object, Radius)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = Radius or UDim.new(0, 8)
    Corner.Parent = Object
    return Corner
end

return Object
end

function Interface.NewIcon(IconName: string, Properties: { [string]: any })
	local Image: ImageLabel = Interface.New("ImageLabel", Properties)
	Icons.SetIcon(Image, IconName)

	return Image
end

function Interface.HideCorner(Frame: GuiObject, Size: UDim2, Offset: Vector2): Frame
	local Hider = Interface.New("Frame", {
		AnchorPoint = Offset or Vector2.zero,
		BackgroundColor3 = Frame.BackgroundColor3,
		Position = UDim2.fromScale(Offset.X or 0, Offset.Y or 0),
		Size = Size,
		ZIndex = Frame.ZIndex,

		Parent = Frame,
	})

	return Hider
end

function Interface.GetScreenParent(): Instance
	if wax.shared.ExecutorName == "VOLT" then
		return wax.shared.CoreGui
	end
	
	local ScreenGui = Interface.New("ScreenGui", {})
	local HiddenUI = wax.shared.gethui()

	if pcall(function()
		ScreenGui.Parent = HiddenUI
		ScreenGui:Destroy()
	end) then
		return HiddenUI
	end

	return wax.shared.LocalPlayer:WaitForChild("PlayerGui")
end

return Interface

end)() end,
    [13] = function()local wax,script,require=ImportGlobals(13)local ImportGlobals return (function(...)local function CreateLookupTable(table)
	local LookupTable = {}
	for _, Method in next, table do
		LookupTable[Method] = true
	end
	return LookupTable
end

local NamecallMethods = CreateLookupTable({
	"FireServer",
	"InvokeServer",
	"Fire",
	"Invoke",
	"fireServer",
	"invokeServer",
	"fire",
	"invoke",
})
local AllowedClassNames = CreateLookupTable({ "RemoteEvent", "RemoteFunction", "UnreliableRemoteEvent", "BindableEvent", "BindableFunction" })

--[[
	Returns the calling function via `debug.info`

	@return `function | nil` The calling function or nil if not found.
]]
local function getcallingfunction()
	local BaseLevel = if wax.shared.ExecutorSupport["oth"].IsWorking then 2 else 4

	for i = BaseLevel, 10 do
		local Function, Source = debug.info(i, "fs")
		if not Function or not Source then
			break
		end

		if Source == "[C]" then
			continue
		end

		return Function
	end

	return debug.info(BaseLevel, "f")
end

--[[
	Returns the calling line of the script that called the function via `debug.info`

	@return number Returns the line number of the calling script.
]]
local function getcallingline()
	local BaseLevel = if wax.shared.ExecutorSupport["oth"].IsWorking then 2 else 4

	for i = BaseLevel, 10 do
		local Source, Line = debug.info(i, "sl")
		if not Source then
			break
		end

		if Source == "[C]" then
			continue
		end

		return Line
	end

	return debug.info(BaseLevel, "l")
end

--[[
	Returns the calling source of the script that called the function via `debug.info`

	@return string Returns the source of the calling script.
]]
local function getcallingsource()
	local BaseLevel = if wax.shared.ExecutorSupport["oth"].IsWorking then 2 else 4

	for i = BaseLevel, 10 do
		local Source = debug.info(i, "s")
		if not Source then
			break
		end

		if Source == "[C]" then
			continue
		end

		return Source
	end

	return debug.info(BaseLevel, "s")
end

-- metamethod hooks
wax.shared.NamecallHook = wax.shared.Hooking.HookMetaMethod(game, "__namecall", function(...)
	local self = ...
	local Method = getnamecallmethod()

	if
		typeof(self) == "Instance"
		and AllowedClassNames[self.ClassName]
		and not rawequal(self, wax.shared.Communicator)
		and not rawequal(self, wax.shared.ActorCommunicator)
		and NamecallMethods[Method]
		and not wax.shared.ShouldIgnore(self, getcallingscript())
	then
		local Log = wax.shared.Logs.Outgoing[self]
		if not Log then
			Log = wax.shared.NewLog(self, "Outgoing", Method, getcallingscript())
		end

		if Log.Blocked then
			return
		elseif not Log.Ignored then
			local Info = {
				Arguments = table.pack(select(2, ...)),
				Origin = getcallingscript(),
				Function = getcallingfunction(),
				Line = getcallingline(),
				Source = getcallingsource(),
				IsExecutor = checkcaller(),
			}
			Log:Call(Info)
			-- For RemoteFunction return value (ex: local result = RemoteFunction:InvokeServer())
			if self.ClassName == "RemoteFunction" and (Method == "InvokeServer" or Method == "invokeServer") then
				Log = wax.shared.Logs.Incoming[self]
				if not Log then
					Log = wax.shared.NewLog(self, "Incoming", Method, getcallingscript())
				end

				if Log.Blocked then
					return
				end

				local Result = table.pack(wax.shared.NamecallHook(...))
				if not Log.Ignored then
					local RFResultInfo = {
						Arguments = Result,
						Origin = getcallingscript(),
						Function = getcallingfunction(),
						Line = getcallingline(),
						Source = getcallingsource(),
						IsExecutor = checkcaller(),
						OriginalInvokeArgs = table.pack(select(2, ...)),
					}
					Log:Call(RFResultInfo)
				end

				return table.unpack(Result, 1, Result.n)
			end
		end
	end

	return wax.shared.NamecallHook(...)
end)

-- function hooks
local FunctionsToHook
do
	local BindableFunction = Instance.new("BindableFunction")
	local BindableEvent = Instance.new("BindableEvent")

	local RemoteFunction = Instance.new("RemoteFunction")
	local RemoteEvent = Instance.new("RemoteEvent")
	local UnreliableRemoteEvent = Instance.new("UnreliableRemoteEvent")

	FunctionsToHook = {
		BindableFunction.Invoke,
		BindableEvent.Fire,

		RemoteFunction.InvokeServer,
		RemoteEvent.FireServer,
		UnreliableRemoteEvent.FireServer,
	}

	BindableFunction:Destroy()
	BindableEvent:Destroy()

	RemoteFunction:Destroy()
	RemoteEvent:Destroy()
	UnreliableRemoteEvent:Destroy()
end

for _, Function in next, FunctionsToHook do
	local Method = debug.info(Function, "n")

	wax.shared.Hooks[Function] = wax.shared.Hooking.HookFunction(Function, function(...)
		local self = ...

		if
			typeof(self) == "Instance"
			and AllowedClassNames[self.ClassName]
			and not rawequal(self, wax.shared.Communicator)
			and not wax.shared.ShouldIgnore(self, getcallingscript())
		then
			local Log = wax.shared.Logs.Outgoing[self]
			if not Log then
				Log = wax.shared.NewLog(self, "Outgoing", Method, getcallingscript())
			end

			if Log.Blocked then
				return
			elseif not Log.Ignored then
				local Info = {
					Arguments = table.pack(select(2, ...)),
					Origin = getcallingscript(),
					Function = getcallingfunction(),
					Line = getcallingline(),
					Source = getcallingsource(),
					IsExecutor = checkcaller(),
				}
				Log:Call(Info)
				-- For RemoteFunction return value (ex: local result = RemoteFunction:InvokeServer())
				if self.ClassName == "RemoteFunction" and (Method == "InvokeServer" or Method == "invokeServer") then
					Log = wax.shared.Logs.Incoming[self]
					if not Log then
						Log = wax.shared.NewLog(self, "Incoming", Method, getcallingscript())
					end

					if Log.Blocked then
						return
					end

					local Result = table.pack(wax.shared.Hooks[Function](...))
					if not Log.Ignored then
						local RFResultInfo = {
							Arguments = Result,
							Origin = getcallingscript(),
							Function = getcallingfunction(),
							Line = getcallingline(),
							Source = getcallingsource(),
							IsExecutor = checkcaller(),
							OriginalInvokeArgs = table.pack(select(2, ...)),
						}
						Log:Call(RFResultInfo)
					end

					return table.unpack(Result, 1, Result.n)
				end
			end
		end

		return wax.shared.Hooks[Function](...)
	end)
end

end)() end,
    [25] = function()local wax,script,require=ImportGlobals(25)local ImportGlobals return (function(...)-- Logger
-- ActualMasterOogway
-- December 8, 2024

--[=[
    A simple logging utility that writes messages to a file. Supports different log levels
    and can be configured to overwrite or append to the log file.

    Log Format:  2024-12-04T15:28:31.131Z,0.131060,MyThread,Warning [FLog::RobloxStarter] Roblox stage ReadyForFlagFetch completed
                 <timestamp>,<elapsed_time>,<thread_id>,<level> <message>
]=]

local Logger = {}
Logger.__index = Logger

Logger.LOG_LEVELS = {
	ERROR = 1,
	WARNING = 2,
	INFO = 3,
	DEBUG = 4,
}

local LOG_LEVEL_STRINGS = {
	[Logger.LOG_LEVELS.ERROR] = "ERROR",
	[Logger.LOG_LEVELS.WARNING] = "WARNING",
	[Logger.LOG_LEVELS.INFO] = "INFO",
	[Logger.LOG_LEVELS.DEBUG] = "DEBUG",
}

local startTime = tick()

local function createDirectoryRecursive(path)
	local currentPath = ""
	for part in path:gmatch("[^\\/]+") do
		currentPath = currentPath .. part
		if not isfolder(currentPath) then
			makefolder(currentPath)
		end
		currentPath = currentPath .. "/"
	end
end

--[=[
    Generates a unique file name for the log file. The file name is based on the current
    job ID, ensuring it is unique per server instance but consistent across multiple
    executions within the same server.

    @return string A unique file name for the log file.
]=]
function Logger:GenerateFileName()
	local JobIdNumber = game.JobId:gsub("%D", "")
	local timestamp = os.date("!%Y%m%d%H%M%S")

	return `{self.logFileDirectory}/{JobIdNumber * 1.7 // 1.8}_{timestamp}.log`
end

--[=[
    Creates a new Logger instance.

    @param logFilePath string The path to the log file.
    @param logLevel number The minimum log level to write to the file. Defaults to INFO.
    @param overwrite boolean Whether to overwrite the log file or append to it. Defaults to false (append).
    @return Logger A new Logger instance.
]=]
function Logger.new(logFilePath: string, logLevel: number?, overwrite: boolean?)
	local self = setmetatable({}, Logger)
	self.logFilePath = logFilePath
	self.logFileDirectory = logFilePath:match("(.+)/")
	self.logLevel = logLevel or Logger.LOG_LEVELS.INFO
	self.overwrite = overwrite or false

	local folderPath, fileName = logFilePath:match("(.*[\\/])(.*)")

	if folderPath and not isfolder(folderPath) then
		createDirectoryRecursive(folderPath)
	end

	if self.overwrite then
		local success, err = pcall(writefile, self.logFilePath, "")
		if not success then
			warn(debug.traceback(`Failed to clear log file: {self.logFilePath} - {err}`, 2))
		end
	end

	self:Info("Logger", "Logger initialized")

	return self
end

--[=[
    Logs a message to the file.

    @param level number The log level of the message.
    @param threadId string The ID of the thread or source of the log message.
    @param message string The message to log.
]=]
function Logger:Log(level: number, threadId: string, message: string)
	if level <= self.logLevel then
		local levelStr = LOG_LEVEL_STRINGS[level]

		local timestamp = `{os.date("!%Y-%m-%dT%H:%M:%S")}{("%.3f"):format(tick() % 1)}Z`
		local elapsedTime = ("%.6f"):format(tick() - startTime)

		local logMessage = `{timestamp},{elapsedTime},{threadId},{levelStr} {message}\n`

		local success, err = pcall(appendfile, self.logFilePath, logMessage)
		if not success then
			warn(debug.traceback(`Failed to write to log file: {self.logFilePath} - {err}`, 2))
		end
	end
end

--[=[
    Logs a debug message.

    @param threadId string The ID of the thread or source of the log message.
    @param message string The message to log.
]=]
function Logger:Debug(threadId: string, message: string)
	self:Log(Logger.LOG_LEVELS.DEBUG, threadId, message)
end

--[=[
    Logs an info message.

    @param threadId string The ID of the thread or source of the log message.
    @param message string The message to log.
]=]
function Logger:Info(threadId: string, message: string)
	self:Log(Logger.LOG_LEVELS.INFO, threadId, message)
end

--[=[
    Logs a warning message.

    @param threadId string The ID of the thread or source of the log message.
    @param message string The message to log.
]=]
function Logger:Warning(threadId: string, message: string)
	self:Log(Logger.LOG_LEVELS.WARNING, threadId, message)
end

--[=[
    Logs an error message.

    @param threadId string The ID of the thread or source of the log message.
    @param message string The message to log.
]=]
function Logger:Error(threadId: string, message: string)
	self:Log(Logger.LOG_LEVELS.ERROR, threadId, message)
end

return Logger
end)() end,
    [26] = function()local wax,script,require=ImportGlobals(26)local ImportGlobals return (function(...)local Hooking = {}

local AlternativeEnabled = wax.shared.SaveManager:GetState("UseAlternativeHooks", false)
wax.shared.AlternativeEnabled = AlternativeEnabled

Hooking.HookFunction = function(Original, Replacement)
	if wax.shared.ExecutorSupport["oth"].IsWorking and iscclosure(Original) and islclosure(Replacement) then
		return oth.hook(Original, Replacement)
	end

	if islclosure(Replacement) then
		Replacement = wax.shared.newcclosure(Replacement)
	end

	if not wax.shared.ExecutorSupport["hookfunction"].IsWorking then
		return Original
	end

	return hookfunction(Original, Replacement)
end
Hooking.HookMetaMethod = function(object, method, hook)
	local Metatable = wax.shared.getrawmetatable(object)
	local originalMethod = rawget(Metatable, method)

	if wax.shared.ExecutorSupport["oth"].IsWorking then
		return oth.hook(originalMethod, hook)
	end

	if islclosure(hook) then
		hook = wax.shared.newcclosure(hook)
	end

	if
		AlternativeEnabled
		or (
			not wax.shared.ExecutorSupport["hookmetamethod"].IsWorking
			and wax.shared.ExecutorSupport["getrawmetatable"].IsWorking
		)
	then
		setreadonly(Metatable, false)
		rawset(Metatable, method, hook)
		setreadonly(Metatable, true)

		return originalMethod
	end

	if not wax.shared.ExecutorSupport["hookmetamethod"].IsWorking then
		if method == "__index" then
			local _, Metamethod = xpcall(function()
				return object[tostring(math.random())]
			end, function(err)
				return debug.info(2, "f")
			end)

			return Metamethod
		elseif method == "__newindex" then
			local _, Metamethod = xpcall(function()
				object[tostring(math.random())] = true
			end, function(err)
				return debug.info(2, "f")
			end)

			return Metamethod
		elseif method == "__namecall" then
			local _, Metamethod = xpcall(function()
				object:Mustard()
			end, function(err)
				return debug.info(2, "f")
			end)

			return Metamethod
		end

		return nil
	end

	return hookmetamethod(object, method, hook)
end

return Hooking

end)() end,
    [46] = function()error("[AOT COMPILER ERROR] Expected '(' when parsing function, got 'table'")end,
    [31] = function()local wax,script,require=ImportGlobals(31)local ImportGlobals return (function(...)-- LuaEncode - Fast table serialization library for pure Luau/Lua 5.1+
-- MIT License | Copyright (c) 2022-2025 Chad Hyatt <chad@hyatt.page>
-- https://github.com/chadhyatt/LuaEncode

--!optimize 2
--!native

local table, string, next, pcall, game, workspace, tostring, tonumber, getmetatable =
    table, string, next, pcall, game, workspace, tostring, tonumber, getmetatable

local GetFullPath = require(script.Parent.Parent.CodeGen.Generator).GetFullPath

local string_pack = string.pack
local string_byte = string.byte
local string_format = string.format
local string_char = string.char
local string_gsub = string.gsub
local string_match = string.match
local string_rep = string.rep
local string_sub = string.sub
local string_gmatch = string.gmatch

local table_concat = table.concat

local Type = typeof or type

local function LookupTable(array, lookupType)
    local Out = {}

    if lookupType == "key" then
        for Key, _ in next, array do
            Out[Key] = true
        end
    else
        for _, Value in next, array do
            Out[Value] = true
        end
    end

    return Out
end

-- Used for checking direct getfield syntax; Lua keywords can't be used as keys without being a str
-- FYI; `continue` is Luau only (in Lua it's actually a global function)
local LuaKeywords = LookupTable({
    "and", "break", "do", "else",
    "elseif", "end", "false", "for",
    "function", "if", "in", "local",
    "nil", "not", "or", "repeat",
    "return", "then", "true", "until",
    "while", "continue"
})

-- Used to properly serialize NaN values
local NumberCorrection = {
	[string_pack(">n", 0 / 0)] = "0/0",
	[string_pack(">n", -(0 / 0))] = "-(0/0)",
	[string_pack(">n", tonumber("nan"))] = 'tonumber("nan")',
	[string_pack(">n", tonumber("-nan"))] = 'tonumber("-nan")',
}

-- Type names that can be used as manual key indexes (i.e. non-reference types)
local KeyIndexTypes = LookupTable({
    "number", "string", "boolean", "Enum",
    "EnumItem", "Enums"
})

local DirectIndexPat = "^[A-Za-z_][A-Za-z0-9_]*$"

local function CheckType(inputData, dataName, ...)
    local ValidTypes = { ... }
    local ValidTypesLookup = LookupTable(ValidTypes)
    local InputType = Type(inputData)

    if not ValidTypesLookup[InputType] then
        error(string_format(
            "LuaEncode: Incorrect type for `%s`: `%s` expected, got `%s`",
            dataName,
            table_concat(ValidTypes, ", "), -- For if multiple types are accepted
            InputType
        ), 0)
    end

    return inputData
end

-- This re-serializes a string back into Lua, for the interpreter AND humans to read. This fixes
-- `string_format("%q")` only outputting in system encoding, instead of explicit Lua byte escapes
local SerializeString
do
    -- These are control characters to be encoded in a certain way in Lua rather than just a byte escape
    local SpecialCharacters = {
        ["\""] = "\\\"",
        ["\\"] = "\\\\",
        ["\a"] = "\\a",
        ["\b"] = "\\b",
        ["\t"] = "\\t",
        ["\n"] = "\\n",
        ["\v"] = "\\v",
        ["\f"] = "\\f",
        ["\r"] = "\\r",
    }

    for Index = 0, 255 do
        local Character = string_char(Index)

        if not SpecialCharacters[Character] and (Index < 32 or Index > 126) then
            SpecialCharacters[Character] = string_format("\\x%02X", Index)
        end
    end

    function SerializeString(inputString)
        -- FYI; We can't do "\0-\31" in Lua 5.1 (Only Luau/Lua 5.2+) due to an embedded zeros in pattern
        -- issue. See: https://stackoverflow.com/a/22962409
        return table_concat({ '"', string_gsub(inputString, "[%z\\\"\1-\31\127-\255]", SpecialCharacters), '"' })
    end
end

-- Escape warning messages and such for comment block inserts
local function CommentBlock(inputString)
    local Longest = -1
    for Match in string_gmatch(inputString, "%](=*)%]") do
        if #Match > Longest then
            Longest = #Match
        end
    end

    local Padding = string_rep("=", Longest + 1)
    return "--[" .. Padding .. "[" .. inputString .. "]" .. Padding .. "]"
end

--[[
LuaEncode(inputTable: {[any]: any}, options: {[string]: any}): string

    ---------- OPTIONS: ----------

    Prettify <boolean:false> | Whether or not the output should be pretty printed

    IndentCount <number:0> | The amount of characters that should be used for indents
    (**Note**: If `Prettify` is set to true and this is unspecified, it will default to `4`)

    InsertCycles <boolean:false> | If there are cyclic references in your table, the output
    will be wrapped in an anonymous function that manually sets paths to those references.
    (**NOTE:** If a key in the index path to the cycle is a reference type (e.g. `table`,
    `function`), the codegen can't externally set that path, and the value will have to be ignored)

    OutputWarnings <boolean:true> | If "warnings" should be placed into the output as
    comment blocks

    UseInstancePaths <boolean:true> | If Roblox `Instance` values should return their
    Lua-accessable path for serialization. If the instance is parented under `nil` or
    isn't under `game`/`workspace`, it'll always fall back to `Instance.new(ClassName)`

    UseFindFirstChild  <boolean:true> | When `options.UseInstancePaths` is true, whether or
    not instance paths should use `FindFirstChild` instead of direct indexes

    SerializeMathHuge <boolean:true> | If "infinite" (or negative-infinite) numbers should
    be serialized as `math.huge`. (uses the `math` global, as opposed to just a direct data
    type) If false, "`1/0`" or "`-1/0`" will be serialized, which is supported on all
    target Lua environments

]]

local function LuaEncode(inputTable, options)
    options = options or {}

    CheckType(inputTable, "inputTable", "table")
    CheckType(options, "options", "table")

    CheckType(options.Prettify, "options.Prettify", "boolean", "nil")
    CheckType(options.PrettyPrinting, "options.PrettyPrinting", "boolean", "nil") -- Alias for `Options.Prettify`
    CheckType(options.IndentCount, "options.IndentCount", "number", "nil")
    CheckType(options.InsertCycles, "options.InsertCycles", "boolean", "nil")
    CheckType(options.OutputWarnings, "options.OutputWarnings", "boolean", "nil")
    CheckType(options.FunctionsReturnRaw, "options.FunctionsReturnRaw", "boolean", "nil")
    CheckType(options.UseInstancePaths, "options.UseInstancePaths", "boolean", "nil")
    CheckType(options.UseFindFirstChild, "options.UseFindFirstChild", "boolean", "nil")
    CheckType(options.SerializeMathHuge, "options.SerializeMathHuge", "boolean", "nil")
    CheckType(options.DisableNilParentHandler, "options.DisableNilParentHandler", "boolean", "nil")
    CheckType(options.IsArray, "options.IsArray", "boolean", "nil")

    CheckType(options._StackLevel, "options._StackLevel", "number", "nil")
    CheckType(options._VisitedTables, "options._VisitedTables", "table", "nil")
    CheckType(options._SharedTableLarpAsRegTable, "options._SharedTableLarpAsRegTable", "boolean", "nil")

    local Prettify = (options.Prettify == nil and options.PrettyPrinting == nil and false) or
        (options.Prettify ~= nil and options.Prettify) or (options.PrettyPrinting and options.PrettyPrinting)
    local IndentCount = options.IndentCount or (Prettify and 4) or 0
    local InsertCycles = (options.InsertCycles == nil and false) or options.InsertCycles
    local OutputWarnings = (options.OutputWarnings == nil and true) or options.OutputWarnings
    local UseInstancePaths = (options.UseInstancePaths == nil and true) or options.UseInstancePaths
    local DisableNilParentHandler = options.DisableNilParentHandler or false
    local SerializeMathHuge = (options.SerializeMathHuge == nil and true) or options.SerializeMathHuge
    local IsArray = (options.IsArray == nil and false) or options.IsArray

    local StackLevelOpt = options._StackLevel or 1
    local VisitedTables = options._VisitedTables or {} -- [Ref: table] = true
    local SharedTableLarpAsRegTable = options._SharedTableLarpAsRegTable or false
    local DidInsertNilFunction = options._DidInsertNilFunction or false

    -- Lazy serialization reference values
    local PositiveInf = (SerializeMathHuge and "math.huge") or "1/0"
    local NegativeInf = (SerializeMathHuge and "-math.huge") or "-1/0"
    local NewEntryString = (Prettify and "\n") or ""
    local CodegenNewline = (Prettify and "\n") or " "
    local ValueSeperator = (Prettify and ", ") or ","
    local BlankSeperator = (Prettify and " ") or ""
    local EqualsSeperator = (Prettify and " = ") or "="

    local StackLevel = StackLevelOpt

    -- For pretty printing we need to keep track of the current stack level, then repeat IndentString by that count
    local IndentStringBase = string_rep(" ", IndentCount)

    -- Calculated in the walk loop, based on the current StackLevel
    local IndentString = nil
    local EndingIndentString = nil

    --IndentString = (Prettify and string_rep(IndentString, StackLevel)) or IndentString
    --local EndingIndentString = (#IndentString > 0 and string_sub(IndentString, 1, -IndentCount - 1)) or ""

    -- For number key values, we want to explicitly serialize the index num ONLY when it needs to be
    local KeyNumIndex = 1

    -- Cases for encoding values, then end setup. Functions are all expected to return a (EncodedKey: string, EncloseInBrackets: boolean)
    local TypeCases = {}
    do
        local function TypeCase(typeName, value, ...)
            local EncodedValue = TypeCases[typeName](value, false, ...) -- False to label as NOT `isKey`
            return EncodedValue
        end

        local function Args(...)
            local EncodedValues = {}

            for _, Arg in next, { ... } do
                EncodedValues[#EncodedValues + 1] = TypeCase(
                    Type(Arg),
                    Arg
                )
            end

            return table_concat(EncodedValues, ValueSeperator)
        end

        -- For Roblox's different `Params` data types
        local function Params(newData, params)
            return "(function(p, t) for n, v in next, t do p[n] = v end return p end)(" ..
                table_concat({ newData, TypeCase("table", params) }, ValueSeperator) ..
                ")"
        end

        TypeCases["number"] = function(value, isKey)
			-- If the number isn't the current real index of the table, we DO want to
			-- explicitly define it in the serialization no matter what for accuracy
			if isKey and value == KeyNumIndex then
				-- ^^ What's EXPECTED unless otherwise explicitly defined, if so, return no encoded num
				KeyNumIndex = KeyNumIndex + 1
				return nil, true
			end

			-- Lua's internal `tostring` handling will denote positive/negativie-infinite number TValues as "inf", which
			-- makes certain numbers not encode properly. We also just want to make the output precise
			if value == 1 / 0 then
				return PositiveInf
			elseif value == -1 / 0 then
				return NegativeInf
			elseif value == math.pi then
				return "math.pi"
			end

			-- Provided by felixdm
			local NumberPacked = string_pack(">n", value) -- gameguy is a boss
			local CorrectedNumber = NumberCorrection[NumberPacked]
			if CorrectedNumber then
				return CorrectedNumber
			end

			if value ~= value then
				return string_format(
					'(string.unpack(">n", "\\%*\\%*\\%*\\%*\\%*\\%*\\%*\\%*"))',
					string_byte(NumberPacked, 1, 8)
				)
			end

			-- Return fixed-formatted precision num
			return string_format("%.14g", value)
		end

        TypeCases["string"] = function(value, isKey)
            if isKey and not LuaKeywords[value] and string_match(value, DirectIndexPat) then
                -- Doesn't need full string def
                return value, true
            end

            return SerializeString(value)
        end

        -- This is NOT used for recursive table serialization, only table-as-key values and Roblox data types that use tables as
        -- arguments for constructor functions
        TypeCases["table"] = function(value, isKey, stLarpAsRegTable)
            -- Primarily for tables-as-keys
            if VisitedTables[value] and OutputWarnings then
                return "{--[[LuaEncode: Duplicate reference]]}"
            end

            local NewOptions = setmetatable({}, { __index = options })
            do
                NewOptions.Prettify = (isKey and false) or Prettify
                NewOptions.IndentCount = (isKey and ((not Prettify and IndentCount) or 1)) or IndentCount
                NewOptions._StackLevel = (isKey and 1) or StackLevel + 1
                NewOptions._VisitedTables = VisitedTables
                NewOptions._SharedTableLarpAsRegTable = (not isKey and stLarpAsRegTable)
                NewOptions.IsArray = false
                NewOptions._DidInsertNilFunction = DidInsertNilFunction
            end

            local Result, DidInsertNilFunction = LuaEncode(value, NewOptions)
            if DidInsertNilFunction then
                DidInsertNilFunction = true
            end

            return Result
        end

        TypeCases["boolean"] = function(value)
            return value and "true" or "false"
        end

        TypeCases["nil"] = function(value)
            return "nil"
        end

        TypeCases["thread"] = function(value)
			return "task.spawn(function() end)"
		end

        TypeCases["function"] = function(value)
			-- We can't serialize functions so we just return a comment block with function information
			local FunctionName, ArgumentCount, VarArg, Line = debug.info(value, "nal")

			local Arguments = {}
			for Index = 1, ArgumentCount do
				Arguments[Index] = string_format("arg%d", Index)
			end

			return string_format(
				[[function(%s)%s%s%s%s%sreturn%send]],
				`{table_concat(Arguments, ", ")}{VarArg and `{Arguments[1] and ", " or ""}...` or ""}`,

				`{CodegenNewline}{IndentString}{IndentStringBase}-- Name: {FunctionName == "" and "Anonymous Function" or FunctionName} | Line: {Line}`,

				`{CodegenNewline}{IndentString}{IndentStringBase}-- {islclosure(value) and `Upvalues: {#debug.getupvalues(
					value
				)}` or "Upvalues: N/A (C Closure)"}`,

				`{CodegenNewline}{IndentString}{IndentStringBase}-- `
					.. (
						getfunctionhash
							and `{islclosure(value) and `Function Hash: {getfunctionhash(value)}` or "Function Hash: N/A (C Closure)"}`
						or "Function Hash: N/A (getfunctionhash == nil)"
					),

				OutputWarnings
						and `{CodegenNewline}{IndentString}{IndentStringBase}-- LuaEncode: Unable to serialize function`
					or "",

				`{CodegenNewline}{IndentString}{IndentStringBase}`,
				`{CodegenNewline}{IndentString}`
			)
		end

        ---------- ROBLOX CUSTOM DATA TYPES BELOW ----------

        TypeCases["Axes"] = function(value)
            local EncodedArgs = {}
            local EnumValues = {
                ["Enum.Axis.X"] = value.X,
                ["Enum.Axis.Y"] = value.Y,
                ["Enum.Axis.Z"] = value.Z,
            }

            for EnumValue, IsEnabled in next, EnumValues do
                if IsEnabled then
                    EncodedArgs[#EncodedArgs + 1] = EnumValue
                end
            end

            return "Axes.new(" .. table_concat(EncodedArgs, ValueSeperator) .. ")"
        end

        TypeCases["BrickColor"] = function(value)
            -- BrickColor.Number (Its enum ID) will be slightly more efficient in all cases in deser,
            -- so we'll use it if Options.Prettify is false
            return "BrickColor.new(" ..
                ((Prettify and TypeCase("string", value.Name)) or value.Number) ..
                ")"
        end

        TypeCases["CFrame"] = function(value)
            return "CFrame.new(" .. Args(value:components()) .. ")"
        end

        TypeCases["CatalogSearchParams"] = function(value)
            return Params("CatalogSearchParams.new()", {
                SearchKeyword = value.SearchKeyword,
                MinPrice = value.MinPrice,
                MaxPrice = value.MaxPrice,
                SortType = value.SortType,             -- EnumItem
                CategoryFilter = value.CategoryFilter, -- EnumItem
                BundleTypes = value.BundleTypes,       -- table
                AssetTypes = value.AssetTypes          -- table
            })
        end

        TypeCases["Color3"] = function(value)
            return "Color3.new(" .. Args(value.R, value.G, value.B) .. ")"
        end

        TypeCases["ColorSequence"] = function(value)
            return "ColorSequence.new(" .. TypeCase("table", value.Keypoints) .. ")"
        end

        TypeCases["ColorSequenceKeypoint"] = function(value)
            return "ColorSequenceKeypoint.new(" .. Args(value.Time, value.Value) .. ")"
        end

        TypeCases["DateTime"] = function(value)
            return "DateTime.fromUnixTimestamp(" .. value.UnixTimestamp .. ")"
        end

        -- Properties seem to throw an error on index if the scope isn't a Studio plugin, so we're
        -- directly getting values! (so fun!!!!)
        TypeCases["DockWidgetPluginGuiInfo"] = function(value)
            -- e.g.: "InitialDockState:Right InitialEnabled:0 InitialEnabledShouldOverrideRestore:0 FloatingXSize:0 FloatingYSize:0 MinWidth:0 MinHeight:0"
            local ValueString = tostring(value)

            return "DockWidgetPluginGuiInfo.new(" ..
                Args(
                -- InitialDockState (Enum.InitialDockState)
                    Enum.InitialDockState[string_match(ValueString, "InitialDockState:(%w+)")],    -- Enum.InitialDockState.Right
                    -- InitialEnabled and InitialEnabledShouldOverrideRestore (boolean as number; `0` or `1`)
                    string_match(ValueString, "InitialEnabled:(%w+)") == "1",                      -- false
                    string_match(ValueString, "InitialEnabledShouldOverrideRestore:(%w+)") == "1", -- false
                    -- FloatingXSize/FloatingYSize (numbers)
                    tonumber(string_match(ValueString, "FloatingXSize:(%w+)")),                    -- 0
                    tonumber(string_match(ValueString, "FloatingYSize:(%w+)")),                    -- 0
                    -- MinWidth/MinHeight (numbers)
                    tonumber(string_match(ValueString, "MinWidth:(%w+)")),                         -- 0
                    tonumber(string_match(ValueString, "MinHeight:(%w+)"))                         -- 0
                ) ..
                ")"
        end

        -- e.g. `Enum.UserInputType`
        TypeCases["Enum"] = function(value)
            local ValueString = tostring(value)

            if string_match(ValueString, DirectIndexPat) then
                return "Enum." .. ValueString
            end
            return "Enum[" .. SerializeString(ValueString) .. "]"
        end

        -- e.g. `Enum.UserInputType.Gyro`
        TypeCases["EnumItem"] = function(value)
            local EnumTypeStr = TypeCase("Enum", value.EnumType)
            local EnumName = value.Name

            if string_match(EnumName, DirectIndexPat) then
                return EnumTypeStr .. "." .. value.Name
            end
            return EnumTypeStr .. "[" .. SerializeString(EnumName) .. "]"
        end

        -- i.e. the `Enum` global return
        TypeCases["Enums"] = function(value)
            return "Enum"
        end

        TypeCases["Faces"] = function(value)
            local EncodedArgs = {}
            local EnumValues = {
                ["Enum.NormalId.Top"] = value.Top, -- These return bools
                ["Enum.NormalId.Bottom"] = value.Bottom,
                ["Enum.NormalId.Left"] = value.Left,
                ["Enum.NormalId.Right"] = value.Right,
                ["Enum.NormalId.Back"] = value.Back,
                ["Enum.NormalId.Front"] = value.Front,
            }

            for EnumValue, IsEnabled in next, EnumValues do
                if IsEnabled then
                    EncodedArgs[#EncodedArgs + 1] = EnumValue
                end
            end

            return "Faces.new(" .. table_concat(EncodedArgs, ValueSeperator) .. ")"
        end

        TypeCases["FloatCurveKey"] = function(value)
            return "FloatCurveKey.new(" .. Args(value.Time, value.Value, value.Interpolation) .. ")"
        end

        TypeCases["Font"] = function(value)
            return "Font.new(" .. Args(value.Family, value.Weight, value.Style) .. ")"
        end

        -- Instance refs can be evaluated to their paths (optional), but if parented to
        -- nil or some DataModel not under `game`, it'll just return nil
        TypeCases["Instance"] = function(value)
			if UseInstancePaths then
				local InstancePath, NilFunctionInserted = GetFullPath(value, {
					DisableNilParentHandler = DisableNilParentHandler,
					OmitNilFunctionGetterCodeGeneration = true
				})

				if NilFunctionInserted then
					DidInsertNilFunction = true
				end

				if InstancePath then
					return InstancePath
				end

				-- ^^ Now, if the path isn't accessable, falls back to the return below anyway
			end

			return "nil"
				.. BlankSeperator
				.. CommentBlock("Instance.new(" .. TypeCase("string", value.ClassName) .. ")")
		end

        TypeCases["NumberRange"] = function(value)
            return "NumberRange.new(" .. Args(value.Min, value.Max) .. ")"
        end

        TypeCases["NumberSequence"] = function(value)
            return "NumberSequence.new(" .. TypeCase("table", value.Keypoints) .. ")"
        end

        TypeCases["NumberSequenceKeypoint"] = function(value)
            return "NumberSequenceKeypoint.new(" .. Args(value.Time, value.Value, value.Envelope) .. ")"
        end

        TypeCases["OverlapParams"] = function(value)
            return Params("OverlapParams.new()", {
                FilterDescendantsInstances = value.FilterDescendantsInstances,
                FilterType = value.FilterType,
                MaxParts = value.MaxParts,
                CollisionGroup = value.CollisionGroup,
                RespectCanCollide = value.RespectCanCollide
            })
        end

        TypeCases["Path2DControlPoint"] = function(value)
            return "Path2DControlPoint.new(" .. Args(value.Position, value.LeftTangent, value.RightTangent) .. ")"
        end

        TypeCases["PathWaypoint"] = function(value)
            return "PathWaypoint.new(" .. Args(value.Position, value.Action, value.Label) .. ")"
        end

        TypeCases["PhysicalProperties"] = function(value)
            return "PhysicalProperties.new(" ..
                Args(
                    value.Density,
                    value.Friction,
                    value.Elasticity,
                    value.FrictionWeight,
                    value.ElasticityWeight
                ) ..
                ")"
        end

        TypeCases["Random"] = function()
            return "Random.new()"
        end

        TypeCases["Ray"] = function(value)
            return "Ray.new(" .. Args(value.Origin, value.Direction) .. ")"
        end

        TypeCases["RaycastParams"] = function(value)
            return Params("RaycastParams.new()", {
                FilterDescendantsInstances = value.FilterDescendantsInstances,
                FilterType = value.FilterType,
                IgnoreWater = value.IgnoreWater,
                CollisionGroup = value.CollisionGroup,
                RespectCanCollide = value.RespectCanCollide
            })
        end

        TypeCases["Rect"] = function(value)
            return "Rect.new(" .. Args(value.Min, value.Max) .. ")"
        end

        -- Roblox doesn't provide direct read properties for min/max on `Region3`, but they do on Region3int16..
        TypeCases["Region3"] = function(value)
            local ValuePos = value.CFrame.Position
            local ValueSize = 0.5 * value.Size

            return "Region3.new(" ..
                Args(
                    ValuePos - ValueSize, -- Minimum
                    ValuePos + ValueSize  -- Maximum
                ) ..
                ")"
        end

        TypeCases["Region3int16"] = function(value)
            return "Region3int16.new(" .. Args(value.Min, value.Max) .. ")"
        end

        TypeCases["TweenInfo"] = function(value)
            return "TweenInfo.new(" ..
                Args(
                    value.Time,
                    value.EasingStyle,
                    value.EasingDirection,
                    value.RepeatCount,
                    value.Reverses,
                    value.DelayTime
                ) ..
                ")"
        end

        TypeCases["RotationCurveKey"] = function(value)
            return "RotationCurveKey.new(" .. Args(value.Time, value.Value, value.Interpolation) .. ")"
        end

        TypeCases["UDim"] = function(value)
            return "UDim.new(" .. Args(value.Scale, value.Offset) .. ")"
        end

        TypeCases["UDim2"] = function(value)
            return "UDim2.new(" ..
                Args(
                    value.X.Scale,
                    value.X.Offset,
                    value.Y.Scale,
                    value.Y.Offset
                ) ..
                ")"
        end

        TypeCases["Vector2"] = function(value)
            return "Vector2.new(" .. Args(value.X, value.Y) .. ")"
        end

        TypeCases["Vector2int16"] = function(value)
            return "Vector2int16.new(" .. Args(value.X, value.Y) .. ")"
        end

        TypeCases["Vector3"] = function(value)
            return "Vector3.new(" .. Args(value.X, value.Y, value.Z) .. ")"
        end

        TypeCases["Vector3int16"] = function(value)
            return "Vector3int16.new(" .. Args(value.X, value.Y, value.Z) .. ")"
        end

        TypeCases["buffer"] = function(value)
            return "buffer.fromstring(" .. SerializeString(buffer.tostring(value)) .. ")"
        end

        TypeCases["SharedTable"] = function(value, isKey)
            local StClone = {}
            -- Will still compile in vanilla Lua if we do it this way. We should probably create a deep clone
            -- of the current state of the table regardless
            for Key, Value in SharedTable.clone(value, not SharedTableLarpAsRegTable) do
                StClone[Key] = Value
            end

            local StCloneStr = TypeCases["table"](StClone, isKey, true) -- 3rd arg is stLarpAsRegTable
            if SharedTableLarpAsRegTable then
                return StCloneStr
            end
            return table_concat({ "SharedTable.new(", StCloneStr, ")" })
        end

        TypeCases["userdata"] = function(value)
            if getmetatable(value) ~= nil then -- Has mt
                return "newproxy(true)"
            else
                return "newproxy()" -- newproxy() defaults to false (no mt)
            end
        end
    end

    -- Setup for final output, which will be concat together
    local Output = {}

    local TablePointer = inputTable
    local NextKey = nil     -- Used with TableStack so the TablePointer loop knows where to continue from upon stack pop
    local IsNewTable = true -- Used with table stack push/pop to identify when an opening curly brace should be added

    -- Stack array for table depth
    local TableStack = {}                   -- [Depth: number] = {TablePointer: table, NextKey: any, KeyNumIndex: number}
    local RefMaps = { [TablePointer] = "" } -- [Ref: table] = ".example["ref path"]'
    local CycleMaps = {}                    -- ['.example["ref path"]'] = '.another["ref path"]'

    if IsArray then
        NextKey = 1
    end

    while TablePointer do
        -- Update StackLevel for formatting
        StackLevel = StackLevelOpt + #TableStack
        IndentString = (Prettify and string_rep(IndentStringBase, StackLevel)) or IndentStringBase
        EndingIndentString = (#IndentString > 0 and string_sub(IndentString, 1, -IndentCount - 1)) or ""
        
        local HasNextValue = (IsArray and NextKey < TablePointer["n"]) or (not IsArray and next(TablePointer, NextKey) ~= nil)
        
        -- Only append an opening brace to the table if this isn't just a continution up the stack
        if IsNewTable then
            Output[#Output + 1] = "{"
        elseif not HasNextValue then -- Formatting for the next entry still needs to be added like any other value
            Output[#Output + 1] = NewEntryString .. EndingIndentString
        else
            Output[#Output + 1] = ","
        end

        VisitedTables[TablePointer] = true

        -- Just because of control flow restrictions with Lua compatibility
        local SkipStackPop = false

        local function WalkTable(Key, Value)
            local KeyType, ValueType = Type(Key), Type(Value)
            local ValueIsTable = ValueType == "table"
            local KeyTypeCase, ValueTypeCase = TypeCases[KeyType], TypeCases[ValueType]

            Output[#Output + 1] = NewEntryString .. IndentString

            if KeyTypeCase and ValueTypeCase then
                local ValueWasEncoded = false -- Keeping track of this for adding a "," to the output if needed

                -- Evaluate output for key
                local KeyEncodedSuccess, EncodedKeyOrError, DontEncloseKeyInBrackets = pcall(KeyTypeCase, Key,
                    true) -- The `true` represents if it's a key or not, here it is

                -- Evaluate output for value, ignoring 2nd arg (`DontEncloseInBrackets`) because this isn't the key
                local ValueEncodedSuccess, EncodedValueOrError
                if not ValueIsTable then
                    ValueEncodedSuccess, EncodedValueOrError = pcall(ValueTypeCase, Value, false)
                end

                -- Ignoring `if EncodedKeyOrError` because the key doesn't actually need to ALWAYS
                -- be explicitly encoded, like if it's a number of the current key index!
                if KeyEncodedSuccess and (ValueIsTable or (ValueEncodedSuccess and EncodedValueOrError)) then
                    -- Append explicit key if necessary
                    if EncodedKeyOrError then
                        if DontEncloseKeyInBrackets then
                            Output[#Output + 1] = EncodedKeyOrError
                        else
                            Output[#Output + 1] = table_concat({ "[", EncodedKeyOrError, "]" })
                        end

                        Output[#Output + 1] = EqualsSeperator
                    end

                    -- Of course, recursive tables are handled differently and use the stack system
                    if ValueIsTable then
                        local IndexPath
                        if InsertCycles and KeyIndexTypes[KeyType] and RefMaps[TablePointer] then
                            if KeyType == "string" and not LuaKeywords[Key] and string_match(Key, DirectIndexPat) then
                                IndexPath = "." .. Key
                            else
                                local EncodedKeyAsValue = TypeCases[KeyType](Key)
                                IndexPath = table_concat({ "[", EncodedKeyAsValue, "]" })
                            end
                        end

                        if not VisitedTables[Value] then
                            if IndexPath then
                                RefMaps[Value] = RefMaps[TablePointer] .. IndexPath
                            end

                            TableStack[#TableStack + 1] = { TablePointer, Key, KeyNumIndex, IsArray }

                            TablePointer = Value
                            NextKey = nil
                            KeyNumIndex = 1
                            IsArray = false -- Nested tables are not treated as arrays with 'n' field

                            IsNewTable = true
                            SkipStackPop = true

                            return false -- break
                        else
                            EncodedValueOrError = string_format(
                                "{%s}",
                                (OutputWarnings and "--[[LuaEncode: Duplicate reference]]") or ""
                            )

                            if IndexPath then
                                CycleMaps[IndexPath] = RefMaps[Value]
                            end
                        end
                    end

                    -- Append value like normal
                    Output[#Output + 1] = EncodedValueOrError

                    ValueWasEncoded = true
                elseif OutputWarnings then -- Then `Encoded(Key/Value)OrError` is the error msg
                    -- ^^ Then either the key or value wasn't properly checked or encoded, and there
                    -- was an error we need to log!
                    local ErrorMessage = string_format(
                        "LuaEncode: Failed to serialize %s of data type %s: %s",
                        (not KeyEncodedSuccess and "key") or (not ValueEncodedSuccess and "value") or "key/value",
                        ValueType,
                        (not KeyEncodedSuccess and SerializeString(EncodedKeyOrError)) or
                        (not ValueEncodedSuccess and SerializeString(EncodedValueOrError)) or
                        "(Failed to get error message)"
                    )

                    Output[#Output + 1] = CommentBlock(ErrorMessage)
                end

                local HasNextValue = (IsArray and Key < TablePointer["n"]) or (not IsArray and next(TablePointer, Key) ~= nil)
                if not HasNextValue then
                    -- If there isn't another value after the current index, add ending formatting
                    Output[#Output + 1] = NewEntryString .. EndingIndentString
                elseif ValueWasEncoded then
                    Output[#Output + 1] = ","
                end
            else
                -- Data type is unimplemented

                -- Dtc
                local KeyTostring = (KeyType == "userdata" and "userdata") or
                    tostring(Key)
                local ValueTostring = (ValueType == "userdata" and "userdata") or
                    tostring(Value)

                Output[#Output + 1] = CommentBlock(BlankSeperator ..
                    KeyType .. "(" .. SerializeString(KeyTostring) .. ")" ..
                    ":" .. BlankSeperator ..
                    ValueType .. "(" .. SerializeString(ValueTostring) .. ")" ..
                    BlankSeperator)

                local HasNextValue = (IsArray and Key < TablePointer["n"]) or (not IsArray and next(TablePointer, Key) ~= nil)
                if not HasNextValue then
                    Output[#Output + 1] = NewEntryString .. EndingIndentString
                end
            end

            return true
        end

        if IsArray then
            -- When returning from a nested table, continue from NextKey + 1 instead of 1
            local StartIndex = IsNewTable and 1 or (NextKey + 1)
            for Index = StartIndex, TablePointer["n"] do
                local Success = WalkTable(Index, rawget(TablePointer, Index))
                if not Success then
                    break
                end
            end
        else
            for Key, Value in next, TablePointer, NextKey do
                local Success = WalkTable(Key, Value)
                if not Success then
                    break
                end
            end
        end

        -- Vanilla Lua control flow is fun
        if not SkipStackPop then
            if not Prettify and IndentCount > 0 then
                Output[#Output + 1] = IndentString
            end
            Output[#Output + 1] = "}"

            if #TableStack > 0 then
                local TableUp = TableStack[#TableStack]
                TableStack[#TableStack] = nil -- Pop off the table stack

                TablePointer, NextKey, KeyNumIndex, IsArray = TableUp[1], TableUp[2], TableUp[3], TableUp[4]
                IsNewTable = false
            else
                break
            end
        end
    end

    if InsertCycles then
        local CycleMapsOut = {}
        for CycleIndex, CycleMap in next, CycleMaps do
            CycleMapsOut[#CycleMapsOut + 1] = IndentString ..
                "t" .. CycleIndex .. EqualsSeperator .. "t" .. CycleMap .. CodegenNewline
        end

        if #CycleMapsOut > 0 then
            return table_concat({ "(function(t)", NewEntryString, table_concat(CycleMapsOut), NewEntryString,
                IndentString, "return t", CodegenNewline, "end)(", table_concat(Output), ")" }), DidInsertNilFunction
        end
    end

    return table_concat(Output), DidInsertNilFunction
end

return LuaEncode
end)() end,
    [27] = function()local wax,script,require=ImportGlobals(27)local ImportGlobals return (function(...)local Log = {}
Log.__index = Log

--// Auto Ignore Constants \\--
local SpamCallCountThreshold = 15
local SpamTimeWindowSeconds = 1

function Log.new(Instance, Type, Method, Index, CallingScript)
	local NewLog = setmetatable({
		Instance = Instance,
		Type = Type,
		Method = Method,
		Index = Index,
		Calls = {},
		GameCalls = {},
		SpamHistory = {},
		Ignored = false,
		Blocked = false,
		Button = nil,
	}, Log)

	return NewLog
end

function DeepClone(orig, copies)
	copies = copies or {}

	if typeof(orig) == "Instance" then
		return cloneref(orig)
	elseif typeof(orig) == "userdata" then
		if getmetatable(orig) then
			return newproxy(true)
		else
			return newproxy()
		end
	elseif typeof(orig) == "function" then
		if clonefunction then
			return clonefunction(orig)
		end

		return orig
	elseif type(orig) ~= "table" then
		return orig
	elseif copies[orig] then
		return copies[orig]
	end

	local copy = {}
	copies[orig] = copy
	for k, v in next, orig do
		copy[DeepClone(k, copies)] = DeepClone(v, copies)
	end
	return copy
end

function Log:IsOverSpamThreshold()
	if not wax.shared.SaveManager:GetState("AutoIgnoreSpammyEvents", false) then
		return false
	end

	local Now = tick()
	table.insert(self.SpamHistory, Now)

	for i = #self.SpamHistory, 1, -1 do
		if Now - self.SpamHistory[i] > SpamTimeWindowSeconds then
			table.remove(self.SpamHistory, i)
		end
	end

	if #self.SpamHistory > SpamCallCountThreshold then
		if not self.Ignored then
			self:Ignore()
			wax.shared.Sonner.info(`Ignored {self.Instance.Name} ({self.Type}) due to event spam.`)
		end
		
		return true
	end

	return false
end

function Log:Call(RawInfo)
	local Success, Data = pcall(function()
		return self:IsOverSpamThreshold()
	end)

	if Success and Data then
		return
	end

	local Info = DeepClone(RawInfo)
	Info.CreationTime = tick()

	local Index = #self.Calls + 1
	self.Calls[Index] = Info
	if not Info.IsExecutor then
		table.insert(self.GameCalls, Index)
	end

	if wax.shared.Communicator then
		wax.shared.Communicator.Fire(wax.shared.Communicator, self.Instance, self.Type, #self.Calls)
	end
end

function Log:Ignore()
	if wax.shared.ActorCommunicator then
		pcall(function()
			wax.shared.ActorCommunicator:Fire("MainIgnore", self.Instance, self.Type)
		end)
	end

	self.Ignored = not self.Ignored

	local IgnoredRemoteList = wax.shared.Settings["IgnoredRemotes"]
	if IgnoredRemoteList then
		if self.Ignored then
			IgnoredRemoteList:AddToList(self)
		else
			IgnoredRemoteList:RemoveFromList(self)
		end
	end
end

local ClassesConnectionsToggle = {
	RemoteEvent = "OnClientEvent",
	UnreliableRemoteEvent = "OnClientEvent",
	BindableEvent = "Event",
}

function Log:SetConnectionsEnabled(enabled: boolean)
	if not self.Instance or not ClassesConnectionsToggle[self.Instance.ClassName] then
		return
	end

	local ConnectionName = ClassesConnectionsToggle[self.Instance.ClassName]
	if self.Type ~= "Incoming" or not ConnectionName then
		return
	end

	for _, Connection in pairs(getconnections(self.Instance[ConnectionName])) do
		if enabled then
			Connection:Enable()
		else
			Connection:Disable()
		end
	end
end

function Log:Block()
	if wax.shared.ActorCommunicator then
		pcall(function()
			wax.shared.ActorCommunicator:Fire("MainBlock", self.Instance, self.Type)
		end)
	end

	self.Blocked = not self.Blocked
	Log:SetConnectionsEnabled(not self.Blocked)
end

function Log:SetButton(Instance, Name, Calls)
	self.Button = {
		Instance = Instance,
		Name = Name,
		Calls = Calls,
	}
end

return Log

end)() end
} -- [RefId] = Closure

-- Holds the actual DOM data
local ObjectTree = {
    {
        1,
        4,
        {
            "nova"
        },
        {
            {
                15,
                1,
                {
                    "Utils"
                },
                {
                    {
                        27,
                        2,
                        {
                            "Log"
                        }
                    },
                    {
                        16,
                        1,
                        {
                            "Anticheats"
                        },
                        {
                            {
                                18,
                                1,
                                {
                                    "impl"
                                },
                                {
                                    {
                                        19,
                                        2,
                                        {
                                            "Adonis"
                                        }
                                    }
                                }
                            },
                            {
                                17,
                                2,
                                {
                                    "Main"
                                }
                            }
                        }
                    },
                    {
                        25,
                        2,
                        {
                            "FileLog"
                        }
                    },
                    {
                        26,
                        2,
                        {
                            "Hooking"
                        }
                    },
                    {
                        24,
                        2,
                        {
                            "Connect"
                        }
                    },
                    {
                        28,
                        2,
                        {
                            "Pagination"
                        }
                    },
                    {
                        32,
                        1,
                        {
                            "UI"
                        },
                        {
                            {
                                41,
                                2,
                                {
                                    "ImprovedButton"
                                }
                            },
                            {
                                43,
                                2,
                                {
                                    "LoadingScreen"
                                }
                            },
                            {
                                40,
                                2,
                                {
                                    "ImageFetch"
                                }
                            },
                            {
                                45,
                                2,
                                {
                                    "Sonner"
                                }
                            },
                            {
                                38,
                                2,
                                {
                                    "Highlighter"
                                }
                            },
                            {
                                36,
                                2,
                                {
                                    "EnhancedModal"
                                }
                            },
                            {
                                42,
                                2,
                                {
                                    "Interface"
                                }
                            },
                            {
                                34,
                                2,
                                {
                                    "Constants"
                                }
                            },
                            {
                                44,
                                2,
                                {
                                    "Resize"
                                }
                            },
                            {
                                33,
                                2,
                                {
                                    "Animations"
                                }
                            },
                            {
                                37,
                                2,
                                {
                                    "Helper"
                                }
                            },
                            {
                                35,
                                2,
                                {
                                    "Drag"
                                }
                            },
                            {
                                39,
                                2,
                                {
                                    "Icons"
                                }
                            }
                        }
                    },
                    {
                        30,
                        1,
                        {
                            "Serializer"
                        },
                        {
                            {
                                31,
                                2,
                                {
                                    "LuaEncode"
                                }
                            }
                        }
                    },
                    {
                        20,
                        1,
                        {
                            "CodeGen"
                        },
                        {
                            {
                                21,
                                2,
                                {
                                    "Generator"
                                }
                            },
                            {
                                22,
                                2,
                                {
                                    "SessionExporter"
                                }
                            },
                            {
                                23,
                                5,
                                {
                                    "SessionHTMLView",
                                    Value = "<!DOCTYPE html>\n<html lang=\"en\">\n  <head>\n    <meta charset=\"UTF-8\" />\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" />\n    <title>Nova - Session Viewer</title>\n    <link\n      rel=\"icon\"\n      type=\"image/png\"\n      href=\"https://raw.githubusercontent.com/DizzyUSER69/novaproject/main/nova_project/Assets/Logo.png\"\n    />\n    <style>\n      :root {\n        --bg-color: #0b0b0b;\n        --surface-color: #161b22;\n        --border-color: #30363d;\n        --text-primary: #c9d1d9;\n        --text-secondary: #8b949e;\n        --accent-blue: #58a6ff;\n        --accent-green: #3fb950;\n        --accent-orange: #d29922;\n        --accent-red: #ff7b72;\n        --font-family: \"Inter\", -apple-system, BlinkMacSystemFont, \"Segoe UI\",\n          Helvetica, Arial, sans-serif;\n      }\n\n      body {\n        background-color: var(--bg-color);\n        color: var(--text-primary);\n        font-family: var(--font-family);\n        margin: 0;\n        padding: 0;\n        font-size: 13px;\n        height: 100vh;\n        display: flex;\n        flex-direction: column;\n        overflow: hidden;\n      }\n\n      /* Top Header */\n      .app-header {\n        height: 50px;\n        border-bottom: 1px solid var(--border-color);\n        display: flex;\n        align-items: center;\n        justify-content: space-between;\n        padding: 0 20px;\n        background-color: var(--bg-color);\n        flex-shrink: 0;\n        z-index: 10;\n      }\n\n      .brand {\n        display: flex;\n        align-items: center;\n        gap: 10px;\n        font-size: 16px;\n        font-weight: 600;\n        color: #fff;\n      }\n\n      .brand-icon {\n        width: 20px;\n        height: 20px;\n        background-image: url(\"https://raw.githubusercontent.com/DizzyUSER69/novaproject/main/nova_project/Assets/Logo.png\");\n        background-size: contain;\n        background-repeat: no-repeat;\n        background-position: center;\n      }\n\n      .session-container {\n        position: relative;\n        display: flex;\n        flex-direction: column;\n        align-items: flex-end;\n      }\n\n      .session-info {\n        color: var(--text-secondary);\n        font-family: monospace;\n        font-size: 12px;\n        cursor: pointer;\n        padding: 2px 5px;\n        border-radius: 4px;\n        transition: background-color 0.2s ease;\n        user-select: none;\n      }\n\n      .session-info:hover {\n        background-color: #1c2128;\n      }\n\n      .session-id {\n        color: #fff;\n      }\n\n      .session-tooltip {\n        position: absolute;\n        top: 100%;\n        right: 0;\n        background-color: #1c2128;\n        border: 1px solid var(--border-color);\n        border-radius: 6px;\n        padding: 10px;\n        z-index: 100;\n        width: 250px;\n        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.5);\n        margin-top: 5px;\n        opacity: 0;\n        transform: translateY(-10px);\n        pointer-events: none;\n        visibility: hidden;\n        transition: opacity 0.2s ease, transform 0.2s ease, visibility 0.2s;\n      }\n\n      .session-tooltip::before {\n        content: \"\";\n        position: absolute;\n        top: -10px;\n        left: 0;\n        width: 100%;\n        height: 10px;\n        background: transparent;\n      }\n\n      .session-container:hover .session-tooltip,\n      .session-tooltip.visible {\n        opacity: 1;\n        transform: translateY(0);\n        pointer-events: auto;\n        visibility: visible;\n      }\n\n      .tooltip-row {\n        display: flex;\n        justify-content: space-between;\n        margin-bottom: 5px;\n        font-size: 11px;\n      }\n\n      .tooltip-label {\n        color: var(--text-secondary);\n      }\n\n      .tooltip-value {\n        color: var(--text-primary);\n        font-family: monospace;\n        user-select: text;\n      }\n\n      /* Mobile Responsiveness */\n      @media (max-width: 768px) {\n        .app-header {\n          height: auto;\n          flex-wrap: wrap;\n          padding: 10px;\n          gap: 10px;\n        }\n\n        .brand {\n          font-size: 14px;\n        }\n\n        .session-container {\n          align-items: flex-start;\n          display: none;\n          /* Hide session info on mobile to save space */\n        }\n\n        .trace-toolbar {\n          height: auto;\n          flex-wrap: wrap;\n          padding: 10px;\n          gap: 10px;\n          justify-content: space-between;\n        }\n\n        /* Hide non-essential info on mobile */\n        .trace-toolbar > div:first-child,\n        #statsLabel {\n          display: none;\n        }\n\n        .search-widget {\n          width: 100%;\n          order: 3;\n          margin-top: 5px;\n        }\n\n        .view-toggle {\n          width: 100%;\n          display: flex;\n        }\n\n        .view-btn {\n          flex: 1;\n          text-align: center;\n        }\n\n        .row-list {\n          width: 60vw;\n          /* Use viewport width to prevent runaway expansion */\n        }\n\n        .col-list {\n          width: 60vw;\n          flex: none;\n        }\n\n        .details-panel.visible {\n          position: fixed;\n          top: 0;\n          left: 0;\n          width: 100%;\n          height: 100%;\n          z-index: 1000;\n          border-left: none;\n        }\n\n        .details-header-top {\n          margin-top: 10px;\n        }\n\n        /* Fix Details Header Overflow */\n        .details-title-group {\n          min-width: 0;\n          flex: 1;\n          margin-right: 10px;\n        }\n\n        .details-name-large {\n          white-space: nowrap;\n          overflow: hidden;\n          text-overflow: ellipsis;\n        }\n\n        .details-actions {\n          flex-shrink: 0;\n        }\n\n        /* Allow wrapping for paths on mobile */\n        .details-path-row,\n        .origin-row,\n        .remote-path-copy {\n          white-space: normal !important;\n          word-break: break-all;\n        }\n      }\n\n      /* Scrollbars */\n      ::-webkit-scrollbar {\n        width: 10px;\n        height: 10px;\n      }\n\n      ::-webkit-scrollbar-track {\n        background: #0d1117;\n      }\n\n      ::-webkit-scrollbar-thumb {\n        background: #30363d;\n        border-radius: 5px;\n        border: 2px solid #0d1117;\n      }\n\n      ::-webkit-scrollbar-thumb:hover {\n        background: #8b949e;\n      }\n\n      ::-webkit-scrollbar-corner {\n        background: var(--bg-color);\n      }\n\n      /* Heatmap Styles */\n      .heatmap-container {\n        flex: 1;\n        display: none;\n        flex-direction: column;\n        overflow: hidden;\n        background-color: var(--bg-color);\n        position: relative;\n      }\n\n      .heatmap-container.visible {\n        display: flex;\n      }\n\n      .heatmap-canvas {\n        flex: 1;\n        width: 100%;\n        height: 100%;\n      }\n\n      .view-toggle {\n        display: flex;\n        background: #1c2128;\n        border: 1px solid var(--border-color);\n        border-radius: 4px;\n        overflow: hidden;\n      }\n\n      .view-btn {\n        padding: 4px 12px;\n        font-size: 12px;\n        cursor: pointer;\n        color: var(--text-secondary);\n        background: transparent;\n        border: none;\n        transition: all 0.2s;\n      }\n\n      .view-btn.active {\n        background: var(--accent-blue);\n        color: white;\n      }\n\n      .view-btn:hover:not(.active) {\n        background: #30363d;\n      }\n\n      /* Main Layout */\n      .main-container {\n        display: flex;\n        flex: 1;\n        overflow: hidden;\n      }\n\n      /* Left Panel: Trace View */\n      .trace-panel {\n        flex: 1;\n        display: flex;\n        flex-direction: column;\n        border-right: 1px solid var(--border-color);\n        min-width: 0;\n        overflow: hidden;\n      }\n\n      .trace-toolbar {\n        height: 40px;\n        border-bottom: 1px solid var(--border-color);\n        display: flex;\n        align-items: center;\n        padding: 0 10px;\n        gap: 10px;\n        background-color: var(--bg-color);\n        flex-shrink: 0;\n      }\n\n      .search-widget {\n        display: flex;\n        flex-direction: column;\n        background-color: var(--bg-color);\n        border: 1px solid var(--border-color);\n        border-radius: 6px;\n        width: 320px;\n        position: relative;\n        transition: border-color 0.2s ease, border-radius 0.2s ease;\n        box-sizing: border-box;\n      }\n\n      .search-widget:focus-within {\n        border-color: var(--accent-blue);\n      }\n\n      .search-widget:focus-within > .search-options {\n        border-color: var(--accent-blue);\n      }\n\n      .search-widget.expanded {\n        border-bottom-left-radius: 0;\n        border-bottom-right-radius: 0;\n        border-bottom-color: transparent;\n      }\n\n      .search-row {\n        display: flex;\n        align-items: center;\n        padding: 4px;\n      }\n\n      .search-chevron {\n        cursor: pointer;\n        padding: 2px;\n        color: var(--text-secondary);\n        display: flex;\n        align-items: center;\n        justify-content: center;\n        transition: transform 0.2s ease, color 0.2s ease;\n        width: 20px;\n        height: 20px;\n        border-radius: 4px;\n      }\n\n      .search-chevron:hover {\n        background-color: rgba(255, 255, 255, 0.1);\n        color: var(--text-primary);\n      }\n\n      .search-chevron.expanded {\n        transform: rotate(90deg);\n      }\n\n      .search-input-container {\n        flex: 1;\n        display: flex;\n        align-items: center;\n        margin-left: 4px;\n      }\n\n      .search-input {\n        background: transparent;\n        border: none;\n        color: var(--text-primary);\n        font-size: 12px;\n        width: 100%;\n        outline: none;\n        height: 20px;\n      }\n\n      .search-options {\n        transition: border-color 0.2s ease, border-radius 0.2s ease;\n        display: none;\n        padding: 10px;\n        border: 1px solid var(--border-color);\n        border-top: none;\n        background-color: var(--bg-color);\n        flex-direction: column;\n        gap: 12px;\n        position: absolute;\n        top: 100%;\n        left: -1px;\n        right: -1px;\n        z-index: 100;\n        border-bottom-left-radius: 6px;\n        border-bottom-right-radius: 6px;\n        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);\n        box-sizing: border-box;\n      }\n\n      .search-options.visible {\n        display: flex;\n      }\n\n      .time-range-row {\n        display: flex;\n        align-items: center;\n        gap: 8px;\n        font-size: 11px;\n        color: var(--text-secondary);\n      }\n\n      .filter-options-row {\n        display: flex;\n        flex-wrap: wrap;\n        gap: 8px;\n        padding-top: 8px;\n        border-top: 1px solid var(--border-color);\n      }\n\n      .filter-checkbox-label {\n        display: flex;\n        align-items: center;\n        gap: 4px;\n        font-size: 11px;\n        color: var(--text-secondary);\n        cursor: pointer;\n        user-select: none;\n      }\n\n      .filter-checkbox-label:hover {\n        color: var(--text-primary);\n      }\n\n      .filter-checkbox {\n        accent-color: var(--accent-blue);\n      }\n\n      .time-input-styled {\n        background-color: #161b22;\n        border: 1px solid var(--border-color);\n        color: var(--text-primary);\n        border-radius: 4px;\n        padding: 4px 8px;\n        width: 60px;\n        outline: none;\n        font-size: 11px;\n        transition: border-color 0.2s ease;\n        margin: 0 2px;\n      }\n\n      .time-input-styled:focus {\n        border-color: var(--accent-blue);\n      }\n\n      .unit-select {\n        background-color: #161b22;\n        border: 1px solid var(--border-color);\n        color: var(--text-primary);\n        border-radius: 4px;\n        outline: none;\n        font-size: 11px;\n        padding: 3px 6px;\n        cursor: pointer;\n        transition: border-color 0.2s ease;\n      }\n\n      .unit-select:focus {\n        border-color: var(--accent-blue);\n      }\n\n      .trace-header-row {\n        display: flex;\n        height: 30px;\n        border-bottom: 1px solid var(--border-color);\n        background-color: var(--surface-color);\n        font-size: 11px;\n        color: var(--text-secondary);\n        line-height: 30px;\n        flex-shrink: 0;\n      }\n\n      .col-list {\n        width: 300px;\n        padding-left: 15px;\n        border-right: 1px solid var(--border-color);\n        flex-shrink: 0;\n        z-index: 5;\n        background-color: var(--surface-color);\n        box-sizing: border-box;\n        /* Match row-list */\n      }\n\n      .col-timeline {\n        flex: 1;\n        position: relative;\n        overflow: hidden;\n        min-width: calc(100vw - 300px);\n      }\n\n      .timeline-ruler {\n        position: relative;\n        top: 0;\n        left: 0;\n        height: 100%;\n        pointer-events: none;\n      }\n\n      .tick {\n        position: absolute;\n        top: 0;\n        bottom: 0;\n        border-left: 1px solid #30363d;\n        font-size: 10px;\n        color: #484f58;\n        padding-left: 4px;\n      }\n\n      .trace-rows {\n        flex: 1;\n        overflow: auto;\n        /* Ensure both scrollbars appear */\n        position: relative;\n        contain: strict;\n      }\n\n      .virtual-spacer {\n        position: absolute;\n        top: 0;\n        left: 0;\n        width: 1px;\n      }\n\n      .virtual-content {\n        position: absolute;\n        top: 0;\n        left: 0;\n        width: 100%;\n      }\n\n      .trace-row {\n        display: flex;\n        height: 28px;\n        /* align-items: center;  Removed to allow children to stretch */\n        cursor: pointer;\n        /* border-bottom: 1px solid #1c2128; Moved to children */\n        width: fit-content;\n        min-width: 100%;\n        transition: background-color 0.1s ease;\n        box-sizing: border-box;\n      }\n\n      .trace-row:hover {\n        background-color: #1c2128;\n      }\n\n      .trace-row.selected {\n        background-color: rgba(88, 166, 255, 0.1);\n      }\n\n      .trace-row.hidden {\n        display: none;\n      }\n\n      .trace-row:hover * {\n        background-color: #1c2128;\n      }\n\n      .trace-row.selected * {\n        background-color: #1c2333;\n      }\n\n      .row-list {\n        width: 300px;\n        padding-left: 15px;\n        /* Use box-shadow for sticky border to prevent it from disappearing */\n        box-shadow: 1px 0 0 0 var(--border-color);\n        border-right: none;\n        border-bottom: 1px solid #1c2128;\n        /* Added border here */\n        display: flex;\n        align-items: center;\n        overflow: hidden;\n        flex-shrink: 0;\n        box-sizing: border-box;\n        position: sticky;\n        left: 0;\n        background-color: var(--bg-color);\n        z-index: 2;\n        transition: background-color 0.1s ease;\n        height: 100%;\n      }\n\n      .row-timeline {\n        flex: 1;\n        position: relative;\n        height: 100%;\n        overflow: hidden;\n        border-bottom: 1px solid #1c2128;\n        /* Added border here */\n        box-sizing: border-box;\n        /* Ensure border is inside height */\n      }\n\n      .type-icon {\n        width: 16px;\n        height: 16px;\n        margin-right: 8px;\n        flex-shrink: 0;\n        background-size: contain;\n        background-repeat: no-repeat;\n        background-position: center;\n      }\n\n      .remote-name {\n        white-space: nowrap;\n        overflow: hidden;\n        text-overflow: ellipsis;\n        color: var(--text-primary);\n        font-size: 12px;\n      }\n\n      .timeline-marker {\n        position: absolute;\n        top: 10px;\n        height: 8px;\n        min-width: 4px;\n        border-radius: 4px;\n        opacity: 0.9;\n      }\n\n      .timeline-marker.incoming {\n        background: linear-gradient(90deg, var(--accent-green), #2ea043);\n      }\n\n      .timeline-marker.outgoing {\n        background: linear-gradient(90deg, var(--accent-orange), #b08800);\n      }\n\n      /* Right Panel: Details */\n      .details-panel {\n        width: 0;\n        opacity: 0;\n        background-color: var(--bg-color);\n        border-left: 0 solid var(--border-color);\n        display: flex;\n        flex-direction: column;\n        padding: 0;\n        box-sizing: border-box;\n        overflow-y: auto;\n        overflow-x: hidden;\n        position: relative;\n        flex-shrink: 0;\n        transition: width 0.3s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.2s ease,\n          padding 0.3s ease;\n      }\n\n      .details-panel.visible {\n        width: 450px;\n        opacity: 1;\n        padding: 20px;\n        border-left: 1px solid var(--border-color);\n      }\n\n      /* Header */\n      .details-header-top {\n        display: flex;\n        align-items: center;\n        justify-content: space-between;\n        margin-bottom: 10px;\n      }\n\n      .details-title-group {\n        display: flex;\n        align-items: center;\n        gap: 10px;\n      }\n\n      .details-icon-large {\n        width: 32px;\n        height: 32px;\n        background-size: contain;\n        background-repeat: no-repeat;\n        background-position: center;\n      }\n\n      .details-name-large {\n        font-size: 20px;\n        font-weight: 600;\n        color: #fff;\n      }\n\n      .details-actions {\n        display: flex;\n        align-items: center;\n        gap: 10px;\n      }\n\n      .close-btn {\n        cursor: pointer;\n        color: var(--text-secondary);\n        font-size: 20px;\n        transition: color 0.2s ease;\n        line-height: 1;\n      }\n\n      .close-btn:hover {\n        color: #fff;\n      }\n\n      /* Unified Badge Style */\n      .badge-pill {\n        padding: 4px 12px;\n        border-radius: 20px;\n        font-size: 11px;\n        font-weight: 600;\n        text-transform: uppercase;\n        border: 1px solid;\n        letter-spacing: 0.5px;\n        white-space: nowrap;\n      }\n\n      .badge-pill.incoming {\n        color: var(--accent-green);\n        border-color: var(--accent-green);\n      }\n\n      .badge-pill.outgoing {\n        color: var(--accent-orange);\n        border-color: var(--accent-orange);\n      }\n\n      .badge-pill.executor {\n        color: var(--accent-green);\n        border-color: var(--accent-green);\n      }\n\n      .badge-pill.actor {\n        color: var(--accent-red);\n        border-color: var(--accent-red);\n        background: repeating-linear-gradient(\n          45deg,\n          transparent,\n          transparent 2px,\n          rgba(255, 123, 114, 0.1) 2px,\n          rgba(255, 123, 114, 0.1) 4px\n        );\n      }\n\n      .details-path-row {\n        color: var(--text-secondary);\n        font-size: 12px;\n        margin-bottom: 20px;\n        font-family: monospace;\n        white-space: nowrap;\n        text-overflow: ellipsis;\n        overflow: hidden;\n        height: 1.2em;\n      }\n\n      .remote-path-copy {\n        cursor: pointer;\n        color: var(--text-secondary);\n        font-size: 12px;\n        font-weight: normal;\n        transition: color 0.2s ease;\n        white-space: nowrap;\n        overflow: hidden;\n        text-overflow: ellipsis;\n        display: block;\n        width: 25%;\n      }\n\n      .remote-path-copy:hover {\n        color: var(--accent-blue);\n      }\n\n      /* Info Grid 2 */\n      .info-grid-2 {\n        display: flex;\n        gap: 20px;\n        margin-bottom: 25px;\n      }\n\n      .info-item-2 h4 {\n        margin: 0 0 6px 0;\n        color: var(--text-secondary);\n        font-size: 12px;\n        font-weight: normal;\n      }\n\n      .info-item-2 div {\n        font-size: 11px;\n        color: var(--text-primary);\n        font-family: monospace;\n      }\n\n      /* Info Grid */\n      .info-grid {\n        display: grid;\n        grid-template-columns: 1fr 1fr;\n        gap: 20px;\n        margin-bottom: 25px;\n      }\n\n      .info-item h4 {\n        margin: 0 0 6px 0;\n        color: var(--text-secondary);\n        font-size: 12px;\n        font-weight: normal;\n      }\n\n      .info-item div {\n        font-size: 14px;\n        color: var(--text-primary);\n        font-family: monospace;\n      }\n\n      .clickable-path {\n        border-bottom: 1px dashed var(--text-secondary);\n        cursor: pointer;\n        transition: color 0.2s, border-color 0.2s;\n      }\n\n      .clickable-path:hover {\n        color: var(--accent-blue);\n        border-color: var(--accent-blue);\n      }\n\n      /* Content Boxes */\n      .content-box {\n        border: 1px solid var(--border-color);\n        border-radius: 8px;\n        padding: 15px;\n        margin-bottom: 20px;\n        position: relative;\n        background-color: rgba(22, 27, 34, 0.5);\n      }\n\n      .box-title {\n        position: absolute;\n        top: -10px;\n        left: 10px;\n        background-color: var(--bg-color);\n        padding: 0 5px;\n        font-size: 11px;\n        color: var(--text-secondary);\n      }\n\n      .caller-header {\n        display: flex;\n        align-items: center;\n        gap: 10px;\n        margin-bottom: 15px;\n      }\n\n      .caller-icon {\n        color: var(--text-secondary);\n        display: flex;\n        align-items: center;\n        justify-content: center;\n      }\n\n      .caller-icon svg {\n        width: 24px;\n        height: 24px;\n      }\n\n      .caller-info {\n        flex: 1;\n        min-width: 0;\n        /* Critical for flex child truncation */\n      }\n\n      .caller-name {\n        color: var(--accent-blue);\n        font-family: monospace;\n        font-size: 14px;\n        margin-bottom: 2px;\n      }\n\n      .caller-source {\n        color: var(--text-secondary);\n        font-size: 11px;\n        font-family: monospace;\n        height: 1.2em;\n        white-space: nowrap;\n        overflow: hidden;\n        text-overflow: ellipsis;\n        display: block;\n      }\n\n      .flags-row {\n        display: flex;\n        gap: 10px;\n        margin-bottom: 10px;\n        align-items: center;\n      }\n\n      .origin-row {\n        font-size: 12px;\n        color: var(--text-primary);\n        font-family: monospace;\n        display: block;\n        white-space: nowrap;\n        height: 1.2em;\n        overflow: hidden;\n        text-overflow: ellipsis;\n        width: 35%;\n      }\n\n      /* Arguments */\n      .args-content {\n        font-family: \"Consolas\", \"Monaco\", monospace;\n        font-size: 12px;\n        white-space: pre-wrap;\n        overflow-x: auto;\n        color: #e0e0e0;\n        max-height: 300px;\n        overflow-y: auto;\n        line-height: 1.5;\n      }\n\n      /* Copy Button with Animation */\n      .copy-icon-btn {\n        position: absolute;\n        top: 10px;\n        right: 10px;\n        background: transparent;\n        border: 1px solid var(--border-color);\n        border-radius: 4px;\n        color: var(--text-secondary);\n        cursor: pointer;\n        width: 28px;\n        height: 28px;\n        display: flex;\n        align-items: center;\n        justify-content: center;\n        transition: all 0.2s;\n        overflow: hidden;\n        /* Ensure check icon doesn't spill out */\n      }\n\n      .copy-icon-btn:hover {\n        border-color: var(--text-primary);\n        color: var(--text-primary);\n        background-color: var(--surface-color);\n      }\n\n      .copy-icon-btn svg {\n        width: 14px;\n        height: 14px;\n        position: absolute;\n        top: 50%;\n        left: 50%;\n        transform: translate(-50%, -50%) scale(1);\n        transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);\n      }\n\n      .copy-icon-btn .icon-check {\n        transform: translate(-50%, -50%) scale(0);\n        color: var(--accent-green);\n      }\n\n      .copy-icon-btn.copied .icon-copy {\n        transform: translate(-50%, -50%) scale(0);\n      }\n\n      .copy-icon-btn.copied .icon-check {\n        transform: translate(-50%, -50%) scale(1);\n      }\n\n      /* Dropdown */\n      .dropdown-menu {\n        position: absolute;\n        top: 42px;\n        /* Button height + spacing */\n        right: 10px;\n        background-color: #1c2128;\n        border: 1px solid var(--border-color);\n        border-radius: 6px;\n        width: 160px;\n        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.5);\n        z-index: 50;\n        display: none;\n        overflow: hidden;\n      }\n\n      .dropdown-menu.visible {\n        display: block;\n      }\n\n      .dropdown-item {\n        padding: 8px 12px;\n        font-size: 12px;\n        color: var(--text-primary);\n        cursor: pointer;\n        transition: background-color 0.2s;\n        display: flex;\n        align-items: center;\n        gap: 8px;\n      }\n\n      .dropdown-item:hover {\n        background-color: var(--accent-blue);\n        color: #fff;\n      }\n\n      .dropdown-item svg {\n        width: 14px;\n        height: 14px;\n        opacity: 0.7;\n      }\n\n      /* Toast Notification */\n      .toast-container {\n        position: fixed;\n        bottom: 30px;\n        left: 50%;\n        transform: translateX(-50%) translateY(20px);\n        background-color: #1c2128;\n        border: 1px solid var(--border-color);\n        border-radius: 6px;\n        padding: 8px 16px;\n        color: #fff;\n        font-size: 12px;\n        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.5);\n        opacity: 0;\n        transition: opacity 0.3s, transform 0.3s;\n        pointer-events: none;\n        z-index: 1000;\n        display: flex;\n        align-items: center;\n        gap: 8px;\n      }\n\n      .toast-container.visible {\n        opacity: 1;\n        transform: translateX(-50%) translateY(0);\n      }\n\n      .toast-container svg {\n        width: 16px;\n        height: 16px;\n        color: var(--accent-green);\n      }\n\n      /* Syntax Highlighting */\n      .hl-str {\n        color: #a5d6ff;\n      }\n\n      .hl-num {\n        color: #79c0ff;\n      }\n\n      .hl-bool {\n        color: #ff7b72;\n      }\n\n      .hl-key {\n        color: #7ee787;\n      }\n\n      .hl-nil {\n        color: #ff7b72;\n      }\n\n      .footer {\n        height: 25px;\n        border-top: 1px solid var(--border-color);\n        display: flex;\n        align-items: center;\n        justify-content: space-between;\n        padding: 0 20px;\n        background-color: var(--bg-color);\n        color: var(--text-secondary);\n        font-size: 11px;\n        flex-shrink: 0;\n      }\n    </style>\n  </head>\n\n  <body>\n    <div class=\"app-header\">\n      <a\n        href=\"https://github.com/DizzyUSER69/novaproject/tree/main\"\n        target=\"_blank\"\n        style=\"text-decoration: none\"\n      >\n        <div class=\"brand\">\n          <div class=\"brand-icon\"></div>\n          Nova - Session Viewer\n        </div>\n      </a>\n      <div class=\"session-container\">\n        <div class=\"session-info\">\n          Session / <span class=\"session-id\">{{SESSION_ID}}</span>\n        </div>\n        <div class=\"session-tooltip\">\n          <div class=\"tooltip-row\">\n            <span class=\"tooltip-label\">Start Time (tick)</span>\n            <span class=\"tooltip-value\">{{START_TIME}}</span>\n          </div>\n          <div class=\"tooltip-row\">\n            <span class=\"tooltip-label\">Place ID</span>\n            <span class=\"tooltip-value\">{{PLACE_ID}}</span>\n          </div>\n          <div class=\"tooltip-row\">\n            <span class=\"tooltip-label\">Job ID</span>\n            <span class=\"tooltip-value\">{{JOB_ID}}</span>\n          </div>\n        </div>\n      </div>\n    </div>\n\n    <div class=\"main-container\">\n      <!-- LEFT PANEL WRAPPER -->\n      <div\n        class=\"left-panel-wrapper\"\n        style=\"\n          flex: 1;\n          display: flex;\n          flex-direction: column;\n          border-right: 1px solid var(--border-color);\n          min-width: 0;\n          overflow: hidden;\n        \"\n      >\n        <!-- SHARED TOOLBAR -->\n        <div class=\"trace-toolbar\">\n          <div\n            style=\"\n              font-size: 11px;\n              color: var(--text-secondary);\n              margin-right: 20px;\n            \"\n          >\n            Started: {{DATE}}\n          </div>\n          <div style=\"flex: 1\"></div>\n          <div class=\"view-toggle\">\n            <button class=\"view-btn active\" onclick=\"switchView('timeline')\">\n              Timeline\n            </button>\n            <button class=\"view-btn\" onclick=\"switchView('heatmap')\">\n              Heatmap\n            </button>\n          </div>\n          <div class=\"divider\"></div>\n          <div class=\"search-widget\">\n            <div class=\"search-row\">\n              <div\n                class=\"search-chevron\"\n                onclick=\"toggleSearchOptions()\"\n                id=\"searchChevron\"\n              >\n                <svg\n                  width=\"16\"\n                  height=\"16\"\n                  viewBox=\"0 0 16 16\"\n                  fill=\"currentColor\"\n                >\n                  <path\n                    d=\"M6 4l4 4-4 4\"\n                    stroke=\"currentColor\"\n                    stroke-width=\"1.5\"\n                    fill=\"none\"\n                  />\n                </svg>\n              </div>\n              <div class=\"search-input-container\">\n                <input\n                  type=\"text\"\n                  class=\"search-input\"\n                  id=\"filterInput\"\n                  placeholder=\"Filter events...\"\n                  oninput=\"handleFilterInput()\"\n                />\n              </div>\n            </div>\n            <div class=\"search-options\" id=\"searchOptions\">\n              <div class=\"time-range-row\">\n                <span>Time Range:</span>\n                <input\n                  type=\"number\"\n                  class=\"time-input-styled\"\n                  id=\"minTimeInput\"\n                  placeholder=\"Start\"\n                  oninput=\"handleTimeInput()\"\n                />\n                <span>-</span>\n                <input\n                  type=\"number\"\n                  class=\"time-input-styled\"\n                  id=\"maxTimeInput\"\n                  placeholder=\"End\"\n                  oninput=\"handleTimeInput()\"\n                />\n                <select\n                  class=\"unit-select\"\n                  id=\"timeUnitSelect\"\n                  onchange=\"handleTimeInput()\"\n                >\n                  <option value=\"1\">s</option>\n                  <option value=\"0.001\">ms</option>\n                </select>\n              </div>\n              <div class=\"filter-options-row\">\n                <label class=\"filter-checkbox-label\"\n                  ><input\n                    type=\"checkbox\"\n                    class=\"filter-checkbox\"\n                    id=\"filterIncoming\"\n                    onchange=\"handleFilterInput()\"\n                  />\n                  Incoming</label\n                >\n                <label class=\"filter-checkbox-label\"\n                  ><input\n                    type=\"checkbox\"\n                    class=\"filter-checkbox\"\n                    id=\"filterOutgoing\"\n                    onchange=\"handleFilterInput()\"\n                  />\n                  Outgoing</label\n                >\n                <div\n                  style=\"\n                    width: 1px;\n                    height: 14px;\n                    background: var(--border-color);\n                    margin: 0 4px;\n                  \"\n                ></div>\n                <label class=\"filter-checkbox-label\"\n                  ><input\n                    type=\"checkbox\"\n                    class=\"filter-checkbox\"\n                    id=\"filterActor\"\n                    onchange=\"handleFilterInput()\"\n                  />\n                  Actor</label\n                >\n                <label class=\"filter-checkbox-label\"\n                  ><input\n                    type=\"checkbox\"\n                    class=\"filter-checkbox\"\n                    id=\"filterNonActor\"\n                    onchange=\"handleFilterInput()\"\n                  />\n                  Non-Actor</label\n                >\n                <div\n                  style=\"\n                    width: 1px;\n                    height: 14px;\n                    background: var(--border-color);\n                    margin: 0 4px;\n                  \"\n                ></div>\n                <label class=\"filter-checkbox-label\"\n                  ><input\n                    type=\"checkbox\"\n                    class=\"filter-checkbox\"\n                    id=\"filterArgs\"\n                    onchange=\"handleFilterInput()\"\n                  />\n                  Args</label\n                >\n                <label class=\"filter-checkbox-label\"\n                  ><input\n                    type=\"checkbox\"\n                    class=\"filter-checkbox\"\n                    id=\"filterProto\"\n                    onchange=\"handleFilterInput()\"\n                  />\n                  Proto</label\n                >\n                <label class=\"filter-checkbox-label\"\n                  ><input\n                    type=\"checkbox\"\n                    class=\"filter-checkbox\"\n                    id=\"filterConst\"\n                    onchange=\"handleFilterInput()\"\n                  />\n                  Const</label\n                >\n                <label class=\"filter-checkbox-label\"\n                  ><input\n                    type=\"checkbox\"\n                    class=\"filter-checkbox\"\n                    id=\"filterHash\"\n                    onchange=\"handleFilterInput()\"\n                  />\n                  Hash</label\n                >\n                <label class=\"filter-checkbox-label\"\n                  ><input\n                    type=\"checkbox\"\n                    class=\"filter-checkbox\"\n                    id=\"filterSource\"\n                    onchange=\"handleFilterInput()\"\n                  />\n                  Source</label\n                >\n              </div>\n            </div>\n          </div>\n        </div>\n\n        <!-- TIMELINE VIEW -->\n        <div class=\"trace-panel\" id=\"timelinePanel\" style=\"border-right: none\">\n          <div class=\"trace-header-row\">\n            <div class=\"col-list\">Remote</div>\n            <div class=\"col-timeline\" id=\"timelineHeader\">\n              <div class=\"timeline-ruler\" id=\"ruler\"></div>\n            </div>\n          </div>\n\n          <div class=\"trace-rows\" id=\"rowsContainer\">\n            <div id=\"virtualSpacer\" class=\"virtual-spacer\"></div>\n            <div id=\"virtualContent\" class=\"virtual-content\"></div>\n          </div>\n        </div>\n\n        <!-- HEATMAP VIEW -->\n        <div class=\"heatmap-container\" id=\"heatmapPanel\">\n          <div\n            id=\"heatmapScroll\"\n            style=\"\n              width: 100%;\n              height: 100%;\n              overflow-x: auto;\n              overflow-y: hidden;\n              position: relative;\n            \"\n          >\n            <div\n              id=\"heatmapSpacer\"\n              style=\"\n                height: 1px;\n                width: 100%;\n                position: absolute;\n                top: 0;\n                left: 0;\n                pointer-events: none;\n              \"\n            ></div>\n            <canvas\n              id=\"heatmapCanvas\"\n              class=\"heatmap-canvas\"\n              style=\"\n                position: sticky;\n                left: 0;\n                top: 0;\n                width: 100%;\n                height: 100%;\n              \"\n            ></canvas>\n          </div>\n          <div\n            id=\"heatmapTooltip\"\n            class=\"heatmap-tooltip\"\n            style=\"\n              display: none;\n              position: absolute;\n              background: #1c2128;\n              border: 1px solid #30363d;\n              padding: 4px 8px;\n              border-radius: 4px;\n              font-size: 11px;\n              color: #c9d1d9;\n              pointer-events: none;\n              z-index: 100;\n            \"\n          ></div>\n        </div>\n      </div>\n\n      <!-- RIGHT PANEL -->\n      <div class=\"details-panel\" id=\"detailsPanel\">\n        <div id=\"detailsContent\"></div>\n      </div>\n    </div>\n\n    <div class=\"footer\">\n      <div>Ended: {{END_DATE}}</div>\n      <span\n        id=\"statsLabel\"\n        style=\"\n          color: var(--text-secondary);\n          font-size: 11px;\n          margin-right: 10px;\n        \"\n      >\n        {{EVENT_COUNT}} Events \226\128\162 {{TOTAL_DURATION}}s\n      </span>\n    </div>\n\n    <!-- Toast Notification -->\n    <div id=\"toast\" class=\"toast-container\">\n      <svg\n        xmlns=\"http://www.w3.org/2000/svg\"\n        width=\"24\"\n        height=\"24\"\n        viewBox=\"0 0 24 24\"\n        fill=\"none\"\n        stroke=\"currentColor\"\n        stroke-width=\"2\"\n        stroke-linecap=\"round\"\n        stroke-linejoin=\"round\"\n        class=\"lucide lucide-check\"\n      >\n        <path d=\"M20 6 9 17l-5-5\" />\n      </svg>\n      <span id=\"toastMessage\">Copied to clipboard</span>\n    </div>\n\n    <!-- Data Script -->\n    <script type=\"application/json\" id=\"dictionary-data\">\n      {{DICTIONARY_JSON}}\n    </script>\n    <script type=\"application/json\" id=\"event-data\">\n      {{EVENTS_JSON}}\n    </script>\n\n    <script>\n      // Data Parsing\n      let startTime = {{START_TIME}}; // Seconds\n      const totalDuration = {{DURATION}};\n      const dictionary = JSON.parse(document.getElementById('dictionary-data').textContent);\n      const rawEvents = JSON.parse(document.getElementById('event-data').textContent);\n\n      // Reconstruct Events\n      const allEvents = rawEvents.map(e => ({\n        name: dictionary[e[0]],\n        className: dictionary[e[1]],\n        path: dictionary[e[2]],\n        type: dictionary[e[3]],\n        timestamp: e[4],\n        origin: dictionary[e[5]],\n\n        args: dictionary[e[6]],\n        method: dictionary[e[7]],\n\n        funcName: dictionary[e[8]],\n        funcLine: e[9],\n        funcSource: dictionary[e[10]],\n        isExecutor: e[11] === 1,\n        isActor: e[12] === 1,\n\n        funcHash: dictionary[e[13]],\n        upvalues: dictionary[e[14]],\n        protos: dictionary[e[15]],\n        constants: dictionary[e[16]]\n      }));\n\n      if (allEvents.length > 0) {\n        const minTimestamp = Math.min(...allEvents.map(e => e.timestamp));\n        if (minTimestamp < startTime) {\n          startTime = minTimestamp;\n        }\n      }\n\n      // Preprocess events\n      allEvents.forEach(evt => {\n        evt.relTime = Math.max(0, evt.timestamp - startTime);\n\n        const typeLower = evt.type.toLowerCase();\n        const methodLower = evt.method ? evt.method.toLowerCase() : '';\n\n        if (methodLower.includes('client') || typeLower.includes('client')) {\n          evt.typeClass = 'incoming';\n        } else {\n          evt.typeClass = 'outgoing';\n        }\n      });\n\n      // State\n      let filteredEvents = allEvents;\n      let zoomLevel = 1;\n      let selectedEvent = null;\n      let filterTimeout = null;\n      let filterMinTime = 0;\n      let filterMaxTime = totalDuration;\n\n      // Initialize Time Inputs\n      document.getElementById('minTimeInput').value = \"0\";\n      document.getElementById('maxTimeInput').value = totalDuration.toFixed(2);\n\n      // Virtual Scroll State\n      let lastStartIndex = -1;\n      let lastEndIndex = -1;\n      let isScrolling = false;\n\n      // DOM Elements\n      const rowsContainer = document.getElementById('rowsContainer');\n      const virtualSpacer = document.getElementById('virtualSpacer');\n      const virtualContent = document.getElementById('virtualContent');\n      const rulerContainer = document.getElementById('ruler');\n      const detailsPanel = document.getElementById('detailsPanel');\n      const detailsContent = document.getElementById('detailsContent');\n      const timelineHeader = document.getElementById('timelineHeader');\n      const statsLabel = document.getElementById('statsLabel');\n\n\n      // Heatmap State\n      let currentView = 'timeline';\n      let heatmapZoom = 1;\n      let detailsWasVisible = false;\n      const heatmapCanvas = document.getElementById('heatmapCanvas');\n      const heatmapTooltip = document.getElementById('heatmapTooltip');\n\n      const timelinePanel = document.getElementById('timelinePanel');\n      const heatmapPanel = document.getElementById('heatmapPanel');\n\n      // Heatmap Interaction\n      heatmapCanvas.addEventListener('wheel', (e) => {\n        if (currentView !== 'heatmap') return;\n        e.preventDefault();\n\n        const delta = e.deltaY > 0 ? 1.1 : 0.9;\n        heatmapZoom = Math.max(1, Math.min(50, heatmapZoom * delta));\n        renderHeatmap();\n      }, { passive: false });\n\n      heatmapCanvas.addEventListener('mousemove', (e) => {\n        if (currentView !== 'heatmap') return;\n        const rect = heatmapCanvas.getBoundingClientRect();\n        const x = e.clientX - rect.left;\n        const y = e.clientY - rect.top;\n\n        if (!window.lastHeatmapData) return;\n\n        const { sortedRemotes, rowHeight, binWidth, remotes, maxBinCount, timeBins, binDuration, margin, scrollLeft } = window.lastHeatmapData;\n        const width = heatmapPanel.clientWidth;\n        const height = heatmapPanel.clientHeight;\n\n        if (x < margin.left || x > width - margin.right || y < margin.top || y > height - margin.bottom) {\n          heatmapTooltip.style.display = 'none';\n          return;\n        }\n\n        const rowIndex = Math.floor((y - margin.top) / rowHeight);\n\n        // Calculate colIndex based on virtual position (x + scrollLeft)\n        const colIndex = Math.floor((x - margin.left + scrollLeft) / binWidth);\n\n        if (rowIndex >= 0 && rowIndex < sortedRemotes.length && colIndex >= 0 && colIndex < timeBins) {\n          const remote = sortedRemotes[rowIndex];\n          // Calculate count for this bin\n          let count = 0;\n          remotes[remote].forEach(evt => {\n            const binIndex = Math.min(Math.floor(evt.relTime / binDuration), timeBins - 1);\n            if (binIndex === colIndex) count++;\n          });\n\n          heatmapTooltip.style.display = 'block';\n          heatmapTooltip.innerHTML = `<b>${remote}</b><br>Time: ${(colIndex * binDuration).toFixed(1)}s<br>Count: ${count}`;\n\n          const tooltipWidth = heatmapTooltip.offsetWidth;\n          const panelWidth = heatmapPanel.clientWidth;\n\n          let leftPos = x + 10;\n          if (leftPos + tooltipWidth > panelWidth - 10) {\n            leftPos = x - tooltipWidth - 10;\n          }\n\n          heatmapTooltip.style.left = leftPos + 'px';\n          heatmapTooltip.style.top = (y + 10) + 'px';\n        } else {\n          heatmapTooltip.style.display = 'none';\n        }\n      });\n\n      heatmapCanvas.addEventListener('mouseleave', () => {\n        heatmapTooltip.style.display = 'none';\n      });\n\n      document.getElementById('heatmapScroll').addEventListener('scroll', () => {\n        if (currentView === 'heatmap') {\n          renderHeatmap();\n        }\n      });\n\n      function switchView(view) {\n        currentView = view;\n        document.querySelectorAll('.view-btn').forEach(btn => {\n          btn.classList.toggle('active', btn.innerText.toLowerCase() === view);\n        });\n\n        if (view === 'timeline') {\n          timelinePanel.style.display = 'flex';\n          heatmapPanel.classList.remove('visible');\n\n          if (detailsWasVisible) {\n            detailsPanel.classList.add('visible');\n          }\n\n          renderVirtualRows(true);\n        } else {\n          if (detailsPanel.classList.contains('visible')) {\n            detailsWasVisible = true;\n            detailsPanel.classList.remove('visible');\n          } else {\n            detailsWasVisible = false;\n          }\n\n          timelinePanel.style.display = 'none';\n          heatmapPanel.classList.add('visible');\n          renderHeatmap();\n        }\n      }\n\n      function renderHeatmap() {\n        const ctx = heatmapCanvas.getContext('2d');\n        const containerWidth = heatmapPanel.clientWidth;\n        const height = heatmapPanel.clientHeight;\n        const scrollLeft = document.getElementById('heatmapScroll').scrollLeft;\n\n        // Calculate total virtual width\n        const totalWidth = containerWidth * heatmapZoom;\n\n        // Update Spacer\n        document.getElementById('heatmapSpacer').style.width = totalWidth + 'px';\n\n        const dpr = window.devicePixelRatio || 1;\n\n        // Canvas is always viewport size\n        heatmapCanvas.width = containerWidth * dpr;\n        heatmapCanvas.height = height * dpr;\n        ctx.scale(dpr, dpr);\n\n        ctx.fillStyle = '#0d1117';\n        ctx.fillRect(0, 0, containerWidth, height);\n\n        if (filteredEvents.length === 0) return;\n\n        const remotes = {};\n        filteredEvents.forEach(evt => {\n          if (!remotes[evt.name]) remotes[evt.name] = [];\n          remotes[evt.name].push(evt);\n        });\n\n        const sortedRemotes = Object.keys(remotes).sort((a, b) => remotes[b].length - remotes[a].length);\n\n        const margin = { top: 30, right: 20, bottom: 20, left: 150 };\n\n        // Virtual chart width\n        const chartWidth = totalWidth - margin.left - margin.right;\n        const chartHeight = height - margin.top - margin.bottom;\n\n        // Apply Zoom to time bins\n        const timeBins = Math.floor(100 * heatmapZoom);\n        const binWidth = chartWidth / timeBins;\n        const binDuration = totalDuration / timeBins;\n\n        // Adjust row height to fit\n        const rowHeight = Math.min(30, chartHeight / sortedRemotes.length);\n\n        // Store data for tooltip (adjusted for virtual scroll)\n        window.lastHeatmapData = { sortedRemotes, rowHeight, binWidth, remotes, timeBins, binDuration, margin, scrollLeft };\n\n        ctx.strokeStyle = '#30363d';\n        ctx.lineWidth = 1;\n\n        ctx.font = '11px -apple-system, BlinkMacSystemFont, \"Segoe UI\", Helvetica, Arial, sans-serif';\n        ctx.textAlign = 'right';\n        ctx.textBaseline = 'middle';\n\n        let maxBinCount = 0;\n        sortedRemotes.forEach(remote => {\n          const bins = new Array(timeBins).fill(0);\n          remotes[remote].forEach(evt => {\n            const binIndex = Math.min(Math.floor(evt.relTime / binDuration), timeBins - 1);\n            bins[binIndex]++;\n          });\n          maxBinCount = Math.max(maxBinCount, ...bins);\n        });\n\n        // Update Legend Labels\n        window.lastHeatmapData.maxBinCount = maxBinCount;\n        window.lastHeatmapData.maxBinCount = maxBinCount;\n\n        sortedRemotes.forEach((remote, i) => {\n          const y = margin.top + (i * rowHeight);\n\n          // Draw Label (Fixed position)\n          ctx.fillStyle = '#8b949e';\n          ctx.fillText(remote.length > 20 ? remote.slice(0, 18) + '...' : remote, margin.left - 10, y + rowHeight / 2);\n\n          // Draw Line\n          ctx.beginPath();\n          ctx.moveTo(margin.left, y);\n          ctx.lineTo(containerWidth - margin.right, y);\n          ctx.stroke();\n\n          const bins = new Array(timeBins).fill(0);\n          remotes[remote].forEach(evt => {\n            const binIndex = Math.min(Math.floor(evt.relTime / binDuration), timeBins - 1);\n            bins[binIndex]++;\n          });\n\n          bins.forEach((count, binIndex) => {\n            if (count === 0) return;\n\n            // Calculate virtual X\n            const virtualX = margin.left + (binIndex * binWidth);\n\n            // Apply scroll offset\n            const screenX = virtualX - scrollLeft;\n\n            // Only draw if visible\n            if (screenX + binWidth < margin.left || screenX > containerWidth - margin.right) return;\n\n            // Clamp to chart area\n            const drawX = Math.max(margin.left, screenX);\n            const drawWidth = Math.min(binWidth, (containerWidth - margin.right) - drawX);\n\n            const intensity = count / maxBinCount;\n            const hue = (1 - intensity) * 240;\n            ctx.fillStyle = `hsla(${hue}, 70%, 50%, 0.8)`;\n\n            ctx.fillRect(drawX, y + 2, drawWidth - 1, rowHeight - 4);\n          });\n        });\n\n        ctx.fillStyle = '#8b949e';\n        ctx.textAlign = 'center';\n        ctx.textBaseline = 'top';\n\n        const numTicks = 5 * Math.ceil(heatmapZoom);\n\n        for (let i = 0; i <= numTicks; i++) {\n          const virtualX = margin.left + (chartWidth * (i / numTicks));\n          const screenX = virtualX - scrollLeft;\n\n          if (screenX < margin.left || screenX > containerWidth - margin.right) continue;\n\n          const time = (totalDuration * (i / numTicks)).toFixed(1) + 's';\n          ctx.fillText(time, screenX, margin.top - 20);\n\n          ctx.beginPath();\n          ctx.moveTo(screenX, margin.top);\n          ctx.lineTo(screenX, height - margin.bottom);\n          ctx.stroke();\n        }\n      }\n\n      // Resize observer for heatmap\n      new ResizeObserver(() => {\n        if (currentView === 'heatmap' && heatmapPanel.classList.contains('visible')) {\n          renderHeatmap();\n        }\n      }).observe(heatmapPanel);\n\n      // Window resize handler for timeline\n      window.addEventListener('resize', () => {\n        if (currentView === 'timeline') {\n          renderVirtualRows(true);\n          renderRuler();\n        }\n      });\n\n      // Virtual Scroll Config\n      const ROW_HEIGHT = 29; // 28px + 1px border\n      const BUFFER_SIZE = 5;\n\n      function formatTime(seconds) {\n        if (seconds < 1) return (seconds * 1000).toFixed(1) + 'ms';\n        return seconds.toFixed(2) + 's';\n      }\n\n      function formatAbsTime(timestamp) {\n        const date = new Date(timestamp * 1000);\n        return date.toLocaleTimeString();\n      }\n\n      function getIconUrl(className) {\n        return `https://robloxapi.github.io/ref/icons/dark/${className}.png`;\n      }\n\n      function escapeHtml(text) {\n        if (!text) return '';\n        return text\n          .replace(/&/g, \"&amp;\")\n          .replace(/</g, \"&lt;\")\n          .replace(/>/g, \"&gt;\")\n          .replace(/\"/g, \"&quot;\")\n          .replace(/'/g, \"&#039;\");\n      }\n\n      function syntaxHighlight(text) {\n        if (!text) return '';\n\n        text = escapeHtml(text);\n        return text\n          .replace(/&quot;((?:[^&]|&(?!(quot;)))*)&quot;/g, '<span class=\"hl-str\">\"$1\"</span>')\n          .replace(/\\b(\\d+(\\.\\d+)?)\\b/g, '<span class=\"hl-num\">$1</span>')\n          .replace(/\\b(true|false)\\b/g, '<span class=\"hl-bool\">$1</span>')\n          .replace(/\\b(nil)\\b/g, '<span class=\"hl-nil\">$1</span>');\n      }\n\n      // Toast Logic\n      function showToast(message) {\n        const toast = document.getElementById('toast');\n        const msgSpan = document.getElementById('toastMessage');\n        msgSpan.innerText = message;\n        toast.classList.add('visible');\n        setTimeout(() => {\n          toast.classList.remove('visible');\n        }, 2000);\n      }\n\n      function copyText(text, message = \"Copied to clipboard\") {\n        navigator.clipboard.writeText(text).then(() => {\n          showToast(message);\n        });\n      }\n\n      function copyArgs(btn) {\n        if (selectedEvent) {\n          navigator.clipboard.writeText(selectedEvent.args).then(() => {\n            btn.classList.add('copied');\n            setTimeout(() => btn.classList.remove('copied'), 2000);\n          });\n        }\n      }\n\n      function toggleCallerDropdown(e) {\n        e.stopPropagation();\n        const menu = document.getElementById('callerDropdown');\n        if (menu) {\n          menu.classList.toggle('visible');\n        }\n      }\n\n      function copyCallerData(type) {\n        if (!selectedEvent) return;\n        let text = \"\";\n        let msg = \"Copied to clipboard\";\n        switch (type) {\n          case 'hash':\n            text = selectedEvent.funcHash || \"N/A\";\n            msg = \"Function Hash copied\";\n            break;\n          case 'upvalues':\n            text = selectedEvent.upvalues || \"{}\";\n            msg = \"Upvalues copied\";\n            break;\n          case 'protos':\n            text = selectedEvent.protos || \"[]\";\n            msg = \"Protos copied\";\n            break;\n          case 'path':\n            text = selectedEvent.origin || \"N/A\";\n            msg = \"Script Path copied\";\n            break;\n          case 'source':\n            text = selectedEvent.funcSource || \"N/A\";\n            msg = \"Source copied\";\n            break;\n        }\n        copyText(text, msg);\n        document.getElementById('callerDropdown').classList.remove('visible');\n      }\n\n      // Render Ruler\n      function renderRuler() {\n        rulerContainer.innerHTML = '';\n        const tickCount = Math.max(5, Math.floor(5 * zoomLevel));\n        for (let i = 0; i <= tickCount; i++) {\n          const pct = (i / tickCount) * 100;\n          const time = (totalDuration * (i / tickCount));\n          const tick = document.createElement('div');\n          tick.className = 'tick';\n          tick.style.left = pct + '%';\n          tick.innerText = formatTime(time);\n          rulerContainer.appendChild(tick);\n        }\n      }\n\n      // Scroll Sync\n      rowsContainer.addEventListener('scroll', () => {\n        timelineHeader.scrollLeft = rowsContainer.scrollLeft;\n      });\n\n      // Virtual Rendering\n      function renderVirtualRows(force = false) {\n        const scrollTop = rowsContainer.scrollTop;\n        const containerHeight = rowsContainer.clientHeight;\n\n        const totalHeight = filteredEvents.length * ROW_HEIGHT;\n        virtualSpacer.style.height = totalHeight + 'px';\n\n        const startIndex = Math.floor(scrollTop / ROW_HEIGHT);\n        const endIndex = Math.min(filteredEvents.length, Math.ceil((scrollTop + containerHeight) / ROW_HEIGHT) + BUFFER_SIZE);\n\n        if (!force && startIndex === lastStartIndex && endIndex === lastEndIndex) {\n          return;\n        }\n\n        lastStartIndex = startIndex;\n        lastEndIndex = endIndex;\n\n        const visibleEvents = filteredEvents.slice(Math.max(0, startIndex - BUFFER_SIZE), endIndex);\n        const startOffset = Math.max(0, startIndex - BUFFER_SIZE) * ROW_HEIGHT;\n\n        virtualContent.style.transform = `translateY(${startOffset}px)`;\n\n        const fragment = document.createDocumentFragment();\n        const zoomWidth = (100 * zoomLevel) + '%';\n\n        // Sync Ruler Width\n        document.getElementById('ruler').style.width = zoomWidth;\n\n        visibleEvents.forEach((evt) => {\n          const row = document.createElement('div');\n          row.className = 'trace-row';\n          if (selectedEvent === evt) row.classList.add('selected');\n\n          row.evtData = evt;\n          row.onclick = function () { selectRow(this, evt); };\n\n          const listCol = document.createElement('div');\n          listCol.className = 'row-list';\n          listCol.innerHTML = `\n                    <div class=\"type-icon\" style=\"background-image: url('${getIconUrl(evt.className)}')\"></div>\n                    <div class=\"remote-name\" title=\"${evt.name}\">${evt.name}</div>\n                `;\n\n          const timelineCol = document.createElement('div');\n          timelineCol.className = 'row-timeline';\n          timelineCol.style.width = zoomWidth;\n          timelineCol.style.flex = 'none';\n\n          const marker = document.createElement('div');\n          marker.className = `timeline-marker ${evt.typeClass}`;\n\n          let leftPct = ((evt.relTime) / totalDuration) * 100;\n          if (leftPct > 99) leftPct = 99;\n\n          let widthPct = (0.05 / totalDuration) * 100;\n          if (widthPct < 1) widthPct = 1;\n\n          marker.style.left = leftPct + '%';\n          marker.style.width = widthPct + '%';\n\n          timelineCol.appendChild(marker);\n          row.appendChild(listCol);\n          row.appendChild(timelineCol);\n          fragment.appendChild(row);\n        });\n\n        virtualContent.innerHTML = '';\n        virtualContent.appendChild(fragment);\n      }\n\n      // Ctrl+F Handler\n      document.addEventListener('keydown', function (e) {\n        if ((e.ctrlKey || e.metaKey) && e.key === 'f') {\n          e.preventDefault();\n          const filterInput = document.getElementById('filterInput');\n          filterInput.focus();\n          filterInput.select();\n        }\n      });\n\n      // Initial Render\n      renderVirtualRows();\n      renderRuler();\n\n      function selectRow(el, evt) {\n        const prev = virtualContent.querySelector('.trace-row.selected');\n        if (prev) prev.classList.remove('selected');\n\n        el.classList.add('selected');\n        selectedEvent = evt;\n\n        detailsPanel.classList.add('visible');\n\n        const isIncoming = evt.typeClass === 'incoming';\n        const badgeClass = isIncoming ? 'incoming' : 'outgoing';\n\n        // Flags with Unified Style\n        let flagsHtml = '';\n        if (evt.isExecutor) {\n          flagsHtml += `<div class=\"badge-pill executor\">Executor</div>`;\n        }\n        if (evt.isActor) {\n          flagsHtml += `<div class=\"badge-pill actor\">Actor</div>`;\n        }\n        if (!flagsHtml) flagsHtml = '<span style=\"color:var(--text-secondary); font-size:11px;\">None</span>';\n\n        const highlightedArgs = syntaxHighlight(evt.args);\n\n        // Icons\n        const copyIcon = `<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" class=\"lucide lucide-copy icon-copy\"><rect width=\"14\" height=\"14\" x=\"8\" y=\"8\" rx=\"2\" ry=\"2\"/><path d=\"M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2\"/></svg>`;\n        const checkIcon = `<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" class=\"lucide lucide-check icon-check\"><path d=\"M20 6 9 17l-5-5\"/></svg>`;\n        const parenthesesIcon = `<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" class=\"lucide lucide-parentheses\"><path d=\"M8 21s-4-3-4-9 4-9 4-9\"/><path d=\"M16 3s4 3 4 9-4 9-4 9\"/></svg>`;\n\n        // Dropdown Icons\n        const hashIcon = `<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" class=\"lucide lucide-hash\"><line x1=\"4\" x2=\"20\" y1=\"9\" y2=\"9\"/><line x1=\"4\" x2=\"20\" y1=\"15\" y2=\"15\"/><line x1=\"10\" x2=\"8\" y1=\"3\" y2=\"21\"/><line x1=\"16\" x2=\"14\" y1=\"3\" y2=\"21\"/></svg>`;\n        const upvaluesIcon = `<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" class=\"lucide lucide-a-arrow-up\"><path d=\"m14 11 4-4 4 4\"/><path d=\"M18 16V7\"/><path d=\"m2 16 4.039-9.69a.5.5 0 0 1 .923 0L11 16\"/><path d=\"M3.304 13h6.392\"/></svg>`;\n        const protosIcon = `<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" class=\"lucide lucide-square-function\"><rect width=\"18\" height=\"18\" x=\"3\" y=\"3\" rx=\"2\" ry=\"2\"/><path d=\"M9 17c2 0 2.8-1 2.8-2.8V10c0-2 1-3.3 3.2-3\"/><path d=\"M9 11.2h5.7\"/></svg>`;\n        const pathIcon = `<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" class=\"lucide lucide-route\"><circle cx=\"6\" cy=\"19\" r=\"3\"/><path d=\"M9 19h8.5a3.5 3.5 0 0 0 0-7h-11a3.5 3.5 0 0 1 0-7H15\"/><circle cx=\"18\" cy=\"5\" r=\"3\"/></svg>`;\n        const sourceIcon = `<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" class=\"lucide lucide-code\"><path d=\"m16 18 6-6-6-6\"/><path d=\"m8 6-6 6 6 6\"/></svg>`;\n        const boxIcon = `<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" class=\"lucide lucide-box\"><path d=\"M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z\"/><path d=\"m3.3 7 8.7 5 8.7-5\"/><path d=\"M12 22v-9\"/></svg>`;\n\n        detailsContent.innerHTML = `\n                <div class=\"details-header-top\">\n                    <div class=\"details-title-group\">\n                        <div class=\"details-icon-large\" style=\"background-image: url('${getIconUrl(evt.className)}')\"></div>\n                        <div class=\"details-name-large\">${escapeHtml(evt.name)}</div>\n                    </div>\n                    <div class=\"details-actions\">\n                        <div class=\"badge-pill ${badgeClass}\">${evt.typeClass.toUpperCase()}</div>\n                        <div class=\"close-btn\" onclick=\"closeDetails()\">\195\151</div>\n                    </div>\n                </div>\n\n                <div class=\"details-path-row\" onclick=\"copyText('${escapeHtml(evt.path).replace(/'/g, \"\\\\'\").replace(/\"/g, \"&quot;\")}', 'Remote Path copied')\" title=\"Click to copy path\"><span class=\"clickable-path\">${escapeHtml(evt.path)}</span></div>\n\n                <div class=\"info-grid\">\n                    <div class=\"info-item\">\n                        <h4>Method</h4>\n                        <div>${escapeHtml(evt.method)}</div>\n                    </div>\n                    <div class=\"info-item\">\n                        <h4>Timestamp</h4>\n                        <div>${formatAbsTime(evt.timestamp)} <span style=\"color:var(--text-secondary)\">(+${formatTime(evt.relTime)})</span></div>\n                    </div>\n                    <div class=\"info-item\">\n                        <h4>ClassName</h4>\n                        <div>${escapeHtml(evt.className)}</div>\n                    </div>\n                    <div class=\"info-item\">\n                        <h4>Remote Path</h4>\n                        <div class=\"remote-path-copy clickable-path\" onclick=\"copyText('${escapeHtml(evt.path).replace(/'/g, \"\\\\'\").replace(/\"/g, \"&quot;\")}', 'Remote Path copied')\" title=\"Click to copy path\">${escapeHtml(evt.path)}</div>\n                    </div>\n                </div>\n\n                <div class=\"content-box\">\n                    <div class=\"box-title\">Caller Data</div>\n                    <button class=\"copy-icon-btn\" onclick=\"toggleCallerDropdown(event)\" title=\"Copy Caller Info\">${copyIcon}</button>\n\n                    <div id=\"callerDropdown\" class=\"dropdown-menu\">\n                        <div class=\"dropdown-item\" onclick=\"copyCallerData('hash')\">${hashIcon} Function Hash</div>\n                        <div class=\"dropdown-item\" onclick=\"copyCallerData('upvalues')\">${upvaluesIcon} Upvalues</div>\n                        <div class=\"dropdown-item\" onclick=\"copyCallerData('protos')\">${protosIcon} Protos</div>\n                        <div class=\"dropdown-item\" onclick=\"copyCallerData('constants')\">${boxIcon} Constants</div>\n                        <div class=\"dropdown-item\" onclick=\"copyCallerData('path')\">${pathIcon} Script Path</div>\n                        <div class=\"dropdown-item\" onclick=\"copyCallerData('source')\">${sourceIcon} Func Source</div>\n                    </div>\n\n                    <div class=\"caller-header\">\n                        <div class=\"caller-icon\">${parenthesesIcon}</div>\n                        <div class=\"caller-info\">\n                            <div class=\"caller-name\">${escapeHtml(evt.funcName)} <span class=\"caller-source\">:${evt.funcLine}</span></div>\n                            <div class=\"caller-source\">${escapeHtml(evt.funcSource)}</div>\n                        </div>\n                    </div>\n\n                    <div class=\"info-grid-2\" style=\"margin-bottom:0; gap:10px;\">\n                         <div class=\"info-item-2\" style=\"margin-right: 100px;\">\n                            <h4>Flags</h4>\n                            <div class=\"flags-row\">${flagsHtml}</div>\n                         </div>\n                         <div class=\"info-item-2\">\n                            <h4>Origin</h4>\n                            <div class=\"origin-row clickable-path\" onclick=\"copyText('${escapeHtml(evt.origin).replace(/'/g, \"\\\\'\").replace(/\"/g, \"&quot;\")}', 'Origin copied')\" title=\"Click to copy origin\">${escapeHtml(evt.origin)}</div>\n                         </div>\n                    </div>\n                </div>\n\n                <div class=\"content-box\">\n                    <div class=\"box-title\">Arguments</div>\n                    <button class=\"copy-icon-btn\" onclick=\"copyArgs(this)\" title=\"Copy Arguments\">\n                        ${copyIcon}\n                        ${checkIcon}\n                    </button>\n                    <div class=\"args-content\">${highlightedArgs}</div>\n                </div>\n            `;\n      }\n\n      function closeDetails() {\n        detailsPanel.classList.remove('visible');\n        const prev = virtualContent.querySelector('.trace-row.selected');\n        if (prev) prev.classList.remove('selected');\n        selectedEvent = null;\n      }\n\n      function handleFilterInput() {\n        if (filterTimeout) clearTimeout(filterTimeout);\n        filterTimeout = setTimeout(applyFilters, 300);\n      }\n\n      function toggleSearchOptions() {\n        const widget = document.getElementById('searchChevron').closest('.search-widget');\n        const options = document.getElementById('searchOptions');\n        const chevron = document.getElementById('searchChevron');\n\n        options.classList.toggle('visible');\n        chevron.classList.toggle('expanded');\n        widget.classList.toggle('expanded');\n      }\n\n      function handleTimeInput() {\n        const minVal = parseFloat(document.getElementById('minTimeInput').value);\n        const maxVal = parseFloat(document.getElementById('maxTimeInput').value);\n        const unit = parseFloat(document.getElementById('timeUnitSelect').value);\n\n        filterMinTime = isNaN(minVal) ? 0 : minVal * unit;\n        filterMaxTime = isNaN(maxVal) ? totalDuration : maxVal * unit;\n\n        if (filterTimeout) clearTimeout(filterTimeout);\n        filterTimeout = setTimeout(applyFilters, 300);\n      }\n\n      function applyFilters() {\n        const query = document.getElementById('filterInput').value.toLowerCase();\n        const checkIncoming = document.getElementById('filterIncoming').checked;\n        const checkOutgoing = document.getElementById('filterOutgoing').checked;\n        const checkActor = document.getElementById('filterActor').checked;\n        const checkNonActor = document.getElementById('filterNonActor').checked;\n        const checkArgs = document.getElementById('filterArgs').checked;\n        const checkProto = document.getElementById('filterProto').checked;\n        const checkConst = document.getElementById('filterConst').checked;\n        const checkHash = document.getElementById('filterHash').checked;\n        const checkSource = document.getElementById('filterSource').checked;\n\n        filteredEvents = allEvents.filter(evt => {\n          // Filter by Type (Incoming/Outgoing)\n          if (checkIncoming || checkOutgoing) {\n            const isIncoming = evt.typeClass === 'incoming';\n            const isOutgoing = evt.typeClass === 'outgoing';\n            if (!((checkIncoming && isIncoming) || (checkOutgoing && isOutgoing))) {\n              return false;\n            }\n          }\n\n          // Filter by Actor Status\n          if (checkActor || checkNonActor) {\n            const isActor = evt.isActor;\n            const isNonActor = !evt.isActor;\n            if (!((checkActor && isActor) || (checkNonActor && isNonActor))) {\n              return false;\n            }\n          }\n\n          let matchesText = !query;\n\n          if (!matchesText) {\n            // Default search: Name and Type\n            if (evt.name.toLowerCase().includes(query) || evt.type.toLowerCase().includes(query)) {\n              matchesText = true;\n            }\n            // Advanced search options\n            else {\n              if (checkArgs && evt.args && evt.args.toLowerCase().includes(query)) matchesText = true;\n              else if (checkProto && evt.protos && evt.protos.toLowerCase().includes(query)) matchesText = true;\n              else if (checkConst && evt.constants && evt.constants.toLowerCase().includes(query)) matchesText = true;\n              else if (checkHash && evt.funcHash && evt.funcHash.toLowerCase().includes(query)) matchesText = true;\n              else if (checkSource && evt.funcSource && evt.funcSource.toLowerCase().includes(query)) matchesText = true;\n            }\n          }\n\n          const matchesTime = evt.relTime >= filterMinTime && evt.relTime <= filterMaxTime;\n\n          return matchesText && matchesTime;\n        });\n\n        // Update Stats\n        statsLabel.innerText = `${filteredEvents.length} Events \226\128\162 ${totalDuration.toFixed(2)}s`;\n\n        // Reset Scroll\n        rowsContainer.scrollTop = 0;\n        lastStartIndex = -1;\n        lastEndIndex = -1;\n\n        if (currentView === 'timeline') {\n          renderVirtualRows(true);\n        } else {\n          renderHeatmap();\n        }\n      } function updateZoom() {\n        const width = (100 * zoomLevel) + '%';\n        rulerContainer.style.width = width;\n        renderRuler();\n        lastStartIndex = -1;\n        renderVirtualRows(true);\n      }\n\n      rowsContainer.addEventListener('wheel', (e) => {\n        if (e.ctrlKey) {\n          e.preventDefault();\n          if (e.deltaY < 0) {\n            zoomLevel = Math.min(zoomLevel * 1.1, 20);\n          } else {\n            zoomLevel = Math.max(zoomLevel / 1.1, 1);\n          }\n          updateZoom();\n        }\n      });\n\n      rowsContainer.addEventListener('scroll', () => {\n        timelineHeader.scrollLeft = rowsContainer.scrollLeft;\n\n        if (!isScrolling) {\n          window.requestAnimationFrame(() => {\n            renderVirtualRows();\n            isScrolling = false;\n          });\n          isScrolling = true;\n        }\n      });\n\n      const sessionInfo = document.querySelector('.session-info');\n      const tooltip = document.querySelector('.session-tooltip');\n\n      sessionInfo.addEventListener('click', (e) => {\n        e.stopPropagation();\n        tooltip.classList.toggle('visible');\n      });\n\n      tooltip.addEventListener('click', (e) => {\n        e.stopPropagation();\n      });\n\n      document.addEventListener('click', () => {\n        tooltip.classList.remove('visible');\n        const dropdown = document.getElementById('callerDropdown');\n        if (dropdown) dropdown.classList.remove('visible');\n      });\n    </script>\n  </body>\n</html>\n"
                                }
                            }
                        }
                    },
                    {
                        29,
                        2,
                        {
                            "SaveManager"
                        }
                    }
                }
            },
            {
                46,
                2,
                {
                    "Window"
                }
            },
            {
                2,
                2,
                {
                    "ExecutorSupport"
                }
            },
            {
                3,
                1,
                {
                    "Spy"
                },
                {
                    {
                        14,
                        2,
                        {
                            "Init"
                        }
                    },
                    {
                        7,
                        1,
                        {
                            "Hooks"
                        },
                        {
                            {
                                11,
                                1,
                                {
                                    "Default"
                                },
                                {
                                    {
                                        12,
                                        2,
                                        {
                                            "Incoming"
                                        }
                                    },
                                    {
                                        13,
                                        2,
                                        {
                                            "Outgoing"
                                        }
                                    }
                                }
                            },
                            {
                                8,
                                1,
                                {
                                    "Actors"
                                },
                                {
                                    {
                                        10,
                                        5,
                                        {
                                            "Outgoing",
                                            Value = "local function CreateLookupTable(table)\n\tlocal LookupTable = {}\n\tfor _, Method in next, table do\n\t\tLookupTable[Method] = true\n\tend\n\treturn LookupTable\nend\n\nlocal NamecallMethods = CreateLookupTable({\n\t\"FireServer\",\n\t\"InvokeServer\",\n\t\"Fire\",\n\t\"Invoke\",\n\t\"fireServer\",\n\t\"invokeServer\",\n\t\"fire\",\n\t\"invoke\",\n})\nlocal AllowedClassNames = CreateLookupTable({ \"RemoteEvent\", \"RemoteFunction\", \"UnreliableRemoteEvent\", \"BindableEvent\", \"BindableFunction\" })\n\n--[[\n\tReturns the calling function via `debug.info`\n\n\t@return `function | nil` The calling function or nil if not found.\n]]\nlocal function getcallingfunction()\n\tlocal BaseLevel = if wax.shared.ExecutorSupport[\"oth\"].IsWorking then 2 else 4\n\n\tfor i = BaseLevel, 10 do\n\t\tlocal Function, Source = debug.info(i, \"fs\")\n\t\tif not Function or not Source then\n\t\t\tbreak\n\t\tend\n\n\t\tif Source == \"[C]\" then\n\t\t\tcontinue\n\t\tend\n\n\t\treturn Function\n\tend\n\n\treturn debug.info(BaseLevel, \"f\")\nend\n\n--[[\n\tReturns the calling line of the script that called the function via `debug.info`\n\n\t@return number Returns the line number of the calling script.\n]]\nlocal function getcallingline()\n\tlocal BaseLevel = if wax.shared.ExecutorSupport[\"oth\"].IsWorking then 2 else 4\n\n\tfor i = BaseLevel, 10 do\n\t\tlocal Source, Line = debug.info(i, \"sl\")\n\t\tif not Source then\n\t\t\tbreak\n\t\tend\n\n\t\tif Source == \"[C]\" then\n\t\t\tcontinue\n\t\tend\n\n\t\treturn Line\n\tend\n\n\treturn debug.info(BaseLevel, \"l\")\nend\n\n--[[\n\tReturns the calling source of the script that called the function via `debug.info`\n\n\t@return string Returns the source of the calling script.\n]]\nlocal function getcallingsource()\n\tlocal BaseLevel = if wax.shared.ExecutorSupport[\"oth\"].IsWorking then 2 else 4\n\n\tfor i = BaseLevel, 10 do\n\t\tlocal Source = debug.info(i, \"s\")\n\t\tif not Source then\n\t\t\tbreak\n\t\tend\n\n\t\tif Source == \"[C]\" then\n\t\t\tcontinue\n\t\tend\n\n\t\treturn Source\n\tend\n\n\treturn debug.info(BaseLevel, \"s\")\nend\n\n-- metamethod hooks\nwax.shared.NamecallHook = wax.shared.Hooking.HookMetaMethod(game, \"__namecall\", function(...)\n\tlocal self = ...\n\tlocal Method = getnamecallmethod()\n\n\tif\n\t\ttypeof(self) == \"Instance\"\n\t\tand AllowedClassNames[self.ClassName]\n\t\tand not rawequal(self, wax.shared.Communicator)\n\t\tand not rawequal(self, wax.shared.ActorCommunicator)\n\t\tand NamecallMethods[Method]\n\t\tand not wax.shared.ShouldIgnore(self, getcallingscript())\n\tthen\n\t\tlocal Log = wax.shared.Logs.Outgoing[self]\n\t\tif not Log then\n\t\t\tLog = wax.shared.NewLog(self, \"Outgoing\", Method, getcallingscript())\n\t\tend\n\n\t\tif Log.Blocked then\n\t\t\treturn\n\t\telseif not Log.Ignored then\n\t\t\tlocal Info = {\n\t\t\t\tArguments = table.pack(select(2, ...)),\n\t\t\t\tOrigin = getcallingscript(),\n\t\t\t\tFunction = getcallingfunction(),\n\t\t\t\tLine = getcallingline(),\n\t\t\t\tSource = getcallingsource(),\n\t\t\t\tIsExecutor = checkcaller(),\n\t\t\t}\n\t\t\tLog:Call(Info)\n\t\t\t-- For RemoteFunction return value (ex: local result = RemoteFunction:InvokeServer())\n\t\t\tif self.ClassName == \"RemoteFunction\" and (Method == \"InvokeServer\" or Method == \"invokeServer\") then\n\t\t\t\tLog = wax.shared.Logs.Incoming[self]\n\t\t\t\tif not Log then\n\t\t\t\t\tLog = wax.shared.NewLog(self, \"Incoming\", Method, getcallingscript())\n\t\t\t\tend\n\n\t\t\t\tif Log.Blocked then\n\t\t\t\t\treturn\n\t\t\t\tend\n\n\t\t\t\tlocal Result = table.pack(wax.shared.NamecallHook(...))\n\t\t\t\tif not Log.Ignored then\n\t\t\t\t\tlocal RFResultInfo = {\n\t\t\t\t\t\tArguments = Result,\n\t\t\t\t\t\tOrigin = getcallingscript(),\n\t\t\t\t\t\tFunction = getcallingfunction(),\n\t\t\t\t\t\tLine = getcallingline(),\n\t\t\t\t\t\tSource = getcallingsource(),\n\t\t\t\t\t\tIsExecutor = checkcaller(),\n\t\t\t\t\t\tOriginalInvokeArgs = table.pack(select(2, ...)),\n\t\t\t\t\t}\n\t\t\t\t\tLog:Call(RFResultInfo)\n\t\t\t\tend\n\n\t\t\t\treturn table.unpack(Result, 1, Result.n)\n\t\t\tend\n\t\tend\n\tend\n\n\treturn wax.shared.NamecallHook(...)\nend)\n\n-- function hooks\nlocal FunctionsToHook\ndo\n\tlocal BindableFunction = Instance.new(\"BindableFunction\")\n\tlocal BindableEvent = Instance.new(\"BindableEvent\")\n\n\tlocal RemoteFunction = Instance.new(\"RemoteFunction\")\n\tlocal RemoteEvent = Instance.new(\"RemoteEvent\")\n\tlocal UnreliableRemoteEvent = Instance.new(\"UnreliableRemoteEvent\")\n\n\tFunctionsToHook = {\n\t\tBindableFunction.Invoke,\n\t\tBindableEvent.Fire,\n\n\t\tRemoteFunction.InvokeServer,\n\t\tRemoteEvent.FireServer,\n\t\tUnreliableRemoteEvent.FireServer,\n\t}\n\n\tBindableFunction:Destroy()\n\tBindableEvent:Destroy()\n\n\tRemoteFunction:Destroy()\n\tRemoteEvent:Destroy()\n\tUnreliableRemoteEvent:Destroy()\nend\n\nfor _, Function in next, FunctionsToHook do\n\tlocal Method = debug.info(Function, \"n\")\n\n\twax.shared.Hooks[Function] = wax.shared.Hooking.HookFunction(Function, function(...)\n\t\tlocal self = ...\n\n\t\tif\n\t\t\ttypeof(self) == \"Instance\"\n\t\t\tand AllowedClassNames[self.ClassName]\n\t\t\tand not rawequal(self, wax.shared.Communicator)\n\t\t\tand not wax.shared.ShouldIgnore(self, getcallingscript())\n\t\tthen\n\t\t\tlocal Log = wax.shared.Logs.Outgoing[self]\n\t\t\tif not Log then\n\t\t\t\tLog = wax.shared.NewLog(self, \"Outgoing\", Method, getcallingscript())\n\t\t\tend\n\n\t\t\tif Log.Blocked then\n\t\t\t\treturn\n\t\t\telseif not Log.Ignored then\n\t\t\t\tlocal Info = {\n\t\t\t\t\tArguments = table.pack(select(2, ...)),\n\t\t\t\t\tOrigin = getcallingscript(),\n\t\t\t\t\tFunction = getcallingfunction(),\n\t\t\t\t\tLine = getcallingline(),\n\t\t\t\t\tSource = getcallingsource(),\n\t\t\t\t\tIsExecutor = checkcaller(),\n\t\t\t\t}\n\t\t\t\tLog:Call(Info)\n\t\t\t\t-- For RemoteFunction return value (ex: local result = RemoteFunction:InvokeServer())\n\t\t\t\tif self.ClassName == \"RemoteFunction\" and (Method == \"InvokeServer\" or Method == \"invokeServer\") then\n\t\t\t\t\tLog = wax.shared.Logs.Incoming[self]\n\t\t\t\t\tif not Log then\n\t\t\t\t\t\tLog = wax.shared.NewLog(self, \"Incoming\", Method, getcallingscript())\n\t\t\t\t\tend\n\n\t\t\t\t\tif Log.Blocked then\n\t\t\t\t\t\treturn\n\t\t\t\t\tend\n\n\t\t\t\t\tlocal Result = table.pack(wax.shared.Hooks[Function](...))\n\t\t\t\t\tif not Log.Ignored then\n\t\t\t\t\t\tlocal RFResultInfo = {\n\t\t\t\t\t\t\tArguments = Result,\n\t\t\t\t\t\t\tOrigin = getcallingscript(),\n\t\t\t\t\t\t\tFunction = getcallingfunction(),\n\t\t\t\t\t\t\tLine = getcallingline(),\n\t\t\t\t\t\t\tSource = getcallingsource(),\n\t\t\t\t\t\t\tIsExecutor = checkcaller(),\n\t\t\t\t\t\t\tOriginalInvokeArgs = table.pack(select(2, ...)),\n\t\t\t\t\t\t}\n\t\t\t\t\t\tLog:Call(RFResultInfo)\n\t\t\t\t\tend\n\n\t\t\t\t\treturn table.unpack(Result, 1, Result.n)\n\t\t\t\tend\n\t\t\tend\n\t\tend\n\n\t\treturn wax.shared.Hooks[Function](...)\n\tend)\nend\n"
                                        }
                                    },
                                    {
                                        9,
                                        5,
                                        {
                                            "Incoming",
                                            Value = "local ClassesToHook = {\n\tRemoteEvent = \"OnClientEvent\",\n\tRemoteFunction = \"OnClientInvoke\",\n\tUnreliableRemoteEvent = \"OnClientEvent\",\n\tBindableEvent = \"Event\",\n\tBindableFunction = \"OnInvoke\",\n}\n\ntype InstancesToHook = RemoteEvent | UnreliableRemoteEvent | RemoteFunction | BindableEvent | BindableFunction\ntype MethodsToHook = \"OnClientEvent\" | \"OnClientInvoke\" | \"Event\" | \"OnInvoke\"\n\nlocal LogConnectionFunctions = {}\nlocal SignalMapping = setmetatable({}, { __mode = \"kv\" })\n\nlocal function CreateLookupTable(table)\n\tlocal LookupTable = {}\n\tfor _, Method in next, table do\n\t\tLookupTable[Method] = true\n\tend\n\treturn LookupTable\nend\n\n\n--[[\n\tIndividually logs an incoming remote call.\n\n\t@param Instance The instance that was called.\n\t@param Method The method that was called (e.g., \"OnClientEvent\").\n\t@param Function The function that was called, if applicable.\n\t@param Info The information about the call, including arguments and origin. Can be nil.\n\t@param ... The arguments passed from the server to the client.\n\t@return boolean Returns true if the call was blocked, false otherwise.\n]]\nlocal function LogRemote(\n\tInstance: InstancesToHook,\n\tMethod: MethodsToHook,\n\tFunction: (...any) -> ...any,\n\tInfo: {\n\t\tArguments: { [number]: any, n: number },\n\t\tOrigin: Instance,\n\t\tFunction: (...any) -> ...any,\n\t\tLine: number,\n\t\tIsExecutor: boolean,\n\t}\n)\n\tif not wax.shared.ShouldIgnore(Instance, getcallingscript()) and not LogConnectionFunctions[Function] then\n\t\tlocal Log = wax.shared.Logs.Incoming[Instance]\n\t\tif not Log then\n\t\t\tLog = wax.shared.NewLog(Instance, \"Incoming\", Method, getcallingscript())\n\t\tend\n\n\t\tif Log.Blocked then\n\t\t\treturn true\n\t\telseif not Log.Ignored then\n\t\t\tLog:Call(Info)\n\t\tend\n\tend\n\n\treturn false\nend\n\n--[[\n\tCreates a function that can be used to pass to `Connect` which will log all the incoming calls. It will additonally add the function to a ignore list (`LogConnectionFunctions`) to prevent unneccessary logging.\n\t\n\t@param Instance The instance to log.\n\t@param Method The method to log (e.g., \"OnClientEvent\").\n\t@return function Returns a function that logs all calls to the given instance and method.\n]]\nlocal function CreateConnectionFunction(Instance: InstancesToHook, Method: MethodsToHook)\n\tlocal ConnectionFunction = function(...)\n\t\tfor _, Connection in pairs(getconnections((Instance :: any)[Method])) do\n\t\t\tif Connection.ForeignState then\n\t\t\t\tcontinue\n\t\t\tend\n\n\t\t\tlocal Function = typeof(Connection.Function) == \"function\" and Connection.Function or nil\n\t\t\tlocal Thread = Connection.Thread\n\n\t\t\tlocal Origin = nil\n\n\t\t\tif Thread and getscriptfromthread then\n\t\t\t\tOrigin = getscriptfromthread(Thread)\n\t\t\tend\n\n\t\t\tif not Origin and Function then\n\t\t\t\t-- ts is unreliable because people could js set the script global to nil\n\t\t\t\t-- if only debug.getinfo(Function).source or debug.info(Function, \"s\") returned an Instance...\n\n\t\t\t\tlocal Script = rawget(getfenv(Function), \"script\")\n\t\t\t\tif typeof(Script) == \"Instance\" then\n\t\t\t\t\tOrigin = Script\n\t\t\t\tend\n\t\t\tend\n\n\t\t\tLogRemote(Instance, Method, Function, {\n\t\t\t\tArguments = table.pack(...),\n\t\t\t\tOrigin = Origin,\n\t\t\t\tFunction = Function,\n\t\t\t\tLine = nil,\n\t\t\t\tIsExecutor = Function and isexecutorclosure(Function) or false,\n\t\t\t})\n\t\tend\n\tend\n\n\tLogConnectionFunctions[ConnectionFunction] = true\n\treturn ConnectionFunction\nend\n\n--[[\n\tCreates a function that can be used to pass to callbacks (.OnInvoke & .OnClientInvoke) which will log all the incoming calls.\n\t\n\t@param Instance The instance to log.\n\t@param Method The method to log (e.g., \"OnClientEvent\").\n\t@param Function The original callback of the RemoteFunction\n\t@return function Returns a function that logs all function calls to the given instance and method.\n]]\nlocal function CreateCallbackDetour(Instance: InstancesToHook, Method: MethodsToHook, Callback: (...any) -> ...any)\n\tlocal Detour = function(...)\n\t\tlocal Origin = nil\n\n\t\t-- May not exist in all executors\n\t\tif getscriptfromthread then\n\t\t\tOrigin = getscriptfromthread(coroutine.running())\n\t\tend\n\n\t\t-- Unreliable method to get script.\n\t\tif not Origin then\n\t\t\tlocal Script = rawget(getfenv(Callback), \"script\")\n\t\t\tif typeof(Script) == \"Instance\" then\n\t\t\t\tOrigin = Script\n\t\t\tend\n\t\tend\n\n\t\tlocal FunctionCaller = debug.info(2, \"f\")\n\t\tlocal IsExecutor = if typeof(FunctionCaller) == \"function\"\n\t\t\tthen isexecutorclosure(FunctionCaller)\n\t\t\telse isexecutorclosure(Callback)\n\n\t\tif\n\t\t\tLogRemote(Instance, Method, Callback, {\n\t\t\t\tArguments = table.pack(...),\n\t\t\t\tOrigin = Origin,\n\t\t\t\tFunction = Callback,\n\t\t\t\tLine = nil,\n\t\t\t\tIsExecutor = IsExecutor,\n\t\t\t})\n\t\tthen\n\t\t\treturn\n\t\tend\n\n\t\treturn Callback(...)\n\tend\n\n\tif wax.shared.ExecutorSupport[\"setstackhidden\"].IsWorking then\n\t\tsetstackhidden(Detour, true)\n\tend\n\n\treturn Detour\nend\n\n--[[\n\tHandles setting up logging for the appropriate instances.\n\n\t@param Instance The instance to handle.\n]]\nlocal function HandleInstance(Instance: any)\n\tif\n\t\tnot ClassesToHook[Instance.ClassName]\n\t\tor Instance == wax.shared.Communicator\n\t\tor Instance == wax.shared.ActorCommunicator\n\tthen\n\t\treturn\n\tend\n\n\tlocal Method = ClassesToHook[Instance.ClassName]\n\n\tif Instance.ClassName == \"RemoteEvent\" or Instance.ClassName == \"UnreliableRemoteEvent\" then\n\t\twax.shared.Connect(Instance.OnClientEvent:Connect(CreateConnectionFunction(Instance, Method)))\n\n\t\tSignalMapping[Instance.OnClientEvent] = Instance\n\telseif Instance.ClassName == \"BindableEvent\" then\n\t\twax.shared.Connect(Instance.Event:Connect(CreateConnectionFunction(Instance, Method)))\n\n\t\tSignalMapping[Instance.Event] = Instance\n\telseif Instance.ClassName == \"RemoteFunction\" or Instance.ClassName == \"BindableFunction\" then\n\t\tlocal Success, Callback = pcall(getcallbackvalue, Instance, Method)\n\t\tlocal IsCallable = (\n\t\t\ttypeof(Callback) == \"function\"\n\t\t\tor wax.shared.getrawmetatable(Callback) ~= nil and typeof(wax.shared.getrawmetatable(Callback)[\"__call\"]) == \"function\"\n\t\t\tor false\n\t\t)\n\n\t\tif not Success or not IsCallable then\n\t\t\treturn\n\t\tend\n\n\t\tInstance[Method] = CreateCallbackDetour(Instance, Method, Callback)\n\tend\nend\n\nwax.shared.Connect(game.DescendantAdded:Connect(HandleInstance))\n\nlocal CategoryToSearch = { game:QueryDescendants(\"RemoteEvent, RemoteFunction, UnreliableRemoteEvent, BindableEvent, BindableFunction\") }\nif wax.shared.ExecutorSupport[\"getnilinstances\"].IsWorking then\n\ttable.insert(CategoryToSearch, getnilinstances())\nend\n\nfor _, Category in CategoryToSearch do\n\tfor _, Instance in next, Category do\n\t\tHandleInstance(Instance)\n\tend\nend\n\nwax.shared.NewIndexHook = wax.shared.Hooking.HookMetaMethod(game, \"__newindex\", function(...)\n\tlocal self, key, value = ...\n\n\tif typeof(self) ~= \"Instance\" or not ClassesToHook[self.ClassName] then\n\t\treturn wax.shared.NewIndexHook(...)\n\tend\n\n\tif self.ClassName == \"RemoteFunction\" or self.ClassName == \"BindableFunction\" then\n\t\tlocal Method = ClassesToHook[self.ClassName]\n\n\t\tlocal IsCallable = (\n\t\t\ttypeof(value) == \"function\"\n\t\t\tor wax.shared.getrawmetatable(value) ~= nil and typeof(wax.shared.getrawmetatable(value)[\"__call\"]) == \"function\"\n\t\t\tor false\n\t\t)\n\n\t\tif key == Method and IsCallable then\n\t\t\treturn wax.shared.NewIndexHook(self, key, CreateCallbackDetour(self :: InstancesToHook, Method, value))\n\t\tend\n\tend\n\n\treturn wax.shared.NewIndexHook(...)\nend)\n\nlocal ConnectionKeys = CreateLookupTable({\n\t\"Connect\",\n\t\"ConnectParallel\",\n\t\"connect\",\n\t\"connectParallel\",\n\t\"once\",\n\t\"Once\",\n})\n\nlocal SignalMetatable = wax.shared.getrawmetatable(Instance.new(\"Part\").Touched)\nwax.shared.Hooks[SignalMetatable.__index] = wax.shared.Hooking.HookFunction(SignalMetatable.__index, function(...)\n\tlocal self, key = ...\n\n\tif ConnectionKeys[key] then\n\t\tlocal Instance = SignalMapping[self]\n\t\tlocal Connect = wax.shared.Hooks[SignalMetatable.__index](...)\n\n\t\tif not Instance then\n\t\t\treturn Connect\n\t\tend\n\n\t\tlocal Method = ClassesToHook[Instance.ClassName]\n\t\twax.shared.Hooks[Connect] = wax.shared.Hooking.HookFunction(Connect, function(...)\n\t\t\tlocal _self, callback = ...\n\n\t\t\tlocal Result = table.pack(wax.shared.Hooks[Connect](...))\n\t\t\tlocal Log = wax.shared.Logs.Incoming[Instance]\n\n\t\t\tif Log and Log.Blocked then\n\t\t\t\tfor _, Connection in pairs(getconnections(Instance[Method])) do\n\t\t\t\t\tif not Connection.ForeignState and Connection.Function ~= callback then\n\t\t\t\t\t\tcontinue\n\t\t\t\t\tend\n\n\t\t\t\t\tConnection:Disable()\n\t\t\t\tend\n\t\t\tend\n\n\t\t\treturn table.unpack(Result, 1, Result.n)\n\t\tend)\n\n\t\treturn Connect\n\tend\n\n\treturn wax.shared.Hooks[SignalMetatable.__index](...)\nend)\n"
                                        }
                                    }
                                }
                            }
                        }
                    },
                    {
                        4,
                        1,
                        {
                            "Actors"
                        },
                        {
                            {
                                5,
                                5,
                                {
                                    "Environment",
                                    Value = "--[[\n\n    Wax Environment replicated for actor env\n\n]]\n\nif getgenv().NovaInitialized == true then\n\treturn\nend\n\ngetgenv().NovaInitialized = true\n\ntype ActorData = {\n\tToken: string,\n\n\tIgnorePlayerModule: boolean,\n\tUseAlternativeHooks: boolean,\n\tIgnoredRemotesDropdown: { [string]: boolean },\n\n\tExecutorSupport: { [string]: { IsWorking: boolean } },\n}\n\nlocal Data: ActorData = NOVA_ACTOR_DATA\n\nlocal RelayChannel = get_comm_channel(...)\n\nlocal wax = { shared = {} }\n\nwax.shared.ExecutorSupport = Data.ExecutorSupport\n\nfor _, Service in pairs({\n\t\"Players\",\n\t\"HttpService\",\n}) do\n\twax.shared[Service] = cloneref(game:GetService(Service))\nend\n\nwax.shared.LocalPlayer = wax.shared.Players.LocalPlayer\nwax.shared.PlayerScripts = cloneref(wax.shared.LocalPlayer:WaitForChild(\"PlayerScripts\"))\nwax.shared.ExecutorName = string.split(identifyexecutor(), \" \")[1]\n\nwax.shared.newcclosure = wax.shared.ExecutorName == \"AWP\"\n\t\tand function(f)\n\t\t\tlocal env = getfenv(f)\n\t\t\tlocal x = setmetatable({\n\t\t\t\t__F = f,\n\t\t\t}, {\n\t\t\t\t__index = env,\n\t\t\t\t__newindex = env,\n\t\t\t})\n\n\t\t\tlocal nf = function(...)\n\t\t\t\treturn __F(...)\n\t\t\tend\n\t\t\tsetfenv(nf, x) -- set func env (env of nf gets deoptimized)\n\t\t\treturn newcclosure(nf)\n\t\tend\n\tor newcclosure\n\nwax.shared.getrawmetatable = wax.shared.ExecutorSupport[\"getrawmetatable\"].IsWorking\n\t\tand (getrawmetatable or debug.getmetatable)\n\tor function()\n\t\treturn setmetatable({}, {\n\t\t\t__index = function()\n\t\t\t\treturn function() end\n\t\t\tend,\n\t\t})\n\tend\n\nwax.shared.restorefunction = function(Function: (...any) -> ...any, Silent: boolean?)\n\tlocal Original = wax.shared.Hooks[Function]\n\n\tif Silent and not Original then\n\t\treturn\n\tend\n\n\tassert(Original, \"Function not hooked\")\n\n\tif restorefunction and isfunctionhooked(Function) then\n\t\trestorefunction(Function)\n\telse\n\t\twax.shared.Hooking.HookFunction(Function, Original)\n\tend\n\n\twax.shared.Hooks[Function] = nil\nend\n\nlocal Hooking = {}\n\nwax.shared.AlternativeEnabled = Data.UseAlternativeHooks\n\nHooking.HookFunction = function(Original, Replacement)\n\tif wax.shared.ExecutorSupport[\"oth\"].IsWorking and iscclosure(Original) and islclosure(Replacement) then\n\t\treturn oth.hook(Original, Replacement)\n\tend\n\n\tif islclosure(Replacement) then\n\t\tReplacement = wax.shared.newcclosure(Replacement)\n\tend\n\n\tif not wax.shared.ExecutorSupport[\"hookfunction\"].IsWorking then\n\t\treturn Original\n\tend\n\n\treturn hookfunction(Original, Replacement)\nend\n\nHooking.HookMetaMethod = function(object, method, hook)\n\tlocal Metatable = wax.shared.getrawmetatable(object)\n\tlocal originalMethod = rawget(Metatable, method)\n\n\tif wax.shared.ExecutorSupport[\"oth\"].IsWorking then\n\t\treturn oth.hook(originalMethod, hook)\n\tend\n\n\tif islclosure(hook) then\n\t\thook = wax.shared.newcclosure(hook)\n\tend\n\n\tif\n\t\tData.UseAlternativeHooks\n\t\tor (\n\t\t\tnot wax.shared.ExecutorSupport[\"hookmetamethod\"].IsWorking\n\t\t\tand wax.shared.ExecutorSupport[\"getrawmetatable\"].IsWorking\n\t\t)\n\tthen\n\t\tsetreadonly(Metatable, false)\n\t\trawset(Metatable, method, hook)\n\t\tsetreadonly(Metatable, true)\n\n\t\treturn originalMethod\n\tend\n\n\tif not wax.shared.ExecutorSupport[\"hookmetamethod\"].IsWorking then\n\t\tif method == \"__index\" then\n\t\t\tlocal _, Metamethod = xpcall(function()\n\t\t\t\treturn object[tostring(math.random())]\n\t\t\tend, function(err)\n\t\t\t\treturn debug.info(2, \"f\")\n\t\t\tend)\n\n\t\t\treturn Metamethod\n\t\telseif method == \"__newindex\" then\n\t\t\tlocal _, Metamethod = xpcall(function()\n\t\t\t\tobject[tostring(math.random())] = true\n\t\t\tend, function(err)\n\t\t\t\treturn debug.info(2, \"f\")\n\t\t\tend)\n\n\t\t\treturn Metamethod\n\t\telseif method == \"__namecall\" then\n\t\t\tlocal _, Metamethod = xpcall(function()\n\t\t\t\tobject:Mustard()\n\t\t\tend, function(err)\n\t\t\t\treturn debug.info(2, \"f\")\n\t\t\tend)\n\n\t\t\treturn Metamethod\n\t\tend\n\n\t\treturn nil\n\tend\n\n\treturn hookmetamethod(object, method, hook)\nend\n\nwax.shared.Hooking = Hooking\n\nwax.shared.Hooks = {}\nwax.shared.Settings = {\n\tIgnorePlayerModule = { Value = Data.IgnorePlayerModule },\n\tIgnoredRemotesDropdown = { Value = Data.IgnoredRemotesDropdown },\n}\n\nwax.shared.IsPlayerModule = function(Origin: LocalScript | ModuleScript, Instance: Instance): boolean\n\tif Instance and Instance.ClassName ~= \"BindableEvent\" then\n\t\treturn false\n\tend\n\n\tlocal PlayerModule = Origin and Origin.FindFirstAncestor(Origin, \"PlayerModule\") or nil\n\tif not PlayerModule then\n\t\treturn false\n\tend\n\n\tif PlayerModule.Parent == nil then\n\t\treturn true\n\tend\n\n\treturn compareinstances(PlayerModule.Parent, wax.shared.PlayerScripts)\nend\nwax.shared.ShouldIgnore = function(Instance, Origin)\n\treturn wax.shared.Settings.IgnoredRemotesDropdown.Value[Instance.ClassName] == true\n\t\tor (wax.shared.Settings.IgnorePlayerModule.Value and wax.shared.IsPlayerModule(Origin, Instance))\nend\n\nwax.shared.Connections = {}\n\nwax.shared.Connect = function(Connection)\n\ttable.insert(wax.shared.Connections, Connection)\n\treturn Connection\nend\n\nwax.shared.Disconnect = function(Connection)\n\tConnection:Disconnect()\n\n\tlocal Index = table.find(wax.shared.Connections, Connection)\n\tif Index then\n\t\ttable.remove(wax.shared.Connections, Index)\n\tend\n\n\treturn true\nend\n\nlocal OnUnload\n\nlocal RelayConnection\nRelayConnection = RelayChannel.Event:Connect(function(Type, ...)\n\tif Type == \"Unload\" then\n\t\tRelayConnection:Disconnect()\n\t\twax.shared.Unloaded = true\n\t\tfor _, Connection in wax.shared.Connections do\n\t\t\twax.shared.Disconnect(Connection)\n\t\tend\n\n\t\tif OnUnload then\n\t\t\tOnUnload()\n\t\tend\n\telseif Type == \"MainBlock\" then\n\t\tlocal Instance, EventType = ...\n\t\tlocal Log = wax.shared.Logs[EventType][Instance]\n\t\tif Log then\n\t\t\tLog:Block()\n\t\tend\n\telseif Type == \"MainIgnore\" then\n\t\tlocal Instance, EventType = ...\n\t\tlocal Log = wax.shared.Logs[EventType][Instance]\n\t\tif Log then\n\t\t\tLog:Ignore()\n\t\tend\n\telseif Type == \"MainSettingsSync\" then\n\t\tlocal Setting, Value = ...\n\t\tif wax.shared.Settings[Setting] then\n\t\t\twax.shared.Settings[Setting].Value = Value\n\t\tend\n\tend\nend)\n\nwax.shared.Unloaded = false\nwax.shared.Communicator = RelayChannel\n\nwax.shared.Log = {}\ndo\n\tlocal Log = wax.shared.Log\n\tLog.__index = Log\n\n\tfunction Log.new(Instance, Type, Method, Index, CallingScript)\n\t\tlocal NewLog = setmetatable({\n\t\t\tInstance = Instance,\n\t\t\tType = Type,\n\t\t\tMethod = Method,\n\t\t\tIndex = Index,\n\t\t\tCalls = {},\n\t\t\tIgnored = false,\n\t\t\tBlocked = false,\n\t\t}, Log)\n\n\t\treturn NewLog\n\tend\n\n\tlocal FunctionToMetatadata\n\n\tlocal GenerateUUID = wax.shared.HttpService.GenerateGUID\n\tlocal function GenerateId()\n\t\treturn GenerateUUID(wax.shared.HttpService, false)\n\tend\n\n\tlocal function FixTable(Table, Refs)\n\t\tif not Table then\n\t\t\treturn nil\n\t\tend\n\n\t\tlocal CyclicRefs = Refs or {}\n\t\tlocal Visited = {}\n\t\tlocal OutputTable = {}\n\t\tlocal ContainsCyclicRef = false\n\n\t\tfor Key, Value in Table do\n\t\t\tif type(Value) == \"table\" then\n\t\t\t\tif Visited[Value] then\n\t\t\t\t\tContainsCyclicRef = true\n\n\t\t\t\t\tOutputTable[Key] = {\n\t\t\t\t\t\t__CyclicRef = true,\n\t\t\t\t\t\t__Id = CyclicRefs[Value],\n\t\t\t\t\t}\n\t\t\t\t\tcontinue\n\t\t\t\tend\n\n\t\t\t\tif getmetatable(Value) then\n\t\t\t\t\tOutputTable[Key] =\n\t\t\t\t\t\t\"Nova: Impossible to bridge table with metatable from actor Environment to main Environment\"\n\t\t\t\tend\n\n\t\t\t\tlocal Result, CycleMetadata, ContainsCyclic = FixTable(Value, CyclicRefs)\n\t\t\t\tif not Result then\n\t\t\t\t\tcontinue\n\t\t\t\tend\n\n\t\t\t\tif not ContainsCyclic then\n\t\t\t\t\tOutputTable[Key] = Result\n\t\t\t\t\tcontinue\n\t\t\t\tend\n\n\t\t\t\t-- Merge the cycle metadata\n\t\t\t\tfor k, v in CycleMetadata do\n\t\t\t\t\tOutputTable[k] = v\n\t\t\t\tend\n\n\t\t\t\t-- Create a new cyclic reference\n\t\t\t\tlocal CycleId = GenerateId()\n\n\t\t\t\tOutputTable[Key] = {\n\t\t\t\t\t__CyclicRef = true,\n\t\t\t\t\t__Id = CycleId,\n\t\t\t\t}\n\n\t\t\t\tCyclicRefs[CycleId] = Value\n\n\t\t\t\tVisited[Value] = true\n\t\t\telseif type(Value) == \"function\" then\n\t\t\t\tOutputTable[Key] = FunctionToMetatadata(Value)\n\t\t\telse\n\t\t\t\tOutputTable[Key] = Value\n\t\t\tend\n\t\tend\n\n\t\treturn OutputTable, CyclicRefs, ContainsCyclicRef\n\tend\n\n\tFunctionToMetatadata = function(Function)\n\t\tif not Function then\n\t\t\treturn nil\n\t\tend\n\n\t\tlocal Metadata = {\n\t\t\tAddress = tostring(Function),\n\t\t\tName = debug.info(Function, \"n\"),\n\t\t\tSource = debug.info(Function, \"s\"),\n\t\t\tIsC = iscclosure(Function),\n\t\t}\n\n\t\tif not iscclosure(Function) then\n\t\t\tMetadata[\"Upvalues\"] = debug.getupvalues(Function)\n\t\t\tMetadata[\"Constants\"] = debug.getconstants(Function)\n\t\t\tMetadata[\"Protos\"] = debug.getprotos(Function)\n\t\t\t\n\t\t\tif getfunctionhash then\n\t\t\t\tMetadata[\"FunctionHash\"] = getfunctionhash(Function)\n\t\t\tend\n\t\tend\n\n\t\t-- to validate that this function was generated by FunctionToMetatadata\n\t\tMetadata[\"Validation\"] = Data.Token\n\t\tMetadata[\"__Function\"] = true\n\n\t\treturn Metadata\n\tend\n\n\tfunction DeepClone(orig, copies)\n\t\tcopies = copies or {}\n\t\tif typeof(orig) == \"Instance\" then\n\t\t\treturn cloneref(orig)\n\t\telseif typeof(orig) == \"userdata\" then\n\t\t\tif getmetatable(orig) then\n\t\t\t\treturn newproxy(true)\n\t\t\telse\n\t\t\t\treturn newproxy()\n\t\t\tend\n\t\telseif typeof(orig) == \"function\" then\n\t\t\tif clonefunction then\n\t\t\t\treturn clonefunction(orig)\n\t\t\tend\n\n\t\t\treturn orig\n\t\telseif type(orig) ~= \"table\" then\n\t\t\treturn orig\n\t\telseif copies[orig] then\n\t\t\treturn copies[orig]\n\t\tend\n\n\t\tlocal copy = {}\n\t\tcopies[orig] = copy\n\t\tfor k, v in next, orig do\n\t\t\tcopy[DeepClone(k, copies)] = DeepClone(v, copies)\n\t\tend\n\t\treturn copy\n\tend\n\n\tlocal ClassesConnectionsToggle = {\n\t\tRemoteEvent = \"OnClientEvent\",\n\t\tUnreliableRemoteEvent = \"OnClientEvent\",\n\t\tBindableEvent = \"Event\",\n\t}\n\n\tfunction Log:SetConnectionsEnabled(enabled: boolean)\n\t\tif not self.Instance or not ClassesConnectionsToggle[self.Instance.ClassName] then\n\t\t\treturn\n\t\tend\n\n\t\tlocal ConnectionName = ClassesConnectionsToggle[self.Instance.ClassName]\n\t\tif self.Type ~= \"Incoming\" or not ConnectionName then\n\t\t\treturn\n\t\tend\n\n\t\tfor _, Connection in getconnections(self.Instance[ConnectionName]) do\n\t\t\tif enabled then\n\t\t\t\tConnection:Enable()\n\t\t\telse\n\t\t\t\tConnection:Disable()\n\t\t\tend\n\t\tend\n\tend\n\n\tfunction Log:Call(RawInfo)\n\t\tif self.Instance == wax.shared.Communicator then\n\t\t\treturn\n\t\tend\n\n\t\tRawInfo[\"IsActor\"] = true\n\t\tlocal Info = DeepClone(RawInfo)\n\t\tlocal OldArguments = Info.Arguments\n\t\tInfo.Arguments = {\n\t\t\tData = OldArguments,\n\t\t\tn = OldArguments.n or rawlen(OldArguments),\n\t\t}\n\n\t\t-- Seliware puts their actor BindableEvents in CoreGui\n\t\tlocal identity = getthreadidentity()\n\t\tsetthreadidentity(8)\n\t\twax.shared.Communicator.Fire(wax.shared.Communicator, \"ActorCall\", self.Instance, self.Type, FixTable(Info))\n\t\tsetthreadidentity(identity)\n\tend\n\n\tfunction Log:Ignore()\n\t\tself.Ignored = not self.Ignored\n\tend\n\n\tfunction Log:Block()\n\t\tself.Blocked = not self.Blocked\n\t\tself:SetConnectionsEnabled(not self.Blocked)\n\tend\nend\n\nwax.shared.Logs = {\n\tOutgoing = {},\n\tIncoming = {},\n}\n\nwax.shared.NewLog = function(Instance, Type, Method, Index, CallingScript)\n\tlocal NewLog = wax.shared.Log.new(Instance, Type, Method, Index, CallingScript)\n\twax.shared.Logs[Type][Instance] = NewLog\n\treturn NewLog\nend\n"
                                }
                            },
                            {
                                6,
                                5,
                                {
                                    "Unload",
                                    Value = "local getrawmetatable = getrawmetatable or debug.getmetatable\n\nwax.shared.Communicator.Event:Connect(function(Type, ...)\n\tif Type ~= \"Unload\" then\n\t\treturn\n\tend\n\n\tlocal gameMetatable = getrawmetatable(game)\n\n\tif wax.shared.ExecutorSupport[\"oth\"].IsWorking then\n\t\tpcall(oth.unhook, gameMetatable.__namecall)\n\t\tpcall(oth.unhook, gameMetatable.__newindex)\n\telse\n\t\tif wax.shared.ExecutorSupport[\"restorefunction\"].IsWorking and not wax.shared.AlternativeEnabled then\n\t\t\tpcall(restorefunction, gameMetatable.__namecall)\n\t\t\tpcall(restorefunction, gameMetatable.__newindex)\n\t\telse\n\t\t\twax.shared.Hooking.HookMetaMethod(game, \"__namecall\", wax.shared.NamecallHook)\n\t\t\twax.shared.Hooking.HookMetaMethod(game, \"__newindex\", wax.shared.NewIndexHook)\n\t\tend\n\tend\n\n\tfor Function, Original in pairs(wax.shared.Hooks) do\n\t\tif wax.shared.ExecutorSupport[\"oth\"].IsWorking then\n\t\t\ttask.spawn(pcall, oth.unhook, Function)\n\t\telseif wax.shared.ExecutorSupport[\"restorefunction\"].IsWorking then\n\t\t\ttask.spawn(pcall, wax.shared.restorefunction, Function)\n\t\telse\n\t\t\tpcall(wax.shared.Hooking.HookFunction, Function, Original)\n\t\tend\n\tend\n\n\ttask.defer(function()\n\t\tgetgenv().NovaInitialized = false\n\tend)\nend)\n"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

-- Line offsets for debugging (only included when minifyTables is false)
local LineOffsets = {
    8,
    359,
    [17] = 810,
    [34] = 1890,
    [38] = 2703,
    [39] = 962,
    [36] = 1012,
    [28] = 1254,
    [21] = 961,
    [35] = 1704,
    [33] = 1773,
    [31] = 4393,
    [22] = 2038,
    [40] = 879,
    [12] = 2418,
    [43] = 3030,
    [29] = 2958,
    [24] = 3010,
    [19] = 3155,
    [37] = 3234,
    [44] = 1406,
    [41] = 3306,
    [45] = 3441,
    [42] = 3781,
    [13] = 3910,
    [25] = 4156,
    [26] = 4310,
    [46] = 4392,
    [14] = 2245,
    [27] = 5300
}

-- Misc AOT variable imports
local WaxVersion = "0.4.1"
local EnvName = "Nova"

-- ++++++++ RUNTIME IMPL BELOW ++++++++ --

-- Localizing certain libraries and built-ins for runtime efficiency
local string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION =
      string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION

local table_insert = table.insert
local table_remove = table.remove
local table_freeze = table.freeze or function(t) return t end -- lol

local coroutine_wrap = coroutine.wrap

local string_sub = string.sub
local string_match = string.match
local string_gmatch = string.gmatch

-- The Lune runtime has its own `task` impl, but it must be imported by its builtin
-- module path, "@lune/task"
if _VERSION and string_sub(_VERSION, 1, 4) == "Lune" then
    local RequireSuccess, LuneTaskLib = pcall(require, "@lune/task")
    if RequireSuccess and LuneTaskLib then
        task = LuneTaskLib
    end
end

local task_defer = task and task.defer

-- If we're not running on the Roblox engine, we won't have a `task` global
local Defer = task_defer or function(f, ...)
    coroutine_wrap(f)(...)
end

-- ClassName "IDs"
local ClassNameIdBindings = {
    [1] = "Folder",
    [2] = "ModuleScript",
    [3] = "Script",
    [4] = "LocalScript",
    [5] = "StringValue",
}

local RefBindings = {} -- [RefId] = RealObject

local ScriptClosures = {}
local ScriptClosureRefIds = {} -- [ScriptClosure] = RefId
local StoredModuleValues = {}
local ScriptsToRun = {}

-- wax.shared __index/__newindex
local SharedEnvironment = {}

-- We're creating 'fake' instance refs soley for traversal of the DOM for require() compatibility
-- It's meant to be as lazy as possible
local RefChildren = {} -- [Ref] = {ChildrenRef, ...}

-- Implemented instance methods
local InstanceMethods = {
    GetFullName = { {}, function(self)
        local Path = self.Name
        local ObjectPointer = self.Parent

        while ObjectPointer do
            Path = ObjectPointer.Name .. "." .. Path

            -- Move up the DOM (parent will be nil at the end, and this while loop will stop)
            ObjectPointer = ObjectPointer.Parent
        end

        return Path
    end},

    GetChildren = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)
        end

        return ReturnArray
    end},

    GetDescendants = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)

            for _, Descendant in next, Child:GetDescendants() do
                table_insert(ReturnArray, Descendant)
            end
        end

        return ReturnArray
    end},

    FindFirstChild = { {"string", "boolean?"}, function(self, name, recursive)
        local Children = RefChildren[self]

        for Child in next, Children do
            if Child.Name == name then
                return Child
            end
        end

        if recursive then
            for Child in next, Children do
                -- Yeah, Roblox follows this behavior- instead of searching the entire base of a
                -- ref first, the engine uses a direct recursive call
                return Child:FindFirstChild(name, true)
            end
        end
    end},

    FindFirstAncestor = { {"string"}, function(self, name)
        local RefPointer = self.Parent
        while RefPointer do
            if RefPointer.Name == name then
                return RefPointer
            end

            RefPointer = RefPointer.Parent
        end
    end},

    -- Just to implement for traversal usage
    WaitForChild = { {"string", "number?"}, function(self, name)
        return self:FindFirstChild(name)
    end},
}

-- "Proxies" to instance methods, with err checks etc
local InstanceMethodProxies = {}
for MethodName, MethodObject in next, InstanceMethods do
    local Types = MethodObject[1]
    local Method = MethodObject[2]

    local EvaluatedTypeInfo = {}
    for ArgIndex, TypeInfo in next, Types do
        local ExpectedType, IsOptional = string_match(TypeInfo, "^([^%?]+)(%??)")
        EvaluatedTypeInfo[ArgIndex] = {ExpectedType, IsOptional}
    end

    InstanceMethodProxies[MethodName] = function(self, ...)
        if not RefChildren[self] then
            error("Expected ':' not '.' calling member function " .. MethodName, 2)
        end

        local Args = {...}
        for ArgIndex, TypeInfo in next, EvaluatedTypeInfo do
            local RealArg = Args[ArgIndex]
            local RealArgType = type(RealArg)
            local ExpectedType, IsOptional = TypeInfo[1], TypeInfo[2]

            if RealArg == nil and not IsOptional then
                error("Argument " .. RealArg .. " missing or nil", 3)
            end

            if ExpectedType ~= "any" and RealArgType ~= ExpectedType and not (RealArgType == "nil" and IsOptional) then
                error("Argument " .. ArgIndex .. " expects type \"" .. ExpectedType .. "\", got \"" .. RealArgType .. "\"", 2)
            end
        end

        return Method(self, ...)
    end
end

local function CreateRef(className, name, parent)
    -- `name` and `parent` can also be set later by the init script if they're absent

    -- Extras
    local StringValue_Value

    -- Will be set to RefChildren later aswell
    local Children = setmetatable({}, {__mode = "k"})

    -- Err funcs
    local function InvalidMember(member)
        error(member .. " is not a valid (virtual) member of " .. className .. " \"" .. name .. "\"", 3)
    end
    local function ReadOnlyProperty(property)
        error("Unable to assign (virtual) property " .. property .. ". Property is read only", 3)
    end

    local Ref = {}
    local RefMetatable = {}

    RefMetatable.__metatable = false

    RefMetatable.__index = function(_, index)
        if index == "ClassName" then -- First check "properties"
            return className
        elseif index == "Name" then
            return name
        elseif index == "Parent" then
            return parent
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            return StringValue_Value
        else -- Lastly, check "methods"
            local InstanceMethod = InstanceMethodProxies[index]

            if InstanceMethod then
                return InstanceMethod
            end
        end

        -- Next we'll look thru child refs
        for Child in next, Children do
            if Child.Name == index then
                return Child
            end
        end

        -- At this point, no member was found; this is the same err format as Roblox
        InvalidMember(index)
    end

    RefMetatable.__newindex = function(_, index, value)
        -- __newindex is only for props fyi
        if index == "ClassName" then
            ReadOnlyProperty(index)
        elseif index == "Name" then
            name = value
        elseif index == "Parent" then
            -- We'll just ignore the process if it's trying to set itself
            if value == Ref then
                return
            end

            if parent ~= nil then
                -- Remove this ref from the CURRENT parent
                RefChildren[parent][Ref] = nil
            end

            parent = value

            if value ~= nil then
                -- And NOW we're setting the new parent
                RefChildren[value][Ref] = true
            end
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            StringValue_Value = value
        else
            -- Same err as __index when no member is found
            InvalidMember(index)
        end
    end

    RefMetatable.__tostring = function()
        return name
    end

    setmetatable(Ref, RefMetatable)

    RefChildren[Ref] = Children

    if parent ~= nil then
        RefChildren[parent][Ref] = true
    end

    return Ref
end

-- Create real ref DOM from object tree
local function CreateRefFromObject(object, parent)
    local RefId = object[1]
    local ClassNameId = object[2]
    local Properties = object[3] -- Optional
    local Children = object[4] -- Optional

    local ClassName = ClassNameIdBindings[ClassNameId]

    local Name = Properties and table_remove(Properties, 1) or ClassName

    local Ref = CreateRef(ClassName, Name, parent) -- 3rd arg may be nil if this is from root
    RefBindings[RefId] = Ref

    if Properties then
        for PropertyName, PropertyValue in next, Properties do
            Ref[PropertyName] = PropertyValue
        end
    end

    if Children then
        for _, ChildObject in next, Children do
            CreateRefFromObject(ChildObject, Ref)
        end
    end

    return Ref
end

local RealObjectRoot = CreateRef("Folder", "[" .. EnvName .. "]")
for _, Object in next, ObjectTree do
    CreateRefFromObject(Object, RealObjectRoot)
end

-- Now we'll set script closure refs and check if they should be ran as a BaseScript
for RefId, Closure in next, ClosureBindings do
    local Ref = RefBindings[RefId]

    ScriptClosures[Ref] = Closure
    ScriptClosureRefIds[Ref] = RefId

    local ClassName = Ref.ClassName
    if ClassName == "LocalScript" or ClassName == "Script" then
        table_insert(ScriptsToRun, Ref)
    end
end

local function LoadScript(scriptRef)
    local ScriptClassName = scriptRef.ClassName

    -- First we'll check for a cached module value (packed into a tbl)
    local StoredModuleValue = StoredModuleValues[scriptRef]
    if StoredModuleValue and ScriptClassName == "ModuleScript" then
        return unpack(StoredModuleValue)
    end

    local Closure = ScriptClosures[scriptRef]

    local function FormatError(originalErrorMessage)
        originalErrorMessage = tostring(originalErrorMessage)

        local VirtualFullName = scriptRef:GetFullName()

        -- Check for vanilla/Roblox format
        local OriginalErrorLine, BaseErrorMessage = string_match(originalErrorMessage, "[^:]+:(%d+): (.+)")

        if not OriginalErrorLine or not LineOffsets then
            return VirtualFullName .. ":*: " .. (BaseErrorMessage or originalErrorMessage)
        end

        OriginalErrorLine = tonumber(OriginalErrorLine)

        local RefId = ScriptClosureRefIds[scriptRef]
        local LineOffset = LineOffsets[RefId]

        local RealErrorLine = OriginalErrorLine - LineOffset + 1
        if RealErrorLine < 0 then
            RealErrorLine = "?"
        end

        return VirtualFullName .. ":" .. RealErrorLine .. ": " .. BaseErrorMessage
    end

    -- If it's a BaseScript, we'll just run it directly!
    if ScriptClassName == "LocalScript" or ScriptClassName == "Script" then
        local RunSuccess, ErrorMessage = xpcall(Closure, function(msg)
            return msg
        end)
        if not RunSuccess then
            error(FormatError(ErrorMessage), 0)
        end
    else
        local PCallReturn = {xpcall(Closure, function(msg)
            return msg
        end)}

        local RunSuccess = table_remove(PCallReturn, 1)
        if not RunSuccess then
            local ErrorMessage = table_remove(PCallReturn, 1)
            error(FormatError(ErrorMessage), 0)
        end

        StoredModuleValues[scriptRef] = PCallReturn
        return unpack(PCallReturn)
    end
end

-- We'll assign the actual func from the top of this output for flattening user globals at runtime
-- Returns (in a tuple order): wax, script, require
function ImportGlobals(refId)
    local ScriptRef = RefBindings[refId]

    local function RealCall(f, ...)
        local PCallReturn = {xpcall(f, function(msg)
            return debug.traceback(msg, 2)
        end, ...)}

        local CallSuccess = table_remove(PCallReturn, 1)
        if not CallSuccess then
            error(PCallReturn[1], 3)
        end

        return unpack(PCallReturn)
    end

    -- `wax.shared` index
    local WaxShared = table_freeze(setmetatable({}, {
        __index = SharedEnvironment,
        __newindex = function(_, index, value)
            SharedEnvironment[index] = value
        end,
        __len = function()
            return #SharedEnvironment
        end,
        __iter = function()
            return next, SharedEnvironment
        end,
    }))

    local Global_wax = table_freeze({
        -- From AOT variable imports
        version = WaxVersion,
        envname = EnvName,

        shared = WaxShared,

        -- "Real" globals instead of the env set ones
        script = script,
        require = require,
    })

    local Global_script = ScriptRef

    local function Global_require(module, ...)
        local ModuleArgType = type(module)

        local ErrorNonModuleScript = "Attempted to call require with a non-ModuleScript"
        local ErrorSelfRequire = "Attempted to call require with self"

        if ModuleArgType == "table" and RefChildren[module]  then
            if module.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif module == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(module)
        elseif ModuleArgType == "string" and string_sub(module, 1, 1) ~= "@" then
            -- The control flow on this SUCKS

            if #module == 0 then
                error("Attempted to call require with empty string", 2)
            end

            local CurrentRefPointer = ScriptRef

            if string_sub(module, 1, 1) == "/" then
                CurrentRefPointer = RealObjectRoot
            elseif string_sub(module, 1, 2) == "./" then
                module = string_sub(module, 3)
            end

            local PreviousPathMatch
            for PathMatch in string_gmatch(module, "([^/]*)/?") do
                local RealIndex = PathMatch
                if PathMatch == ".." then
                    RealIndex = "Parent"
                end

                -- Don't advance dir if it's just another "/" either
                if RealIndex ~= "" then
                    local ResultRef = CurrentRefPointer:FindFirstChild(RealIndex)
                    if not ResultRef then
                        local CurrentRefParent = CurrentRefPointer.Parent
                        if CurrentRefParent then
                            ResultRef = CurrentRefParent:FindFirstChild(RealIndex)
                        end
                    end

                    if ResultRef then
                        CurrentRefPointer = ResultRef
                    elseif PathMatch ~= PreviousPathMatch and PathMatch ~= "init" and PathMatch ~= "init.server" and PathMatch ~= "init.client" then
                        error("Virtual script path \"" .. module .. "\" not found", 2)
                    end
                end

                -- For possible checks next cycle
                PreviousPathMatch = PathMatch
            end

            if CurrentRefPointer.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif CurrentRefPointer == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(CurrentRefPointer)
        end

        return RealCall(require, module, ...)
    end

    -- Now, return flattened globals ready for direct runtime exec
    return Global_wax, Global_script, Global_require
end

for _, ScriptRef in next, ScriptsToRun do
    Defer(LoadScript, ScriptRef)
end
