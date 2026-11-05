-- Sophie Scanner v1: read-only egg snapshot and optional cloud reporting.
-- Runs in the currently joined server only. Does not hop servers.
-- Never publish your reporting token in a public script.
local RS = game:GetService('ReplicatedStorage')
local HttpService = game:GetService('HttpService')
local Players = game:GetService('Players')
local API = 'https://lqqpcyrocnjprhnutprc.supabase.co/functions/v1/sophie-api'
local PLACE_ID = 107778070777162
local INTERVAL = 15
local PRIORITY = {Divine=1, Eternal=2, Secret=3}

local function httpRequest(opts)
    local f = request or http_request or (syn and syn.request)
    if not f then return nil, 'HTTP request function unavailable' end
    local ok, res = pcall(f, opts)
    if not ok then return nil, tostring(res) end
    return res
end

local function getRemote()
    local p = RS:WaitForChild('Packages', 10)
    local n = p and p:WaitForChild('Networking', 10)
    return n and n:FindFirstChild('RF/EggWorld/AskFieldEggSnapshot')
end

local function getAssets()
    local ok, mod = pcall(function() return require(RS.Data.Assets).Directory end)
    return ok and mod or {}
end

local function mutationScalar(id, mutationsModule)
    if not id or id == '' then return 1 end
    local ok, entry = pcall(function() return mutationsModule.Get(id) end)
    return (ok and type(entry) == 'table' and tonumber(entry.EarningsScalar)) or 1
end

local function collect(remote, assets, mutationsModule)
    local ok, snapshot = pcall(function() return remote:InvokeServer() end)
    if not ok or type(snapshot) ~= 'table' or type(snapshot.Records) ~= 'table' then
        return nil, 'Snapshot unavailable'
    end
    local results = {}
    for _, egg in pairs(snapshot.Records) do
        if type(egg) == 'table' then
            local cfg = assets[egg.AssetCategory]
            local rarity = cfg and cfg.Rarity and cfg.Rarity.DisplayName
            if PRIORITY[rarity] then
                local scale = tonumber(egg.AssetScale) or 1
                local mult = mutationScalar(egg.BaseMutation, mutationsModule)
                local mutationNames = {}
                if egg.BaseMutation and egg.BaseMutation ~= '' then
                    table.insert(mutationNames, tostring(egg.BaseMutation))
                end
                if type(egg.Mutations) == 'table' then
                    for k, v in pairs(egg.Mutations) do
                        local id = type(v) == 'string' and v or (type(k) == 'string' and k or nil)
                        if id and id ~= egg.BaseMutation then
                            mult = mult * mutationScalar(id, mutationsModule)
                            table.insert(mutationNames, id)
                        end
                    end
                end
                local income = (tonumber(cfg.EarningRate) or 0) * scale^1.85 * mult
                local weight = (tonumber(cfg.Egg and cfg.Egg.WeightKg) or 0) * scale
                table.insert(results, {
                    server_id = game.JobId,
                    place_id = game.PlaceId,
                    pet_uid = tostring(egg.Uid or ''),
                    pet_name = tostring(cfg.DisplayName or egg.AssetCategory or 'Unknown'),
                    rarity = rarity,
                    mutation = table.concat(mutationNames, ', '),
                    weight_kg = weight,
                    income_per_second = income,
                    player_count = #Players:GetPlayers()
                })
            end
        end
    end
    table.sort(results, function(a,b)
        if PRIORITY[a.rarity] ~= PRIORITY[b.rarity] then
            return PRIORITY[a.rarity] < PRIORITY[b.rarity]
        end
        return a.income_per_second > b.income_per_second
    end)
    return results
end

local function run()
    if game.PlaceId ~= PLACE_ID then
        warn('[Sophie] This scanner is for Steal An Egg only')
        return
    end
    local remote = getRemote()
    if not remote then warn('[Sophie] Egg snapshot remote not found'); return end
    local assets = getAssets()
    local ok, mutationsModule = pcall(function() return require(RS.Shared.Modules.Mutations) end)
    if not ok then warn('[Sophie] Mutation module unavailable'); return end

    -- Optional: set this only in your PRIVATE local copy or executor session.
    -- Do NOT commit a token to GitHub or send it in chat.
    local token = (getgenv and getgenv().SOPHIE_REPORT_TOKEN) or nil
    print('[Sophie] Scanner started in server ' .. game.JobId)
    while task.wait(INTERVAL) do
        local eggs, err = collect(remote, assets, mutationsModule)
        if not eggs then warn('[Sophie] ' .. tostring(err))
        else
            print(string.format('[Sophie] %d target eggs in current server', #eggs))
            for i=1,math.min(8,#eggs) do
                local e=eggs[i]
                print(string.format('%d. %s | %s | $%.0f/s | %.2fkg', i, e.rarity, e.pet_name, e.income_per_second, e.weight_kg))
            end
            if token and token ~= '' and #eggs > 0 then
                local res, postErr = httpRequest({
                    Url=API, Method='POST',
                    Headers={['Content-Type']='application/json', ['x-sophie-token']=token},
                    Body=HttpService:JSONEncode({sightings=eggs})
                })
                if not res then warn('[Sophie] Report failed: ' .. tostring(postErr))
                elseif (res.StatusCode or 0) < 200 or (res.StatusCode or 0) >= 300 then
                    warn('[Sophie] Report HTTP ' .. tostring(res.StatusCode))
                else print('[Sophie] Report sent') end
            elseif not token then
                print('[Sophie] Local scan only: no private reporting token configured')
            end
        end
    end
end

task.spawn(run)
