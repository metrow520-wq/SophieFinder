-- Sophie Finder v5 - current-server live egg viewer
-- Displays server-provided snapshot data; does not modify eggs or join servers.
local Players = game:GetService('Players')
local RS = game:GetService('ReplicatedStorage')
local player = Players.LocalPlayer
local guiParent = player:WaitForChild('PlayerGui')
local existing = guiParent:FindFirstChild('SophieFinderV5')
if existing then existing:Destroy() end
local remote = RS:WaitForChild('Packages'):WaitForChild('Networking'):FindFirstChild('RF/EggWorld/AskFieldEggSnapshot')
local assets = require(RS:WaitForChild('Data'):WaitForChild('Assets'))
local gui = Instance.new('ScreenGui')
gui.Name='SophieFinderV5'; gui.ResetOnSpawn=false; gui.Parent=guiParent
local function make(class,props,parent)
 local x=Instance.new(class)
 for k,v in pairs(props) do x[k]=v end
 x.Parent=parent
 return x
end
local panel=make('Frame',{Size=UDim2.fromOffset(440,490),Position=UDim2.new(.5,-220,.5,-245),BackgroundColor3=Color3.fromRGB(23,25,37),BorderSizePixel=0,Active=true,Draggable=true},gui)
make('UICorner',{CornerRadius=UDim.new(0,12)},panel)
make('TextLabel',{Size=UDim2.new(1,-100,0,44),Position=UDim2.fromOffset(12,0),BackgroundTransparency=1,Text='Sophie Finder v5 | LIVE SERVER',TextColor3=Color3.fromRGB(245,245,255),TextSize=18,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},panel)
local close=make('TextButton',{Size=UDim2.fromOffset(30,30),Position=UDim2.new(1,-38,0,7),Text='X',TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(115,42,58)},panel)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
local status=make('TextLabel',{Size=UDim2.new(1,-24,0,35),Position=UDim2.fromOffset(12,45),BackgroundTransparency=1,Text='Waiting for first scan...',TextColor3=Color3.fromRGB(190,200,220),TextSize=12,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},panel)
local refresh=make('TextButton',{Size=UDim2.fromOffset(110,30),Position=UDim2.fromOffset(12,84),Text='Refresh now',TextSize=13,Font=Enum.Font.GothamBold,TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(65,105,195)},panel)
make('UICorner',{CornerRadius=UDim.new(0,6)},refresh)
local minInput=make('TextBox',{Size=UDim2.fromOffset(150,30),Position=UDim2.fromOffset(132,84),PlaceholderText='Min base $/s (0)',Text='',ClearTextOnFocus=false,TextSize=12,TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(43,47,63)},panel)
make('UICorner',{CornerRadius=UDim.new(0,6)},minInput)
local list=make('ScrollingFrame',{Size=UDim2.new(1,-24,1,-133),Position=UDim2.fromOffset(12,123),BackgroundColor3=Color3.fromRGB(30,33,47),BorderSizePixel=0,ScrollBarThickness=5,CanvasSize=UDim2.fromOffset(0,0)},panel)
local layout=make('UIListLayout',{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},list)
layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()list.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+8)end)
local last={}
local function fmt(n)
 n=tonumber(n) or 0
 if n>=1e12 then return string.format('%.2fT',n/1e12) end
 if n>=1e9 then return string.format('%.2fB',n/1e9) end
 if n>=1e6 then return string.format('%.2fM',n/1e6) end
 if n>=1e3 then return string.format('%.2fK',n/1e3) end
 return string.format('%.0f',n)
end
local function render()
 for _,child in ipairs(list:GetChildren()) do if child:IsA('Frame') then child:Destroy() end end
 local threshold=tonumber(minInput.Text) or 0
 local shown=0
 for _,item in ipairs(last) do
  if item.base>=threshold then
   shown=shown+1
   local row=make('Frame',{Size=UDim2.new(1,-8,0,59),BackgroundColor3=Color3.fromRGB(41,45,62),BorderSizePixel=0,LayoutOrder=shown},list)
   make('UICorner',{CornerRadius=UDim.new(0,5)},row)
   make('TextLabel',{Size=UDim2.new(1,-12,0,25),Position=UDim2.fromOffset(6,2),BackgroundTransparency=1,Text=item.name..'  ['..item.rarity..']  $'..fmt(item.base)..'/s base',TextSize=13,Font=Enum.Font.GothamBold,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},row)
   make('TextLabel',{Size=UDim2.new(1,-12,0,25),Position=UDim2.fromOffset(6,29),BackgroundTransparency=1,Text='Area: '..item.area..' | Mutation: '..item.mutation..' | Scale: '..string.format('%.2f',item.scale)..' | Egg base: '..fmt(item.weight)..' kg',TextSize=11,TextColor3=Color3.fromRGB(197,204,224),TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},row)
  end
 end
 status.Text='Server: '..string.sub(game.JobId,1,18)..'... | Matched: '..#last..' | Showing: '..shown..' | Base rates only'
end
local busy=false
local function scan()
 if busy then return end
 busy=true
 status.Text='Requesting current server snapshot...'
 if not remote or not remote:IsA('RemoteFunction') then status.Text='Egg snapshot remote unavailable';busy=false;return end
 local ok,snapshot=pcall(function()return remote:InvokeServer()end)
 if not ok or type(snapshot)~='table' or type(snapshot.Records)~='table' then
  status.Text='Snapshot failed: '..tostring(snapshot);busy=false;return
 end
 local found={}
 for _,egg in pairs(snapshot.Records) do
  if type(egg)=='table' then
   local cfg=assets.Directory[egg.AssetCategory]
   if type(cfg)=='table' then
    table.insert(found,{name=tostring(cfg.DisplayName or egg.AssetCategory),rarity=tostring(cfg.Rarity and cfg.Rarity.DisplayName or '?'),base=tonumber(cfg.EarningRate) or 0,weight=tonumber(cfg.Egg and cfg.Egg.WeightKg) or 0,scale=tonumber(egg.AssetScale) or 1,mutation=tostring(egg.BaseMutation or 'None'),area=tostring(egg.AreaId or '?')})
   end
  end
 end
 table.sort(found,function(a,b)return a.base>b.base end)
 last=found;render();busy=false
end
refresh.MouseButton1Click:Connect(scan)
minInput.FocusLost:Connect(render)
scan()
-- Poll at a modest interval to catch five-minute egg resets.
task.spawn(function()
 while gui.Parent do task.wait(30);if gui.Parent then scan() end end
end)
