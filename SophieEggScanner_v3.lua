-- Sophie Finder | Current-server discovery scanner v3
-- Read-only inspection of client-replicated Roblox instances.
-- Does not access other servers, protected scripts, or private APIs.
local Players = game:GetService('Players')
local RS = game:GetService('ReplicatedStorage')
local WS = game:GetService('Workspace')
local player = Players.LocalPlayer
local pg = player:WaitForChild('PlayerGui')
local old = pg:FindFirstChild('SophieScannerV3')
if old then old:Destroy() end

local gui = Instance.new('ScreenGui')
gui.Name = 'SophieScannerV3'
gui.ResetOnSpawn = false
gui.DisplayOrder = 1000
gui.Parent = pg
local frame = Instance.new('Frame')
frame.Size = UDim2.fromOffset(540, 420)
frame.Position = UDim2.new(0.5, -270, 0.5, -210)
frame.BackgroundColor3 = Color3.fromRGB(23, 24, 36)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new('UICorner', frame).CornerRadius = UDim.new(0, 12)
local function label(text, pos, size, fontSize, color)
 local l = Instance.new('TextLabel')
 l.BackgroundTransparency = 1
 l.Position = pos
 l.Size = size
 l.Text = text
 l.TextColor3 = color or Color3.fromRGB(235, 235, 245)
 l.TextSize = fontSize or 14
 l.Font = Enum.Font.Gotham
 l.TextXAlignment = Enum.TextXAlignment.Left
 l.Parent = frame
 return l
end
label('SOPHIE FINDER | Egg Discovery v3', UDim2.fromOffset(15, 10), UDim2.fromOffset(450, 27), 19)
label('Current server: '..tostring(game.JobId), UDim2.fromOffset(15, 43), UDim2.fromOffset(505, 24), 12)
local close = Instance.new('TextButton')
close.Size = UDim2.fromOffset(35, 30)
close.Position = UDim2.new(1, -44, 0, 8)
close.Text = 'X'
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(155, 55, 70)
close.Parent = frame
close.MouseButton1Click:Connect(function() gui:Destroy() end)
local scan = Instance.new('TextButton')
scan.Size = UDim2.fromOffset(130, 34)
scan.Position = UDim2.fromOffset(15, 75)
scan.Text = 'SCAN AGAIN'
scan.TextColor3 = Color3.new(1,1,1)
scan.BackgroundColor3 = Color3.fromRGB(91, 72, 167)
scan.Parent = frame
local status = label('Ready to inspect replicated objects.', UDim2.fromOffset(155, 79), UDim2.fromOffset(360, 28), 12)
local scroll = Instance.new('ScrollingFrame')
scroll.Position = UDim2.fromOffset(15, 119)
scroll.Size = UDim2.new(1, -30, 1, -133)
scroll.BackgroundColor3 = Color3.fromRGB(32, 34, 48)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.Parent = frame
local listing = Instance.new('UIListLayout')
listing.Padding = UDim.new(0, 5)
listing.Parent = scroll
listing:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
 scroll.CanvasSize = UDim2.fromOffset(0, listing.AbsoluteContentSize.Y + 8)
end)
local function addLine(s)
 local l = Instance.new('TextLabel')
 l.BackgroundTransparency = 1
 l.Size = UDim2.new(1, -10, 0, 0)
 l.AutomaticSize = Enum.AutomaticSize.Y
 l.TextWrapped = true
 l.TextXAlignment = Enum.TextXAlignment.Left
 l.TextYAlignment = Enum.TextYAlignment.Top
 l.Font = Enum.Font.Code
 l.TextSize = 12
 l.TextColor3 = Color3.fromRGB(215, 228, 241)
 l.Text = s
 l.Parent = scroll
end
local patterns = {'egg','field','hatch','mutation','asset','pet','spawn'}
local fields = {'AssetCategory','AssetScale','Mutations','Income','IncomePerSecond','CashPerSecond','Weight','Rarity','Mutation','Rate'}
local function relevant(name)
 local n = string.lower(name)
 for _, p in ipairs(patterns) do if string.find(n, p, 1, true) then return true end end
 return false
end
local function safeString(v)
 local t = typeof(v)
 if t == 'string' or t == 'number' or t == 'boolean' then return tostring(v) end
 if t == 'Instance' then return v:GetFullName() end
 return '['..t..']'
end
local function run()
 for _, c in ipairs(scroll:GetChildren()) do if c:IsA('TextLabel') then c:Destroy() end end
 status.Text = 'Scanning...'
 local seen, shown = 0, 0
 for _, root in ipairs({WS, RS}) do
  for _, obj in ipairs(root:GetDescendants()) do
   seen = seen + 1
   if relevant(obj.Name) then
    shown = shown + 1
    if shown <= 100 then
     local lines = {obj.ClassName..' | '..obj:GetFullName()}
     for _, field in ipairs(fields) do
      local ok, val = pcall(function() return obj:GetAttribute(field) end)
      if ok and val ~= nil then table.insert(lines, '  '..field..' = '..safeString(val)) end
      local child = obj:FindFirstChild(field)
      if child and child:IsA('ValueBase') then
       local ok2, val2 = pcall(function() return child.Value end)
       if ok2 then table.insert(lines, '  '..field..' = '..safeString(val2)) end
      end
     end
     addLine(table.concat(lines, '\n'))
    end
   end
   if seen % 350 == 0 then task.wait() end
  end
 end
 status.Text = 'Matches: '..shown..' | inspected: '..seen
 if shown == 0 then addLine('No matching objects found. This does not prove eggs are unavailable; the game may use different names or server-only data.') end
 if shown > 100 then addLine('Only first 100 matches shown. Narrower detection will follow once we identify the correct objects.') end
 print('[Sophie v3] server='..tostring(game.JobId)..' inspected='..seen..' matches='..shown)
end
scan.MouseButton1Click:Connect(run)
task.spawn(run)
