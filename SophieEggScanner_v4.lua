-- Sophie Finder v4: read-only egg data discovery (current server only)
-- Does not invoke game remotes, alter gameplay, or send data anywhere.
local RS = game:GetService('ReplicatedStorage')
local WS = game:GetService('Workspace')
local Players = game:GetService('Players')
local player = Players.LocalPlayer
local old = player:WaitForChild('PlayerGui'):FindFirstChild('SophieDiscoveryV4')
if old then old:Destroy() end
local gui = Instance.new('ScreenGui')
gui.Name = 'SophieDiscoveryV4'; gui.ResetOnSpawn = false; gui.Parent = player.PlayerGui
local frame = Instance.new('Frame')
frame.Size = UDim2.fromOffset(620,430); frame.Position = UDim2.new(.5,-310,.5,-215)
frame.BackgroundColor3 = Color3.fromRGB(22,25,39); frame.Parent = gui
Instance.new('UICorner',frame).CornerRadius = UDim.new(0,10)
local title = Instance.new('TextLabel',frame)
title.Size = UDim2.new(1,-55,0,42); title.Position = UDim2.fromOffset(12,5)
title.BackgroundTransparency = 1; title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold; title.TextSize = 18; title.TextColor3 = Color3.new(1,1,1)
title.Text = 'SOPHIE FINDER | Egg Data Discovery v4'
local close = Instance.new('TextButton',frame)
close.Size = UDim2.fromOffset(34,30); close.Position = UDim2.new(1,-41,0,9)
close.Text = 'X'; close.TextColor3 = Color3.new(1,1,1); close.BackgroundColor3 = Color3.fromRGB(151,53,72)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
local status = Instance.new('TextLabel',frame)
status.Size = UDim2.new(1,-24,0,32); status.Position = UDim2.fromOffset(12,48)
status.BackgroundTransparency = 1; status.TextXAlignment = Enum.TextXAlignment.Left
status.Font = Enum.Font.Code; status.TextSize = 13; status.TextColor3 = Color3.fromRGB(170,190,220)
status.Text = 'Server: '..tostring(game.JobId)
local scan = Instance.new('TextButton',frame)
scan.Size = UDim2.fromOffset(115,31); scan.Position = UDim2.fromOffset(12,84)
scan.Text = 'SCAN DATA'; scan.Font = Enum.Font.GothamBold; scan.TextSize = 13
scan.TextColor3 = Color3.new(1,1,1); scan.BackgroundColor3 = Color3.fromRGB(91,77,166)
local scroll = Instance.new('ScrollingFrame',frame)
scroll.Size = UDim2.new(1,-24,1,-130); scroll.Position = UDim2.fromOffset(12,122)
scroll.BackgroundColor3 = Color3.fromRGB(30,34,52); scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 7; scroll.CanvasSize = UDim2.new()
local output = Instance.new('TextLabel',scroll)
output.Size = UDim2.new(1,-12,0,100); output.Position = UDim2.fromOffset(6,5)
output.AutomaticSize = Enum.AutomaticSize.Y; output.TextWrapped = true
output.TextXAlignment = Enum.TextXAlignment.Left; output.TextYAlignment = Enum.TextYAlignment.Top
output.Font = Enum.Font.Code; output.TextSize = 12; output.TextColor3 = Color3.fromRGB(226,232,244)
output.BackgroundTransparency = 1
local function run()
 scan.Text = 'SCANNING...'; scan.Active = false
 local lines = {}; local count = 0
 local function add(s) if #lines < 110 then table.insert(lines,s) end end
 add('Current server: '..tostring(game.JobId))
 add('Read-only discovery. No remote calls.\n')
 local terms = {'EggWorld','AskFieldEggSnapshot','Assets','Mutations','Egg','Pet'}
 local function interesting(n)
  local lower = string.lower(n)
  for _,word in ipairs(terms) do if string.find(lower,string.lower(word),1,true) then return true end end
  return false
 end
 local function examine(root,label,max)
  add('--- '..label..' ---')
  local found = 0
  for _,obj in ipairs(root:GetDescendants()) do
   count = count + 1
   if interesting(obj.Name) and (obj:IsA('RemoteFunction') or obj:IsA('RemoteEvent') or obj:IsA('ModuleScript') or obj:IsA('Folder')) then
    found = found + 1
    if found <= max then add(obj.ClassName..' | '..obj:GetFullName()) end
   end
   if count % 2500 == 0 then task.wait() end
  end
  add('Matching containers/modules/remotes: '..found..' (first '..max..' shown)\n')
 end
 examine(RS,'ReplicatedStorage',65)
 local candidates = {'World','Eggs','Pets','Fields'}
 add('--- Workspace candidate roots ---')
 for _,name in ipairs(candidates) do
  local o = WS:FindFirstChild(name)
  if o then add(o:GetFullName()..' | children: '..#o:GetChildren()) end
 end
 add('\n--- Sample egg-related object attributes ---')
 local shown = 0
 for _,obj in ipairs(WS:GetDescendants()) do
  if interesting(obj.Name) and (obj:IsA('Model') or obj:IsA('Folder')) then
   local attrs = obj:GetAttributes()
   if next(attrs) ~= nil then
    local parts = {}
    for k,v in pairs(attrs) do
     if type(v) == 'string' or type(v) == 'number' or type(v) == 'boolean' then
      table.insert(parts,k..'='..tostring(v):sub(1,55))
     end
     if #parts >= 7 then break end
    end
    if #parts > 0 then
     add(obj:GetFullName()..' | '..table.concat(parts,', '))
     shown = shown + 1
     if shown >= 18 then break end
    end
   end
  end
 end
 if shown == 0 then add('No attributes on sampled egg-named folders/models.') end
 add('\nDONE. Share screenshot of results, especially RemoteFunction/ModuleScript paths.')
 output.Text = table.concat(lines,'\n')
 task.defer(function()
  scroll.CanvasSize = UDim2.fromOffset(0,output.TextBounds.Y+30)
 end)
 status.Text = 'Server: '..tostring(game.JobId)..' | Objects inspected: '..count
 scan.Text = 'SCAN AGAIN'; scan.Active = true
end
scan.MouseButton1Click:Connect(function() task.spawn(run) end)
task.spawn(run)
