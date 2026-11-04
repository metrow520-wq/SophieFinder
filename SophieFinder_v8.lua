-- Sophie Finder v8 | Unified current + cloud egg finder
-- Public script contains no secret. Enter private report token each session.
-- Income/weight use v6 estimated formulas; not independently verified.
local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local HttpService=game:GetService('HttpService')
local TeleportService=game:GetService('TeleportService')
local parent=Players.LocalPlayer:WaitForChild('PlayerGui')
for _,n in ipairs({'SophieFinderV5','SophieFinderV6','SophieFinderV7','SophieCloudV7','SophieFinderV8'}) do
 local old=parent:FindFirstChild(n);if old then old:Destroy() end
end
local gui=Instance.new('ScreenGui');gui.Name='SophieFinderV8';gui.ResetOnSpawn=false;gui.Parent=parent
local function make(c,p,at)
 local o=Instance.new(c);for k,v in pairs(p) do o[k]=v end;o.Parent=at;return o
end
local dark=Color3.fromRGB(20,20,22);local panelColor=Color3.fromRGB(31,31,34)
local orange=Color3.fromRGB(244,142,35);local muted=Color3.fromRGB(195,195,198)
local main=make('Frame',{Size=UDim2.fromOffset(720,555),Position=UDim2.new(.5,-360,.5,-277),BackgroundColor3=dark,BorderSizePixel=0,Active=true,Draggable=true},gui)
make('UICorner',{CornerRadius=UDim.new(0,12)},main)
make('TextLabel',{Size=UDim2.fromOffset(550,38),Position=UDim2.fromOffset(16,5),BackgroundTransparency=1,Text='SOPHIE FINDER  v8',TextColor3=orange,TextSize=21,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},main)
local close=make('TextButton',{Size=UDim2.fromOffset(32,30),Position=UDim2.new(1,-40,0,8),Text='X',TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(150,55,55)},main)
close.MouseButton1Click:Connect(function()gui:Destroy()end)
local status=make('TextLabel',{Size=UDim2.new(1,-28,0,34),Position=UDim2.fromOffset(14,43),BackgroundTransparency=1,Text='Starting...',TextColor3=muted,TextSize=12,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},main)
local function btn(text,x,y,w)
 local b=make('TextButton',{Size=UDim2.fromOffset(w,30),Position=UDim2.fromOffset(x,y),Text=text,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=12,BackgroundColor3=Color3.fromRGB(65,65,70)},main)
 make('UICorner',{CornerRadius=UDim.new(0,6)},b);return b
end
local currentTab=btn('THIS SERVER',14,80,132)
local cloudTab=btn('CROSS-SERVER',152,80,145)
local refresh=btn('REFRESH',303,80,100)
local best=btn('JOIN BEST',409,80,110)
local auto=btn('AUTO JOIN: OFF',525,80,180)
local search=make('TextBox',{Size=UDim2.fromOffset(252,30),Position=UDim2.fromOffset(14,119),PlaceholderText='Search egg name or mutation...',Text='',ClearTextOnFocus=false,TextSize=12,TextColor3=Color3.new(1,1,1),BackgroundColor3=panelColor},main)
local minimum=make('TextBox',{Size=UDim2.fromOffset(145,30),Position=UDim2.fromOffset(274,119),PlaceholderText='Min $/s (e.g. 1B)',Text='',ClearTextOnFocus=false,TextSize=12,TextColor3=Color3.new(1,1,1),BackgroundColor3=panelColor},main)
local rarities={'All','Rare','Epic','Legendary','Mythic','Cosmic','Secret','Divine','Eternal'}
local selected=1
local rarity=btn('Rarity: All',428,119,136)
local mutationOnly=btn('Mutated: ANY',570,119,135)
local tokenBox=make('TextBox',{Size=UDim2.fromOffset(360,30),Position=UDim2.fromOffset(14,157),PlaceholderText='Private reporting token (enter each session)',Text='',ClearTextOnFocus=false,TextSize=12,TextColor3=Color3.new(1,1,1),BackgroundColor3=panelColor},main)
local toggle=btn('REPORT: OFF',383,157,145)
local note=make('TextLabel',{Size=UDim2.fromOffset(174,30),Position=UDim2.fromOffset(535,157),BackgroundTransparency=1,Text='Cloud reports: 6 min TTL',TextColor3=muted,TextSize=11},main)
local list=make('ScrollingFrame',{Size=UDim2.new(1,-28,1,-245),Position=UDim2.fromOffset(14,196),BackgroundColor3=Color3.fromRGB(26,26,29),BorderSizePixel=0,ScrollBarThickness=6,CanvasSize=UDim2.fromOffset(0,0)},main)
local layout=make('UIListLayout',{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},list)
layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()list.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+8)end)
make('TextLabel',{Size=UDim2.new(1,-28,0,34),Position=UDim2.new(0,14,1,-38),BackgroundTransparency=1,Text='Only participating servers appear in cloud. Values use v6 estimated formulas. Auto Join is OFF by default.',TextSize=11,TextColor3=Color3.fromRGB(244,187,105),TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},main)
local function fmt(n)
 n=tonumber(n) or 0
 if n>=1e12 then return string.format('%.2fT',n/1e12) end
 if n>=1e9 then return string.format('%.2fB',n/1e9) end
 if n>=1e6 then return string.format('%.2fM',n/1e6) end
 if n>=1e3 then return string.format('%.2fK',n/1e3) end
 return string.format('%.1f',n)
end
local function minValue(s)
 local a,b=string.match(string.upper(s or ''),'^%s*([%d%.]+)%s*([KMBT]?)%s*$')
 local mul={K=1e3,M=1e6,B=1e9,T=1e12}
 return (tonumber(a) or 0)*(mul[b] or 1)
end
local last={};local cloudItems={};local tab='cloud';local mutated=false;local autoOn=false;local autoAttempted={}
local reporting=false;local reportToken=nil;local reportBusy=false;local sophieReport=nil
local function setStatus(s) status.Text=tostring(s) end
local function join(item)
 local sid=tostring(item.server_id or '')
 local pid=tonumber(item.place_id)
 if not pid or #sid<20 then setStatus('Invalid or test server ID; cannot join.');return end
 if sid==game.JobId then setStatus('Already in this server.');return end
 setStatus('Joining server '..sid:sub(1,8)..'...')
 local ok,err=pcall(function()TeleportService:TeleportToPlaceInstance(pid,sid,Players.LocalPlayer)end)
 if not ok then setStatus('Join failed: '..tostring(err)) end
end
local function filtered()
 local source=tab=='cloud' and cloudItems or last
 local result={};local query=string.lower(search.Text or '');local min=minValue(minimum.Text)
 for _,item in ipairs(source) do
  local name=tostring(item.pet_name or item.name or '')
  local mut=tostring(item.mutation or 'None')
  local rarityName=tostring(item.rarity or '')
  local income=tonumber(item.income_per_second or item.estimated) or 0
  if income>=min and (selected==1 or rarityName==rarities[selected]) and
     (not mutated or (mut~='None' and mut~='')) and
     (query=='' or string.find(string.lower(name..' '..mut),query,1,true)) then
   table.insert(result,item)
  end
 end
 table.sort(result,function(a,b)return (tonumber(a.income_per_second or a.estimated) or 0)>(tonumber(b.income_per_second or b.estimated) or 0) end)
 return result
end
local function renderLocal()
 for _,child in ipairs(list:GetChildren()) do if child:IsA('Frame') then child:Destroy() end end
 local items=filtered()
 for i,item in ipairs(items) do
  local income=tonumber(item.income_per_second or item.estimated) or 0
  local weight=tonumber(item.weight_kg or item.weight) or 0
  local name=tostring(item.pet_name or item.name or '?')
  local row=make('Frame',{Size=UDim2.new(1,-8,0,62),BackgroundColor3=panelColor,BorderSizePixel=0,LayoutOrder=i},list)
  make('UICorner',{CornerRadius=UDim.new(0,6)},row)
  make('TextLabel',{Size=UDim2.new(1,-115,0,26),Position=UDim2.fromOffset(9,3),BackgroundTransparency=1,Text=name..' ['..tostring(item.rarity or '?')..']  ~$'..fmt(income)..'/s',TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Color3.new(1,1,1),TextTruncate=Enum.TextTruncate.AtEnd},row)
  local meta='~'..fmt(weight)..' kg  |  '..tostring(item.mutation or 'None')
  if tab=='cloud' then
   meta=meta..'  |  '..tostring(item.player_count or '?')..' players  |  '..tostring(item.server_id or ''):sub(1,8)
  else meta=meta..'  |  '..tostring(item.area or '?') end
  make('TextLabel',{Size=UDim2.new(1,-115,0,24),Position=UDim2.fromOffset(9,31),BackgroundTransparency=1,Text=meta,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=muted,TextTruncate=Enum.TextTruncate.AtEnd},row)
  if tab=='cloud' then
   local j=make('TextButton',{Size=UDim2.fromOffset(87,33),Position=UDim2.new(1,-98,0,14),Text='JOIN',Font=Enum.Font.GothamBold,TextSize=12,TextColor3=Color3.new(1,1,1),BackgroundColor3=orange},row)
   make('UICorner',{CornerRadius=UDim.new(0,5)},j)
   j.MouseButton1Click:Connect(function()join(item)end)
  end
 end
 currentTab.BackgroundColor3=tab=='local' and orange or Color3.fromRGB(65,65,70)
 cloudTab.BackgroundColor3=tab=='cloud' and orange or Color3.fromRGB(65,65,70)
 note.Text=(tab=='cloud' and 'Cloud: ' or 'Current: ')..#items..' shown'
end
local function send(method,body,token)
 local fn=(syn and syn.request) or http_request or request or (http and http.request)
 if type(fn)~='function' then return false,'Executor HTTP unavailable' end
 local headers={['Content-Type']='application/json'}
 if token then headers['x-sophie-token']=token end
 local ok,res=pcall(function()return fn({Url='https://lqqpcyrocnjprhnutprc.supabase.co/functions/v1/sophie-api',Method=method,Headers=headers,Body=body})end)
 if not ok then return false,tostring(res) end
 if type(res)~='table' then return false,'Unexpected response' end
 local code=tonumber(res.StatusCode or res.Status) or 0
 if code<200 or code>=300 then return false,'HTTP '..code..': '..tostring(res.Body or ''):sub(1,150) end
 local decoded,bodyValue=pcall(function()return HttpService:JSONDecode(res.Body or '{}')end)
 if not decoded then return false,'Invalid API JSON' end
 return true,bodyValue
end
local cloudBusy=false
local function refreshCloud()
 if cloudBusy or not gui.Parent then return end
 cloudBusy=true
 local ok,result=send('GET')
 if ok and type(result)=='table' and type(result.sightings)=='table' then
  cloudItems=result.sightings
  if tab=='cloud' then renderLocal() end
  setStatus('Cloud: '..#cloudItems..' sightings. Reporting '..(reporting and 'ON' or 'OFF')..'.')
 else setStatus('Cloud read failed: '..tostring(result)) end
 cloudBusy=false
end
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
    table.insert(found,{uid=tostring(egg.Uid or ''),name=tostring(cfg.DisplayName or egg.AssetCategory),rarity=tostring(cfg.Rarity and cfg.Rarity.DisplayName or '?'),base=base,scale=scale,weight=baseWeight*scale,estimated=base*(scale^1.85)*mult,multiplier=mult,mutation=mutation,area=tostring(egg.AreaId or '?')})
   end
  end
 end
 table.sort(found,function(a,b)return a.estimated>b.estimated end)
 last=found;renderLocal();busy=false
 if sophieReport then task.spawn(function() sophieReport(found) end) end
end

sophieReport=function(found)
 if not reporting or reportBusy or not reportToken or not gui.Parent then return end
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
 if #rows==0 then setStatus('No eggs with valid UIDs to report.');reportBusy=false;return end
 local saved=0
 for first=1,#rows,100 do
  if not reporting then break end
  local batch={}
  for i=first,math.min(first+99,#rows) do table.insert(batch,rows[i]) end
  local ok,result=send('POST',HttpService:JSONEncode({sightings=batch}),reportToken)
  if not ok then setStatus('Report failed: '..tostring(result));reportBusy=false;return end
  saved=saved+(tonumber(result.saved) or 0)
 end
 setStatus('Reported '..saved..' eggs from this server. Cloud list can be refreshed.')
 reportBusy=false
 task.spawn(refreshCloud)
end


local function refreshCurrent() task.spawn(scan) end
currentTab.MouseButton1Click:Connect(function()tab='local';renderLocal()end)
cloudTab.MouseButton1Click:Connect(function()tab='cloud';renderLocal()end)
refresh.MouseButton1Click:Connect(function()if tab=='cloud' then task.spawn(refreshCloud) else refreshCurrent() end end)
rarity.MouseButton1Click:Connect(function()selected=selected%#rarities+1;rarity.Text='Rarity: '..rarities[selected];renderLocal()end)
mutationOnly.MouseButton1Click:Connect(function()mutated=not mutated;mutationOnly.Text=mutated and 'Mutated: ONLY' or 'Mutated: ANY';renderLocal()end)
search:GetPropertyChangedSignal('Text'):Connect(renderLocal)
minimum.FocusLost:Connect(renderLocal)
best.MouseButton1Click:Connect(function()
 if tab~='cloud' then tab='cloud';renderLocal() end
 local items=filtered()
 if #items==0 then setStatus('No matching cloud sightings.');return end
 join(items[1])
end)
auto.MouseButton1Click:Connect(function()
 autoOn=not autoOn
 auto.Text=autoOn and 'AUTO JOIN: ON' or 'AUTO JOIN: OFF'
 auto.BackgroundColor3=autoOn and Color3.fromRGB(120,90,30) or Color3.fromRGB(65,65,70)
 setStatus(autoOn and 'Auto Join ON: will attempt highest matching remote server on next cloud refresh.' or 'Auto Join OFF.')
end)
local function maybeAutoJoin()
 if not autoOn or tab~='cloud' then return end
 for _,item in ipairs(filtered()) do
  local sid=tostring(item.server_id or '')
  if sid~=game.JobId and #sid>=20 and not autoAttempted[sid] then
   autoAttempted[sid]=true;autoOn=false;auto.Text='AUTO JOIN: OFF';join(item);return
  end
 end
end
local refreshCloudBase=refreshCloud
refreshCloud=function()
 refreshCloudBase()
 if not cloudBusy then maybeAutoJoin() end
end
-- Keep the token in memory only; never put it in GitHub or in the script.
toggle.MouseButton1Click:Connect(function()
 if reporting then
  reporting=false;reportToken=nil;tokenBox.Text='';toggle.Text='REPORT: OFF';setStatus('Reporting disabled.')
 else
  local token=tokenBox.Text
  if #token<32 then setStatus('Enter your private reporting token (32+ characters).');return end
  reportToken=token;tokenBox.Text='';reporting=true;toggle.Text='REPORT: ON'
  setStatus('Reporting enabled; scanning current server now.')
  task.spawn(scan)
 end
end)
renderLocal()
task.spawn(scan)
task.spawn(refreshCloud)
task.spawn(function()
 while gui.Parent do
  task.wait(30)
  if gui.Parent then task.spawn(scan);task.spawn(refreshCloud) end
 end
end)
