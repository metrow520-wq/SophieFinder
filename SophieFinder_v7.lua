-- Sophie Finder v7: v6 current-server viewer + opt-in private cloud reporting and cross-server sightings.
-- Uses one EggWorld snapshot every 30 seconds. Estimates are NOT verified against displayed in-game values.
local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local parent=Players.LocalPlayer:WaitForChild('PlayerGui')
for _,name in ipairs({'SophieFinderV5','SophieFinderV6','SophieFinderV7','SophieCloudV7'}) do
 local old=parent:FindFirstChild(name)
 if old then old:Destroy() end
end
local gui=Instance.new('ScreenGui')
gui.Name='SophieFinderV7';gui.ResetOnSpawn=false;gui.Parent=parent
local function make(class,props,p)
 local obj=Instance.new(class)
 for k,v in pairs(props) do obj[k]=v end
 obj.Parent=p
 return obj
end
local panel=make('Frame',{Size=UDim2.fromOffset(490,535),Position=UDim2.new(.5,-245,.5,-267),BackgroundColor3=Color3.fromRGB(22,25,38),BorderSizePixel=0,Active=true,Draggable=true},gui)
make('UICorner',{CornerRadius=UDim.new(0,12)},panel)
make('TextLabel',{Size=UDim2.new(1,-55,0,38),Position=UDim2.fromOffset(12,4),BackgroundTransparency=1,Text='Sophie Finder v7  |  LIVE SERVER',Font=Enum.Font.GothamBold,TextSize=17,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Color3.new(1,1,1)},panel)
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
local sophieReport=nil
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
    table.insert(found,{uid=tostring(egg.Uid or ''),name=tostring(cfg.DisplayName or egg.AssetCategory),rarity=tostring(cfg.Rarity and cfg.Rarity.DisplayName or '?'),base=base,scale=scale,weight=baseWeight*scale,estimated=base*(scale^1.85)*mult,multiplier=mult,mutation=mutation,area=tostring(egg.AreaId or '?')})
   end
  end
 end
 table.sort(found,function(a,b)return a.estimated>b.estimated end)
 last=found;render();busy=false
 if sophieReport then task.spawn(function() sophieReport(found) end) end
end
refresh.MouseButton1Click:Connect(scan)
scan()
task.spawn(function()while gui.Parent do task.wait(30);if gui.Parent then scan()end end end)



-- Private cloud test: token is entered in the UI, never included in this file.
local HttpService=game:GetService('HttpService')
local TeleportService=game:GetService('TeleportService')
local API='https://lqqpcyrocnjprhnutprc.supabase.co/functions/v1/sophie-api'
local cloud=make('ScreenGui',{Name='SophieCloudV7',ResetOnSpawn=false},parent)
local cp=make('Frame',{Size=UDim2.fromOffset(450,425),Position=UDim2.new(.5,260,.5,-210),BackgroundColor3=Color3.fromRGB(22,25,38),BorderSizePixel=0,Active=true,Draggable=true},cloud)
make('UICorner',{CornerRadius=UDim.new(0,12)},cp)
make('TextLabel',{Size=UDim2.new(1,-15,0,30),Position=UDim2.fromOffset(10,6),BackgroundTransparency=1,Text='Sophie Finder v7  |  CROSS-SERVER (TEST)',Font=Enum.Font.GothamBold,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Color3.new(1,1,1)},cp)
local cloudStatus=make('TextLabel',{Size=UDim2.new(1,-20,0,40),Position=UDim2.fromOffset(10,40),BackgroundTransparency=1,Text='Public sightings: ready. Reporting: OFF.',TextWrapped=true,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Color3.fromRGB(195,209,235)},cp)
local tokenBox=make('TextBox',{Size=UDim2.fromOffset(270,30),Position=UDim2.fromOffset(10,83),PlaceholderText='Private reporting token (not saved)',Text='',ClearTextOnFocus=false,TextSize=12,TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(43,47,63)},cp)
make('UICorner',{CornerRadius=UDim.new(0,6)},tokenBox)
local toggle=make('TextButton',{Size=UDim2.fromOffset(152,30),Position=UDim2.fromOffset(287,83),Text='Reporting: OFF',TextSize=12,TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(115,55,65)},cp)
make('UICorner',{CornerRadius=UDim.new(0,6)},toggle)
local loadButton=make('TextButton',{Size=UDim2.fromOffset(138,28),Position=UDim2.fromOffset(10,121),Text='Refresh cloud list',TextSize=12,TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(65,105,195)},cp)
make('UICorner',{CornerRadius=UDim.new(0,6)},loadButton)
local cloudList=make('ScrollingFrame',{Size=UDim2.new(1,-20,1,-193),Position=UDim2.fromOffset(10,158),BackgroundColor3=Color3.fromRGB(30,33,47),BorderSizePixel=0,ScrollBarThickness=5,CanvasSize=UDim2.fromOffset(0,0)},cp)
local cloudLayout=make('UIListLayout',{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},cloudList)
cloudLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() cloudList.CanvasSize=UDim2.fromOffset(0,cloudLayout.AbsoluteContentSize.Y+6) end)
make('TextLabel',{Size=UDim2.new(1,-20,0,26),Position=UDim2.new(0,10,1,-30),BackgroundTransparency=1,Text='Only participating servers. Sightings expire after 6 minutes.',TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Color3.fromRGB(245,191,108)},cp)

local function send(method,body,token)
 local fn=(syn and syn.request) or http_request or request or (http and http.request)
 if type(fn)~='function' then return false,'Executor HTTP request function unavailable' end
 local h={['Content-Type']='application/json'}
 if token then h['x-sophie-token']=token end
 local ok,res=pcall(function() return fn({Url=API,Method=method,Headers=h,Body=body}) end)
 if not ok then return false,tostring(res) end
 if type(res)~='table' then return false,'Unexpected HTTP response' end
 local status=tonumber(res.StatusCode or res.Status) or 0
 if status<200 or status>=300 then return false,'HTTP '..status..': '..tostring(res.Body or ''):sub(1,130) end
 local parsed,decoded=pcall(function()return HttpService:JSONDecode(res.Body or '{}')end)
 if not parsed then return false,'Invalid API JSON' end
 return true,decoded
end

local reporting=false
local reportBusy=false
local reportToken=nil
local function updateReportStatus(msg)
 cloudStatus.Text=msg
end

toggle.MouseButton1Click:Connect(function()
 if reporting then
  reporting=false;reportToken=nil;tokenBox.Text='';toggle.Text='Reporting: OFF';toggle.BackgroundColor3=Color3.fromRGB(115,55,65)
  updateReportStatus('Reporting stopped. Cloud browsing still available.')
 else
  local entered=tokenBox.Text
  if #entered<32 then updateReportStatus('Enter your private token (at least 32 characters).');return end
  reportToken=entered;tokenBox.Text='';reporting=true;toggle.Text='Reporting: ON';toggle.BackgroundColor3=Color3.fromRGB(45,120,75)
  updateReportStatus('Reporting enabled for THIS client only. Next scan will send eggs.')
  task.spawn(scan)
 end
end)

sophieReport=function(found)
 if not reporting or reportBusy or not reportToken or not cloud.Parent then return end
 reportBusy=true
 local rows={}
 local players=#Players:GetPlayers()
 for _,item in ipairs(found) do
  if item.uid and item.uid~='' and #item.name<=120 then
   local mutation=tostring(item.mutation or 'None'):sub(1,80)
   table.insert(rows,{
    server_id=game.JobId,place_id=game.PlaceId,pet_uid=item.uid,pet_name=item.name,
    rarity=tostring(item.rarity):sub(1,80),mutation=mutation,
    weight_kg=math.max(0,item.weight),income_per_second=math.max(0,item.estimated),player_count=players
   })
  end
 end
 if #rows==0 then updateReportStatus('No eggs with valid UIDs to report.');reportBusy=false;return end
 local saved=0
 for first=1,#rows,100 do
  if not reporting then break end
  local batch={}
  for i=first,math.min(first+99,#rows) do table.insert(batch,rows[i]) end
  local ok,result=send('POST',HttpService:JSONEncode({sightings=batch}),reportToken)
  if not ok then updateReportStatus('Report failed: '..tostring(result));reportBusy=false;return end
  saved=saved+(tonumber(result.saved) or 0)
 end
 updateReportStatus('Reported '..saved..' eggs from this server. Cloud list can be refreshed.')
 reportBusy=false
end

local cloudBusy=false
local function refreshCloud()
 if cloudBusy or not cloud.Parent then return end
 cloudBusy=true
 local ok,result=send('GET')
 if not ok then updateReportStatus('Cloud read failed: '..tostring(result));cloudBusy=false;return end
 local sightings=(type(result)=='table' and result.sightings) or {}
 if type(sightings)~='table' then sightings={} end
 for _,child in ipairs(cloudList:GetChildren()) do if child:IsA('Frame') then child:Destroy() end end
 local count=0
 for _,item in ipairs(sightings) do
  if type(item)=='table' then
   count=count+1
   local row=make('Frame',{Size=UDim2.new(1,-8,0,56),BackgroundColor3=Color3.fromRGB(42,46,64),BorderSizePixel=0,LayoutOrder=count},cloudList)
   make('UICorner',{CornerRadius=UDim.new(0,6)},row)
   make('TextLabel',{Size=UDim2.new(1,-90,0,22),Position=UDim2.fromOffset(6,3),BackgroundTransparency=1,Text=tostring(item.pet_name or '?')..' ['..tostring(item.rarity or '?')..']  $'..fmt(item.income_per_second)..'/s',TextColor3=Color3.new(1,1,1),TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},row)
   make('TextLabel',{Size=UDim2.new(1,-90,0,25),Position=UDim2.fromOffset(6,25),BackgroundTransparency=1,Text=tostring(item.mutation or 'None')..' | '..fmt(item.weight_kg)..'kg | '..tostring(item.player_count or '?')..' players | '..tostring(item.server_id or ''):sub(1,8),TextColor3=Color3.fromRGB(195,209,235),TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},row)
   local join=make('TextButton',{Size=UDim2.fromOffset(74,32),Position=UDim2.new(1,-81,0,12),Text='Join',TextColor3=Color3.new(1,1,1),TextSize=12,BackgroundColor3=Color3.fromRGB(60,120,88)},row)
   join.MouseButton1Click:Connect(function()
    local serverId=tostring(item.server_id or '')
    local placeId=tonumber(item.place_id)
    if not placeId or #serverId<20 then updateReportStatus('Test entry or invalid server ID: cannot join.');return end
    updateReportStatus('Attempting to join server '..serverId:sub(1,8)..'...')
    local success,err=pcall(function()TeleportService:TeleportToPlaceInstance(placeId,serverId,Players.LocalPlayer)end)
    if not success then updateReportStatus('Join failed: '..tostring(err)) end
   end)
  end
 end
 if count==0 then updateReportStatus('Cloud connected. No recent egg sightings.') else updateReportStatus('Cloud connected. '..count..' recent sightings. Reporting '..(reporting and 'ON' or 'OFF')..'.') end
 cloudBusy=false
end
loadButton.MouseButton1Click:Connect(function()task.spawn(refreshCloud)end)
task.spawn(refreshCloud)
task.spawn(function()while cloud.Parent do task.wait(30);if cloud.Parent then refreshCloud()end end end)
