repeat task.wait() until game:IsLoaded();

local slot = "%s" -- Gets inlined by builder.
local big = "%s"

local do_sound = ("%s") == "true";
local should_wipe = ("%s") == "true";

big = big ~= "true";

local services = setmetatable({}, {
    __index = function(...)
        return cloneref(game:GetService(select(2, ...)));
    end
});

--#region Region Data
local regions = {
    ["São Paulo, BR"] = {
        -23.555625762928127, 
        -46.63739848542402
    },
    ["Singapore, SG"] = {
        1.3661654291144634, 103.80166319200437
    },
    ["England, UK"] = {
        52.853576269728634, -1.100132317113187
    },
    ["Hesse, DE"] = {
        50.587309839275385, 9.092188166947581
    },
    ["Paris, FR"] = {
        48.85905142305871, 2.344971600714648
    },
    ["North Holland, NL"] = {
        52.587134340838524, 4.8516474416805435
    },
    ["Georgia, USA"] = {
        32.539817127196564, -83.3512786296502
    },
    ["Virginia, USA"] = {
        37.373872806243774, -78.76191929114455
    },
    ["Florida, USA"] = {
        28.480187029162977, -81.7437957307833
    },
    ["New York, USA"] = {
        42.97367873962785, -76.09120961971205
    },
    ["Illinois, USA"] = {
        40.04673696610475, -89.6099142592046
    },
    ["Texas, USA"] = {
        31.698603317837726, -99.21281657127408
    },
    ["California, USA"] = {
        37.08186665943036, -120.04354279002409
    },
    ["Washington, USA"] = {
        47.25015341864505, -120.01675164899676
    },
    ["Tokyo, JP"] = {
        35.69814673021601, 139.6013137758827
    }
}
--#endregion

--[1] - latitude, [2] - longitude

local ip_data = game:GetService("HttpService"):JSONDecode(readfile("Project Rain/Server Hopper Data.json"));

function deg_2_rad(deg)
    return deg * (math.pi / 180)
end

function get_distance_in_kilometers(lat1, lon1, lat2, lon2)
    local R = 6371 

    local dLat = deg_2_rad(lat2 - lat1)
    local dLon = deg_2_rad(lon2 - lon1)

    local a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(deg_2_rad(lat1)) * math.cos(deg_2_rad(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2)

    local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    local d = R * c

    return d
end

local function get_distance(server)
    return get_distance_in_kilometers(
        ip_data.lat,
        ip_data.lon,
        server.lat,
        server.lon
    )
end

local function get_server_score(server)
    local distance = get_distance(server)

    local filled_percent = server.players / server.max_players
    local distance_score = math.min(distance / 2000, 1)

    if big then
        filled_percent = 1 - filled_percent;
    end;

    return distance_score * 0.35 + (filled_percent ^ 2) * 0.65
end

local function server_sorter(server_a, server_b)
    return get_server_score(server_a) < get_server_score(server_b);
end;

local currently_joining;

local game_servers = game:GetService("ReplicatedStorage"):WaitForChild("Servers")
local requests = game:GetService("ReplicatedStorage"):WaitForChild("Requests");
local start = requests:WaitForChild("StartMenu");

local show_servers = requests:WaitForChild("ShowServers");
local pick_server = start:WaitForChild("PickServer");
local wipe_slot = requests:WaitForChild("WipeSlot");
local pick_slot = start:WaitForChild("PickSlot");

--table.sort(servers, function(a, b)
--    return getScore(a) < getScore(b)
--end)

local blacklisted_servers = isfile("Project Rain/hopper blacklisted servers.json") and game:GetService("HttpService"):JSONDecode(readfile("Project Rain/hopper blacklisted servers.json")) or {};
local canidates = {}; -- TeleportInitFailed needs this - You know why :)

for id, server in blacklisted_servers do
    if server.expiry < tick() then
        blacklisted_servers[id] = nil;
    end;
end;

writefile("Project Rain/hopper blacklisted servers.json", game:GetService("HttpService"):JSONEncode(blacklisted_servers));

function canidates_updated(canidates)
    local first_server = canidates[1] do
        while blacklisted_servers[first_server.id] or not game:GetService("Players").LocalPlayer.PlayerGui.LoadingGui.Overlay.Columns.MainFrame.Servers.Servers:FindFirstChild(first_server.id) do
            table.remove(canidates, 1);
            first_server = canidates[1];

            task.wait();
        end;

        currently_joining = first_server;
    end;

    firesignal(game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("LoadingGui"):WaitForChild("Overlay"):WaitForChild("Columns"):WaitForChild("MainFrame"):WaitForChild("Servers"):WaitForChild("Servers"):WaitForChild(currently_joining.id).MouseButton1Click);
    --pick_server:FireServer(currently_joining.id);
end

function blacklist(server, expiry)
    blacklisted_servers[server] = {
        expiry = tick() + (expiry or 900)
    }

    writefile("Project Rain/hopper blacklisted servers.json", game:GetService("HttpService"):JSONEncode(blacklisted_servers));
end;

local init_failed = false;
function sort_canidates(luminant)
    local servers = {};

    for _, server in game_servers:FindFirstChild(luminant):GetChildren() do
        local max_players = server:FindFirstChild("MaxPlayers").Value;
        local last_update = server:FindFirstChild("LastUpdate").Value;
        local players = server:FindFirstChild("NumPlayers").Value;
        local region = server:FindFirstChild("Region").Value;

        if players <= 1 then -- 1 player and last update over 90 seconds ago? pass the ball!
            continue;
        end;

        if players == max_players then 
            --print("Blacklisted server");
            continue;
        end

        local coordinates = regions[region] or {
            0, -180 -- Unknown region. Middle of the world.   
        };

        table.insert(servers, {
            max_players = max_players,
            players = players,
            id = server:GetAttribute("JobId"),
            re = region, -- Debugging needed.
            
            lat = coordinates[1],
            lon = coordinates[2],
        })
    end;

    print(#blacklisted_servers, "are currently blacklisted");
    print(#servers, "are canidates");

    table.sort(servers, server_sorter);
    canidates = servers;

    --if init_failed then return; end
    task.wait(0.5);
    canidates_updated(servers);
end;

services.TeleportService.TeleportInitFailed:Connect(function(_, result: Enum.TeleportResult)
    if result == Enum.TeleportResult.Success then return; end

    task.delay(0.25, function()
        services.GuiService:ClearError();
    end);

    if result == Enum.TeleportResult.IsTeleporting then
        return task.delay(5, function()
            canidates_updated(canidates);
        end);
    elseif result == Enum.TeleportResult.Flooded then -- Don't blacklist this server. We got ratelimited (somehow)
        return task.delay(20, function()
            canidates_updated(canidates);
        end);
    else
        local failed_id = currently_joining.id; 

        return task.delay(0.5, function()
            blacklist(failed_id, ({
                [Enum.TeleportResult.GameNotFound] = 60 * 60 * 12,
                [Enum.TeleportResult.GameEnded] = 60 * 60 * 12,
                [Enum.TeleportResult.GameFull] = 5 * 60,
            })[result] or 10 * 60)

            for i, server in canidates do
                if server.id == failed_id then
                    table.remove(canidates, i);
                    break;
                end;
            end;

            canidates_updated(canidates);
        end);
    end;
end);

show_servers.OnClientEvent:Connect(sort_canidates);

services.ReplicatedStorage:WaitForChild("SlotData"):WaitForChild(tostring(services.Players.LocalPlayer.UserId)):WaitForChild(slot);

if do_sound then
    queue_on_teleport('if game.PlaceId == 4111023553 then return; end; repeat task.wait() until game:IsLoaded(); xpcall(function() local sound = Instance.new("Sound", game:GetService("CoreGui")); game:GetService("Debris"):AddItem(sound, 6); sound.Volume = 1.3; sound.SoundId = getcustomasset("Project Rain/assets/notification.mp3"); sound:Play(); end, warn);')
end;

if should_wipe then
    wipe_slot:InvokeServer(slot)
end;

task.delay(60, function() 
    game:GetService("TeleportService"):Teleport(game.PlaceId);
    queueonteleport(readfile("hopper.lua"));
end);


while not (workspace:GetAttribute("ServerReady")) do
    task.wait()
end
repeat task.wait() until game:GetService("Players").LocalPlayer:GetAttribute("GameLoaded");
repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui.LoadingGui.Overlay.Columns.MainFrame.Slots.SlotScroll.Visible;
task.wait(0.1);
repeat 
    firesignal(game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("LoadingGui"):WaitForChild("Overlay"):WaitForChild("Columns"):WaitForChild("MainFrame"):WaitForChild("Slots"):WaitForChild("SlotScroll"):WaitForChild(slot).MouseButton1Click)
    replicatesignal(game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("LoadingGui"):WaitForChild("Overlay"):WaitForChild("Columns"):WaitForChild("MainFrame"):WaitForChild("Slots"):WaitForChild("SlotScroll"):WaitForChild(slot).MouseButton1Click)
    task.wait(5)
until false;--not game:GetService("Players").LocalPlayer.PlayerGui.LoadingGui.Overlay.Columns.MainFrame.Slots.SlotScroll.Visible