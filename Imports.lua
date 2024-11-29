--[=[

    Link: https://github.com/BloodyBurns/Dexter/blob/main/Imports.lua
    Src: https://raw.githubusercontent.com/BloodyBurns/Dexter/refs/heads/main/Imports.lua
    LS: loadstring(game:HttpGet('https://raw.githubusercontent.com/BloodyBurns/Dexter/refs/heads/main/Imports.lua'), 'IvImports')()

]=]

-->| Services
HttpGet = game['HttpGet']
plrs = game:GetService('Players')
CoreGui = game:GetService('CoreGui')
Lighting = game:GetService('Lighting')
RunService = game:GetService('RunService')
HttpService = game:GetService('HttpService')
TweenService = game:GetService('TweenService')
SoundService = game:GetService('SoundService')
InputService = game:GetService('UserInputService')
TeleportService = game:GetService('TeleportService')
ReplicatedStorage = game:GetService('ReplicatedStorage')
MarketplaceService = game:GetService('MarketplaceService')

-->| Variables
Stepped = RunService['Stepped']
Heartbeat = RunService['Heartbeat']
RenderStepped = RunService['RenderStepped']

plr = plrs.LocalPlayer
Backpack = plr:FindFirstChild('Backpack')
Camera = workspace:FindFirstChild('Camera')
PlayerGui = plr:FindFirstChild('PlayerGui')
leaderstats = plr:FindFirstChild('leaderstats')
StarterGear = plr:FindFirstChild('StarterGear')
PlayerScripts = plr:FindFirstChild('PlayerScripts')
MessageRequest = ReplicatedStorage:FindFirstChild('SayMessageRequest', true)

-->| Custom Function
--> Temp
local _type, _typeof = type, typeof

--> local IvDebug = function(...) warn('[Iv Library Debugger]:\n\t', ...) end
GetObjects = function(asset) return game:GetObjects(`rbxassetid://{asset}`)[1] end
f = function(pattern, ...) return pattern:format(...) end
JSON = function(method, data) return method == 'Encode' and HttpService:JSONEncode(data) or HttpService:JSONDecode(data) end
pfp = function(playerUserID) return plrs:GetUserThumbnailAsync(playerUserID, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end
type = function(object, typeValue, orValue) return not typeValue and _type(object) or _type(object) == typeValue or orValue and _type(object) == orValue end
typeof = function(object, typeValue, orValue) return not typeValue and _typeof(object) or _typeof(object) == typeValue or orValue and _typeof(object) == orValue end
hash = function(str) str = tostring(str) local hash = 0 for i = 1, #str do hash = (hash * 31 + string.byte(str, i)) % 2^32 end return f('%08x', hash) end

-->| Signals
SignalRegistry = function()
    return setmetatable({}, {
        ['__index'] = {
            Connections = {},
            isConnection = function(self, Connection)
                assert(type(Connection, 'string', 'RBXScriptConnection'), 'Connection type not supported')

                --> Check 1
                if type(Connection, 'string') then
                    if self.Connections[Connection] then
                        return true
                    end
                end

                --> Check 2
                for x, v in self.Connections do
                    if v.Connection == Connection then
                        return true
                    end
                end
                return false
            end,

            Connect = function(self, ConnectionName, Signal, Callback)
                --> IvDebug(f('Attempting to create connection: %s\n\t\t\tSignal: %s\n\t\t\tCallback: %s', ConnectionName, tostring(Signal):split(' ')[2], tostring(Callback)))
                assert(ConnectionName and Signal and Callback, 'Failed to establish connection: Missing Arguments')
                assert(type(ConnectionName, 'string', 'number'), 'Failed to establish connection: Unsupported Connection Name Type')
                assert(typeof(Signal, 'RBXScriptSignal'), 'Failed to establish connection: Invalid Signal Event')
                assert(type(Callback, 'function'), 'Failed to establish connection: Invalid Callback Function')
                --> if self.Connections[ConnectionName] then IvDebug(f('Overriding existing connection: %s', ConnectionName)) self.Connections[ConnectionName]:Disconnect() end
                self.Connections[ConnectionName] = {
                    State = 'Active',
                    Signal = Signal,
                    Callback = Callback,
                    Connection = Signal:Connect(function(...)
                        if self.Connections[ConnectionName] and self.Connections[ConnectionName].State == 'Idle' then
                            return
                        end
                        Callback(...)
                    end)
                }
                return self.Connections[ConnectionName].Connection
            end,

            Disconnect = function(self, Connection)
                assert(type(Connection, 'string', 'RBXScriptConnection'), 'Failed to disconnect connection: Unsupported Connection Type')
                local isValidConnection, connectionName

                --> Check 1
                if type(Connection, 'string') then
                    if self.Connections[Connection] then
                        self.Connections[Connection].Connection:Disconnect()
                        self.Connections[Connection] = nil
                        isValidConnection = true
                        connectionName = Connection
                    end
                end

                --> Check 2
                for x, v in self.Connections do
                    if v.Connection == Connection then
                        connectionName = x
                        isValidConnection = true
                        v.Connection:Disconnect()
                        self[x] = nil
                        break
                    end
                end

                --> Debug?
                --> if not connectionName then IvDebug('Connection does not exist within haystack:', Connection) return end
                --> local status = isValidConnection and 'Successfully' or 'Failed to'
                --> local action = isValidConnection and 'disconnected' or 'disconnect'
                --> IvDebug(f('%s %s connection: %s', status, action, connectionName))
            end,

            DisconnectAll = function(self)
                local Connections = 0 do
                    for x, v in self.Connections do
                        Connections = Connections + 1
                        v.Connection:Disconnect(x)
                        self[x] = nil
                    end
                end
                --> IvDebug(f('Successfully disconnected all connections [%d]', Connections, Connections))
            end,

            Pause = function(self, Connection)
                assert(type(Connection, 'string', 'RBXScriptConnection'), 'Connection type not supported')
                if not self:isConnection(Connection) then
                    --> IvDebug('Connection does not exist within haystack:', Connection)
                    return
                end

                if self.Connections[Connection].State == 'Active' then
                    self.Connections[Connection].State = 'Idle'
                end
            end,

            Resume = function(self, Connection)
                assert(type(Connection, 'string', 'RBXScriptConnection'), 'Connection type not supported')
                if not self:isConnection(Connection) then
                    --> IvDebug('Connection does not exist within haystack:', Connection)
                    return
                end

                if self.Connections[Connection].State == 'Idle' then
                    self.Connections[Connection].State = 'Active'
                end
            end
        }
    })
end

GetChildren = function(dataModel, filter)
    if not filter then return dataModel:GetChildren() end
    if not type(filter, 'table') or #filter == 0 then return {} end

    local children = {}
    local dataModelChildren = dataModel:GetChildren()

    for x, v in dataModelChildren do
        for x, y in ipairs(filter) do
            local Type, Properties = y[1], y[2]

            if type(Type, 'string') and v:IsA(Type) then
                if not Properties then
                    table.insert(children, v)
                    break
                end

                for name, value in pairs(Properties) do
                    if v[name] == value then
                        table.insert(children, v)
                        break
                    end
                end
            end
        end
    end
    return children
end

GetDescendants = function(dataModel, filter)
    if not filter then return dataModel:GetDescendants() end
    if not type(filter, 'table') or #filter == 0 then return {} end

    local descendants = {}
    local dataModelDescendants = dataModel:GetDescendants()

    for x, v in ipairs(descendants) do
        for x, z in ipairs(filter) do
            local Type, Properties = z[1], z[2]

            if type(Type, 'string') and v:IsA(Type) then
                if not filterProperties then
                    table.insert(descendants, v)
                    break
                end

                for name, value in pairs(Properties) do
                    if v[name] == value then
                        table.insert(descendants, v)
                        break
                    end
                end
            end
        end
    end
    return descendants
end

GetPlayers = function(...)
    if #{...} == 0 then return plrs:GetPlayers() end

    local players = {}
    local fetchPlayers = {...}
    for x, v in plrs:GetPlayers() do
        for y, z in fetchPlayers do
            if v.Name:lower():sub(1, #z) == z:lower() or v.DisplayName:lower():sub(1, #z) == z:lower() then
                table.insert(players, v)
            end
        end
    end
    return players
end

randomString = function(length)
    length = tonumber(length) or 5
    local RandomString, cleanString = '', ''
    for i = 1, length do RandomString = `{RandomString}{string.char(math.random(48, 132))}` end
    cleanString = string.gsub((string.gsub(RandomString, '[%p+%.%z+%c+]', ' ')), ' ', '')
    return cleanString
end

GetPlayer = function(player)
    assert('Player user required')

    for x, v in plrs:GetPlayers() do
        if v.Name:lower():sub(1, #player) == player:lower() or v.DisplayName:lower():sub(1, #player) == player:lower() then
            return v
        end
    end
end

isCharacter = function(Character, Values)
    if not Character then return false end

    local isSeated, isAlive
    local alive = table.find(Values, 'isAlive')
    local sitting = table.find(Values, 'isSitting')

    if sitting then
        if Character:FindFirstChild('Humanoid') and Character.Humanoid.Seated then
            if not alive then return true end
            isSeated = true
        end
    end

    if alive then
        if Character:FindFirstChild('Humanoid') and Character.Humanoid.Health > 0 then
            if not sitting then return true end
            isSeated = true
        end
    end

    return isSeated and isAlive
end

isMe = function(object)
    if object:IsA('Player') then return object == plr end
    if object:IsA('Model') then return object == plr.Character end
    if object:IsA('Instance') then return object:IsDescendantOf(plr.Character) end

    return false
end

isIndexOf = function(data, value)
    if type(data, 'table') then
        for x, v in data do
            if v == value then
                return x
            end
        end
    end

    return false
end

Drag = function(Frame, Speed)
    if not Frame then return end
    local Settings, Connections = {Pos = nil,  Drag = nil, MPos = nil, GPos = nil, Input = nil,  DragSpeed = Speed or 5}, {}
    local maath = function(...) local Args = {...} if #Args <= 2 then return math.pi * math.rad(50) end  return Args[1] + (Args[2] - Args[1]) * Args[3] end

    Frame.Destroying:Connect(function() for x, v in Connections do v:Disconnect() end Connections = nil end)
    table.insert(Connections, Frame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then Settings.Input = input end end))
    table.insert(Connections, Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Settings.Drag = true
            Settings.Pos = Frame.Position
            Settings.MPos = InputService:GetMouseLocation()
            table.insert(Connections, input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Settings.Drag = false
                end
            end))
        end
    end))

    table.insert(Connections, Heartbeat:Connect(function(isActive)
        if not Settings.Pos then return end
        if not Settings.Drag and Settings.GPos then
            local Output1 = maath(Frame.Position.X.Offset, Settings.GPos.X.Offset, isActive * Settings.DragSpeed)
            local Output2 = maath(Frame.Position.Y.Offset, Settings.GPos.Y.Offset, isActive * Settings.DragSpeed)
            Frame.Position = UDim2.new(Settings.Pos.X.Scale, Output1, Settings.Pos.Y.Scale, Output2)
            return
        end

        local GMD = (Settings.MPos - InputService:GetMouseLocation())
        local x, y = (Settings.Pos.X.Offset - GMD.X), (Settings.Pos.Y.Offset - GMD.Y)
        local Output1 = maath(Frame.Position.X.Offset, x, isActive * Settings.DragSpeed)
        local Output2 = maath(Frame.Position.Y.Offset, y, isActive * Settings.DragSpeed)
        Settings.GPos = UDim2.new(Settings.Pos.X.Scale, x, Settings.Pos.Y.Scale, y)
        Frame.Position = UDim2.new(Settings.Pos.X.Scale, Output1, Settings.Pos.Y.Scale, Output2)
    end))
end

TweenTP = function(Object, TeleportTo, ...)
    if Object:IsA('BasePart') and TeleportTo:IsA('BasePart') then
        local tween = TweenService:Create(Object, ..., {['CFrame'] = TeleportTo['CFrame']}):Play()
        return tween
    end
end

purgeSignal = function(Signal, clearAfter)
    if not type(Signal, 'RBXScriptConnection') then return end

    task.spawn(function()
        task.wait(clearAfter)
        Signal:Disconnect()
    end)
end

--> File System
loadAsset = function(dir, url, name)
    if dir and url and writefile then
        local Request = pcall(HttpGet, tostring(url))
        local data = string.format('%s.png', type(name, 'string') or randomString(math.random(5, 10)))
        local path = string.format('%s\\%s', dir, data)

        if isfolder(dir) or makefolder(dir) and Request and getcustomasset then
            xpcall(function()
                writefile(path, HttpGet(tostring(url)))
                return getcustomasset(path), (task.spawn(function()
                    (function()
                        task.wait(5)
                        if isfile(path) then
                            delfile(path)
                        end
                    end)()
                end)), true
            end, function()
                return 0, false
            end)
        end
    end
    return 0, false
end

Save = function(path, data)
    writefile(path, type(data, 'table') and JSON('Encode', data) or data)
end

-->| Unassigned Variables Assinging
--> ThemeProvider = ((function()  for x, v in GetDescendants(CoreGui, {{'Frame', {Name = 'TopBarFrame'}}}) do return v end end)())
--> TopBarFrame = ThemeProvider and ThemeProvider:FindFirstChild('LeftFrame') or ThemeProvider:FindFirstChild('RightFrame')
