-- Sophie Finder v1.0 | UI prototype for Roblox Studio / authorized LocalScript use.
-- This does NOT scan other servers, access Aijans data, or execute remote code.
-- Install as a LocalScript in StarterPlayer > StarterPlayerScripts in an experience you control.
local Players = game:GetService('Players')
local player = Players.LocalPlayer
if not player then return end
local pg = player:WaitForChild('PlayerGui')
local old = pg:FindFirstChild('SophieFinderGui')
if old then old:Destroy() end

local gui = Instance.new('ScreenGui')
gui.Name = 'SophieFinderGui'
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = pg

local function make(class, parent, props)
    local x = Instance.new(class)
    for k,v in pairs(props or {}) do x[k] = v end
    x.Parent = parent
    return x
end
local bg = Color3.fromRGB(19,21,33)
local panel = Color3.fromRGB(31,34,51)
local white = Color3.fromRGB(241,244,255)
local muted = Color3.fromRGB(175,183,206)
local green = Color3.fromRGB(113,234,151)
local function corner(obj, r) make('UICorner',obj,{CornerRadius=UDim.new(0,r or 9)}) end
local function label(parent,text,pos,size,color,weight)
    return make('TextLabel',parent,{BackgroundTransparency=1,Text=text,TextColor3=color or white,Font=weight or Enum.Font.Gotham,TextSize=size or 13,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-20,0,25),Position=pos or UDim2.new(0,10,0,0)})
end
local function button(parent,text,pos,sz,color)
    local b=make('TextButton',parent,{Text=text,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=white,BackgroundColor3=color or Color3.fromRGB(72,65,131),Position=pos,Size=sz,AutoButtonColor=true})
    corner(b,7)
    return b
end
local main=make('Frame',gui,{Name='Window',Size=UDim2.fromOffset(435,470),Position=UDim2.new(.5,-217,.5,-235),BackgroundColor3=bg,Active=true,Draggable=true})
corner(main,13)
make('UIStroke',main,{Color=Color3.fromRGB(85,74,152),Thickness=1.5})
label(main,'🥚 Sophie Finder',UDim2.fromOffset(16,9),20,white,Enum.Font.GothamBold)
label(main,'Steal An Egg • UI TEST • no live feed',UDim2.fromOffset(17,37),11,muted)
local close=button(main,'×',UDim2.new(1,-37,0,12),UDim2.fromOffset(24,24),Color3.fromRGB(103,50,72))
close.MouseButton1Click:Connect(function() gui:Destroy() end)
local filterLabel=label(main,'Minimum $/s:',UDim2.fromOffset(16,72),12,muted)
filterLabel.Size=UDim2.fromOffset(110,24)
local minimum=make('TextBox',main,{Text='0',PlaceholderText='0',ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=13,TextColor3=white,BackgroundColor3=panel,Position=UDim2.fromOffset(128,73),Size=UDim2.fromOffset(123,28)})
corner(minimum,7)
local rarity='All'
local rarityButton=button(main,'Rarity: All',UDim2.fromOffset(260,73),UDim2.fromOffset(157,28))
local rarityOptions={'All','Secret','Divine','Eternal'}
rarityButton.MouseButton1Click:Connect(function()
    local idx=table.find(rarityOptions,rarity) or 1
    rarity=rarityOptions[idx%#rarityOptions+1]
    rarityButton.Text='Rarity: '..rarity
end)
local status=label(main,'Sample sightings only • no Roblox server scan',UDim2.fromOffset(16,111),11,Color3.fromRGB(255,208,130))
local list=make('ScrollingFrame',main,{Position=UDim2.fromOffset(14,139),Size=UDim2.fromOffset(407,242),BackgroundColor3=panel,BorderSizePixel=0,ScrollBarThickness=5,CanvasSize=UDim2.fromOffset(0,0)})
corner(list,9)
local layout=make('UIListLayout',list,{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})
make('UIPadding',list,{PaddingTop=UDim.new(0,7),PaddingLeft=UDim.new(0,7),PaddingRight=UDim.new(0,7),PaddingBottom=UDim.new(0,7)})
local demo={
    {name='Royal Skywhale',rarity='Eternal',income=1180000000000,weight='850K kg',serverId=nil,seen=os.time()},
    {name='Golden Gargoyle',rarity='Divine',income=7530000000,weight='671K kg',serverId=nil,seen=os.time()},
    {name='Phoenix',rarity='Secret',income=85000000,weight='120K kg',serverId=nil,seen=os.time()},
}
local sightings=demo
local function pretty(v)
    if v>=1e12 then return string.format('$%.2fT/s',v/1e12) end
    if v>=1e9 then return string.format('$%.2fB/s',v/1e9) end
    if v>=1e6 then return string.format('$%.2fM/s',v/1e6) end
    return string.format('$%.0f/s',v)
end
local function ranked()
    local min=tonumber(minimum.Text) or 0
    local a={}
    for _,s in ipairs(sightings) do
        if s.income>=min and (rarity=='All' or s.rarity==rarity) then table.insert(a,s) end
    end
    table.sort(a,function(x,y) return x.income>y.income end)
    return a
end
local function render()
    for _,child in ipairs(list:GetChildren()) do if child:IsA('Frame') then child:Destroy() end end
    local items=ranked()
    status.Text=string.format('%d results • SAMPLE DATA ONLY • Join disabled',#items)
    for i,s in ipairs(items) do
        local row=make('Frame',list,{Size=UDim2.new(1,-10,0,68),BackgroundColor3=Color3.fromRGB(41,44,64),LayoutOrder=i})
        corner(row,7)
        local n=label(row,s.name,UDim2.fromOffset(10,5),13,white,Enum.Font.GothamBold)
        n.Size=UDim2.fromOffset(250,23)
        local val=label(row,pretty(s.income),UDim2.fromOffset(10,28),15,green,Enum.Font.GothamBold)
        val.Size=UDim2.fromOffset(225,25)
        local meta=label(row,s.rarity..' • '..s.weight,UDim2.fromOffset(10,51),10,muted)
        meta.Size=UDim2.fromOffset(260,13)
        local join=button(row,'No server ID',UDim2.new(1,-116,0,18),UDim2.fromOffset(108,30),Color3.fromRGB(74,77,92))
        join.AutoButtonColor=false
        join.MouseButton1Click:Connect(function()
            status.Text='Cannot join: sample sighting has no verified server ID.'
        end)
    end
    list.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+20)
end
layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()list.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+20)end)
minimum:GetPropertyChangedSignal('Text'):Connect(render)
rarityButton.MouseButton1Click:Connect(render)
local refresh=button(main,'Refresh sample list',UDim2.fromOffset(14,397),UDim2.fromOffset(192,37))
refresh.MouseButton1Click:Connect(render)
local best=button(main,'Join Best (unavailable)',UDim2.fromOffset(215,397),UDim2.fromOffset(206,37),Color3.fromRGB(70,75,90))
best.MouseButton1Click:Connect(function() status.Text='Join Best requires verified live sightings with server IDs.' end)
label(main,'Next: connect an authorized cross-server sightings feed.',UDim2.fromOffset(16,443),11,muted)
render()
