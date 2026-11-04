-- Sophie Finder v6: current-server egg viewer (not a cross-server scanner).
-- Uses one EggWorld snapshot every 30 seconds. Estimates are NOT verified against displayed in-game values.
local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local parent=Players.LocalPlayer:WaitForChild('PlayerGui')
for _,name in ipairs({'SophieFinderV5','SophieFinderV6'}) do
 local old=parent:FindFirstChild(name)
 if old then old:Destroy() end
end
local gui=Instance.new('ScreenGui')
gui.Name='SophieFinderV6';gui.ResetOnSpawn=false;gui.Parent=parent
local function make(class,props,p)
 local obj=Instance.new(class)
 for k,v in pairs(props) do obj[k]=v end
 obj.Parent=p
 return obj
end
local panel=make('Frame',{Size=UDim2.fromOffset(490,535),Position=UDim2.new(.5,-245,.5,-267),BackgroundColor3=Color3.fromRGB(22,25,38),BorderSizePixel=0,Active=true,Draggable=true},gui)
make('UICorner',{CornerRadius=UDim.new(0,12)},panel)
make('TextLabel',{Size=UDim2.new(1,-55,0,38),Position=UDim2.fromOffset(12,4),BackgroundTransparency=1,Text='Sophie Finder v6  |  LIVE SERVER',Font=Enum.Font.GothamBold,TextSize=17,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Color3.new(1,1,1)},panel)
local close=make('TextButton',{Size=UDim2.fromOffset(31,30),Position=UDim2.new(1,-39,0,7),Text='X',TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(145,50,70)},panel)
close.MouseButton1Click:Connect(function()gui:Destroy()end)
local status=make('TextLabel',{Size=UDim2.new(1,-24,0,40),Position=UDim2.fromOffset(12,41),BackgroundTransparency=1,Text='Starting...',TextSize=12,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Color3.fromRGB(197,210,232)},panel)
local refresh=make('TextButton',{Size=UDim2.fromOffset(90,30),Position=UDim2.fromOffset(12,85),Text='Refresh',TextSize=12,Font=Enum.Font.GothamBold,TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(65,105,195)},panel)
make('UICorner',{CornerRadius=UDim.new(0,6)},refresh)
local minimum=make('TextBox',{Size=UDim2.fromOffset(155,30),Position=UDim2.fromOffset(109,85),PlaceholderText='Min est. $/s',Text='',ClearTextOnFocus=false,TextSize=12,TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(43,47,63)},panel)
make('UICorner',{CornerRadius=UDim.new(0,6)},minimum)
local rarities={'All','Rare','Epic','Legendary','Mythic','Cosmic','Secret','Divine','Eternal'}
local selected=1
local rarity=make('TextButton',{Size=UDim2.fromOffset(132,30),Position=UDim2.fromOffset(272,85),Text='Rarity: All',TextSize=12,TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(52,58,80)},panel)
make('UICorner',{CornerRadius=UDim.new(0,6)},rarity)
local list=make('ScrollingFrame',{Size=UDim2.new(1,-24,1,-165),Position=UDim2.fromOffset(12,124),BackgroundColor3=Color3.fromRGB(30,33,47),BorderSizePixel=0,ScrollBarThickness=6,CanvasSize=UDim2.fromOffset(0,0)},panel)
local layout=make('UIListLayout',{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},list)
layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()list.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+8)end)
make('TextLabel',{Size=UDim2.new(1,-24,0,26),Position=UDim2.new(0,12,1,-31),BackgroundTransparency=1,Text='Estimated income uses scale^1.85 (unverified). Current server only.',TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Color3.fromRGB(245,191,108)},panel)
local function fmt(n)
 n=tonumber(n) or 0
 if n>=1e12 then return string.format('%.2fT',n/1e12) end
 if n>=1e9 then return string.format('%.2fB',n/1e9) end
 if n>=1e6 then return string.format('%.2fM',n/1e6) end
 if n>=1e3 then return string.format('%.2fK',n/1e3) end
 return string.format('%.1f',n)
end
local last={}
local function render()
 for _,child in ipairs(list:GetChildren()) do if child:IsA('Frame') then child:Destroy() end end
 local min=tonumber(minimum.Text) or 0
 local shown=0
 for _,item in ipairs(last) do
  if item.estimated>=min and (selected==1 or item.rarity==rarities[selected]) then
   shown=shown+1
   local row=make('Frame',{Size=UDim2.new(1,-8,0,66),BackgroundColor3=Color3.fromRGB(42,46,64),BorderSizePixel=0,LayoutOrder=shown},list)
   make('UICorner',{CornerRadius=UDim.new(0,6)},row)
   make('TextLabel',{Size=UDim2.new(1,-12,0,23),Position=UDim2.fromOffset(6,3),BackgroundTransparency=1,Text=item.name..' ['..item.rarity..']   ~$'..fmt(item.estimated)..'/s',TextColor3=Color3.fromRGB(243,248,255),Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},row)
   make('TextLabel',{Size=UDim2.new(1,-12,0,19),Position=UDim2.fromOffset(6,25),BackgroundTransparency=1,Text='~'..fmt(item.weight)..' kg  |  '..item.mutation..'  |  '..item.area..'  |  Scale '..string.format('%.2f',item.scale),TextColor3=Color3.fromRGB(194,207,230),TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},row)
   make('TextLabel',{Size=UDim2.new(1,-12,0,17),Position=UDim2.fromOffset(6,45),BackgroundTransparency=1,Text='Base $'..fmt(item.base)..'/s  |  Mutation x'..string.format('%.2f',item.multiplier),TextColor3=Color3.fromRGB(165,177,201),TextSize=10,TextXAlignment=Enum.TextXAlignment.Left},row)
  end
 end
 status.Text='Server '..string.sub(game.JobId,1,16)..'...  |  Live eggs: '..#last..'  |  Showing: '..shown..'\nRefreshes every 30s; income and weight are estimates'
end
rarity.MouseButton1Click:Connect(function()selected=selected%#rarities+1;rarity.Text='Rarity: '..rarities[selected];render()end)
minimum.FocusLost:Connect(render)
local okAssets,assets=pcall(function()return require(RS:WaitForChild('Data'):WaitForChild('Assets'))end)
local okMut,mutations=pcall(function()return require(RS:WaitForChild('Shared'):WaitForChild('Modules'):WaitForChild('Mutations'))end)
local remote=RS:WaitForChild('Packages'):WaitForChild('Networking'):FindFirstChild('RF/EggWorld/AskFieldEggSnapshot')
local function multiplierFor(egg)
 local scalar=1
 local names={}
 if type(egg.BaseMutation)=='string' and egg.BaseMutation~='None' then table.insert(names,egg.BaseMutation) end
 if type(egg.Mutations)=='table' then
  for key,value in pairs(egg.Mutations) do
   local id=nil
   if type(key)=='string' and value==true then id=key
   elseif type(value)=='string' then id=value
   elseif type(value)=='table' then id=value.Id or value._id end
   if type(id)=='string' and id~='None' then table.insert(names,id) end
  end
 end
 local used={}
 local labels={}
 for _,id in ipairs(names) do
  if not used[id] then
   used[id]=true
   table.insert(labels,id)
   if okMut and type(mutations.Get)=='function' then
    local ok,config=pcall(function()return mutations.Get(id)end)
    if ok and type(config)=='table' then scalar=scalar*(tonumber(config.EarningsScalar) or 1) end
   end
  end
 end
 return scalar,(#labels>0 and table.concat(labels,', ') or 'None')
end
local busy=false
local function scan()
 if busy or not gui.Parent then return end
 busy=true
 status.Text='Reading current server snapshot...'
 if not okAssets or type(assets.Directory)~='table' or not remote or not remote:IsA('RemoteFunction') then
  status.Text='Required game data or snapshot remote unavailable';busy=false;return
 end
 local ok,snapshot=pcall(function()return remote:InvokeServer()end)
 if not ok or type(snapshot)~='table' or type(snapshot.Records)~='table' then
  status.Text='Snapshot unavailable: '..tostring(snapshot);busy=false;return
 end
 local found={}
 for _,egg in pairs(snapshot.Records) do
  if type(egg)=='table' then
   local cfg=assets.Directory[egg.AssetCategory]
   if type(cfg)=='table' then
    local scale=tonumber(egg.AssetScale) or 1
    local base=tonumber(cfg.EarningRate) or 0
    local baseWeight=tonumber(cfg.Egg and cfg.Egg.WeightKg) or 0
    local mult,mutation=multiplierFor(egg)
    table.insert(found,{name=tostring(cfg.DisplayName or egg.AssetCategory),rarity=tostring(cfg.Rarity and cfg.Rarity.DisplayName or '?'),base=base,scale=scale,weight=baseWeight*scale,estimated=base*(scale^1.85)*mult,multiplier=mult,mutation=mutation,area=tostring(egg.AreaId or '?')})
   end
  end
 end
 table.sort(found,function(a,b)return a.estimated>b.estimated end)
 last=found;render();busy=false
end
refresh.MouseButton1Click:Connect(scan)
scan()
task.spawn(function()while gui.Parent do task.wait(30);if gui.Parent then scan()end end end)
